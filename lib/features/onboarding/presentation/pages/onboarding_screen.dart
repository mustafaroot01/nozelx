import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // الألوان المطلوبة: fbd505 و fbf597
  final Color _color1 = const Color(0xFFfbd505);
  final Color _color2 = const Color(0xFFfbf597);

  final List<Map<String, String>> _pages = [
    {
      'title': 'منتجات عالية الجودة',
      'description':
          'نقدم لكم أفضل أنواع الزيوت والفلاتر ومستلزمات السيارات من علامات تجارية عالمية موثوقة',
    },
    {
      'title': 'توصيل سريع',
      'description':
          'شحن لجميع المناطق مع تتبع الطلبات وتوصيل سريع لغاية باب منزلك',
    },
    {
      'title': 'خصومات حصرية',
      'description':
          'عروض مستمرة وأسعار تنافسية مع برنامج ولاء يمنحك المزيد من التوفير',
    },
  ];

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
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
        child: SafeArea(
          child: Column(
            children: [
              // Logo at the top
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Image.asset(
                  'IMG/logoapp.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.local_gas_station,
                        size: 50,
                        color: Color(0xFFfbd505),
                      ),
                    );
                  },
                ),
              ),

              // Skip Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        'تخطي',
                        style: GoogleFonts.cairo(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),

              // Indicators
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => _buildIndicator(index),
                  ),
                ),
              ),

              // Button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: _buildActionButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(Map<String, String> page) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(
              _currentPage == 0
                  ? Icons.oil_barrel
                  : _currentPage == 1
                  ? Icons.local_shipping
                  : Icons.discount,
              size: 60,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 40),

          // Title
          Text(
            page['title'] ?? '',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              color: Colors.black87,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            page['description'] ?? '',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              color: Colors.black54,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: _currentPage == index ? Colors.black87 : Colors.black26,
      ),
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          if (_currentPage == _pages.length - 1) {
            _completeOnboarding();
          } else {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          _currentPage == _pages.length - 1 ? 'ابدأ الآن' : 'التالي',
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
