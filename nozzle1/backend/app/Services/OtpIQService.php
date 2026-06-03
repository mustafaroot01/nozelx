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
        $this->apiKey = config('services.otpiq.key');
        $this->url = config('services.otpiq.url');
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
            $response = Http::withToken($this->apiKey)
                ->post($this->url, [
                    'phoneNumber'      => $phoneNumber,
                    'smsType'          => 'verification',
                    'provider'         => 'whatsapp',
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
