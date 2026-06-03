import 'package:flutter/material.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/features/profile/data/services/account_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final fetched = await AccountService.getNotifications();
      setState(() {
        _notifications = fetched;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        title: Text(
          'الإشعارات',
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.done_all, color: AppColors.primary),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) => _buildNotificationCard(_notifications[index], index),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none_rounded, size: 60, color: AppColors.warning),
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد إشعارات',
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ستظهر هنا آخر التحديثات والعروض',
            style: GoogleFonts.cairo(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    final type = notification['type']?.toString().toLowerCase() ?? 'system';
    IconData icon;
    Color color;

    switch (type) {
      case 'order':
        icon = Icons.shopping_bag_outlined;
        color = AppColors.primary;
        break;
      case 'promo':
        icon = Icons.local_offer_outlined;
        color = AppColors.success;
        break;
      case 'alert':
        icon = Icons.info_outline;
        color = AppColors.error;
        break;
      default:
        icon = Icons.notifications_none_rounded;
        color = AppColors.warning;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          notification['title'] ?? 'إشعار جديد',
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification['message'] ?? '',
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              notification['created_at'] ?? '',
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        onTap: () {},
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
  }
}
