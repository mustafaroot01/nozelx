<?php

namespace App\Helpers;

use Exception;

class JWTHelper
{
    private static $secret = "super_secret_jwt_key_please_change_in_production_1234567890";

    public static function encode(array $payload): string
    {
        $header = json_encode(['alg' => 'HS256', 'typ' => 'JWT']);
        
        $base64UrlHeader = self::base64url_encode($header);
        $base64UrlPayload = self::base64url_encode(json_encode($payload));
        
        $signature = hash_hmac('sha256', $base64UrlHeader . "." . $base64UrlPayload, self::$secret, true);
        $base64UrlSignature = self::base64url_encode($signature);
        
        return $base64UrlHeader . "." . $base64UrlPayload . "." . $base64UrlSignature;
    }

    public static function decode(string $jwt): ?array
    {
        $parts = explode('.', $jwt);
        if (count($parts) !== 3) {
            return null;
        }
        
        list($headerB64, $payloadB64, $signatureB64) = $parts;
        
        // Verify signature
        $signature = self::base64url_decode($signatureB64);
        $expectedSignature = hash_hmac('sha256', $headerB64 . "." . $payloadB64, self::$secret, true);
        
        if (!hash_equals($signature, $expectedSignature)) {
            return null;
        }
        
        $payload = json_decode(self::base64url_decode($payloadB64), true);
        
        // Check expiration
        if (isset($payload['exp']) && $payload['exp'] < time()) {
            return null;
        }
        
        return $payload;
    }

    private static function base64url_encode($data)
    {
        return str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($data));
    }

    private static function base64url_decode($data)
    {
        return base64_decode(str_replace(['-', '_'], ['+', '/'], $data));
    }
}
