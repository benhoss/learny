<?php

namespace Database\Seeders;

use App\Models\ChildProfile;
use App\Models\User;
use Illuminate\Database\Seeder;

class TestSeeder extends Seeder
{
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
            'notes' => 'Prefers math games.',
        ]);
    }
}
