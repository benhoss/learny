<?php

namespace App\Services\Documents;

class MetadataSuggestionService
{
    /**
     * @param  array{filename?: string|null, context_text?: string|null, ocr_snippet?: string|null, language_hint?: string|null}  $input
     * @return array{subject: string, language: string, learning_goal: string, confidence: float, alternatives: array<int, string>}
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
        $learningGoal = $this->goalForSubject($subject);

        $confidence = min(0.95, max(0.35, 0.35 + ($topSubjectScore * 0.15)));

        return [
            'subject' => $subject,
            'language' => $language,
            'learning_goal' => $learningGoal,
            'confidence' => round($confidence, 2),
            'alternatives' => $alternatives,
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

    protected function goalForSubject(string $subject): string
    {
        return match ($subject) {
            'Math' => 'Solve core exercises with fewer mistakes.',
            'Science' => 'Explain key concepts using simple examples.',
            'History' => 'Recall events and connect causes and outcomes.',
            'Geography' => 'Identify places and compare regions.',
            'Language' => 'Practice vocabulary and sentence construction.',
            default => 'Build confidence on the main concepts.',
        };
    }
}
