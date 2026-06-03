<?php

use App\Http\Controllers\Api\BannerController;
use App\Http\Controllers\Api\BrandController;
use App\Http\Controllers\Api\CategoryBannerController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\CouponController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\OTPController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\ProductTagController;
use App\Http\Controllers\Api\SpecialOfferController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::post('/verify_phone', [OTPController::class, 'handle']);

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

// Categories
Route::get('/categories', [CategoryController::class, 'index']);

// Products
Route::get('/products', [ProductController::class, 'index']);
Route::get('/brands', [BrandController::class, 'index']); // New
Route::get('/products/tags', [ProductTagController::class, 'index']); // New
Route::get('/products/{product}', [ProductController::class, 'show']);
Route::get('/categories/{category}/products', [ProductController::class, 'byCategory']);

// Banners
Route::get('/banners', [BannerController::class, 'index']);
Route::get('/category-banners', [CategoryBannerController::class, 'index']); // New

// Special Offers
Route::get('/special-offers', [SpecialOfferController::class, 'index']); // New

// Coupons
Route::get('/coupons/validate', [CouponController::class, 'validateCoupon']); // New

// Orders
Route::get('/orders', [OrderController::class, 'index']);
Route::post('/orders', [OrderController::class, 'store']);
Route::get('/orders/{order}', [OrderController::class, 'show']);
Route::put('/orders/{order}', [OrderController::class, 'update']);
Route::patch('/orders/{order}', [OrderController::class, 'update']);

// Favorites
Route::get('/favorites', [\App\Http\Controllers\FavoriteController::class, 'index']);
Route::post('/favorites', [\App\Http\Controllers\FavoriteController::class, 'store']);
Route::delete('/favorites', [\App\Http\Controllers\FavoriteController::class, 'destroy']);
Route::get('/favorites/check', [\App\Http\Controllers\FavoriteController::class, 'check']);

// Addresses
Route::get('/addresses', [App\Http\Controllers\Api\AddressController::class, 'index']);
Route::post('/addresses', [App\Http\Controllers\Api\AddressController::class, 'store']);
Route::put('/addresses/{id}', [App\Http\Controllers\Api\AddressController::class, 'update']);
Route::delete('/addresses/{id}', [App\Http\Controllers\Api\AddressController::class, 'destroy']);
Route::post('/addresses/{id}/set-default', [App\Http\Controllers\Api\AddressController::class, 'setDefault']);

// Services
Route::get('/services', [\App\Http\Controllers\Api\ServiceController::class, 'index']);
Route::get('/services/{id}', [\App\Http\Controllers\Api\ServiceController::class, 'show']);

// Service Bookings
Route::post('/services/book', [\App\Http\Controllers\Api\ServiceBookingController::class, 'store']);
Route::get('/services/my-bookings', [\App\Http\Controllers\Api\ServiceBookingController::class, 'userBookings']);

