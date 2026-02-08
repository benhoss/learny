<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\ChildProfile;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $user = User::create([
            'name' => 'Parent Tester',
            'email' => 'parent@example.com',
            'password' => 'secret123',
        ]);

        ChildProfile::create([
            'user_id' => (string) $user->_id,
            'name' => 'Alex',
            'grade_level' => '6th',
            'birth_year' => 2013,
            'preferred_language' => 'en',
            'notes' => 'Prefers math games.',
        ]);

        ChildProfile::create([
            'user_id' => (string) $user->_id,
            'name' => 'Judith',
            'grade_level' => '1ere secondaire',
            'birth_year' => 2014,
            'preferred_language' => 'fr',
            'notes' => 'Belgium, French-speaking',
        ]);
    }
}
