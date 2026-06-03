import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/core/services/user_stats_service.dart';
import 'package:auto_lube/core/services/api_service.dart';

enum AuthViewState { selection, login, register }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  AuthViewState _viewState = AuthViewState.selection;
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // API base URL
  static const String _baseUrl = ApiService.baseUrl;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _toggleAuthMode() {
    _animationController.reverse().then((_) {
      setState(() {
        _viewState = _viewState == AuthViewState.login
            ? AuthViewState.register
            : AuthViewState.login;
      });
      _animationController.forward();
    });
  }

  // ==================== Validation ====================

  /// التحقق من رقم الهاتف العراقي (11 رقم يبدأ بـ 077/078/079/075)
  String? _validateIraqiPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال رقم الهاتف';
    }
    final clean = value.replaceAll(RegExp(r'[^\d]'), '');
    if (!clean.startsWith('077') &&
        !clean.startsWith('078') &&
        !clean.startsWith('079') &&
        !clean.startsWith('075')) {
      return 'رقم الهاتف يجب أن يبدأ بـ 077 أو 078 أو 079';
    }
    if (clean.length != 11) {
      return 'رقم الهاتف يجب أن يكون 11 رقم';
    }
    return null;
  }

  // ==================== Submit ====================

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      if (_viewState == AuthViewState.login) {
        await _login();
      } else {
        await _register();
      }
    } catch (e) {
      if (mounted) _showError('حدث خطأ غير متوقع: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ==================== Login ====================

  Future<void> _login() async {
    final cleanPhone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/account.php?action=login'),
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: json.encode({
              'phone': cleanPhone,
              'pin_code': _passwordController.text,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        await _saveSession(data['data']['user']);
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      } else {
        if (mounted) _showError(data['message'] ?? 'فشل تسجيل الدخول');
      }
    } on Exception catch (_) {
      if (mounted) {
        _showError('تعذر الاتصال بالسيرفر.\nتحقق من اتصالك بالإنترنت.');
      }
    }
  }

  // ==================== Register ====================

  Future<void> _register() async {
    final cleanPhone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/account.php?action=register'),
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: json.encode({
              'name': _nameController.text.trim(),
              'phone': cleanPhone,
              'pin_code': _passwordController.text,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        await _saveSession(data['data']['user']);
        if (mounted) Navigator.pushReplacementNamed(context, '/home');
      } else {
        if (mounted) _showError(data['message'] ?? 'فشل التسجيل');
      }
    } on Exception catch (_) {
      if (mounted) {
        _showError('تعذر الاتصال بالسيرفر.\nتحقق من اتصالك بالإنترنت.');
      }
    }
  }

  // ==================== Save Session (NO password stored) ====================

  /// يحفظ بيانات الجلسة فقط - بدون كلمة المرور أبداً
  Future<void> _saveSession(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    // بيانات الجلسة فقط (لا يوجد كلمة مرور)
    final sessionData = {
      'id': userData['id'].toString(),
      'name': userData['name'] ?? '',
      'phone': userData['phone'] ?? '',
      'email': userData['email'] ?? '',
      'avatar': userData['avatar'] ?? '',
      'is_admin': userData['is_admin'] ?? 0,
      'points': userData['points'] ?? 0,
      'level': userData['level'] ?? 'bronze',
      'level_name': userData['level_name'] ?? 'برونزي',
      'total_orders': userData['total_orders'] ?? 0,
      'total_spent': userData['total_spent'] ?? 0.0,
      'access_level': userData['access_level'] ?? 'basic',
    };

    // حفظ بيانات الجلسة (بدون كلمة مرور)
    await prefs.setString('current_user', json.encode(sessionData));
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('user_token', userData['token'] ?? '');
    await prefs.setInt('user_id', int.tryParse(userData['id'].toString()) ?? 0);

    // تحديث UserStatsService
    final userId = int.tryParse(userData['id'].toString()) ?? 0;
    await UserStatsService.setCurrentUserId(userId);
  }

  // ==================== Helpers ====================

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 14),
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ==================== Build ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background soft mesh gradients
          Positioned(
            top: -50,
            right: -30,
            child: _buildMeshBlob(
                const Color(0xFF007AFF).withOpacity(0.05), 250),
          ),
          Positioned(
            bottom: -50,
            left: -30,
            child: _buildMeshBlob(
                const Color(0xFF5856D6).withOpacity(0.03), 200),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildTopBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _viewState == AuthViewState.selection
                            ? _buildSelectionView()
                            : _buildFormView(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeshBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size / 2,
            spreadRadius: size / 4,
          ),
        ],
      ),
    );
  }

  Widget _buildAuthCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(32),
        border:
            Border.all(color: Colors.black.withOpacity(0.03), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildForm(),
          const SizedBox(height: 32),
          _buildSubmitButton(),
          const SizedBox(height: 24),
          _buildToggleButton(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_viewState != AuthViewState.selection)
            IconButton(
              onPressed: () {
                _animationController.reverse().then((_) {
                  setState(() => _viewState = AuthViewState.selection);
                  _animationController.forward();
                });
              },
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            )
          else
            const SizedBox(width: 48),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded, size: 20, color: AppColors.textPrimary.withOpacity(0.6)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionView() {
    return Column(
      children: [
        const SizedBox(height: 60),
        _buildHeader(),
        const SizedBox(height: 100),
        _buildChoiceButton(
          label: 'تسجيل الدخول',
          onPressed: () {
            _animationController.reverse().then((_) {
              setState(() => _viewState = AuthViewState.login);
              _animationController.forward();
            });
          },
          isPrimary: true,
          icon: Icons.login_rounded,
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 16),
        _buildChoiceButton(
          label: 'إنشاء حساب جديد',
          onPressed: () {
            _animationController.reverse().then((_) {
              setState(() => _viewState = AuthViewState.register);
              _animationController.forward();
            });
          },
          isPrimary: false,
          icon: Icons.person_add_rounded,
        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
        const SizedBox(height: 60),
      ],
    );
  }

  Widget _buildChoiceButton({
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
    required IconData icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? AppColors.primary : Colors.white,
          foregroundColor: isPrimary ? Colors.white : AppColors.primary,
          elevation: isPrimary ? 8 : 0,
          shadowColor: isPrimary ? AppColors.primary.withOpacity(0.3) : Colors.transparent,
          side: isPrimary ? BorderSide.none : BorderSide(color: AppColors.primary.withOpacity(0.2), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildHeader(),
        const SizedBox(height: 48),
        _buildAuthCard(),
      ],
    );
  }

  // ==================== Header ====================

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Image.asset(
            'IMG/logoapp.png',
            fit: BoxFit.contain,
          ),
        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 28),
        Text(
          'نوزل',
          style: GoogleFonts.cairo(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
        const SizedBox(height: 6),
        Text(
          _viewState == AuthViewState.register 
            ? 'انضم إلينا اليوم واحصل على مكافآت حصرية'
            : 'عالم نوزل يرحب بك مجدداً',
          style: GoogleFonts.cairo(
            fontSize: 15,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
      ],
    );
  }

  // ==================== Form ====================

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (_viewState == AuthViewState.register) ...[
            _buildNameField(),
            const SizedBox(height: 20)
          ],
          _buildPhoneField(),
          const SizedBox(height: 20),
          _buildPasswordField(),
          if (_viewState == AuthViewState.login) ...[
            const SizedBox(height: 16),
            _buildForgotPassword(),
          ],
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return _buildTextField(
      controller: _nameController,
      label: 'الاسم الكامل',
      prefixIcon: _iconBox(Icons.person_outline),
      keyboardType: TextInputType.name,
      validator: (v) {
        if (v == null || v.isEmpty) return 'الرجاء إدخال الاسم';
        if (v.length < 3) return 'الاسم يجب أن يكون 3 أحرف على الأقل';
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return _buildTextField(
      controller: _phoneController,
      label: 'رقم الهاتف',
      hintText: '07XXXXXXXXX',
      prefixIcon: _iconBoxWithText(Icons.phone_android, '+964'),
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
      validator: _validateIraqiPhone,
    );
  }

  Widget _buildPasswordField() {
    return _buildTextField(
      controller: _passwordController,
      label: 'كلمة المرور',
      hintText: '••••••',
      prefixIcon: _iconBox(Icons.lock_outline),
      obscureText: _obscurePassword,
      keyboardType: TextInputType.visiblePassword,
      suffixIcon: IconButton(
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        icon: Icon(
          _obscurePassword ? Icons.visibility_off : Icons.visibility,
          color: AppColors.textTertiary,
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'الرجاء إدخال كلمة المرور';
        if (v.length < 6) return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
        return null;
      },
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.primary, size: 20),
    );
  }

  Widget _iconBoxWithText(IconData icon, String text) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    Widget? prefixIcon,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? hintText,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: GoogleFonts.cairo(fontSize: 16, color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          labelStyle: GoogleFonts.cairo(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          hintStyle: GoogleFonts.cairo(
            fontSize: 14,
            color: AppColors.textTertiary,
          ),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          minimumSize: const Size(50, 30),
        ),
        child: Text(
          'نسيت كلمة المرور؟',
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ==================== Submit Button ====================

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          elevation: 8,
          shadowColor: AppColors.primary.withOpacity(0.3),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _viewState == AuthViewState.login ? 'تسجيل الدخول' : 'بدء الرحلة الآن',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    _viewState == AuthViewState.login
                        ? Icons.login_rounded
                        : Icons.rocket_launch_rounded,
                    size: 24,
                  ),
                ],
              ),
      ),
    );
  }

  // ==================== Toggle ====================

  Widget _buildToggleButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _viewState == AuthViewState.login ? 'ليس لديك حساب؟' : 'لديك حساب بالفعل؟',
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () {
            _animationController.reverse().then((_) {
              setState(() {
                _viewState = _viewState == AuthViewState.login 
                  ? AuthViewState.register 
                  : AuthViewState.login;
              });
              _animationController.forward();
            });
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Text(
            _viewState == AuthViewState.login ? 'سجل الآن' : 'ادخل لحسابك',
            style: GoogleFonts.cairo(
              fontSize: 15,
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
