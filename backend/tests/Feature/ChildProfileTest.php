<?php

namespace Tests\Feature;

use App\Models\ChildProfile;
use App\Models\User;
use Illuminate\Foundation\Testing\WithFaker;
use Illuminate\Support\Facades\Auth;
use Tests\TestCase;

class ChildProfileTest extends TestCase
{
    use WithFaker;

    public function test_parent_can_crud_child_profiles(): void
    {
        $user = User::create([
            'name' => 'Parent',
            'email' => 'parent3@example.com',
            'password' => 'secret123',
        ]);

        $token = Auth::guard('api')->login($user);

        $create = $this->withHeader('Authorization', 'Bearer '.$token)
            ->postJson('/api/v1/children', [
                'name' => 'Jamie',
                'grade_level' => '5th',
                'birth_year' => 2014,
                'notes' => 'Needs help with fractions.',
            ]);

        $create->assertStatus(201);
        $childId = $this->extractId($create->json('data'));

        $index = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/children');
        $index->assertOk()->assertJsonCount(1, 'data');

        $update = $this->withHeader('Authorization', 'Bearer '.$token)
            ->patchJson('/api/v1/children/'.$childId, [
                'grade_level' => '6th',
            ]);
        $update->assertOk()->assertJsonPath('data.grade_level', '6th');

        $delete = $this->withHeader('Authorization', 'Bearer '.$token)
            ->deleteJson('/api/v1/children/'.$childId);
        $delete->assertOk();

        $this->assertEquals(0, ChildProfile::count());
    }
}
