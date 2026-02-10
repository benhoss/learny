<?php

namespace App\Services\Documents;

use App\Concerns\RetriesLlmCalls;
use Illuminate\Http\UploadedFile;
use Prism\Prism\Enums\Provider;
use Prism\Prism\Facades\Prism;
use Prism\Prism\ValueObjects\Media\Image;

class MetadataSuggestionService
{
    use RetriesLlmCalls;

    /**
     * @param  array{filename?: string|null, context_text?: string|null, ocr_snippet?: string|null, language_hint?: string|null}  $input
     * @return array{subject: string, language: string, learning_goal: string, title: string, confidence: float, alternatives: array<int, string>}
     */
    public function suggest(array $input): array
    {
        $text = strtolower(trim(implode(' ', array_filter([
            $input['filename'] ?? null,
            $input['context_text'] ?? null,
            $input['ocr_snippet'] ?? null,
        ]))));

        $subjectScores = [
            'Math' => $this->score($text, ['math', 'algebra', 'geometry', 'fraction', 'equation', 'number']),
            'Science' => $this->score($text, ['science', 'biology', 'chemistry', 'physics', 'experiment', 'cell']),
            'History' => $this->score($text, ['history', 'war', 'civilization', 'empire', 'timeline', 'revolution']),
            'Geography' => $this->score($text, ['geography', 'map', 'country', 'continent', 'climate', 'capital']),
            'Language' => $this->score($text, ['verb', 'grammar', 'vocabulary', 'conjugation', 'sentence']),
        ];

        arsort($subjectScores);
        $subject = array_key_first($subjectScores) ?: 'General';
        $topSubjectScore = (int) current($subjectScores);

        $alternatives = array_slice(
            array_keys(array_filter($subjectScores, fn (int $score) => $score > 0)),
            0,
            3
        );
        if ($alternatives === []) {
            $alternatives = ['General', 'Math', 'Language'];
        }

        $language = $this->detectLanguage($text, (string) ($input['language_hint'] ?? ''));
        $learningGoal = $this->goalForSubject($subject, $language);

        $confidence = min(0.95, max(0.35, 0.35 + ($topSubjectScore * 0.15)));

        return [
            'subject' => $subject,
            'language' => $language,
            'learning_goal' => $learningGoal,
            'title' => $this->titleForSuggestion($subject, $learningGoal, $language),
            'confidence' => round($confidence, 2),
            'alternatives' => $alternatives,
        ];
    }

    /**
     * @param  array{filename?: string|null, context_text?: string|null, ocr_snippet?: string|null, language_hint?: string|null}  $input
     * @return array{subject: string, language: string, learning_goal: string, title: string, confidence: float, alternatives: array<int, string>, model?: string}
     */
    public function suggestWithImage(array $input, UploadedFile $image): array
    {
        $model = config('prism.openrouter.fast_scan_model', 'google/gemini-2.0-flash-lite-001');
        $prompt = $this->buildVisionPrompt($input);
        $media = Image::fromRawContent($image->get(), $image->getMimeType());

        $response = $this->callWithRetry(function () use ($model, $prompt, $media) {
            return Prism::text()
                ->using(Provider::OpenRouter, $model)
                ->withSystemPrompt('Return only valid JSON. Do not include any other text.')
                ->withPrompt($prompt, [$media])
                ->withMaxTokens(300)
                ->usingTemperature(0.2)
                ->asText();
        });

        $decoded = json_decode($response->text, true);
        if (! is_array($decoded)) {
            $decoded = $this->extractJson($response->text);
        }

        if (! is_array($decoded)) {
            return $this->suggest($input);
        }

        $subject = $this->normalizeSubject($decoded['subject'] ?? null);
        $language = $this->normalizeLanguage($decoded['language'] ?? null, $input);
        $alternatives = $decoded['alternatives'] ?? [];
        $confidence = (float) ($decoded['confidence'] ?? 0.5);

        $learningGoal = $decoded['learning_goal'] ?? null;
        if (! is_string($learningGoal) || trim($learningGoal) === '') {
            $learningGoal = $this->goalForSubject($subject, $language);
        }

        $title = $decoded['title'] ?? null;
        if (! is_string($title) || trim($title) === '') {
            $title = $this->titleForSuggestion($subject, $learningGoal, $language);
        }

        return [
            'subject' => $subject,
            'language' => $language,
            'learning_goal' => $learningGoal,
            'title' => $title,
            'confidence' => round(max(0.0, min(1.0, $confidence)), 2),
            'alternatives' => is_array($alternatives) ? array_values($alternatives) : [],
            'model' => (string) $model,
        ];
    }

    /**
     * @param  list<string>  $keywords
     */
    protected function score(string $text, array $keywords): int
    {
        $score = 0;
        foreach ($keywords as $keyword) {
            if (str_contains($text, $keyword)) {
                $score += 1;
            }
        }

        return $score;
    }

    protected function detectLanguage(string $text, string $hint): string
    {
        if ($hint !== '') {
            return ucfirst(strtolower($hint));
        }

        if (preg_match('/\\b(le|la|les|des|bonjour|merci|être|avoir|nous)\\b/u', $text) === 1) {
            return 'French';
        }

        if (preg_match('/\\b(el|la|los|las|gracias|hola|ser|estar|nosotros)\\b/u', $text) === 1) {
            return 'Spanish';
        }

        return 'English';
    }

    protected function goalForSubject(string $subject, string $language = 'English'): string
    {
        $lang = strtolower($language);
        if ($lang === 'french') {
            return match ($subject) {
                'Math' => 'Résoudre les exercices de base avec moins d’erreurs.',
                'Science' => 'Expliquer les concepts clés avec des exemples simples.',
                'History' => 'Retenir les événements et relier causes et conséquences.',
                'Geography' => 'Identifier les lieux et comparer les régions.',
                'Language' => 'Pratiquer le vocabulaire et la construction de phrases.',
                default => 'Renforcer la confiance sur les concepts principaux.',
            };
        }
        if ($lang === 'dutch') {
            return match ($subject) {
                'Math' => 'Kernopgaven oplossen met minder fouten.',
                'Science' => 'Belangrijke concepten uitleggen met eenvoudige voorbeelden.',
                'History' => 'Gebeurtenissen onthouden en oorzaken met gevolgen verbinden.',
                'Geography' => 'Plaatsen herkennen en regio’s vergelijken.',
                'Language' => 'Woordenschat en zinsbouw oefenen.',
                default => 'Zelfvertrouwen opbouwen rond de belangrijkste concepten.',
            };
        }
        if ($lang === 'spanish') {
            return match ($subject) {
                'Math' => 'Resolver ejercicios básicos con menos errores.',
                'Science' => 'Explicar conceptos clave con ejemplos sencillos.',
                'History' => 'Recordar eventos y conectar causas y consecuencias.',
                'Geography' => 'Identificar lugares y comparar regiones.',
                'Language' => 'Practicar vocabulario y construcción de oraciones.',
                default => 'Aumentar la confianza en los conceptos principales.',
            };
        }

        return match ($subject) {
            'Math' => 'Solve core exercises with fewer mistakes.',
            'Science' => 'Explain key concepts using simple examples.',
            'History' => 'Recall events and connect causes and outcomes.',
            'Geography' => 'Identify places and compare regions.',
            'Language' => 'Practice vocabulary and sentence construction.',
            default => 'Build confidence on the main concepts.',
        };
    }

    /**
     * @param  array{filename?: string|null, context_text?: string|null, ocr_snippet?: string|null, language_hint?: string|null}  $input
     */
    private function buildVisionPrompt(array $input): string
    {
        $context = trim(implode(' ', array_filter([
            $input['filename'] ?? null,
            $input['context_text'] ?? null,
            $input['ocr_snippet'] ?? null,
        ])));

        $languageHint = (string) ($input['language_hint'] ?? '');

        return <<<PROMPT
You are classifying a school document image.
Return JSON only, no markdown:
{
  "subject": string,       // one of: Math, Science, History, Geography, Language, General
  "language": string,      // English, French, Spanish, Dutch, or General if unknown
  "learning_goal": string,
  "title": string,
  "confidence": number,    // 0.0 to 1.0
  "alternatives": [string]
}

Rules:
- Prefer the document's actual language over English if the text is clearly non-English.
- If unsure, set subject "General" and confidence <= 0.5.
- The learning_goal must be written in the same language as the language field.
- Use the image content as the main source of truth.

Context text (may be empty): {$context}
Language hint (may be empty): {$languageHint}
PROMPT;
    }

    private function normalizeSubject(mixed $subject): string
    {
        $candidate = trim((string) $subject);
        $allowed = ['Math', 'Science', 'History', 'Geography', 'Language', 'General'];
        if (in_array($candidate, $allowed, true)) {
            return $candidate;
        }

        return 'General';
    }

    /**
     * @param  array{filename?: string|null, context_text?: string|null, ocr_snippet?: string|null, language_hint?: string|null}  $input
     */
    private function normalizeLanguage(mixed $language, array $input): string
    {
        $candidate = trim((string) $language);
        if ($candidate !== '') {
            return $candidate;
        }

        $fallbackText = strtolower(trim(implode(' ', array_filter([
            $input['filename'] ?? null,
            $input['context_text'] ?? null,
            $input['ocr_snippet'] ?? null,
        ]))));

        return $this->detectLanguage($fallbackText, (string) ($input['language_hint'] ?? ''));
    }

    private function titleForSuggestion(string $subject, string $learningGoal, string $language): string
    {
        $subjectLabel = $subject;
        $lang = strtolower($language);
        if ($lang === 'french') {
            $subjectLabel = match ($subject) {
                'Math' => 'Maths',
                'Science' => 'Sciences',
                'History' => 'Histoire',
                'Geography' => 'Géographie',
                'Language' => 'Langue',
                default => 'Activité',
            };
        } elseif ($lang === 'dutch') {
            $subjectLabel = match ($subject) {
                'Math' => 'Wiskunde',
                'Science' => 'Wetenschappen',
                'History' => 'Geschiedenis',
                'Geography' => 'Aardrijkskunde',
                'Language' => 'Taal',
                default => 'Activiteit',
            };
        } elseif ($lang === 'spanish') {
            $subjectLabel = match ($subject) {
                'Math' => 'Matemáticas',
                'Science' => 'Ciencias',
                'History' => 'Historia',
                'Geography' => 'Geografía',
                'Language' => 'Lengua',
                default => 'Actividad',
            };
        }

        $goal = trim($learningGoal);
        if ($goal === '') {
            return $subjectLabel;
        }

        $title = "{$subjectLabel} — {$goal}";
        if (mb_strlen($title) > 80) {
            return mb_substr($title, 0, 77).'...';
        }

        return $title;
    }
}
