<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ServiceBooking;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ServiceBookingController extends Controller
{
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'service_id' => 'required|exists:services,id',
            'customer_name' => 'required|string|max:255',
            'customer_phone' => 'required|string|max:20',
            'booking_date' => 'nullable|date',
            'notes' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'بيانات غير صالحة',
                'errors' => $validator->errors()
            ], 422);
        }

        $booking = ServiceBooking::create([
            'user_id' => auth('sanctum')->id(),
            'service_id' => $request->service_id,
            'customer_name' => $request->customer_name,
            'customer_phone' => $request->customer_phone,
            'booking_date' => $request->booking_date,
            'notes' => $request->notes,
            'status' => 'pending',
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'تم استلام طلب الحجز بنجاح، سنتواصل معك قريباً',
            'data' => $booking
        ], 201);
    }

    public function userBookings()
    {
        $bookings = ServiceBooking::where('user_id', auth('sanctum')->id())
            ->with('service')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'status' => 'success',
            'data' => $bookings
        ]);
    }
}
