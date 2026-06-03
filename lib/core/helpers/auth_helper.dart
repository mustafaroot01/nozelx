import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto_lube/providers/auth_provider.dart';

/// Helper class for authentication checks before performing actions
class AuthHelper {
  /// Check if user is logged in
  /// Returns true if user is logged in, false otherwise
  static Future<bool> checkAuth(BuildContext context) async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      return auth.isLoggedIn;
    } catch (e) {
      debugPrint('Error checking auth: $e');
      return false;
    }
  }

  /// Check auth and redirect to login screen if not logged in
  /// Returns true if user is logged in, false otherwise
  static Future<bool> checkAuthAndProceed(BuildContext context) async {
    final isLoggedIn = await checkAuth(context);

    if (!isLoggedIn) {
      if (context.mounted) {
        Navigator.pushNamed(context, '/login');
      }
      return false;
    }

    return true;
  }

  /// Check auth and execute callback if logged in, otherwise redirect to login screen
  /// Use this for actions that require authentication
  static Future<void> requireAuth(
    BuildContext context, {
    required Future<void> Function() onAuthSuccess,
    VoidCallback? onAuthFail,
  }) async {
    final isLoggedIn = await checkAuth(context);

    if (!isLoggedIn) {
      if (context.mounted) {
        Navigator.pushNamed(context, '/login');
        onAuthFail?.call();
      }
    } else {
      await onAuthSuccess();
    }
  }
}
