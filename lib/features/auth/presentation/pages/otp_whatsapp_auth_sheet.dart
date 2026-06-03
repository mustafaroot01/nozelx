import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:auto_lube/core/services/api_service.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/core/services/user_stats_service.dart';

/// Bottom Sheet for OTP WhatsApp Authentication
class OTPWhatsAppAuthSheet extends StatefulWidget {
  const OTPWhatsAppAuthSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => const OTPWhatsAppAuthSheet(),
    );
  }

  @override
  State<OTPWhatsAppAuthSheet> createState() => _OTPWhatsAppAuthSheetState();
}

class _OTPWhatsAppAuthSheetState extends State<OTPWhatsAppAuthSheet> {
  AuthStep _currentStep = AuthStep.phone;
  bool _isLoading = false;
  String _errorMessage = '';
  String _phoneNumber = '';
  int _resendTimer = 0;
  bool _canResend = true;

  // Controllers
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  final _formKey = GlobalKey<FormState>();

  // API - Meta WhatsApp Business API (via verify_phone.php)
  static final String _apiUrl =
      '${ApiService.baseUrl}/verify_phone';
  static const String _infobipBaseUrl = 'https://grg8de.api.infobip.com';
  static const String _infobipApiKey =
      '93970ecfe4a793bc35e393d0573023c8-2910882d-b0a7-4b60-8d79-b4ad20a847a4';

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال رقم الهاتف';
    }
    final clean = value.replaceAll(RegExp(r'[^\d]'), '');
    if (!clean.startsWith('077') &&
        !clean.startsWith('078') &&
        !clean.startsWith('079') &&
        !clean.startsWith('075')) {
      return 'يرجى إدخال رقم صحيح';
    }
    if (clean.length != 11) {
      return 'رقم الهاتف يجب أن يكون 11 رقم';
    }
    return null;
  }

  Future<void> _requestOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _phoneNumber = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    });

    try {
      // Send OTP via backend API (which handles Infobip)
      final response = await http
          .post(
            Uri.parse('$_apiUrl?action=request_otp'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'phone': _phoneNumber, 'via': 'whatsapp'}),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        // In demo mode, show the OTP for testing
        if (data['data']?['demo_mode'] == true &&
            data['data']?['otp'] != null) {
          debugPrint('Demo OTP: ${data['data']['otp']}');
        }

        setState(() {
          _currentStep = AuthStep.otp;
        });
        _startResendTimer();
        
        // Auto-focus the first OTP field
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && _otpFocusNodes.isNotEmpty) {
            FocusScope.of(context).requestFocus(_otpFocusNodes[0]);
          }
        });
      } else {
        setState(() {
          _errorMessage =
              data['message'] ?? 'فشل إرسال الرمز، يرجى المحاولة مرة أخرى';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ في الاتصال';
      });
    }

    setState(() => _isLoading = false);
  }

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
      // Verify with local API
      final response = await http
          .post(
            Uri.parse('$_apiUrl?action=verify_otp'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'phone': _phoneNumber, 'otp': otp}),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        final userExists = data['data']['user_exists'] == true;

        if (userExists) {
          // User already exists, log them in immediately! No password needed.
          await _saveSession(data['data']['user']);
          if (mounted) {
            Navigator.pop(context, true);
          }
        } else {
          // New user, go to register step
          setState(() => _currentStep = AuthStep.register);
        }
      } else {
        setState(() {
          _errorMessage = data['message'] ?? 'الرمز غير صحيح';
        });
        _clearOTPFields();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ في الاتصال';
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http
          .post(
            Uri.parse('$_apiUrl?action=login_with_otp'),
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: json.encode({
              'phone': _phoneNumber,
              'password': _passwordController.text,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        await _saveSession(data['data']['user']);
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        setState(() {
          _errorMessage = data['message'] ?? 'فشل تسجيل الدخول';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ في الاتصال';
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http
          .post(
            Uri.parse('$_apiUrl?action=complete_registration'),
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: json.encode({
              'phone': _phoneNumber,
              'name': _nameController.text.trim(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (data['success'] == true) {
        await _saveSession(data['data']['user']);
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        setState(() {
          _errorMessage = data['message'] ?? 'فشل إنشاء الحساب';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ في الاتصال';
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveSession(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    final sessionData = {
      'id': userData['id'].toString(),
      'name': userData['name'] ?? '',
      'phone': userData['phone'] ?? '',
      'email': userData['email'] ?? '',
      'avatar': userData['avatar'] ?? '',
      'is_admin': userData['is_admin'] ?? 0,
    };

    await prefs.setString('current_user', json.encode(sessionData));
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('user_token', userData['token'] ?? '');
    await prefs.setInt('user_id', int.tryParse(userData['id'].toString()) ?? 0);

    final userId = int.tryParse(userData['id'].toString()) ?? 0;
    await UserStatsService.setCurrentUserId(userId);
  }

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

  void _clearOTPFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _otpFocusNodes[0].requestFocus();
  }

  void _goBack() {
    if (_currentStep == AuthStep.otp) {
      setState(() => _currentStep = AuthStep.phone);
    } else if (_currentStep == AuthStep.login ||
        _currentStep == AuthStep.register) {
      setState(() => _currentStep = AuthStep.otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          // Background soft mesh blobs for the sheet
          Positioned(
            top: -50,
            right: -30,
            child: _buildMeshBlob(const Color(0xFF007AFF).withOpacity(0.04), 150),
          ),
          
          Column(
            children: [
              _buildHandle(),
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: _buildCurrentStep(),
                ),
              ),
            ],
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

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.border.withOpacity(0.5),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _currentStep != AuthStep.phone
            ? IconButton(
                onPressed: _goBack,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              )
            : IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded, size: 18, color: AppColors.textPrimary.withOpacity(0.5)),
                ),
              ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF25D366).withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF25D366).withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_user_rounded, size: 14, color: Color(0xFF25D366)),
                const SizedBox(width: 6),
                Text(
                  'تحقق آمن عبر واتساب',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: const Color(0xFF25D366),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case AuthStep.phone:
        return _buildPhoneStep();
      case AuthStep.otp:
        return _buildOTPStep();
      case AuthStep.login:
        return _buildLoginStep();
      case AuthStep.register:
        return _buildRegisterStep();
    }
  }

  Widget _buildPhoneStep() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildLogo(),
          const SizedBox(height: 24),
          Text(
            'نوزل',
            style: GoogleFonts.cairo(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'أدخل رقم هاتفك ليصلك رمز التحقق عبر واتساب',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOTPStep() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildLogo(),
        const SizedBox(height: 24),
        Text(
          'رمز التأكيد',
          style: GoogleFonts.cairo(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'أرسلنا رمزاً مكوناً من 6 أرقام إلى \n$_phoneNumber',
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _buildOTPFields(),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'لم يصلك الرمز؟ ',
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            if (_canResend)
              GestureDetector(
                onTap: _requestOTP,
                child: Text(
                  'إرسال مرة أخرى',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              )
            else
              Text(
                '$_resendTimer ثانية',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        if (_errorMessage.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildErrorMessage(),
        ],
        const SizedBox(height: 32),
        _buildPrimaryButton(
          onPressed: _verifyOTP,
          text: 'تأكيد الرمز',
          icon: Icons.check_circle_rounded,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLoginStep() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildLogo(),
          const SizedBox(height: 24),
          Text(
            'تسجيل الدخول',
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أدخل كلمة المرور لتسجيل الدخول',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildPasswordField(),
          if (_errorMessage.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildErrorMessage(),
          ],
          const SizedBox(height: 32),
          _buildPrimaryButton(
            onPressed: _login,
            text: 'دخول',
            icon: Icons.login,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRegisterStep() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildLogo(),
          const SizedBox(height: 24),
          Text(
            'أهلاً بك في نوزل',
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ما اسمك الكريم؟',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildNameField(),
          if (_errorMessage.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildErrorMessage(),
          ],
          const SizedBox(height: 32),
          _buildPrimaryButton(
            onPressed: _register,
            text: 'إكمال التسجيل',
            icon: Icons.person_add,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 76,
      height: 76,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Image.asset(
        'IMG/logoapp.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildPhoneField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11),
        ],
        style: GoogleFonts.cairo(
          fontSize: 18,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
        textAlign: TextAlign.center,
        validator: _validatePhone,
        decoration: InputDecoration(
          hintText: '07X XXX XXXX',
          hintStyle: GoogleFonts.cairo(
            fontSize: 16,
            color: AppColors.textTertiary,
            letterSpacing: 0,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.phone_iphone_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  '+964',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          border: InputBorder.none,
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
          width: 44,
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withOpacity(0.5), width: 1.5),
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
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                if (index < 5) {
                  _otpFocusNodes[index + 1].requestFocus();
                } else {
                  // Auto submit when last digit is entered
                  _verifyOTP();
                }
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: TextFormField(
        controller: _nameController,
        keyboardType: TextInputType.name,
        style: GoogleFonts.cairo(fontSize: 15, color: AppColors.textPrimary),
        validator: (value) {
          if (value == null || value.isEmpty) return 'يرجى إدخال الاسم';
          if (value.length < 3) return 'الاسم يجب أن يكون 3 أحرف على الأقل';
          return null;
        },
        decoration: InputDecoration(
          hintText: 'الاسم الكامل',
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person_outline, color: AppColors.primary),
          ),
          border: InputBorder.none,
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: TextFormField(
        controller: _passwordController,
        obscureText: true,
        keyboardType: TextInputType.visiblePassword,
        style: GoogleFonts.cairo(fontSize: 15, color: AppColors.textPrimary),
        validator: (value) {
          if (value == null || value.isEmpty) return 'يرجى إدخال كلمة المرور';
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
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lock_outline, color: AppColors.primary),
          ),
          border: InputBorder.none,
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: TextFormField(
        controller: _confirmPasswordController,
        obscureText: true,
        keyboardType: TextInputType.visiblePassword,
        style: GoogleFonts.cairo(fontSize: 15, color: AppColors.textPrimary),
        validator: (value) {
          if (value == null || value.isEmpty) return 'يرجى تأكيد كلمة المرور';
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
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lock_outline, color: AppColors.primary),
          ),
          border: InputBorder.none,
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
      height: 62,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          elevation: 6,
          shadowColor: AppColors.primary.withOpacity(0.2),
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
                    text,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(icon, size: 20),
                ],
              ),
      ),
    );
  }
}

enum AuthStep { phone, otp, login, register }
