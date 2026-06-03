<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\UserAddress;
use App\Models\User;
use App\Helpers\JWTHelper;
use Illuminate\Http\Request;

class AddressController extends Controller
{
    /**
     * Helper to resolve the user ID from request, Authorization header, or phone fallback.
     */
    private function resolveUserId(Request $request, ?int $userId = null): ?int
    {
        // 1. If we have a user ID, check if it exists in db
        if ($userId) {
            if (User::where('id', $userId)->exists()) {
                return $userId;
            }
        }

        // 2. Try to get user ID from Authorization header
        $authHeader = $request->header('Authorization');
        if ($authHeader && preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
            $token = $matches[1];
            try {
                $payload = JWTHelper::decode($token);
                if ($payload && isset($payload['sub'])) {
                    $email = $payload['sub'];
                    $user = User::where('email', $email)->orWhere('phone', $email)->first();
                    if ($user) {
                        return $user->id;
                    }
                }
            } catch (\Exception $e) {
                // Ignore
            }
        }

        // 3. Fallback: if we have a phone number in the request, try to lookup
        $phone = $request->input('phone') ?: $request->input('customer_phone') ?: $request->query('phone') ?: $request->input('recipient_phone') ?: $request->query('phone_number');
        if ($phone) {
            $user = User::where('phone', $phone)->first();
            if ($user) {
                return $user->id;
            }
        }

        return $userId;
    }

    /**
     * Helper to normalize input parameters from legacy app formats.
     */
    private function normalizeInput(Request $request)
    {
        if ($request->has('label') && !$request->has('title')) {
            $request->merge(['title' => $request->input('label')]);
        }
        if ($request->has('full_name') && !$request->has('recipient_name')) {
            $request->merge(['recipient_name' => $request->input('full_name')]);
        }
        if ($request->has('phone') && !$request->has('recipient_phone')) {
            $request->merge(['recipient_phone' => $request->input('phone')]);
        }
        if ($request->has('street_address') && !$request->has('address_details')) {
            $request->merge(['address_details' => $request->input('street_address')]);
        }
        if ($request->has('address') && !$request->has('address_details')) {
            $request->merge(['address_details' => $request->input('address')]);
        }
        if ($request->has('phone_number') && !$request->has('recipient_phone')) {
            $request->merge(['recipient_phone' => $request->input('phone_number')]);
        }
    }

    /**
     * Display a listing of the addresses for a user.
     */
    public function index(Request $request)
    {
        $userId = $this->resolveUserId($request, $request->query('user_id'));
        
        $query = UserAddress::query();
        if ($userId) {
            $query->where('user_id', $userId);
        } else {
            $phone = $request->query('phone') ?: $request->query('phone_number') ?: $request->query('recipient_phone');
            if ($phone) {
                $query->where('recipient_phone', $phone)->orWhere('phone_number', $phone);
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'User ID or Phone is required'
                ], 400);
            }
        }

        $addresses = $query->orderBy('is_default', 'desc')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $addresses
        ]);
    }

    /**
     * Store a newly created address.
     */
    public function store(Request $request)
    {
        $this->normalizeInput($request);
        
        $resolvedUserId = $this->resolveUserId($request, $request->input('user_id'));
        if ($resolvedUserId) {
            $request->merge(['user_id' => $resolvedUserId]);
        }

        $request->validate([
            'user_id' => 'nullable|exists:users,id',
            'title' => 'required|string',
            'recipient_name' => 'required|string',
            'recipient_phone' => 'required|string',
            'address_details' => 'required|string',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'is_default' => 'boolean',
        ]);

        $userId = $request->user_id;

        // If this is the first address or set as default, handle default status
        if ($request->is_default) {
            if ($userId) {
                UserAddress::where('user_id', $userId)->update(['is_default' => false]);
            }
        } else {
            // Check if user has any addresses, if not, make this one default
            $count = $userId ? UserAddress::where('user_id', $userId)->count() : 0;
            if ($count === 0) {
                $request->merge(['is_default' => true]);
            }
        }

        $addressData = [
            'user_id' => $userId,
            'title' => $request->title,
            'recipient_name' => $request->recipient_name,
            'recipient_phone' => $request->recipient_phone,
            'address_details' => $request->address_details,
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'is_default' => $request->is_default ?? false,
            'phone_number' => $request->recipient_phone, // Compatibility column
        ];

        $address = UserAddress::create($addressData);

        return response()->json([
            'success' => true,
            'message' => 'تم حفظ العنوان بنجاح',
            'data' => $address
        ]);
    }

    /**
     * Update the specified address.
     */
    public function update(Request $request, $id)
    {
        $address = UserAddress::findOrFail($id);
        
        $this->normalizeInput($request);
        
        $request->validate([
            'title' => 'nullable|string',
            'recipient_name' => 'nullable|string',
            'recipient_phone' => 'nullable|string',
            'address_details' => 'nullable|string',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'is_default' => 'boolean',
        ]);

        if ($request->has('is_default') && $request->is_default && !$address->is_default) {
            if ($address->user_id) {
                UserAddress::where('user_id', $address->user_id)->update(['is_default' => false]);
            }
        }

        $updateData = [];
        if ($request->has('title')) $updateData['title'] = $request->title;
        if ($request->has('recipient_name')) $updateData['recipient_name'] = $request->recipient_name;
        if ($request->has('recipient_phone')) {
            $updateData['recipient_phone'] = $request->recipient_phone;
            $updateData['phone_number'] = $request->recipient_phone;
        }
        if ($request->has('address_details')) $updateData['address_details'] = $request->address_details;
        if ($request->has('latitude')) $updateData['latitude'] = $request->latitude;
        if ($request->has('longitude')) $updateData['longitude'] = $request->longitude;
        if ($request->has('is_default')) $updateData['is_default'] = $request->is_default;

        $address->update($updateData);

        return response()->json([
            'success' => true,
            'message' => 'تم تحديث العنوان بنجاح',
            'data' => $address
        ]);
    }

    /**
     * Remove the specified address.
     */
    public function destroy($id)
    {
        $address = UserAddress::findOrFail($id);
        $userId = $address->user_id;
        $wasDefault = $address->is_default;

        $address->delete();

        // If we deleted the default address, make the most recent one default
        if ($wasDefault && $userId) {
            $latest = UserAddress::where('user_id', $userId)->latest()->first();
            if ($latest) {
                $latest->update(['is_default' => true]);
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'تم حذف العنوان بنجاح'
        ]);
    }

    /**
     * Set an address as default.
     */
    public function setDefault(Request $request, $id)
    {
        $address = UserAddress::findOrFail($id);
        
        if ($address->user_id) {
            UserAddress::where('user_id', $address->user_id)->update(['is_default' => false]);
        }
        $address->update(['is_default' => true]);

        return response()->json([
            'success' => true,
            'message' => 'تم تعيين العنوان كافتراضي بنجاح'
        ]);
    }
}
