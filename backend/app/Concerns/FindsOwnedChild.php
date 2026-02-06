<?php

namespace App\Concerns;

use App\Models\ChildProfile;
use Illuminate\Support\Facades\Auth;

trait FindsOwnedChild
{
    protected function findOwnedChild(string $childId): ChildProfile
    {
        $userId = (string) Auth::guard('api')->id();

        return ChildProfile::where('_id', $childId)
            ->where('user_id', $userId)
            ->firstOrFail();
    }
}
