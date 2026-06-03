import 'package:flutter/material.dart';
import 'package:auto_lube/providers/auth_provider.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_lube/core/config/api_config.dart';
import 'package:auto_lube/core/widgets/app_network_image.dart';
import 'package:auto_lube/features/profile/data/services/account_service.dart';
import 'package:auto_lube/repositories/service_repository.dart';
import 'package:auto_lube/core/services/user_stats_service.dart';
import 'package:auto_lube/features/auth/data/models/user_model.dart';

class AuthUser {
  final String name;
  final String? phone;
  final String? avatarUrl;

  AuthUser({
    required this.name,
    this.phone,
    this.avatarUrl,
  });
}

class UserStats {
  final int ordersCount;
  final int serviceRequestsCount;
  final int favoritesCount;

  UserStats({
    required this.ordersCount,
    required this.serviceRequestsCount,
    required this.favoritesCount,
  });
}

class ProfileDataProvider extends ChangeNotifier {
  AuthUser? _currentUser;
  UserStats? _userStats;
  bool _isLoading = true;

  AuthUser? get currentUser => _currentUser;
  UserStats? get userStats => _userStats;
  bool get isLoading => _isLoading;

  ProfileDataProvider() {
    loadData();
  }

  Future<void> loadData() async {
    try {
      final userResult = await AccountService.getProfile();
      UserModel? user;
      if (userResult.isSuccess) {
        user = userResult.getOrNull();
      } else {
        user = await AccountService.getCurrentUser();
      }

      if (user != null) {
        _currentUser = AuthUser(
          name: user.name,
          phone: user.phoneNumber,
          avatarUrl: user.profileImage,
        );

        final ordersList = await AccountService.getOrders();
        final ordersCount = ordersList.length;

        final serviceRepo = ServiceRepository();
        final requests = await serviceRepo.getMyRequests(user.phoneNumber);
        final serviceRequestsCount = requests.length;

        final favsCount = await UserStatsService.getFavoritesCount();

        _userStats = UserStats(
          ordersCount: ordersCount,
          serviceRequestsCount: serviceRequestsCount,
          favoritesCount: favsCount,
        );
      }
    } catch (e) {
      debugPrint('Error loading ProfileDataProvider data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await AccountService.clearUser();
      _currentUser = null;
      _userStats = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ProfileDataProvider>(
      create: (_) => ProfileDataProvider(),
      child: Scaffold(
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
        body: Consumer<ProfileDataProvider>(
          builder: (context, authProvider, child) {
            if (authProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF2563EB),
                ),
              );
            }

            return FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: RefreshIndicator(
                  color: const Color(0xFF2563EB),
                  onRefresh: () => authProvider.loadData(),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // ── Floating Profile Card Header ──
                        _ProfileHeaderCard(),
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
                        _GroupedMenuCard(),
                        const SizedBox(height: 24),

                        // ── Logout Button ──
                        _LogoutButtonCard(),

                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── _ProfileHeaderCard ────────────────────────────────
class _ProfileHeaderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileDataProvider>(
      builder: (_, auth, __) {
        final user = auth.currentUser;
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
                      child: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                          ? AppNetworkImage(
                              imageUrl: ApiConfig.img(user.avatarUrl),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: const Color(0xFFEFF6FF), // Soft Blue
                              child: Center(
                                child: Text(
                                  _initials(user?.name ?? 'م'),
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
                user?.name ?? 'مستخدم نوزل',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),

              // Phone badge
              if (user?.phone != null && user!.phone!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.phone_iphone_rounded,
                        color: Colors.white,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.phone!,
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'م';
  }
}

// ── _GroupedMenuCard ─────────────────────────────────
class _GroupedMenuCard extends StatelessWidget {
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
            onTap: () => Navigator.pushNamed(context, '/favorites'),
            showDivider: true,
          ),
          _MenuTile(
            icon: Icons.person_rounded,
            iconColor: const Color(0xFF3B82F6), // Sky Blue
            iconBg: const Color(0xFFDBEAFE),
            title: 'تعديل الملف الشخصي',
            subtitle: 'تحديث الاسم وتفاصيل الحساب الشخصي',
            onTap: () async {
              final updated = await Navigator.pushNamed(context, '/edit-profile');
              if (updated == true && context.mounted) {
                Provider.of<ProfileDataProvider>(context, listen: false).loadData();
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
  final VoidCallback onTap;
  final bool showDivider;

  const _MenuTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
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
              'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: const Color(0xFF64748B),
              ),
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
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(sheetContext);
                      context.read<AuthProvider>().logout(context);
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (_) => false,
                      );
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
