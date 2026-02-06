<?php

namespace Tests\Feature;

use App\Models\ChildProfile;
use App\Models\MasteryProfile;
use App\Models\User;
use App\Providers\AppServiceProvider;
use Illuminate\Support\Facades\Auth;
use RuntimeException;
use Tests\TestCase;

class BoundChildModeTest extends TestCase
{
    public function test_bound_child_mode_uses_configured_child_in_non_production(): void
    {
        $user = User::factory()->create();
        $boundChild = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);
        $requestedChild = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);

        MasteryProfile::factory()->create([
            'child_profile_id' => (string) $boundChild->_id,
            'mastery_level' => 0.8,
        ]);

        $token = Auth::guard('api')->login($user);
        config()->set('learny.bound_child_profile_id', (string) $boundChild->_id);

        $response = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/children/'.$requestedChild->_id.'/progress');

        $response->assertOk()
            ->assertJsonPath('data.child_id', (string) $boundChild->_id);
    }

    public function test_bound_child_mode_still_enforces_child_ownership(): void
    {
        $user = User::factory()->create();
        $otherUser = User::factory()->create();
        $ownedChild = ChildProfile::factory()->create([
            'user_id' => (string) $user->_id,
        ]);
        $foreignChild = ChildProfile::factory()->create([
            'user_id' => (string) $otherUser->_id,
        ]);

        $token = Auth::guard('api')->login($user);
        config()->set('learny.bound_child_profile_id', (string) $foreignChild->_id);

        $response = $this->withHeader('Authorization', 'Bearer '.$token)
            ->getJson('/api/v1/children/'.$ownedChild->_id.'/progress');

        $response->assertNotFound();
    }

    public function test_app_boot_fails_if_bound_child_mode_enabled_in_production(): void
    {
        config()->set('learny.bound_child_profile_id', 'dev-child');
        $this->app->detectEnvironment(fn () => 'production');

        $this->expectException(RuntimeException::class);
        $this->expectExceptionMessage('BOUND_CHILD_PROFILE_ID must not be set in production.');

        (new AppServiceProvider($this->app))->boot();
    }
}
