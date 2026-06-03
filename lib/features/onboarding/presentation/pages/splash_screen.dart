import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  final bool shouldNavigate;
  const SplashScreen({super.key, this.shouldNavigate = true});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // الألوان المطلوبة: fbd505 و fbf597
  final Color _color1 = const Color(0xFFfbd505);
  final Color _color2 = const Color(0xFFfbf597);

  @override
  void initState() {
    super.initState();
    if (widget.shouldNavigate) {
      _navigateToHome();
    }
  }

  /// الانتقال مباشرة للشاشة الرئيسية
  Future<void> _navigateToHome() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    
    // الانتظار حتى اكتمال تحميل الجلسة
    final startTime = DateTime.now();
    while (!auth.isSessionLoaded) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
    }
    
    // الانتظار ثانية واحدة على الأقل لعرض شعار التطبيق بشكل لائق
    final elapsed = DateTime.now().difference(startTime);
    final remaining = const Duration(seconds: 1) - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_color1, _color2],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'IMG/appnozzlelogo1.png',
                width: 180,
                height: 180,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.local_gas_station,
                      size: 80,
                      color: Color(0xFFfbd505),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Loading indicator
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
