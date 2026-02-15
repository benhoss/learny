<?php

namespace App\Services\Onboarding;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Cache;

/**
 * Service to detect user country from IP and provide grade suggestions
 * based on the detected country and age.
 */
class GradeByCountryService
{
    private const CACHE_TTL_SECONDS = 86400; // 24 hours

    /**
     * Mapping of countries to their school grade systems.
     * Each country has grade ranges mapped to typical age brackets.
     */
    private const GRADE_MAPPINGS = [
        'US' => [
            'name' => 'United States',
            'grades' => [
                ['label' => 'Kindergarten', 'min_age' => 5, 'max_age' => 6],
                ['label' => '1st Grade', 'min_age' => 6, 'max_age' => 7],
                ['label' => '2nd Grade', 'min_age' => 7, 'max_age' => 8],
                ['label' => '3rd Grade', 'min_age' => 8, 'max_age' => 9],
                ['label' => '4th Grade', 'min_age' => 9, 'max_age' => 10],
                ['label' => '5th Grade', 'min_age' => 10, 'max_age' => 11],
                ['label' => '6th Grade', 'min_age' => 11, 'max_age' => 12],
                ['label' => '7th Grade', 'min_age' => 12, 'max_age' => 13],
                ['label' => '8th Grade', 'min_age' => 13, 'max_age' => 14],
                ['label' => '9th Grade', 'min_age' => 14, 'max_age' => 15],
                ['label' => '10th Grade', 'min_age' => 15, 'max_age' => 16],
                ['label' => '11th Grade', 'min_age' => 16, 'max_age' => 17],
                ['label' => '12th Grade', 'min_age' => 17, 'max_age' => 18],
            ],
        ],
        'GB' => [
            'name' => 'United Kingdom',
            'grades' => [
                ['label' => 'Reception', 'min_age' => 4, 'max_age' => 5],
                ['label' => 'Year 1', 'min_age' => 5, 'max_age' => 6],
                ['label' => 'Year 2', 'min_age' => 6, 'max_age' => 7],
                ['label' => 'Year 3', 'min_age' => 7, 'max_age' => 8],
                ['label' => 'Year 4', 'min_age' => 8, 'max_age' => 9],
                ['label' => 'Year 5', 'min_age' => 9, 'max_age' => 10],
                ['label' => 'Year 6', 'min_age' => 10, 'max_age' => 11],
                ['label' => 'Year 7', 'min_age' => 11, 'max_age' => 12],
                ['label' => 'Year 8', 'min_age' => 12, 'max_age' => 13],
                ['label' => 'Year 9', 'min_age' => 13, 'max_age' => 14],
                ['label' => 'Year 10', 'min_age' => 14, 'max_age' => 15],
                ['label' => 'Year 11', 'min_age' => 15, 'max_age' => 16],
                ['label' => 'Year 12', 'min_age' => 16, 'max_age' => 17],
                ['label' => 'Year 13', 'min_age' => 17, 'max_age' => 18],
            ],
        ],
        'FR' => [
            'name' => 'France',
            'grades' => [
                ['label' => 'Petite Section', 'min_age' => 3, 'max_age' => 4],
                ['label' => 'Moyenne Section', 'min_age' => 4, 'max_age' => 5],
                ['label' => 'Grande Section', 'min_age' => 5, 'max_age' => 6],
                ['label' => 'CP', 'min_age' => 6, 'max_age' => 7],
                ['label' => 'CE1', 'min_age' => 7, 'max_age' => 8],
                ['label' => 'CE2', 'min_age' => 8, 'max_age' => 9],
                ['label' => 'CM1', 'min_age' => 9, 'max_age' => 10],
                ['label' => 'CM2', 'min_age' => 10, 'max_age' => 11],
                ['label' => '6e', 'min_age' => 11, 'max_age' => 12],
                ['label' => '5e', 'min_age' => 12, 'max_age' => 13],
                ['label' => '4e', 'min_age' => 13, 'max_age' => 14],
                ['label' => '3e', 'min_age' => 14, 'max_age' => 15],
                ['label' => '2nde', 'min_age' => 15, 'max_age' => 16],
                ['label' => '1ère', 'min_age' => 16, 'max_age' => 17],
                ['label' => 'Terminale', 'min_age' => 17, 'max_age' => 18],
            ],
        ],
        'DE' => [
            'name' => 'Germany',
            'grades' => [
                ['label' => 'Vorschule', 'min_age' => 5, 'max_age' => 6],
                ['label' => '1. Klasse', 'min_age' => 6, 'max_age' => 7],
                ['label' => '2. Klasse', 'min_age' => 7, 'max_age' => 8],
                ['label' => '3. Klasse', 'min_age' => 8, 'max_age' => 9],
                ['label' => '4. Klasse', 'min_age' => 9, 'max_age' => 10],
                ['label' => '5. Klasse', 'min_age' => 10, 'max_age' => 11],
                ['label' => '6. Klasse', 'min_age' => 11, 'max_age' => 12],
                ['label' => '7. Klasse', 'min_age' => 12, 'max_age' => 13],
                ['label' => '8. Klasse', 'min_age' => 13, 'max_age' => 14],
                ['label' => '9. Klasse', 'min_age' => 14, 'max_age' => 15],
                ['label' => '10. Klasse', 'min_age' => 15, 'max_age' => 16],
                ['label' => '11. Klasse', 'min_age' => 16, 'max_age' => 17],
                ['label' => '12. Klasse', 'min_age' => 17, 'max_age' => 18],
                ['label' => '13. Klasse', 'min_age' => 18, 'max_age' => 19],
            ],
        ],
        'BE' => [
            'name' => 'Belgium',
            'grades' => [
                ['label' => 'Maternelle', 'min_age' => 3, 'max_age' => 6],
                ['label' => '1re Primaire', 'min_age' => 6, 'max_age' => 7],
                ['label' => '2e Primaire', 'min_age' => 7, 'max_age' => 8],
                ['label' => '3e Primaire', 'min_age' => 8, 'max_age' => 9],
                ['label' => '4e Primaire', 'min_age' => 9, 'max_age' => 10],
                ['label' => '5e Primaire', 'min_age' => 10, 'max_age' => 11],
                ['label' => '6e Primaire', 'min_age' => 11, 'max_age' => 12],
                ['label' => '1re Secondaire', 'min_age' => 12, 'max_age' => 13],
                ['label' => '2e Secondaire', 'min_age' => 13, 'max_age' => 14],
                ['label' => '3e Secondaire', 'min_age' => 14, 'max_age' => 15],
                ['label' => '4e Secondaire', 'min_age' => 15, 'max_age' => 16],
                ['label' => '5e Secondaire', 'min_age' => 16, 'max_age' => 17],
                ['label' => '6e Secondaire', 'min_age' => 17, 'max_age' => 18],
            ],
        ],
        'NL' => [
            'name' => 'Netherlands',
            'grades' => [
                ['label' => 'Groep 1', 'min_age' => 4, 'max_age' => 5],
                ['label' => 'Groep 2', 'min_age' => 5, 'max_age' => 6],
                ['label' => 'Groep 3', 'min_age' => 6, 'max_age' => 7],
                ['label' => 'Groep 4', 'min_age' => 7, 'max_age' => 8],
                ['label' => 'Groep 5', 'min_age' => 8, 'max_age' => 9],
                ['label' => 'Groep 6', 'min_age' => 9, 'max_age' => 10],
                ['label' => 'Groep 7', 'min_age' => 10, 'max_age' => 11],
                ['label' => 'Groep 8', 'min_age' => 11, 'max_age' => 12],
                ['label' => 'VMBO-1', 'min_age' => 12, 'max_age' => 13],
                ['label' => 'VMBO-2', 'min_age' => 13, 'max_age' => 14],
                ['label' => 'VMBO-3', 'min_age' => 14, 'max_age' => 15],
                ['label' => 'VMBO-4', 'min_age' => 15, 'max_age' => 16],
                ['label' => 'HAVO-1', 'min_age' => 12, 'max_age' => 13],
                ['label' => 'HAVO-2', 'min_age' => 13, 'max_age' => 14],
                ['label' => 'HAVO-3', 'min_age' => 14, 'max_age' => 15],
                ['label' => 'HAVO-4', 'min_age' => 15, 'max_age' => 16],
                ['label' => 'HAVO-5', 'min_age' => 16, 'max_age' => 17],
                ['label' => 'VWO-1', 'min_age' => 12, 'max_age' => 13],
                ['label' => 'VWO-2', 'min_age' => 13, 'max_age' => 14],
                ['label' => 'VWO-3', 'min_age' => 14, 'max_age' => 15],
                ['label' => 'VWO-4', 'min_age' => 15, 'max_age' => 16],
                ['label' => 'VWO-5', 'min_age' => 16, 'max_age' => 17],
                ['label' => 'VWO-6', 'min_age' => 17, 'max_age' => 18],
            ],
        ],
        'ES' => [
            'name' => 'Spain',
            'grades' => [
                ['label' => 'Educación Infantil 1', 'min_age' => 3, 'max_age' => 4],
                ['label' => 'Educación Infantil 2', 'min_age' => 4, 'max_age' => 5],
                ['label' => 'Educación Infantil 3', 'min_age' => 5, 'max_age' => 6],
                ['label' => '1º Primaria', 'min_age' => 6, 'max_age' => 7],
                ['label' => '2º Primaria', 'min_age' => 7, 'max_age' => 8],
                ['label' => '3º Primaria', 'min_age' => 8, 'max_age' => 9],
                ['label' => '4º Primaria', 'min_age' => 9, 'max_age' => 10],
                ['label' => '5º Primaria', 'min_age' => 10, 'max_age' => 11],
                ['label' => '6º Primaria', 'min_age' => 11, 'max_age' => 12],
                ['label' => '1º ESO', 'min_age' => 12, 'max_age' => 13],
                ['label' => '2º ESO', 'min_age' => 13, 'max_age' => 14],
                ['label' => '3º ESO', 'min_age' => 14, 'max_age' => 15],
                ['label' => '4º ESO', 'min_age' => 15, 'max_age' => 16],
                ['label' => '1º Bachillerato', 'min_age' => 16, 'max_age' => 17],
                ['label' => '2º Bachillerato', 'min_age' => 17, 'max_age' => 18],
            ],
        ],
        'IT' => [
            'name' => 'Italy',
            'grades' => [
                ['label' => 'Scuola Infanzia', 'min_age' => 3, 'max_age' => 6],
                ['label' => '1ª Elementare', 'min_age' => 6, 'max_age' => 7],
                ['label' => '2ª Elementare', 'min_age' => 7, 'max_age' => 8],
                ['label' => '3ª Elementare', 'min_age' => 8, 'max_age' => 9],
                ['label' => '4ª Elementare', 'min_age' => 9, 'max_age' => 10],
                ['label' => '5ª Elementare', 'min_age' => 10, 'max_age' => 11],
                ['label' => '1ª Media', 'min_age' => 11, 'max_age' => 12],
                ['label' => '2ª Media', 'min_age' => 12, 'max_age' => 13],
                ['label' => '3ª Media', 'min_age' => 13, 'max_age' => 14],
                ['label' => '1ª Superiore', 'min_age' => 14, 'max_age' => 15],
                ['label' => '2ª Superiore', 'min_age' => 15, 'max_age' => 16],
                ['label' => '3ª Superiore', 'min_age' => 16, 'max_age' => 17],
                ['label' => '4ª Superiore', 'min_age' => 17, 'max_age' => 18],
                ['label' => '5ª Superiore', 'min_age' => 18, 'max_age' => 19],
            ],
        ],
        'CA' => [
            'name' => 'Canada',
            'grades' => [
                ['label' => 'Kindergarten', 'min_age' => 4, 'max_age' => 6],
                ['label' => 'Grade 1', 'min_age' => 6, 'max_age' => 7],
                ['label' => 'Grade 2', 'min_age' => 7, 'max_age' => 8],
                ['label' => 'Grade 3', 'min_age' => 8, 'max_age' => 9],
                ['label' => 'Grade 4', 'min_age' => 9, 'max_age' => 10],
                ['label' => 'Grade 5', 'min_age' => 10, 'max_age' => 11],
                ['label' => 'Grade 6', 'min_age' => 11, 'max_age' => 12],
                ['label' => 'Grade 7', 'min_age' => 12, 'max_age' => 13],
                ['label' => 'Grade 8', 'min_age' => 13, 'max_age' => 14],
                ['label' => 'Grade 9', 'min_age' => 14, 'max_age' => 15],
                ['label' => 'Grade 10', 'min_age' => 15, 'max_age' => 16],
                ['label' => 'Grade 11', 'min_age' => 16, 'max_age' => 17],
                ['label' => 'Grade 12', 'min_age' => 17, 'max_age' => 18],
            ],
        ],
        'AU' => [
            'name' => 'Australia',
            'grades' => [
                ['label' => 'Kindergarten', 'min_age' => 4, 'max_age' => 5],
                ['label' => 'Year 1', 'min_age' => 5, 'max_age' => 6],
                ['label' => 'Year 2', 'min_age' => 6, 'max_age' => 7],
                ['label' => 'Year 3', 'min_age' => 7, 'max_age' => 8],
                ['label' => 'Year 4', 'min_age' => 8, 'max_age' => 9],
                ['label' => 'Year 5', 'min_age' => 9, 'max_age' => 10],
                ['label' => 'Year 6', 'min_age' => 10, 'max_age' => 11],
                ['label' => 'Year 7', 'min_age' => 11, 'max_age' => 12],
                ['label' => 'Year 8', 'min_age' => 12, 'max_age' => 13],
                ['label' => 'Year 9', 'min_age' => 13, 'max_age' => 14],
                ['label' => 'Year 10', 'min_age' => 14, 'max_age' => 15],
                ['label' => 'Year 11', 'min_age' => 15, 'max_age' => 16],
                ['label' => 'Year 12', 'min_age' => 16, 'max_age' => 17],
            ],
        ],
        'CH' => [
            'name' => 'Switzerland',
            'grades' => [
                ['label' => 'Kindergarten', 'min_age' => 4, 'max_age' => 6],
                ['label' => '1. Primarschule', 'min_age' => 6, 'max_age' => 7],
                ['label' => '2. Primarschule', 'min_age' => 7, 'max_age' => 8],
                ['label' => '3. Primarschule', 'min_age' => 8, 'max_age' => 9],
                ['label' => '4. Primarschule', 'min_age' => 9, 'max_age' => 10],
                ['label' => '5. Primarschule', 'min_age' => 10, 'max_age' => 11],
                ['label' => '6. Primarschule', 'min_age' => 11, 'max_age' => 12],
                ['label' => '7. Schuljahr', 'min_age' => 12, 'max_age' => 13],
                ['label' => '8. Schuljahr', 'min_age' => 13, 'max_age' => 14],
                ['label' => '9. Schuljahr', 'min_age' => 14, 'max_age' => 15],
                ['label' => '10. Schuljahr', 'min_age' => 15, 'max_age' => 16],
                ['label' => '11. Schuljahr', 'min_age' => 16, 'max_age' => 17],
                ['label' => '12. Schuljahr', 'min_age' => 17, 'max_age' => 18],
            ],
        ],
        'AT' => [
            'name' => 'Austria',
            'grades' => [
                ['label' => 'Volksschule 1', 'min_age' => 6, 'max_age' => 7],
                ['label' => 'Volksschule 2', 'min_age' => 7, 'max_age' => 8],
                ['label' => 'Volksschule 3', 'min_age' => 8, 'max_age' => 9],
                ['label' => 'Volksschule 4', 'min_age' => 9, 'max_age' => 10],
                ['label' => '1. Klasse AHS', 'min_age' => 10, 'max_age' => 11],
                ['label' => '2. Klasse AHS', 'min_age' => 11, 'max_age' => 12],
                ['label' => '3. Klasse AHS', 'min_age' => 12, 'max_age' => 13],
                ['label' => '4. Klasse AHS', 'min_age' => 13, 'max_age' => 14],
                ['label' => '5. Klasse AHS', 'min_age' => 14, 'max_age' => 15],
                ['label' => '6. Klasse AHS', 'min_age' => 15, 'max_age' => 16],
                ['label' => '7. Klasse AHS', 'min_age' => 16, 'max_age' => 17],
                ['label' => '8. Klasse AHS', 'min_age' => 17, 'max_age' => 18],
            ],
        ],
        'PT' => [
            'name' => 'Portugal',
            'grades' => [
                ['label' => 'Educação Infantil', 'min_age' => 3, 'max_age' => 6],
                ['label' => '1º Ano', 'min_age' => 6, 'max_age' => 7],
                ['label' => '2º Ano', 'min_age' => 7, 'max_age' => 8],
                ['label' => '3º Ano', 'min_age' => 8, 'max_age' => 9],
                ['label' => '4º Ano', 'min_age' => 9, 'max_age' => 10],
                ['label' => '5º Ano', 'min_age' => 10, 'max_age' => 11],
                ['label' => '6º Ano', 'min_age' => 11, 'max_age' => 12],
                ['label' => '7º Ano', 'min_age' => 12, 'max_age' => 13],
                ['label' => '8º Ano', 'min_age' => 13, 'max_age' => 14],
                ['label' => '9º Ano', 'min_age' => 14, 'max_age' => 15],
                ['label' => '10º Ano', 'min_age' => 15, 'max_age' => 16],
                ['label' => '11º Ano', 'min_age' => 16, 'max_age' => 17],
                ['label' => '12º Ano', 'min_age' => 17, 'max_age' => 18],
            ],
        ],
        'IE' => [
            'name' => 'Ireland',
            'grades' => [
                ['label' => 'Junior Infants', 'min_age' => 4, 'max_age' => 5],
                ['label' => 'Senior Infants', 'min_age' => 5, 'max_age' => 6],
                ['label' => '1st Class', 'min_age' => 6, 'max_age' => 7],
                ['label' => '2nd Class', 'min_age' => 7, 'max_age' => 8],
                ['label' => '3rd Class', 'min_age' => 8, 'max_age' => 9],
                ['label' => '4th Class', 'min_age' => 9, 'max_age' => 10],
                ['label' => '5th Class', 'min_age' => 10, 'max_age' => 11],
                ['label' => '6th Class', 'min_age' => 11, 'max_age' => 12],
                ['label' => '1st Year', 'min_age' => 12, 'max_age' => 13],
                ['label' => '2nd Year', 'min_age' => 13, 'max_age' => 14],
                ['label' => '3rd Year', 'min_age' => 14, 'max_age' => 15],
                ['label' => 'Transition Year', 'min_age' => 15, 'max_age' => 16],
                ['label' => '5th Year', 'min_age' => 16, 'max_age' => 17],
                ['label' => '6th Year', 'min_age' => 17, 'max_age' => 18],
            ],
        ],
        'SE' => [
            'name' => 'Sweden',
            'grades' => [
                ['label' => 'Förskoleklass', 'min_age' => 6, 'max_age' => 7],
                ['label' => 'Årskurs 1', 'min_age' => 7, 'max_age' => 8],
                ['label' => 'Årskurs 2', 'min_age' => 8, 'max_age' => 9],
                ['label' => 'Årskurs 3', 'min_age' => 9, 'max_age' => 10],
                ['label' => 'Årskurs 4', 'min_age' => 10, 'max_age' => 11],
                ['label' => 'Årskurs 5', 'min_age' => 11, 'max_age' => 12],
                ['label' => 'Årskurs 6', 'min_age' => 12, 'max_age' => 13],
                ['label' => 'Årskurs 7', 'min_age' => 13, 'max_age' => 14],
                ['label' => 'Årskurs 8', 'min_age' => 14, 'max_age' => 15],
                ['label' => 'Årskurs 9', 'min_age' => 15, 'max_age' => 16],
                ['label' => 'Gymnasiet År 1', 'min_age' => 16, 'max_age' => 17],
                ['label' => 'Gymnasiet År 2', 'min_age' => 17, 'max_age' => 18],
                ['label' => 'Gymnasiet År 3', 'min_age' => 18, 'max_age' => 19],
            ],
        ],
        'NO' => [
            'name' => 'Norway',
            'grades' => [
                ['label' => '1. Trinn', 'min_age' => 6, 'max_age' => 7],
                ['label' => '2. Trinn', 'min_age' => 7, 'max_age' => 8],
                ['label' => '3. Trinn', 'min_age' => 8, 'max_age' => 9],
                ['label' => '4. Trinn', 'min_age' => 9, 'max_age' => 10],
                ['label' => '5. Trinn', 'min_age' => 10, 'max_age' => 11],
                ['label' => '6. Trinn', 'min_age' => 11, 'max_age' => 12],
                ['label' => '7. Trinn', 'min_age' => 12, 'max_age' => 13],
                ['label' => '8. Trinn', 'min_age' => 13, 'max_age' => 14],
                ['label' => '9. Trinn', 'min_age' => 14, 'max_age' => 15],
                ['label' => '10. Trinn', 'min_age' => 15, 'max_age' => 16],
                ['label' => 'Vg1', 'min_age' => 16, 'max_age' => 17],
                ['label' => 'Vg2', 'min_age' => 17, 'max_age' => 18],
                ['label' => 'Vg3', 'min_age' => 18, 'max_age' => 19],
            ],
        ],
        'DK' => [
            'name' => 'Denmark',
            'grades' => [
                ['label' => 'Børnehave', 'min_age' => 5, 'max_age' => 6],
                ['label' => '0. Klasse', 'min_age' => 6, 'max_age' => 7],
                ['label' => '1. Klasse', 'min_age' => 7, 'max_age' => 8],
                ['label' => '2. Klasse', 'min_age' => 8, 'max_age' => 9],
                ['label' => '3. Klasse', 'min_age' => 9, 'max_age' => 10],
                ['label' => '4. Klasse', 'min_age' => 10, 'max_age' => 11],
                ['label' => '5. Klasse', 'min_age' => 11, 'max_age' => 12],
                ['label' => '6. Klasse', 'min_age' => 12, 'max_age' => 13],
                ['label' => '7. Klasse', 'min_age' => 13, 'max_age' => 14],
                ['label' => '8. Klasse', 'min_age' => 14, 'max_age' => 15],
                ['label' => '9. Klasse', 'min_age' => 15, 'max_age' => 16],
                ['label' => '10. Klasse', 'min_age' => 16, 'max_age' => 17],
                ['label' => '1.g', 'min_age' => 16, 'max_age' => 17],
                ['label' => '2.g', 'min_age' => 17, 'max_age' => 18],
                ['label' => '3.g', 'min_age' => 18, 'max_age' => 19],
            ],
        ],
        'PL' => [
            'name' => 'Poland',
            'grades' => [
                ['label' => 'Przedszkole', 'min_age' => 3, 'max_age' => 6],
                ['label' => 'Klasa 1', 'min_age' => 7, 'max_age' => 8],
                ['label' => 'Klasa 2', 'min_age' => 8, 'max_age' => 9],
                ['label' => 'Klasa 3', 'min_age' => 9, 'max_age' => 10],
                ['label' => 'Klasa 4', 'min_age' => 10, 'max_age' => 11],
                ['label' => 'Klasa 5', 'min_age' => 11, 'max_age' => 12],
                ['label' => 'Klasa 6', 'min_age' => 12, 'max_age' => 13],
                ['label' => 'Klasa 7', 'min_age' => 13, 'max_age' => 14],
                ['label' => 'Klasa 8', 'min_age' => 14, 'max_age' => 15],
                ['label' => 'Szkoła średnia 1', 'min_age' => 15, 'max_age' => 16],
                ['label' => 'Szkoła średnia 2', 'min_age' => 16, 'max_age' => 17],
                ['label' => 'Szkoła średnia 3', 'min_age' => 17, 'max_age' => 18],
                ['label' => 'Szkoła średnia 4', 'min_age' => 18, 'max_age' => 19],
            ],
        ],
        'JP' => [
            'name' => 'Japan',
            'grades' => [
                ['label' => '年中', 'min_age' => 4, 'max_age' => 5],
                ['label' => '年長', 'min_age' => 5, 'max_age' => 6],
                ['label' => '小学1年', 'min_age' => 6, 'max_age' => 7],
                ['label' => '小学2年', 'min_age' => 7, 'max_age' => 8],
                ['label' => '小学3年', 'min_age' => 8, 'max_age' => 9],
                ['label' => '小学4年', 'min_age' => 9, 'max_age' => 10],
                ['label' => '小学5年', 'min_age' => 10, 'max_age' => 11],
                ['label' => '小学6年', 'min_age' => 11, 'max_age' => 12],
                ['label' => '中学1年', 'min_age' => 12, 'max_age' => 13],
                ['label' => '中学2年', 'min_age' => 13, 'max_age' => 14],
                ['label' => '中学3年', 'min_age' => 14, 'max_age' => 15],
                ['label' => '高校1年', 'min_age' => 15, 'max_age' => 16],
                ['label' => '高校2年', 'min_age' => 16, 'max_age' => 17],
                ['label' => '高校3年', 'min_age' => 17, 'max_age' => 18],
            ],
        ],
    ];

    /**
     * Detect country from IP address using a free geoIP service.
     */
    public function detectCountryFromIp(?string $ipAddress): ?string
    {
        // Skip localhost/private IPs
        if (empty($ipAddress) || $this->isPrivateIp($ipAddress)) {
            \Log::info('GradeByCountryService: Skipping IP detection - private/localhost IP', [
                'ip' => $ipAddress,
                'reason' => empty($ipAddress) ? 'empty' : 'private_range',
            ]);
            return null;
        }

        $cacheKey = "geoip:{$ipAddress}";

        return Cache::remember($cacheKey, self::CACHE_TTL_SECONDS, function () use ($ipAddress) {
            try {
                // Use ipapi.co free API (no API key required, 1000 requests/month)
                \Log::info('GradeByCountryService: Detecting country from IP', ['ip' => $ipAddress]);
                
                $response = Http::timeout(5)
                    ->get("https://ipapi.co/{$ipAddress}/country_code/");

                if ($response->successful()) {
                    $countryCode = trim($response->body());
                    if (strlen($countryCode) === 2) {
                        $country = strtoupper($countryCode);
                        \Log::info('GradeByCountryService: IP country detected', [
                            'ip' => $ipAddress,
                            'country' => $country,
                        ]);
                        return $country;
                    }
                }
                
                \Log::warning('GradeByCountryService: IP detection failed - invalid response', [
                    'ip' => $ipAddress,
                    'status' => $response->status(),
                    'body' => $response->body(),
                ]);
            } catch (\Exception $e) {
                // Log error but don't break the flow
                \Log::warning("GradeByCountryService: IP detection exception: " . $e->getMessage(), [
                    'ip' => $ipAddress,
                ]);
            }

            return null;
        });
    }

    /**
     * Get country code from request (from headers or IP detection).
     */
    public function getCountryFromRequest($request): ?string
    {
        // First check Cloudflare/forwarded headers
        $countryCode = $request->header('CF-IPCountry') 
            ?? $request->header('X-Geo-Country')
            ?? $request->header('X-Geo-IP-Country');

        if (!empty($countryCode) && strlen($countryCode) === 2) {
            return strtoupper($countryCode);
        }

        // Try to detect from IP
        $ip = $request->ip();
        return $this->detectCountryFromIp($ip);
    }

    /**
     * Get all available countries with grade systems.
     */
    public function getAvailableCountries(): array
    {
        $countries = [];
        foreach (self::GRADE_MAPPINGS as $code => $data) {
            $countries[] = [
                'code' => $code,
                'name' => $data['name'],
            ];
        }
        return $countries;
    }

    /**
     * Get grades for a specific country.
     */
    public function getGradesByCountry(string $countryCode): ?array
    {
        $countryCode = strtoupper($countryCode);
        
        if (!isset(self::GRADE_MAPPINGS[$countryCode])) {
            return null;
        }

        return self::GRADE_MAPPINGS[$countryCode];
    }

    /**
     * Suggest a grade based on age and country.
     * Returns the best matching grade label or null if no match.
     */
    public function suggestGradeByAgeAndCountry(?string $countryCode, int $age): ?string
    {
        if (empty($countryCode)) {
            return null;
        }

        $countryCode = strtoupper($countryCode);
        
        if (!isset(self::GRADE_MAPPINGS[$countryCode])) {
            return null;
        }

        $grades = self::GRADE_MAPPINGS[$countryCode]['grades'];

        // Find the grade that matches the age
        foreach ($grades as $grade) {
            if ($age >= $grade['min_age'] && $age < $grade['max_age']) {
                return $grade['label'];
            }
        }

        // If age is outside all ranges, return the closest grade
        if ($age < $grades[0]['min_age']) {
            return $grades[0]['label'];
        }

        if ($age >= end($grades)['max_age']) {
            return end($grades)['label'];
        }

        return null;
    }

    /**
     * Get all grade labels for a country.
     */
    public function getGradeLabelsByCountry(string $countryCode): array
    {
        $countryCode = strtoupper($countryCode);
        
        if (!isset(self::GRADE_MAPPINGS[$countryCode])) {
            return [];
        }

        return array_column(self::GRADE_MAPPINGS[$countryCode]['grades'], 'label');
    }

    /**
     * Check if a country is supported.
     */
    public function isCountrySupported(string $countryCode): bool
    {
        return isset(self::GRADE_MAPPINGS[strtoupper($countryCode)]);
    }

    /**
     * Get all grade mappings (for debugging/admin).
     */
    public function getAllGradeMappings(): array
    {
        return self::GRADE_MAPPINGS;
    }

    /**
     * Check if IP is private/localhost.
     */
    private function isPrivateIp(string $ip): bool
    {
        $privateRanges = [
            '10.',
            '172.16.', '172.17.', '172.18.', '172.19.',
            '172.20.', '172.21.', '172.22.', '172.23.', '172.24.',
            '172.25.', '172.26.', '172.27.', '172.28.', '172.29.',
            '172.30.', '172.31.',
            '192.168.',
            '127.',
            'localhost',
        ];

        // Check localhost
        if ($ip === 'localhost' || $ip === '::1') {
            return true;
        }

        // Check IPv4 private ranges
        foreach ($privateRanges as $range) {
            if (str_starts_with($ip, $range)) {
                return true;
            }
        }

        // Check if it's not a valid public IP (simplified check)
        if (filter_var($ip, FILTER_VALIDATE_IP, FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE) === false) {
            return true;
        }

        return false;
    }
}
