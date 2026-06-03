import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'otp_screen.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen>
    with SingleTickerProviderStateMixin {
  final _phoneCtrl = TextEditingController();
  final _formKey   = GlobalKey<FormState>();
  bool _isLoading  = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(
        parent: _animCtrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animCtrl,
        curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    children: [
                      // زر إغلاق الصفحة (اكس)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Color(0xFF0D1B2A),
                              size: 28,
                            ),
                            onPressed: () {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/home',
                                  (route) => false,
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
  
                      // ── نص ترحيبي ──────────────
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'مرحبا بكم',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0D1B2A),
                            height: 1.2,
                          ),
                        ),
                      ),
  
                      const SizedBox(height: 10),
  
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'أدخل رقم هاتفك المحمول حتى نتمكن من التواصل معك.',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                            height: 1.6,
                          ),
                        ),
                      ),
  
                      const SizedBox(height: 36),
  
                      // ── حقل الرقم + علم العراق ──
                      Row(
                        children: [
                          // حقل الرقم (اليمين)
                          Expanded(
                            child: TextFormField(
                              controller: _phoneCtrl,
                              keyboardType:
                                  TextInputType.phone,
                              textAlign: TextAlign.right,
                              textDirection:
                                  TextDirection.ltr,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF0D1B2A),
                                letterSpacing: 1,
                              ),
                              inputFormatters: [
                                ArabicToEnglishNumbersFormatter(),
                                LengthLimitingTextInputFormatter(11),
                              ],
                              decoration:
                                  InputDecoration(
                                labelText: 'رقم الهاتف المحمول',
                                hintText: 'مثلاً 07XXXXXXXXX',
                                hintStyle:
                                    const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF9CA3AF),
                                ),
                                labelStyle:
                                    const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(12),
                                  borderSide:
                                      const BorderSide(
                                    color:
                                        Color(0xFFD1D5DB),
                                  ),
                                ),
                                enabledBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(12),
                                  borderSide:
                                      const BorderSide(
                                    color:
                                        Color(0xFFD1D5DB),
                                  ),
                                ),
                                focusedBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(12),
                                  borderSide:
                                      const BorderSide(
                                    color:
                                        Color(0xFF1565C0),
                                    width: 1.5,
                                  ),
                                ),
                                errorBorder:
                                    OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(12),
                                  borderSide:
                                      const BorderSide(
                                    color:
                                        Color(0xFFE24B4A),
                                  ),
                                ),
                                contentPadding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              validator: (v) {
                                if (v == null ||
                                    v.trim().isEmpty) {
                                  return 'أدخل رقم الهاتف';
                                }
                                final clean =
                                    v.trim().replaceAll(
                                        ' ', '');
                                if (clean.length != 11 ||
                                    !clean
                                        .startsWith('07')) {
                                  return 'رقم غير صحيح';
                                }
                                return null;
                              },
                            ),
                          ),
  
                          const SizedBox(width: 10),
  
                          // علم العراق + الكود (اليسار)
                          Container(
                            height: 58,
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    const Color(0xFFD1D5DB),
                              ),
                            ),
                            child: Row(
                              mainAxisSize:
                                  MainAxisSize.min,
                              children: [
                                // علم العراق
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(
                                          3),
                                  child: Image.asset(
                                    'assets/flags/iq.png',
                                    width: 28,
                                    height: 20,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Text(
                                      '🇮🇶',
                                      style: TextStyle(
                                          fontSize: 22),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  '+964',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight:
                                        FontWeight.w600,
                                    color:
                                        Color(0xFF0D1B2A),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 18,
                                  color: Color(0xFF6B7280),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
  
                      const SizedBox(height: 16),
  
                      // ── الشروط والأحكام ─────────
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // فتح صفحة الشروط
                            },
                            child: const Text(
                              'الشروط والأحكام',
                              style: TextStyle(
                                color: Color(0xFF1565C0),
                                fontSize: 13,
                                fontWeight:
                                    FontWeight.w600,
                                decoration:
                                    TextDecoration
                                        .underline,
                              ),
                            ),
                          ),
                          const Text(
                            ' من خلال التسجيل، أوافق على ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
  
                      const SizedBox(height: 80),
  
                      // ── زر المتابعة ─────────────
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF1565C0),
                            disabledBackgroundColor:
                                const Color(0xFFBBDEFB),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child:
                                      CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'متابعة',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),
                        ),
                      ),
  
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneCtrl.text.trim();
    setState(() => _isLoading = true);

    try {
      await context
          .read<AuthProvider>()
          .sendOtp(phone);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                OtpScreen(phone: phone),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(e.toString()
                .replaceAll('Exception: ', '')),
            backgroundColor:
                const Color(0xFFE24B4A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

/// TextInputFormatter لتحويل الأرقام العربية والهندية والفارسية إلى أرقام إنجليزية
class ArabicToEnglishNumbersFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;
    
    // استبدال الأرقام الهندية/العربية
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    
    for (int i = 0; i < 10; i++) {
      text = text.replaceAll(arabicDigits[i], englishDigits[i]);
    }
    
    // استبدال الأرقام الفارسية
    const persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    for (int i = 0; i < 10; i++) {
      text = text.replaceAll(persianDigits[i], englishDigits[i]);
    }
    
    // السماح بالأرقام فقط
    final cleanText = text.replaceAll(RegExp(r'[^0-9]'), '');
    
    return TextEditingValue(
      text: cleanText,
      selection: TextSelection.collapsed(offset: cleanText.length),
    );
  }
}
