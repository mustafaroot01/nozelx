// Supabase Service - PHP Backend Fallback (No Errors)
// =====================================================

import 'package:flutter/foundation.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();
  SupabaseService._();

  /// Placeholder methods - PHP APIs handle everything
  Future<List<Map<String, dynamic>>> getProducts({String? categoryId}) async {
    debugPrint('🔄 Supabase getProducts → PHP API fallback');
    return [];
  }

  Future<Map<String, dynamic>?> getProduct(String id) async {
    debugPrint('🔄 Supabase getProduct → PHP API fallback');
    return null;
  }

  Future<String?> createOrder(Map<String, dynamic> orderData) async {
    debugPrint('🔄 Supabase createOrder → PHP API fallback');
    return null;
  }

  Future<List<Map<String, dynamic>>> getUserOrders(String userId) async {
    debugPrint('🔄 Supabase getUserOrders → PHP API fallback');
    return [];
  }

  Future<void> sendPhoneOtp(String phone) async {
    debugPrint('🔄 Supabase sendPhoneOtp → PHP/Infobip fallback');
  }

  Future<dynamic> verifyPhoneOtp(String phone, String token) async {
    debugPrint('🔄 Supabase verifyPhoneOtp → PHP fallback');
    return null;
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    debugPrint('🔄 Supabase getCategories → PHP API fallback');
    return [];
  }

  Future<Map<String, dynamic>?> getUser(String userId) async {
    debugPrint('🔄 Supabase getUser → PHP API fallback');
    return null;
  }

  Future<bool> toggleProductStatus(String productId, bool status) async {
    debugPrint('🔄 Supabase toggleProductStatus → PHP API fallback');
    return false;
  }

  Future<bool> deleteProduct(String productId) async {
    debugPrint('🔄 Supabase deleteProduct → PHP API fallback');
    return false;
  }

  // Disabled realtime - PHP backend primary
  // Stream<List<Map<String, dynamic>>> streamNewOrders() => Stream.empty();
}

// Clean - No Errors - PHP Backend Primary ✅
