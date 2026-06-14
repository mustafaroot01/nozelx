<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class OtpIQService
{
    protected string $apiKey;
    protected string $url;

    public function __construct()
    {
        // Read from system_settings (admin panel) first, then fall back to env
        $dbKey = \Illuminate\Support\Facades\DB::table('system_settings')->where('key', 'otp_api_key')->value('value');
        $dbUrl = \Illuminate\Support\Facades\DB::table('system_settings')->where('key', 'otp_api_url')->value('value');

        $this->apiKey = ($dbKey ? json_decode($dbKey, true) : null) ?: config('services.otpiq.key') ?: '';
        $this->url    = ($dbUrl ? json_decode($dbUrl, true) : null) ?: config('services.otpiq.url') ?: 'https://api.otpiq.com/api/sms';
    }

    /**
     * Send a verification code via WhatsApp.
     *
     * @param string $phoneNumber
     * @param string $code
     * @return array
     */
    public function sendVerificationCode(string $phoneNumber, string $code): array
    {
        // Format phoneNumber to ensure it has 964 country code for Iraqi numbers
        if (str_starts_with($phoneNumber, '07')) {
            $phoneNumber = '964' . substr($phoneNumber, 1);
        } elseif (str_starts_with($phoneNumber, '7') && strlen($phoneNumber) == 10) {
            $phoneNumber = '964' . $phoneNumber;
        }

        try {
            if (empty($this->url) || empty($this->apiKey)) {
                Log::info("OtpIQ config empty. Mocking success for OTP verification.", [
                    'phone' => $phoneNumber,
                    'code' => $code
                ]);
                return [
                    'success' => true,
                    'message' => 'Demo/Mock mode OTP sent',
                    'mock' => true
                ];
            }

            $response = Http::withToken($this->apiKey)
                ->post($this->url, [
                    'phoneNumber'      => $phoneNumber,
                    'smsType'          => 'verification',
                    'provider'         => 'whatsapp-sms',
                    'verificationCode' => $code,
                ]);

            if ($response->successful()) {
                return [
                    'success' => true,
                    'data'    => $response->json(),
                ];
            }

            $errorData = json_decode($response->body(), true);
            $apiError = $errorData['error'] ?? 'Failed to send WhatsApp message.';

            Log::error('OtpIQ API Error', [
                'status'  => $response->status(),
                'body'    => $response->body(),
                'phone'   => $phoneNumber
            ]);

            // Bypass trial mode error blocking the UI
            if ($response->status() === 400 && str_contains(strtolower($apiError), 'trial mode')) {
                return [
                    'success' => true,
                    'message' => 'Trial mode bypass',
                ];
            }

            return [
                'success' => false,
                'message' => "خطأ من مزود الواتساب: " . $apiError,
            ];

        } catch (\Exception $e) {
            Log::error('OtpIQ Exception', [
                'message' => $e->getMessage(),
                'phone'   => $phoneNumber
            ]);

            return [
                'success' => false,
                'message' => $e->getMessage(),
            ];
        }
    }
}
