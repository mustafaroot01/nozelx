<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use Illuminate\Http\Request;

class SettingsController extends Controller
{
    /**
     * Get all system settings as key => value JSON.
     */
    public function index()
    {
        $settings = Setting::all();
        $settings_dict = [];

        foreach ($settings as $setting) {
            $decoded = json_decode($setting->value, true);
            if (json_last_error() === JSON_ERROR_NONE) {
                $settings_dict[$setting->key] = $decoded;
            } else {
                $settings_dict[$setting->key] = $setting->value;
            }
        }

        // Add defaults if missing
        if (!isset($settings_dict['store_address'])) {
            $settings_dict['store_address'] = ['ar' => 'العراق، بغداد', 'en' => 'Baghdad, Iraq'];
        }
        if (!isset($settings_dict['invoice_logo'])) {
            $settings_dict['invoice_logo'] = '';
        }

        return response()->json($settings_dict);
    }

    /**
     * Update multiple settings.
     */
    public function save(Request $request)
    {
        $data = $request->all();

        foreach ($data as $key => $value) {
            $setting = Setting::firstOrNew(['key' => $key]);
            $setting->value = json_encode($value, JSON_UNESCAPED_UNICODE);
            $setting->save();
        }

        return response()->json(['message' => 'Settings updated successfully']);
    }
}
