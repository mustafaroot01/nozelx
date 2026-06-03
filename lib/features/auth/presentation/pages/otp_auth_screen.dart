import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:auto_lube/core/services/api_service.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/core/services/user_stats_service.dart';

/// OTP Auth Screen - نظام تسجيل متكامل مع التحقق من الواتساب
class OTPAuthScreen extends StatefulWidget {
  const OTPAuthScreen({super.key});

  @override
  State<OTPAuthScreen> createState() => _OTPAuthScreenState();
}

class _OTPAuthScreenState extends State<OTPAuthScreen>
    with SingleTickerProviderStateMixin {
  // Auth States
  AuthStep _currentStep = AuthStep.phoneEntry;

  // Controllers
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  // Form Key
  final _formKey = GlobalKey<FormState>();

  // Loading States
  bool _isLoading = false;
  String _errorMessage = '';

  // Timer for OTP resend
  int _resendTimer = 0;
  bool _canResend = true;

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // API
  static const String _baseUrl = ApiService.baseUrl;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _animateToStep(AuthStep step) {
    _animationController.reverse().then((_) {
      setState(() {
        _currentStep = step;
        _errorMessage = '';
      });
      _animationController.forward();
    });
  }

  // Validate Iraqi Phone
  String? _validateIraqiPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال رقم الهاتف';
    }
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    if (!cleanPhone.startsWith('077') &&
        !cleanPhone.startsWith('078') &&
        !cleanPhone.startsWith('079') &&
        !cleanPhone.startsWith('075')) {
      return 'رقم الهاتف يجب أن يبدأ بـ 077 أو 078 أو 079';
    }
    if (cleanPhone.length != 11) {
      return 'رقم الهاتف يجب أن يكون 11 رقم';
    }
    return null;
  }

  // Request OTP
  Future<void> _requestOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final cleanPhone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/v1/auth/request-otp'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'phone': cleanPhone}),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        // For demo, show OTP in console
        if (data['data'] != null && data['data']['demo_mode'] == true) {
          debugPrint('🔐 OTP Code: ${data['data']['otp']}');
        }

        setState(() {
          _currentStep = AuthStep.otpVerification;
        });

        _startResendTimer();
      } else {
        setState(() {
          _errorMessage = data['message'] ?? 'فشل إرسال رمز التحقق';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ في الاتصال، يرجى المحاولة مرة أخرى';
      });
    }

    setState(() => _isLoading = false);
  }

  // Verify OTP
  Future<void> _verifyOTP() async {
    final otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      setState(() => _errorMessage = 'يرجى إدخال الرمز الكامل');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final cleanPhone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/v1/auth/verify-otp'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'phone': cleanPhone, 'otp': otp}),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        final authData = data['data'];
        final userData = authData['user'];
        userData['token'] = authData['access_token'];
        
        await _saveSessionAndNavigate(userData);
      } else {
        setState(() {
          _errorMessage = data['message'] ?? 'رمز التحقق غير صحيح';
        });
        _clearOTPFields();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ في الاتصال: $e';
      });
    }

    setState(() => _isLoading = false);
  }

  // Register
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final cleanPhone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');

      final response = await http
          .post(
            Uri.parse(
              '$_baseUrl/verify_phone.php?action=complete_registration',
            ),
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: json.encode({
              'phone': cleanPhone,
              'name': _nameController.text.trim(),
              'password': _passwordController.text,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        await _saveSessionAndNavigate(data['data']['user']);
      } else {
        setState(() => _errorMessage = data['message'] ?? 'فشل التسجيل');
      }
    } catch (_) {
      setState(
        () =>
            _errorMessage = 'تعذر الاتصال بالسيرفر. تحقق من اتصالك بالإنترنت.',
      );
    }

    setState(() => _isLoading = false);
  }

  // Login
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final cleanPhone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/verify_phone.php?action=login_with_otp'),
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: json.encode({
              'phone': cleanPhone,
              'password': _passwordController.text,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        await _saveSessionAndNavigate(data['data']['user']);
      } else {
        setState(() => _errorMessage = data['message'] ?? 'فشل تسجيل الدخول');
      }
    } catch (_) {
      setState(
        () =>
            _errorMessage = 'تعذر الاتصال بالسيرفر. تحقق من اتصالك بالإنترنت.',
      );
    }

    setState(() => _isLoading = false);
  }

  /// حفظ بيانات الجلسة فقط (بدون كلمة مرور) والانتقال للرئيسية
  Future<void> _saveSessionAndNavigate(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    // بيانات الجلسة فقط - لا كلمة مرور
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

    await prefs.setString('current_user', json.encode(sessionData));
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('user_token', userData['token'] ?? '');
    await prefs.setInt('user_id', int.tryParse(userData['id'].toString()) ?? 0);

    final userId = int.tryParse(userData['id'].toString()) ?? 0;
    await UserStatsService.setCurrentUserId(userId);

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  // Timer for resend
  void _startResendTimer() {
    setState(() {
      _resendTimer = 60;
      _canResend = false;
    });

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;

      setState(() {
        _resendTimer--;
        if (_resendTimer <= 0) {
          _canResend = true;
        }
      });

      return _resendTimer > 0;
    });
  }

  // Clear OTP fields
  void _clearOTPFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _otpFocusNodes[0].requestFocus();
  }

  // Go back
  void _goBack() {
    if (_currentStep == AuthStep.otpVerification) {
      _animateToStep(AuthStep.phoneEntry);
    } else if (_currentStep == AuthStep.registration ||
        _currentStep == AuthStep.login) {
      _animateToStep(AuthStep.otpVerification);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildCurrentStep(),
                ),
              ),
              _buildBottomSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              if (_currentStep != AuthStep.phoneEntry)
                IconButton(
                  onPressed: _goBack,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 20,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_user,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'تحقق عبر الواتساب',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Logo
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.local_gas_station,
              size: 40,
              color: Colors.white,
            ),
          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 16),
          Text(
            _getTitle(),
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
          const SizedBox(height: 8),
          Text(
            _getSubtitle(),
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_currentStep) {
      case AuthStep.phoneEntry:
        return 'مرحباً بك';
      case AuthStep.otpVerification:
        return 'رمز التحقق';
      case AuthStep.registration:
        return 'إنشاء حساب';
      case AuthStep.login:
        return 'تسجيل الدخول';
    }
  }

  String _getSubtitle() {
    switch (_currentStep) {
      case AuthStep.phoneEntry:
        return 'أدخل رقم هاتفك للتحقق';
      case AuthStep.otpVerification:
        return 'أرنا رمز التحقق المرسل إلى الواتساب';
      case AuthStep.registration:
        return 'أدخل بياناتك لإكمال التسجيل';
      case AuthStep.login:
        return 'أدخل كلمة المرور لتسجيل الدخول';
    }
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case AuthStep.phoneEntry:
        return _buildPhoneEntryStep();
      case AuthStep.otpVerification:
        return _buildOTPStep();
      case AuthStep.registration:
        return _buildRegistrationStep();
      case AuthStep.login:
        return _buildLoginStep();
    }
  }

  Widget _buildPhoneEntryStep() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildPhoneField(),
          if (_errorMessage.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildErrorMessage(),
          ],
          const SizedBox(height: 32),
          _buildPrimaryButton(
            onPressed: _requestOTP,
            text: 'إرسال رمز التحقق',
            icon: Icons.send,
          ),
        ],
      ),
    ).animate().slideY(begin: 0.1, duration: 400.ms);
  }

  Widget _buildOTPStep() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildOTPFields(),
        const SizedBox(height: 8),
        Text(
          'لم تستلم الرمز؟ $_resendTimer ثانية',
          style: GoogleFonts.cairo(
            fontSize: 13,
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _canResend ? _requestOTP : null,
          child: Text(
            'إعادة إرسال الرمز',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: _canResend ? AppColors.primary : AppColors.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (_errorMessage.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildErrorMessage(),
        ],
        const SizedBox(height: 24),
        _buildPrimaryButton(
          onPressed: _verifyOTP,
          text: 'تحقق',
          icon: Icons.check_circle,
        ),
      ],
    ).animate().slideY(begin: 0.1, duration: 400.ms);
  }

  Widget _buildRegistrationStep() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildNameField(),
          const SizedBox(height: 16),
          _buildPasswordField(),
          const SizedBox(height: 16),
          _buildConfirmPasswordField(),
          if (_errorMessage.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildErrorMessage(),
          ],
          const SizedBox(height: 32),
          _buildPrimaryButton(
            onPressed: _register,
            text: 'إنشاء حساب',
            icon: Icons.person_add,
          ),
        ],
      ),
    ).animate().slideY(begin: 0.1, duration: 400.ms);
  }

  Widget _buildLoginStep() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildPasswordField(),
          if (_errorMessage.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildErrorMessage(),
          ],
          const SizedBox(height: 32),
          _buildPrimaryButton(
            onPressed: _login,
            text: 'تسجيل الدخول',
            icon: Icons.login,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => _animateToStep(AuthStep.phoneEntry),
            child: Text(
              'نسيت كلمة المرور؟',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.1, duration: 400.ms);
  }

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11),
        ],
        style: GoogleFonts.cairo(fontSize: 16, color: AppColors.textPrimary),
        textAlign: TextAlign.center,
        validator: _validateIraqiPhone,
        decoration: InputDecoration(
          hintText: '077xxx xxxx',
          hintStyle: GoogleFonts.cairo(
            fontSize: 16,
            color: AppColors.textTertiary.withOpacity(0.5),
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.phone_android,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '+964',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: AppColors.border.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.red),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildOTPFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return Container(
          width: 45,
          height: 55,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: TextField(
            controller: _otpControllers[index],
            focusNode: _otpFocusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 16),
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                _otpFocusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                _otpFocusNodes[index - 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildNameField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: TextFormField(
        controller: _nameController,
        keyboardType: TextInputType.name,
        style: GoogleFonts.cairo(fontSize: 15, color: AppColors.textPrimary),
        validator: (value) {
          if (value == null || value.isEmpty) return 'الرجاء إدخال الاسم';
          if (value.length < 3) return 'الاسم يجب أن يكون 3 أحرف على الأقل';
          return null;
        },
        decoration: InputDecoration(
          hintText: 'الاسم الكامل',
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person_outline, color: AppColors.primary),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: AppColors.border.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: TextFormField(
        controller: _passwordController,
        obscureText: true,
        keyboardType: TextInputType.visiblePassword,
        style: GoogleFonts.cairo(fontSize: 15, color: AppColors.textPrimary),
        validator: (value) {
          if (value == null || value.isEmpty) return 'الرجاء إدخال كلمة المرور';
          if (value.length < 4) {
            return 'كلمة المرور يجب أن تكون 4 أحرف على الأقل';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: 'كلمة المرور',
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lock_outline, color: AppColors.primary),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: AppColors.border.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: TextFormField(
        controller: _confirmPasswordController,
        obscureText: true,
        keyboardType: TextInputType.visiblePassword,
        style: GoogleFonts.cairo(fontSize: 15, color: AppColors.textPrimary),
        validator: (value) {
          if (value == null || value.isEmpty) return 'الرجاء تأكيد كلمة المرور';
          if (value != _passwordController.text) {
            return 'كلمات المرور غير متطابقة';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: 'تأكيد كلمة المرور',
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lock_outline, color: AppColors.primary),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: AppColors.border.withOpacity(0.3),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage,
              style: GoogleFonts.cairo(fontSize: 13, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 8,
          shadowColor: AppColors.primary.withOpacity(0.4),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: GoogleFonts.cairo(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(icon, size: 22),
                ],
              ),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _currentStep == AuthStep.login
                    ? 'ليس لديك حساب؟'
                    : 'لديك حساب بالفعل؟',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              TextButton(
                onPressed: () {
                  if (_currentStep == AuthStep.login) {
                    _animateToStep(AuthStep.phoneEntry);
                  } else {
                    _animateToStep(AuthStep.login);
                  }
                },
                child: Text(
                  _currentStep == AuthStep.login
                      ? 'إنشاء حساب'
                      : 'تسجيل الدخول',
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum AuthStep { phoneEntry, otpVerification, registration, login }
