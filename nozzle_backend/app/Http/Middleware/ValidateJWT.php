<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use App\Helpers\JWTHelper;
use App\Models\User;
use Illuminate\Support\Facades\Auth;

class ValidateJWT
{
    public function handle(Request $request, Closure $next)
    {
        $authHeader = $request->header('Authorization');
        if (!$authHeader || !preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
            return response()->json(['detail' => 'Could not validate credentials'], 401);
        }

        $token = $matches[1];
        $payload = JWTHelper::decode($token);
        
        if (!$payload || !isset($payload['sub'])) {
            return response()->json(['detail' => 'Could not validate credentials'], 401);
        }

        $email = $payload['sub'];
        $user = User::where('email', $email)->orWhere('phone', $email)->first();

        if (!$user) {
            return response()->json(['detail' => 'Could not validate credentials'], 401);
        }

        // is_active in our SQLite schema can be stored as 1 or true.
        // We cast it or verify directly:
        if (!$user->is_active) {
            return response()->json(['detail' => 'Inactive user'], 400);
        }

        // Login the user into the Laravel auth context for the request
        Auth::login($user);

        return $next($request);
    }
}
