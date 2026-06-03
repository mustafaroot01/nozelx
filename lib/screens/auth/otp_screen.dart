import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'name_screen.dart';
import '../../features/home/presentation/pages/home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen>
    with SingleTickerProviderStateMixin {
  // 6 controllers للخانات الست
  final List<TextEditingController> _ctrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _nodes =
      List.generate(6, (_) => FocusNode());

  bool _isLoading   = false;
  bool _canResend   = false;
  int  _seconds     = 120; // دقيقتان
  Timer? _timer;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(
        parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();
    _startTimer();
    
    // إضافة مستمعين لتغيير الفوكس وتعيين معالج زر المسح (backspace)
    for (int i = 0; i < 6; i++) {
      _nodes[i].addListener(_onFocusChange);
      _nodes[i].onKeyEvent = (node, event) {
        if ((event is KeyDownEvent || event is RawKeyDownEvent) &&
            event.logicalKey == LogicalKeyboardKey.backspace) {
          if (_ctrls[i].text.isEmpty && i > 0) {
            _nodes[i - 1].requestFocus();
            _ctrls[i - 1].clear();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      };
    }
    
    // فوكس على أول خانة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _nodes.isNotEmpty) {
        _nodes[0].requestFocus();
      }
    });
  }

  void _onFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  void _startTimer() {
    _seconds = 120;
    _canResend = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_seconds == 0) {
        t.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _seconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animCtrl.dispose();
    for (final node in _nodes) {
      node.removeListener(_onFocusChange);
    }
    for (final c in _ctrls) c.dispose();
    for (final n in _nodes) n.dispose();
    super.dispose();
  }

  String get _otpValue =>
      _ctrls.map((c) => c.text).join();

  String get _timerText {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 20),
  
                  // ── زر الرجوع (يمين) ───────────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () =>
                          Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF0F4F8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Color(0xFF0D1B2A),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
  
                  const SizedBox(height: 24),
  
                  // ── العنوان ─────────────────────
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'أدخل رمز التحقق',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D1B2A),
                      ),
                    ),
                  ),
  
                  const SizedBox(height: 20),
  
                  // ── أيقونة واتساب ───────────────
                  Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/icons/whatsapp.png',
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) =>
                                  const Center(
                            child: Text('💬',
                                style: TextStyle(
                                    fontSize: 28)),
                          ),
                        ),
                      ),
                    ),
                  ),
  
                  const SizedBox(height: 16),
  
                  // ── رسالة الإرسال ───────────────
                  Center(
                    child: Text(
                      'لقد أرسلناه إلى ${widget.phone} عبر رسالة نصية (WhatsApp)',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        height: 1.6,
                      ),
                    ),
                  ),
  
                  const SizedBox(height: 8),
  
                  // ── تعديل الرقم ─────────────────
                  Center(
                    child: GestureDetector(
                      onTap: () =>
                          Navigator.pop(context),
                      child: RichText(
                        text: const TextSpan(
                          text: 'رقم خاطئ؟ ',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                          children: [
                            TextSpan(
                              text: 'تعديل',
                              style: TextStyle(
                                color:
                                    Color(0xFF1565C0),
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
  
                  const SizedBox(height: 36),
  
                  // ── خانات OTP ───────────────────
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (i) =>
                      _OtpBox(
                        controller: _ctrls[i],
                        focusNode: _nodes[i],
                        onChanged: (val) {
                          if (val.isNotEmpty && i < 5) {
                            _nodes[i + 1].requestFocus();
                          }
                          if (val.isEmpty && i > 0) {
                            _nodes[i - 1].requestFocus();
                          }
                          // إذا اكتملت 6 أرقام
                          if (_otpValue.length == 6) {
                            _verify();
                          }
                        },
                      ),
                    ),
                  ),
  
                  const SizedBox(height: 28),
  
                  // ── مؤقت إعادة الإرسال ──────────
                  Center(
                    child: _canResend
                        ? GestureDetector(
                            onTap: _resend,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'إعادة إرسال الرمز',
                                style: TextStyle(
                                  color: Color(0xFF1565C0),
                                  fontSize: 14,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                        : Text(
                            'إعادة إرسال الرمز خلال $_timerText',
                            textAlign:
                                TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                  ),
  
                  const SizedBox(height: 50),
  
                  // ── زر التحقق ───────────────────
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1565C0),
                      ),
                    ),
  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _verify() async {
    if (_otpValue.length < 6) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      final isNew = await context
          .read<AuthProvider>()
          .verifyOtp(widget.phone, _otpValue);

      if (!mounted) return;

      if (isNew) {
        // مستخدم جديد → شاشة الاسم
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                NameScreen(phone: widget.phone),
          ),
        );
      } else {
        // مستخدم قديم → دخول مباشر للرئيسية
        if (mounted) {
          final authProv = context.read<AuthProvider>();
          if (authProv.user != null) {
            await authProv.finalizeLogin(context, authProv.user!.phone, authProv.user!.token);
          }
          
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (_) => const HomeScreen()),
            (_) => false,
          );
        }
      }
    } catch (e) {
      // احمرار الخانات
      for (final c in _ctrls) c.clear();
      _nodes[0].requestFocus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('DioException: ', '').replaceAll('Exception: ', '')),
            backgroundColor: const Color(0xFFE24B4A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
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

  Future<void> _resend() async {
    try {
      await context
          .read<AuthProvider>()
          .sendOtp(widget.phone);
      _startTimer();
      for (final c in _ctrls) c.clear();
      _nodes[0].requestFocus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('DioException: ', '').replaceAll('Exception: ', '')),
            backgroundColor: const Color(0xFFE24B4A),
          ),
        );
      }
    }
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 52,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [
          ArabicToEnglishNumbersFormatter(), // تحويل الأرقام العربية والهندية تلقائياً
        ],
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0D1B2A),
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          counterText: '',
          filled: true,
          fillColor: focusNode.hasFocus
              ? const Color(0xFFE3F2FD)
              : const Color(0xFFF8F9FA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color(0xFFE5E7EB),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color(0xFFE5E7EB),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color(0xFF1565C0),
              width: 2,
            ),
          ),
        ),
      ),
    );
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
