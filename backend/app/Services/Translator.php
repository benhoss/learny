<?php

namespace App\Services;

class Translator
{
    protected string $locale;

    protected static array $translations = [
        'en' => [
            'revision.prompt_review' => 'Which concept should you review now?',
            'revision.reason_due' => 'Due now in your review queue',
            'revision.not_sure' => 'Not sure yet',
            'revision.recent_mistake' => 'Recent mistake',
            'revision.reason_mistake' => 'Based on a recent wrong answer',
            'revision.prompt_recent_upload' => 'Pick the concept from your recent upload.',
            'revision.reason_recent_upload' => 'From your latest uploaded document',
            'revision.subject_label' => 'Quick Revision',
            'recommendation.review_title' => 'Review now: :label',
            'recommendation.review_subtitle' => 'This concept is due for spaced revision.',
            'recommendation.weak_title' => 'Practice weak area',
            'recommendation.weak_subtitle' => ':concept had :count recent mistakes.',
            'recommendation.recent_upload_title' => 'Continue latest upload',
            'recommendation.streak_title' => 'Streak rescue session',
            'recommendation.streak_subtitle' => 'Keep your streak alive with a 2-minute quick review.',
            'recommendation.generic_title' => 'Start a quick practice',
            'recommendation.generic_subtitle' => 'Personalization is paused. You can still learn from uploads.',
        ],
        'fr' => [
            'revision.prompt_review' => 'Quel concept devriez-vous revoir maintenant ?',
            'revision.reason_due' => 'À revoir dans votre file d\'attente',
            'revision.not_sure' => 'Pas sûr(e)',
            'revision.recent_mistake' => 'Erreur récente',
            'revision.reason_mistake' => 'Basé sur une réponse incorrecte récente',
            'revision.prompt_recent_upload' => 'Choisissez le concept de votre dernier envoi.',
            'revision.reason_recent_upload' => 'De votre dernier document envoyé',
            'revision.subject_label' => 'Révision rapide',
            'recommendation.review_title' => 'À revoir : :label',
            'recommendation.review_subtitle' => 'Ce concept est prêt pour une révision espacée.',
            'recommendation.weak_title' => 'Renforcer un point faible',
            'recommendation.weak_subtitle' => ':concept a eu :count erreurs récentes.',
            'recommendation.recent_upload_title' => 'Continuer le dernier envoi',
            'recommendation.streak_title' => 'Session de sauvetage de série',
            'recommendation.streak_subtitle' => 'Gardez votre série avec une révision rapide de 2 minutes.',
            'recommendation.generic_title' => 'Commencer un exercice rapide',
            'recommendation.generic_subtitle' => 'La personnalisation est en pause. Vous pouvez toujours apprendre depuis vos envois.',
        ],
        'nl' => [
            'revision.prompt_review' => 'Welk concept moet je nu herhalen?',
            'revision.reason_due' => 'Nu te herhalen in je wachtrij',
            'revision.not_sure' => 'Weet ik niet',
            'revision.recent_mistake' => 'Recente fout',
            'revision.reason_mistake' => 'Gebaseerd op een recent fout antwoord',
            'revision.prompt_recent_upload' => 'Kies het concept van je laatste upload.',
            'revision.reason_recent_upload' => 'Van je laatst geüploade document',
            'revision.subject_label' => 'Snelle herhaling',
            'recommendation.review_title' => 'Nu herhalen: :label',
            'recommendation.review_subtitle' => 'Dit concept is klaar voor gespreide herhaling.',
            'recommendation.weak_title' => 'Zwak punt oefenen',
            'recommendation.weak_subtitle' => ':concept had :count recente fouten.',
            'recommendation.recent_upload_title' => 'Laatste upload voortzetten',
            'recommendation.streak_title' => 'Reeks-reddingssessie',
            'recommendation.streak_subtitle' => 'Houd je reeks met een snelle herhaling van 2 minuten.',
            'recommendation.generic_title' => 'Start een snelle oefening',
            'recommendation.generic_subtitle' => 'Personalisatie is gepauzeerd. Je kunt nog steeds leren van je uploads.',
        ],
    ];

    public function __construct(string $locale = 'en')
    {
        $this->locale = self::normalizeLocale($locale);
    }

    public static function forChild($child): self
    {
        $locale = is_object($child)
            ? ($child->preferred_language ?? 'en')
            : ($child['preferred_language'] ?? 'en');

        return new self((string) $locale);
    }

    public function get(string $key, array $replace = []): string
    {
        $text = self::$translations[$this->locale][$key]
            ?? self::$translations['en'][$key]
            ?? $key;

        foreach ($replace as $placeholder => $value) {
            $text = str_replace(':'.$placeholder, (string) $value, $text);
        }

        return $text;
    }

    protected static function normalizeLocale(string $locale): string
    {
        $locale = strtolower(trim($locale));

        return isset(self::$translations[$locale]) ? $locale : 'en';
    }
}
