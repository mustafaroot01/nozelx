import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/core/constants/assets_constants.dart';

/// Premium Auth Screen - صفحة تسجيل فخمة لتطبيق نوزل
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _toggleAuthMode() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final prefs = await SharedPreferences.getInstance();

        if (isLogin) {
          // Login logic
          final usersJson = prefs.getString('users_database');
          if (usersJson != null) {
            final List<dynamic> usersList = json.decode(usersJson);
            final cleanPhone = _phoneController.text.replaceAll(
              RegExp(r'[^\d+]'),
              '',
            );

            final userMap = usersList.firstWhere(
              (user) =>
                  user['phoneNumber'] == cleanPhone &&
                  user['pinCode'] == _passwordController.text,
              orElse: () => null,
            );

            if (userMap != null) {
              // Save current user
              prefs.setString('current_user', json.encode(userMap));
              prefs.setBool('isLoggedIn', true);

              if (mounted) {
                Navigator.pushReplacementNamed(context, '/home');
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('رقم الهاتف أو كلمة المرور غير صحيحة'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('رقم الهاتف غير مسجل'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } else {
          // Register new user
          final usersJson = prefs.getString('users_database');
          List<dynamic> usersList = usersJson != null
              ? json.decode(usersJson)
              : [];

          final cleanPhone = _phoneController.text.replaceAll(
            RegExp(r'[^\d+]'),
            '',
          );

          // Check if phone already exists
          final existingUser = usersList.firstWhere(
            (user) => user['phoneNumber'] == cleanPhone,
            orElse: () => null,
          );

          if (existingUser != null) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('رقم الهاتف مسجل مسبقاً'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else {
            // Create new user
            final newUser = {
              'id': DateTime.now().millisecondsSinceEpoch.toString(),
              'phoneNumber': cleanPhone,
              'name': _nameController.text.trim(),
              'pinCode': _passwordController.text,
              'createdAt': DateTime.now().toIso8601String(),
              'lastLoginAt': DateTime.now().toIso8601String(),
              'isActive': true,
            };

            usersList.add(newUser);
            prefs.setString('users_database', json.encode(usersList));

            // Save as current user
            prefs.setString('current_user', json.encode(newUser));
            prefs.setBool('isLoggedIn', true);

            if (mounted) {
              Navigator.pushReplacementNamed(context, '/home');
            }
          }
        }
      } catch (e) {
        print('Error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
          );
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              _buildLogo(),
              const SizedBox(height: 30),
              _buildTitle(),
              const SizedBox(height: 30),
              _buildForm(),
              const SizedBox(height: 20),
              _buildSubmitButton(),
              const SizedBox(height: 20),
              _buildToggleButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      AssetsConstants.nozzleLogo,
      width: 120,
      height: 120,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 120,
          height: 120,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
          ),
          child: const Icon(
            Icons.local_gas_station,
            size: 60,
            color: Colors.white,
          ),
        );
      },
    ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack);
  }

  Widget _buildTitle() {
    return Text(
      isLogin ? 'مرحباً بعودتك' : 'أنشئ حسابك',
      style: GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            if (!isLogin) ...[_buildNameField(), const SizedBox(height: 16)],
            _buildPhoneField(),
            const SizedBox(height: 16),
            _buildPasswordField(),
            if (isLogin) ...[
              const SizedBox(height: 12),
              _buildForgotPassword(),
            ],
          ],
        ),
      ),
    ).animate().slideY(begin: 0.2, duration: 400.ms, delay: 400.ms);
  }

  Widget _buildNameField() {
    return _buildTextField(
      controller: _nameController,
      label: 'الاسم الكامل',
      icon: Icons.person_outline,
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال الاسم';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField() {
    return _buildTextField(
      controller: _phoneController,
      label: 'رقم الهاتف',
      icon: Icons.phone_iphone,
      keyboardType: TextInputType.phone,
      prefixText: '+964 ',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال رقم الهاتف';
        }
        if (value.length < 10) {
          return 'رقم الهاتف غير صحيح';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return _buildTextField(
      controller: _passwordController,
      label: 'كلمة المرور',
      icon: Icons.lock_outline,
      obscureText: _obscurePassword,
      suffixIcon: IconButton(
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        icon: Icon(
          _obscurePassword ? Icons.visibility_off : Icons.visibility,
          color: AppColors.textTertiary,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال كلمة المرور';
        }
        if (value.length < 4) {
          return 'كلمة المرور يجب أن تكون 4 أحرف على الأقل';
        }
        return null;
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? prefixText,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: GoogleFonts.cairo(fontSize: 15, color: AppColors.textPrimary),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.cairo(
            fontSize: 14,
            color: AppColors.textTertiary,
          ),
          prefixText: prefixText,
          prefixStyle: GoogleFonts.cairo(
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
          prefixIcon: Icon(icon, color: AppColors.primary),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
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
        child: Text(
          'نسيت كلمة المرور؟',
          style: GoogleFonts.cairo(
            fontSize: 13,
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            shadowColor: AppColors.primary.withOpacity(0.4),
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
              : Text(
                  isLogin ? 'تسجيل الدخول' : 'إنشاء حساب',
                  style: GoogleFonts.cairo(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 500.ms);
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.divider.withOpacity(0.3),
                  AppColors.divider,
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'أو',
          style: GoogleFonts.cairo(
            fontSize: 13,
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.divider,
                  AppColors.divider.withOpacity(0.3),
                ],
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 600.ms);
  }

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          icon: Icons.g_mobiledata,
          color: const Color(0xFFDB4437),
          onTap: () {},
        ),
        const SizedBox(width: 20),
        _buildSocialButton(
          icon: Icons.facebook,
          color: const Color(0xFF4267B2),
          onTap: () {},
        ),
        const SizedBox(width: 20),
        _buildSocialButton(
          icon: Icons.apple,
          color: Colors.black,
          onTap: () {},
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 700.ms);
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }

  Widget _buildToggleButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isLogin ? 'ليس لديك حساب؟' : 'لديك حساب بالفعل؟',
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: _toggleAuthMode,
          child: Text(
            isLogin ? 'إنشاء حساب' : 'تسجيل الدخول',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 800.ms);
  }
}
