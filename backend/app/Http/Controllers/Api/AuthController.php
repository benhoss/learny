<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'email' => ['required', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
        ]);

        $user = User::create($data);
        $token = Auth::guard('api')->login($user);

        return $this->respondWithToken($token, $user);
    }

    public function login(Request $request): JsonResponse
    {
        $credentials = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        $token = Auth::guard('api')->attempt($credentials);

        if (! $token) {
            $demoEmail = env('DEMO_USER_EMAIL', 'parent@example.com');
            $demoPassword = env('DEMO_USER_PASSWORD', 'password1234');
            $demoName = env('DEMO_USER_NAME', 'Learny Parent');

            if (app()->environment('local') && $credentials['email'] === $demoEmail) {
                $user = User::where('email', $demoEmail)->first();
                if (! $user) {
                    $user = User::create([
                        'name' => $demoName,
                        'email' => $demoEmail,
                        'password' => Hash::make($demoPassword),
                    ]);
                }

                $token = Auth::guard('api')->login($user);
            }
        }

        if (! $token) {
            throw ValidationException::withMessages([
                'email' => ['Invalid credentials.'],
            ]);
        }

        return $this->respondWithToken($token, Auth::guard('api')->user());
    }

    public function me(): JsonResponse
    {
        return response()->json([
            'data' => Auth::guard('api')->user(),
        ]);
    }

    public function logout(): JsonResponse
    {
        Auth::guard('api')->logout();

        return response()->json([
            'message' => 'Logged out.',
        ]);
    }

    public function refresh(): JsonResponse
    {
        $token = Auth::guard('api')->refresh();

        return $this->respondWithToken($token, Auth::guard('api')->user());
    }

    protected function respondWithToken(string $token, ?User $user): JsonResponse
    {
        $guard = Auth::guard('api');

        return response()->json([
            'access_token' => $token,
            'token_type' => 'bearer',
            'expires_in' => $guard->factory()->getTTL() * 60,
            'user' => $user,
        ]);
    }
}
