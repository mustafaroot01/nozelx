import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/core/theme/dark_colors.dart';
import 'package:auto_lube/core/theme/dimensions.dart';
import 'package:auto_lube/core/theme/theme_controller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_lube/features/profile/data/services/account_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  ThemeModeOption _selectedThemeMode = ThemeModeOption.dark;

  final List<Map<String, dynamic>> settingsItems = [
    {
      'title': 'الحساب',
      'items': [
        {
          'icon': Icons.person,
          'title': 'معلومات الحساب',
          'subtitle': 'الاسم، البريد، الجوال',
        },
        {
          'icon': Icons.lock,
          'title': 'كلمة المرور',
          'subtitle': 'تغيير كلمة المرور',
        },
        {
          'icon': Icons.security,
          'title': 'الخصوصية',
          'subtitle': 'إدارة بياناتك',
        },
      ],
    },
    {
      'title': 'التطبيق',
      'items': [
        {
          'icon': Icons.notifications,
          'title': 'الإشعارات',
          'subtitle': 'إدارة الإشعارات',
          'hasSwitch': true,
        },
        {
          'icon': Icons.language,
          'title': 'اللغة',
          'subtitle': 'العربية',
          'hasSwitch': false,
        },
      ],
    },
    {
      'title': 'الدعم',
      'items': [
        {
          'icon': Icons.help_outline,
          'title': 'المساعدة',
          'subtitle': 'الأسئلة الشائعة والدعم',
        },
        {
          'icon': Icons.info,
          'title': 'عن التطبيق',
          'subtitle': 'الإصدار 1.0.0',
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final themeController = Provider.of<ThemeController>(
      context,
      listen: false,
    );
    await themeController.initialize();
    if (mounted) {
      setState(() {
        _selectedThemeMode = themeController.themeMode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode
          ? DarkAppColors.background
          : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? DarkAppColors.surface : AppColors.surface,
        elevation: 0,
        leading: BackButton(
          onPressed: () => Navigator.of(context).pop(),
          color: isDarkMode ? DarkAppColors.textPrimary : AppColors.textPrimary,
        ),
        title: Text(
          'الإعدادات',
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode
                ? DarkAppColors.textPrimary
                : AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Section with beautiful selection
            _buildThemeSection(themeController),

            // Settings sections
            ...settingsItems.map((section) {
              return _buildSettingsSection(section, isDarkMode);
            }),
          ],
        ),
      ),

      // Logout Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? DarkAppColors.surface : AppColors.surface,
          border: Border(
            top: BorderSide(
              color: isDarkMode ? DarkAppColors.divider : AppColors.divider,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: AppDimensions.buttonHeight,
            child: OutlinedButton(
              onPressed: () async {
                await AccountService.clearUser();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: isDarkMode
                    ? DarkAppColors.error
                    : AppColors.error,
                side: BorderSide(
                  color: isDarkMode ? DarkAppColors.error : AppColors.error,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.buttonBorderRadius,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout),
                  const SizedBox(width: 8),
                  Text(
                    'تسجيل خروج',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSection(ThemeController themeController) {
    final isDarkMode = themeController.isDarkMode;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    DarkAppColors.surfaceVariant.withOpacity(0.5),
                    DarkAppColors.surface,
                  ]
                : [
                    AppColors.surfaceVariant.withOpacity(0.5),
                    AppColors.surface,
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDarkMode ? DarkAppColors.border : AppColors.border,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDarkMode
                            ? [
                                DarkAppColors.primary,
                                DarkAppColors.primaryLight,
                              ]
                            : [AppColors.primary, AppColors.primaryLight],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isDarkMode ? Icons.dark_mode : Icons.light_mode,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'المظهر',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode
                                ? DarkAppColors.textPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getThemeModeText(_selectedThemeMode),
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: isDarkMode
                                ? DarkAppColors.textSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Theme Options with smooth selection
              _buildThemeOption(
                icon: Icons.brightness_auto,
                title: 'تابع النظام',
                subtitle: 'يتوافق مع إعدادات هاتفك',
                isSelected: _selectedThemeMode == ThemeModeOption.system,
                themeMode: ThemeModeOption.system,
                themeController: themeController,
              ),

              const SizedBox(height: 12),

              _buildThemeOption(
                icon: Icons.light_mode,
                title: 'المظهر الفاتح',
                subtitle: 'ألوان زاهية ومريحة للعين',
                isSelected: _selectedThemeMode == ThemeModeOption.light,
                themeMode: ThemeModeOption.light,
                themeController: themeController,
              ),

              const SizedBox(height: 12),

              _buildThemeOption(
                icon: Icons.dark_mode,
                title: 'المظهر الداكن',
                subtitle: 'مثالي للاستخدام الليلي',
                isSelected: _selectedThemeMode == ThemeModeOption.dark,
                themeMode: ThemeModeOption.dark,
                themeController: themeController,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required ThemeModeOption themeMode,
    required ThemeController themeController,
  }) {
    final isDarkMode = themeController.isDarkMode;

    return GestureDetector(
      onTap: () async {
        await themeController.setThemeMode(themeMode);
        setState(() {
          _selectedThemeMode = themeMode;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode
                    ? DarkAppColors.primary.withOpacity(0.15)
                    : AppColors.primary.withOpacity(0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? (isDarkMode ? DarkAppColors.primary : AppColors.primary)
                : (isDarkMode ? DarkAppColors.border : AppColors.border),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color:
                      (isDarkMode
                              ? DarkAppColors.surfaceVariant
                              : AppColors.surfaceVariant)
                          .withValues(alpha: isSelected ? 0.3 : 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? (isDarkMode ? DarkAppColors.primary : AppColors.primary)
                      : (isDarkMode
                            ? DarkAppColors.textSecondary
                            : AppColors.textSecondary),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: isDarkMode
                            ? DarkAppColors.textPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: isDarkMode
                            ? DarkAppColors.textTertiary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDarkMode
                          ? [DarkAppColors.primary, DarkAppColors.primaryLight]
                          : [AppColors.primary, AppColors.primaryLight],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getThemeModeText(ThemeModeOption mode) {
    switch (mode) {
      case ThemeModeOption.system:
        return 'تابع إعدادات النظام';
      case ThemeModeOption.light:
        return 'المظهر الفاتح';
      case ThemeModeOption.dark:
        return 'المظهر الداكن';
    }
  }

  Widget _buildSettingsSection(Map<String, dynamic> section, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text(
            section['title'] as String,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? DarkAppColors.primary : AppColors.primary,
            ),
          ),
        ),

        // Items
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDarkMode ? DarkAppColors.surface : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDarkMode ? DarkAppColors.border : AppColors.border,
            ),
          ),
          child: Column(
            children: (section['items'] as List).asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value as Map<String, dynamic>;
              final isLast = index == (section['items'] as List).length - 1;

              return Column(
                children: [
                  _buildSettingsItem(item, isDarkMode),
                  if (!isLast)
                    Padding(
                      padding: const EdgeInsets.only(left: 56),
                      child: Container(
                        height: 1,
                        color: isDarkMode
                            ? DarkAppColors.divider
                            : AppColors.divider,
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(Map<String, dynamic> item, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _getIconColor(
                item['icon'] as IconData,
              ).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item['icon'] as IconData,
              color: _getIconColor(item['icon'] as IconData),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] as String,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode
                        ? DarkAppColors.textPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item['subtitle'] as String,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: isDarkMode
                        ? DarkAppColors.textSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (item['hasSwitch'] as bool? ?? false)
            _buildCustomSwitch(isDarkMode, item['title'] as String)
          else
            Icon(
              Icons.arrow_forward_ios,
              color: isDarkMode
                  ? DarkAppColors.textTertiary
                  : AppColors.textTertiary,
              size: 16,
            ),
        ],
      ),
    );
  }

  Widget _buildCustomSwitch(bool isDarkMode, String title) {
    bool value = false;
    switch (title) {
      case 'الإشعارات':
        value = notificationsEnabled;
        break;
      case 'الوضع الداكن':
        value = _selectedThemeMode == ThemeModeOption.dark;
        break;
      default:
        value = false;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (title == 'الإشعارات') {
            notificationsEnabled = !notificationsEnabled;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: value
              ? (isDarkMode ? DarkAppColors.primary : AppColors.primary)
              : (isDarkMode
                    ? DarkAppColors.surfaceVariant
                    : AppColors.surfaceVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 200),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getIconColor(IconData icon) {
    switch (icon) {
      case Icons.person:
        return AppColors.primary;
      case Icons.lock:
        return AppColors.warning;
      case Icons.security:
        return AppColors.success;
      case Icons.notifications:
        return AppColors.info;
      case Icons.language:
        return AppColors.tertiary;
      case Icons.help_outline:
        return AppColors.primary;
      case Icons.info:
        return AppColors.textSecondary;
      case Icons.rate_review:
        return AppColors.ratingStar;
      default:
        return AppColors.primary;
    }
  }
}
