<?php

namespace App\Concerns;

use App\Models\ChildProfile;
use Illuminate\Support\Facades\Auth;

trait FindsOwnedChild
{
    protected function findOwnedChild(string $childId): ChildProfile
    {
        $userId = (string) Auth::guard('api')->id();
        $boundChildId = config('learny.bound_child_profile_id');
        $resolvedChildId = (app()->environment('local') && filled($boundChildId))
            ? (string) $boundChildId
            : $childId;

        return ChildProfile::where('_id', $resolvedChildId)
            ->where('user_id', $userId)
            ->firstOrFail();
    }
}
