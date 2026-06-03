import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_lube/providers/auth_provider.dart';
import 'package:auto_lube/providers/cart_provider.dart';
import 'package:auto_lube/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:auto_lube/core/config/api_config.dart';
import 'package:auto_lube/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:auto_lube/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().refreshStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50 (Very clean background)
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        title: Text(
          'حسابي الشخصي',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A), // Slate 900
          ),
        ),
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (_, auth, __) {
          final user = auth.user;
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2563EB),
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFF2563EB),
            onRefresh: auth.refreshStats,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // ── Floating Profile Card Header ──
                  _ProfileHeaderCard(user: user),
                  const SizedBox(height: 24),

                  // ── Menu Section Title ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'الخيارات والإعدادات',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF475569), // Slate 600
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Grouped Menu Card ──
                  _GroupedMenuCard(user: user),
                  const SizedBox(height: 24),

                  // ── Logout Button ──
                  _LogoutButtonCard(user: user),

                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom + 24,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── _ProfileHeaderCard ────────────────────────────────
class _ProfileHeaderCard extends StatelessWidget {
  final UserModel user;
  const _ProfileHeaderCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2563EB), // Royal Blue
            Color(0xFF1D4ED8), // Deep Blue
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        children: [
          // Avatar with Dual-ring border
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white24,
            ),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: SizedBox(
                width: 80,
                height: 80,
                child: ClipOval(
                  child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                      ? AppNetworkImage(
                          imageUrl: ApiConfig.img(user.avatarUrl!),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: const Color(0xFFEFF6FF), // Soft Blue
                          child: Center(
                            child: Text(
                              user.initials,
                              style: GoogleFonts.cairo(
                                color: const Color(0xFF2563EB),
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            user.name,
            style: GoogleFonts.cairo(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),

          // Phone badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🇮🇶', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 5),
                Text(
                  user.phone,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Member since
          Text(
            'عضو منذ ${_fmtDate(user.createdAt)}',
            style: GoogleFonts.cairo(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const m = [
      '',
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return '${m[d.month]} ${d.year}';
  }
}

// ── _GroupedMenuCard ─────────────────────────────────
class _GroupedMenuCard extends StatelessWidget {
  final UserModel user;
  const _GroupedMenuCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)), // Light Gray border
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _MenuTile(
            icon: Icons.favorite_rounded,
            iconColor: const Color(0xFFEF4444), // Rose Red
            iconBg: const Color(0xFFFEE2E2),
            title: 'المفضلة',
            subtitle: 'استعرض منتجاتك المحفوظة ومتابعتها',
            badge: user.stats.favoritesCount > 0 ? '${user.stats.favoritesCount}' : null,
            onTap: () => Navigator.pushNamed(context, '/favorites'),
            showDivider: true,
          ),
          _MenuTile(
            icon: Icons.calendar_month_rounded,
            iconColor: const Color(0xFF6366F1), // Indigo
            iconBg: const Color(0xFFE0E7FF),
            title: 'حجوزاتي ومواعيدي',
            subtitle: 'متابعة وتتبع طلبات الخدمات والحجوزات',
            badge: user.stats.serviceRequestsCount > 0 ? '${user.stats.serviceRequestsCount}' : null,
            onTap: () => Navigator.pushNamed(context, '/my-bookings'),
            showDivider: true,
          ),
          _MenuTile(
            icon: Icons.person_rounded,
            iconColor: const Color(0xFF3B82F6), // Sky Blue
            iconBg: const Color(0xFFDBEAFE),
            title: 'تعديل الملف الشخصي',
            subtitle: 'تحديث الاسم وتفاصيل الحساب الشخصي',
            onTap: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditProfileScreen()),
              );
              if (updated == true && context.mounted) {
                Provider.of<AuthProvider>(context, listen: false).refreshStats();
              }
            },
            showDivider: true,
          ),
          _MenuTile(
            icon: Icons.location_on_rounded,
            iconColor: const Color(0xFF10B981), // Emerald Green
            iconBg: const Color(0xFFD1FAE5),
            title: 'عناويني',
            subtitle: 'إدارة وتحديث عناوين التوصيل والخدمات',
            onTap: () => Navigator.pushNamed(context, '/addresses'),
            showDivider: true,
          ),
          _MenuTile(
            icon: Icons.info_rounded,
            iconColor: const Color(0xFFF59E0B), // Amber Orange
            iconBg: const Color(0xFFFEF3C7),
            title: 'عن التطبيق',
            subtitle: 'معلومات الإصدار والدعم الفني والخصوصية',
            onTap: () => _showAboutDialog(context),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        backgroundColor: Colors.white,
        title: Text(
          'عن التطبيق',
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF1D4ED8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.store_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'نوزل برو - تطبيق غسيل السيارات المتكامل',
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'الإصدار 1.0.0',
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text(
                'حسناً',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── _MenuTile ────────────────────────────────────────
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;
  final bool showDivider;

  const _MenuTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.badge,
    required this.onTap,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon Background
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A), // Slate 900
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: const Color(0xFF64748B), // Slate 500
                        ),
                      ),
                    ],
                  ),
                ),

                // Badge (like favorites count)
                if (badge != null && badge != '0' && badge != '') ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge!,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Chevron icon
                const Icon(
                  Icons.chevron_left_rounded,
                  size: 22,
                  color: Color(0xFF94A3B8), // Slate 400
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.only(right: 74, left: 16),
            child: Divider(
              height: 1,
              color: Color(0xFFF1F5F9),
            ),
          ),
      ],
    );
  }
}

// ── _LogoutButtonCard ─────────────────────────────────
class _LogoutButtonCard extends StatelessWidget {
  final UserModel user;
  const _LogoutButtonCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFEE2E2)), // Light red border
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withOpacity(0.02),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showLogoutConfirm(context),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.power_settings_new_rounded, // Modern logout icon
                  color: Color(0xFFEF4444),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'تسجيل الخروج من الحساب',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.power_settings_new_rounded,
                color: Color(0xFFEF4444),
                size: 26,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'تسجيل الخروج',
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'هل أنت متأكد من رغبتك في تسجيل الخروج يا ${user.name}؟',
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(sheetContext);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(
                        color: Color(0xFFCBD5E1),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'إلغاء',
                      style: GoogleFonts.cairo(
                        color: const Color(0xFF475569),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      Navigator.pop(sheetContext);
                      
                      final authProv = context.read<AuthProvider>();
                      await authProv.logout();
                      
                      if (context.mounted) {
                        context.read<CartProvider>().clearForLogout();
                        context.read<FavoritesProvider>().clearForLogout();
                        
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (_) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'تسجيل الخروج',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade200,
          child: Icon(Icons.error_outline_rounded, color: Colors.grey.shade400),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey.shade100,
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }
}
