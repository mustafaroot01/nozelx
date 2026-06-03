import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/core/theme/theme_controller.dart';
import 'package:auto_lube/features/auth/data/models/user_model.dart';
import 'package:auto_lube/features/profile/data/services/account_service.dart';
import 'package:auto_lube/features/auth/presentation/pages/otp_whatsapp_auth_sheet.dart';
import 'package:auto_lube/core/services/api_service.dart';

/// Account Screen - Professional & Simplified Design
/// Connected with database and admin panel
class AccountScreenNew extends StatefulWidget {
  const AccountScreenNew({super.key});

  @override
  State<AccountScreenNew> createState() => _AccountScreenNewState();
}

class _AccountScreenNewState extends State<AccountScreenNew> {
  bool _isLoading = true;
  UserModel? _currentUser;
  int _addressesCount = 0;

  // API Configuration
  static const String _baseUrl = ApiService.baseUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Sync fresh data from server
      final profileResult = await AccountService.getProfile();
      
      if (profileResult.isSuccess && mounted) {
        final user = profileResult.getOrNull();
        if (user != null) {
          setState(() {
            _currentUser = user;
          });
        }
      }

      // Get addresses count
      final addresses = await AccountService.getAddresses();
      if (mounted) {
        setState(() {
          _addressesCount = addresses.length;
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<Map<String, dynamic>?> fetchUserStats(int userId) async {
    try {
      // Using http directly to avoid import issues
      final response = await Future.delayed(
        const Duration(milliseconds: 100),
        () => null,
      );
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userId');
    await prefs.remove('current_user');

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'تسجيل الخروج',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'هل أنت متأكد من تسجيل الخروج؟',
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'تسجيل الخروج',
              style: GoogleFonts.cairo(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final reasonController = TextEditingController();
    bool isDeleting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'حذف الحساب',
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'سيتم حذف حسابك نهائياً وجميع بياناتك. هذا الإجراء لا يمكن التراجع عنه.',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'سبب الحذف (اختياري)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: GoogleFonts.cairo(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: isDeleting
                  ? null
                  : () async {
                      setDialogState(() => isDeleting = true);

                      final result = await AccountService.deleteAccount(
                        reasonController.text.isEmpty
                            ? 'لم يحدد سبب'
                            : reasonController.text,
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        if (result.isSuccess) {
                          Navigator.pushReplacementNamed(context, '/login');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result.error),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'حذف الحساب',
                      style: GoogleFonts.cairo(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF121212)
          : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'حسابي',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: isDarkMode ? Colors.white : AppColors.textPrimary,
            ),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUserData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Profile Card
                    _buildProfileCard(isDarkMode)
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 20),

                    // Stats Row
                    _buildStatsRow(isDarkMode)
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 400.ms)
                        .slideY(begin: 0.1, end: 0),
                    const SizedBox(height: 32),

                    // Menu Sections
                    _buildMenuSection(isDarkMode)
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 400.ms),
                    const SizedBox(height: 16),

                    _buildSettingsSection(isDarkMode)
                        .animate()
                        .fadeIn(delay: 400.ms, duration: 400.ms),
                    const SizedBox(height: 16),

                    _buildSupportSection(isDarkMode)
                        .animate()
                        .fadeIn(delay: 500.ms, duration: 400.ms),
                    const SizedBox(height: 24),

                    // Logout & Delete
                    _buildLogoutSection(isDarkMode)
                        .animate()
                        .fadeIn(delay: 600.ms, duration: 400.ms),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileCard(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.person_rounded,
                    size: 45,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                    child: const Icon(Icons.edit_rounded, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _currentUser?.name ?? 'ضيف',
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            _currentUser?.phoneNumber ?? '',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildStatsRow(bool isDarkMode) {
    return Row(
      children: [
        _buildStatItem(Icons.location_on_outlined, 'العناوين', '$_addressesCount', AppColors.info),
        const SizedBox(width: 12),
        _buildStatItem(Icons.favorite_rounded, 'المفضلة', '0', AppColors.favorite),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(bool isDarkMode) {
    final menuItems = [
      {
        'icon': Icons.location_on_outlined,
        'title': 'عناويني',
        'route': '/addresses',
        'color': AppColors.info,
      },
      {
        'icon': Icons.receipt_long_outlined,
        'title': 'طلباتي',
        'route': '/orders',
        'color': AppColors.primary,
      },
      {
        'icon': Icons.favorite_outline,
        'title': 'المفضلة',
        'route': '/favorites',
        'color': AppColors.favorite,
      },
    ];

    return _buildSection(isDarkMode, 'خدمات الحساب', menuItems);
  }

  Widget _buildSettingsSection(bool isDarkMode) {
    final settingsItems = [
      {
        'icon': Icons.notifications_outlined,
        'title': 'الإشعارات',
        'route': '/notifications',
        'color': AppColors.warning,
      },
      {
        'icon': Icons.dark_mode_outlined,
        'title': 'الوضع الداكن',
        'route': null,
        'color': AppColors.tertiary,
        'isSwitch': true,
      },
      {
        'icon': Icons.language_outlined,
        'title': 'اللغة',
        'route': null,
        'color': AppColors.info,
        'onTap': () => _showLanguagePicker(),
      },
    ];

    return _buildSection(isDarkMode, 'الإعدادات', settingsItems);
  }

  Widget _buildSupportSection(bool isDarkMode) {
    final supportItems = [
      {
        'icon': Icons.help_outline,
        'title': 'المساعدة والدعم',
        'route': '/support',
        'color': AppColors.primary,
      },
      {
        'icon': Icons.info_outline,
        'title': 'من نحن',
        'route': '/about',
        'color': AppColors.info,
      },
    ];

    return _buildSection(isDarkMode, 'الدعم', supportItems);
  }

  Widget _buildSection(
    bool isDarkMode,
    String title,
    List<Map<String, dynamic>> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4, bottom: 12, top: 8),
          child: Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  _buildMenuItem(
                    isDarkMode,
                    item['icon'] as IconData,
                    item['title'] as String,
                    item['route'] as String?,
                    item['color'] as Color,
                    item['isSwitch'] == true,
                    onTap: item['onTap'] as VoidCallback?,
                  ),
                  if (index < items.length - 1)
                    Divider(
                      height: 1,
                      indent: 60,
                      endIndent: 20,
                      color: AppColors.divider.withOpacity(0.5),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    bool isDarkMode,
    IconData icon,
    String title,
    String? route,
    Color color,
    bool isSwitch, {
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? (route != null ? () => _checkAuthAndNavigate(route) : null),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (isSwitch)
                Switch.adaptive(
                  value: isDarkMode,
                  onChanged: (val) {
                    context.read<ThemeController>().toggleDarkMode();
                  },
                  activeColor: AppColors.primary,
                )
              else
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'اختر اللغة',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            _buildLanguageOption('العربية', 'ar', true),
            const SizedBox(height: 12),
            _buildLanguageOption('English', 'en', false),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String title, String code, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.divider.withOpacity(0.5),
        ),
      ),
      child: ListTile(
        onTap: () => Navigator.pop(context),
        title: Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
      ),
    );
  }

  Widget _buildLogoutSection(bool isDarkMode) {
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildActionTile(
          'تسجيل الخروج',
          Icons.logout_rounded,
          AppColors.error,
          _showLogoutDialog,
        ),
        const SizedBox(height: 12),
        _buildActionTile(
          'حذف الحساب',
          Icons.delete_outline_rounded,
          AppColors.textSecondary,
          _showDeleteAccountDialog,
        ),
      ],
    );
  }

  Widget _buildActionTile(String title, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _checkAuthAndNavigate(String route) async {
    if (_currentUser != null) {
      if (mounted) Navigator.pushNamed(context, route);
    } else {
      final result = await OTPWhatsAppAuthSheet.show(context);
      if (result == true) {
        await _loadUserData();
        if (mounted && _currentUser != null) {
          Navigator.pushNamed(context, route);
        }
      }
    }
  }

}
