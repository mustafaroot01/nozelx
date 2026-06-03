<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\UserAddress;
use Illuminate\Http\Request;

class AddressController extends Controller
{
    /**
     * Display a listing of the addresses for a user.
     */
    public function index(Request $request)
    {
        $userId = $request->query('user_id');
        
        if (!$userId) {
            return response()->json([
                'success' => false,
                'message' => 'User ID is required'
            ], 400);
        }

        $addresses = UserAddress::where('user_id', $userId)
            ->orderBy('is_default', 'desc')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'addresses' => $addresses
            ]
        ]);
    }

    /**
     * Store a newly created address.
     */
    public function store(Request $request)
    {
        $request->validate([
            'user_id' => 'required|exists:users,id',
            'label' => 'required|string',
            'full_name' => 'required|string',
            'phone' => 'required|string',
            'city' => 'required|string',
            'street_address' => 'required|string',
            'district' => 'nullable|string',
            'notes' => 'nullable|string',
            'is_default' => 'boolean',
        ]);

        // If this is the first address or set as default, handle default status
        if ($request->is_default) {
            UserAddress::where('user_id', $request->user_id)->update(['is_default' => false]);
        } else {
            // Check if user has any addresses, if not, make this one default
            $count = UserAddress::where('user_id', $request->user_id)->count();
            if ($count === 0) {
                $request->merge(['is_default' => true]);
            }
        }

        $address = UserAddress::create($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Address added successfully',
            'data' => [
                'address' => $address
            ]
        ]);
    }

    /**
     * Update the specified address.
     */
    public function update(Request $request, $id)
    {
        $address = UserAddress::findOrFail($id);
        
        $request->validate([
            'label' => 'string',
            'full_name' => 'string',
            'phone' => 'string',
            'city' => 'string',
            'street_address' => 'string',
            'district' => 'nullable|string',
            'notes' => 'nullable|string',
            'is_default' => 'boolean',
        ]);

        if ($request->has('is_default') && $request->is_default && !$address->is_default) {
            UserAddress::where('user_id', $address->user_id)->update(['is_default' => false]);
        }

        $address->update($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Address updated successfully',
            'data' => [
                'address' => $address
            ]
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
        if ($wasDefault) {
            $latest = UserAddress::where('user_id', $userId)->latest()->first();
            if ($latest) {
                $latest->update(['is_default' => true]);
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'Address deleted successfully'
        ]);
    }

    /**
     * Set an address as default.
     */
    public function setDefault(Request $request, $id)
    {
        $address = UserAddress::findOrFail($id);
        
        UserAddress::where('user_id', $address->user_id)->update(['is_default' => false]);
        $address->update(['is_default' => true]);

        return response()->json([
            'success' => true,
            'message' => 'Address set as default'
        ]);
    }
}
