import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../features/home/presentation/pages/home_screen.dart';

class NameScreen extends StatefulWidget {
  final String phone;
  const NameScreen({super.key, required this.phone});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final _nameCtrl = TextEditingController();
  final _formKey  = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
                  const SizedBox(height: 48),
  
                  // ── أيقونة ─────────────────────
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF1565C0),
                            Color(0xFF1E88E5),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
  
                  const SizedBox(height: 24),
  
                  // ── العنوان ─────────────────────
                  const Center(
                    child: Text(
                      'أكمل تسجيلك',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D1B2A),
                      ),
                    ),
                  ),
  
                  const SizedBox(height: 8),
  
                  const Center(
                    child: Text(
                      'أدخل اسمك الكامل',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
  
                  const SizedBox(height: 36),
  
                  // ── حقل الاسم ───────────────────
                  TextFormField(
                    controller: _nameCtrl,
                    textAlign: TextAlign.right,
                    textCapitalization:
                        TextCapitalization.words,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF0D1B2A),
                    ),
                    decoration: InputDecoration(
                      labelText: 'الاسم الكامل',
                      hintText: 'مثلاً: محمد أحمد',
                      prefixIcon: const Icon(
                        Icons.badge_outlined,
                        color: Color(0xFF1565C0),
                      ),
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9CA3AF),
                      ),
                      labelStyle: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFD1D5DB),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFD1D5DB),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF1565C0),
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE24B4A),
                        ),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    validator: (v) {
                      if (v == null ||
                          v.trim().isEmpty) {
                        return 'أدخل الاسم';
                      }
                      if (v.trim().length < 2) {
                        return 'الاسم قصير جداً';
                      }
                      return null;
                    },
                  ),
  
                  const SizedBox(height: 80),
  
                  // ── زر إنشاء الحساب ─────────────
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
                              'إنشاء الحساب',
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
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await context.read<AuthProvider>().saveName(
          widget.phone,
          _nameCtrl.text.trim());

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
    } catch (e) {
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
}
