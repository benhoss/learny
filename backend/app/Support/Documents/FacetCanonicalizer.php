<?php

namespace App\Support\Documents;

class FacetCanonicalizer
{
    private const CORE_SUBJECTS = ['Math', 'Science', 'History', 'Geography', 'Language', 'General'];

    /**
     * @var array<string, string>
     */
    private const SUBJECT_ALIASES = [
        'math' => 'Math',
        'maths' => 'Math',
        'mathematics' => 'Math',
        'science' => 'Science',
        'sciences' => 'Science',
        'history' => 'History',
        'geography' => 'Geography',
        'language' => 'Language',
        'languages' => 'Language',
        'general' => 'General',
        'other' => 'General',
        'misc' => 'General',
    ];

    /**
     * @var array<string, string>
     */
    private const LANGUAGE_ALIASES = [
        'en' => 'English',
        'eng' => 'English',
        'english' => 'English',
        'fr' => 'French',
        'fra' => 'French',
        'french' => 'French',
        'francais' => 'French',
        'es' => 'Spanish',
        'spa' => 'Spanish',
        'spanish' => 'Spanish',
        'nl' => 'Dutch',
        'dut' => 'Dutch',
        'nld' => 'Dutch',
        'dutch' => 'Dutch',
        'de' => 'German',
        'ger' => 'German',
        'deu' => 'German',
        'german' => 'German',
        'it' => 'Italian',
        'italian' => 'Italian',
        'pt' => 'Portuguese',
        'portuguese' => 'Portuguese',
        'ar' => 'Arabic',
        'arabic' => 'Arabic',
    ];

    public static function canonicalizeSubject(?string $value): ?string
    {
        $normalized = self::normalizeToken($value);
        if ($normalized === null) {
            return null;
        }

        if (array_key_exists($normalized, self::SUBJECT_ALIASES)) {
            return self::SUBJECT_ALIASES[$normalized];
        }

        return self::titleCase($value);
    }

    public static function canonicalizeLanguage(?string $value): ?string
    {
        $normalized = self::normalizeToken($value);
        if ($normalized === null) {
            return null;
        }

        if (array_key_exists($normalized, self::LANGUAGE_ALIASES)) {
            return self::LANGUAGE_ALIASES[$normalized];
        }

        return self::titleCase($value);
    }

    public static function canonicalizeTopic(?string $value): ?string
    {
        $normalized = self::normalizeToken($value);
        if ($normalized === null) {
            return null;
        }

        // Topic names that are actually a subject should collapse to one canonical facet.
        if (array_key_exists($normalized, self::SUBJECT_ALIASES)) {
            return self::SUBJECT_ALIASES[$normalized];
        }

        return self::titleCase($value);
    }

    public static function canonicalizeGradeLevel(?string $value): ?string
    {
        return self::titleCase($value);
    }

    /**
     * @param  array<int, string>  $values
     * @return array<int, string>
     */
    public static function canonicalizeList(array $values): array
    {
        $canonical = [];
        $seen = [];
        foreach ($values as $value) {
            $entry = self::titleCase($value);
            if ($entry === null) {
                continue;
            }

            $key = self::normalizeToken($entry);
            if ($key === null || isset($seen[$key])) {
                continue;
            }

            $canonical[] = $entry;
            $seen[$key] = true;
        }

        return $canonical;
    }

    public static function isCoreSubject(?string $value): bool
    {
        if ($value === null) {
            return false;
        }

        return in_array($value, self::CORE_SUBJECTS, true);
    }

    private static function titleCase(?string $value): ?string
    {
        $normalized = self::normalizeToken($value);
        if ($normalized === null) {
            return null;
        }

        return ucwords($normalized);
    }

    private static function normalizeToken(?string $value): ?string
    {
        if ($value === null) {
            return null;
        }

        $trimmed = trim(preg_replace('/\s+/', ' ', $value) ?? '');
        if ($trimmed === '') {
            return null;
        }

        return strtolower($trimmed);
    }
}

