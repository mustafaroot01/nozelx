<?php

namespace App\Console\Commands;

use App\Services\OtpIQService;
use Illuminate\Console\Command;

class TestWhatsAppSend extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'whatsapp:test {phone} {code=1234}';

    /**
     * The description of the console command.
     *
     * @var string
     */
    protected $description = 'Test sending a WhatsApp verification code via OtpIQ';

    /**
     * Execute the console command.
     */
    public function handle(OtpIQService $otpIQService)
    {
        $phone = $this->argument('phone');
        $code = $this->argument('code');

        $this->info("Sending WhatsApp OTP to {$phone}...");

        $result = $otpIQService->sendVerificationCode($phone, $code);

        if ($result['success']) {
            $this->info('Success! Message sent.');
            $this->line(json_encode($result['data'], JSON_PRETTY_PRINT));
        } else {
            $this->error('Failed: ' . $result['message']);
        }
    }
}
