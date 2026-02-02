<?php

namespace Tests\Feature;

use App\Models\User;
use Database\Seeders\TestSeeder;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;

class AuthFlowTest extends TestCase
{
    use WithFaker;

    public function test_parent_can_register_and_get_token(): void
    {
        $payload = [
            'name' => 'New Parent',
            'email' => 'newparent@example.com',
            'password' => 'secret123',
            'password_confirmation' => 'secret123',
        ];

        $response = $this->postJson('/api/v1/auth/register', $payload);

        $response->assertOk()
            ->assertJsonStructure([
                'access_token',
                'token_type',
                'expires_in',
                'user' => ['name', 'email'],
            ]);

        $userPayload = $response->json('user');
        $this->assertNotSame('', $this->extractId($userPayload));
    }

    public function test_parent_can_login_and_fetch_profile(): void
    {
        $this->seed(TestSeeder::class);

        $login = $this->postJson('/api/v1/auth/login', [
            'email' => 'parent@example.com',
            'password' => 'secret123',
        ]);

        $login->assertOk();

        $token = $login->json('access_token');

        $me = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/auth/me');

        $me->assertOk()
            ->assertJsonPath('data.email', 'parent@example.com');
    }

    public function test_invalid_login_returns_validation_error(): void
    {
        User::create([
            'name' => 'Parent',
            'email' => 'parent2@example.com',
            'password' => 'secret123',
        ]);

        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'parent2@example.com',
            'password' => 'wrongpass',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['email']);
    }
}
