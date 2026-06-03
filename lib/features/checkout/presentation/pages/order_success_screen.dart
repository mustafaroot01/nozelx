import 'package:flutter/material.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/core/utils/currency_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

class OrderSuccessScreen extends StatefulWidget {
  final String orderNumber;
  final double totalAmount;

  const OrderSuccessScreen({
    super.key,
    required this.orderNumber,
    required this.totalAmount,
  });

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Confetti animation controller
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    // Scale animation for checkmark
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    // Start animations
    Future.delayed(const Duration(milliseconds: 150), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Confetti animation background
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _confettiController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ConfettiPainter(_confettiController.value),
                    size: Size.infinite,
                  );
                },
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  
                  // ScaleTransition Green Checkmark Circle
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 64,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Success and Thank You Text
                  Text(
                    'تم تأكيد طلبك بنجاح!',
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'شكراً لثقتك بنا. نقوم الآن بتجهيز طلبك وسيتم إشعارك فور الشحن والتوصيل.',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Order details card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'رقم الطلب:',
                              style: GoogleFonts.cairo(fontSize: 14, color: AppColors.textSecondary),
                            ),
                            Text(
                              widget.orderNumber,
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'المبلغ الإجمالي:',
                              style: GoogleFonts.cairo(fontSize: 14, color: AppColors.textSecondary),
                            ),
                            Text(
                              CurrencyFormatter.formatIQD(widget.totalAmount),
                              style: GoogleFonts.cairo(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Continue shopping button (Blue Gradient)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home',
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_bag_outlined),
                            const SizedBox(width: 8),
                            Text(
                              'الاستمرار بالتسوق',
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ConfettiPainter extends CustomPainter {
  final double animation;

  ConfettiPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42);
    final colors = [
      AppColors.primary,
      AppColors.primaryLight,
      AppColors.success,
      AppColors.warning,
      Colors.pinkAccent,
      Colors.purpleAccent,
    ];

    for (int i = 0; i < 40; i++) {
      final x = size.width * random.nextDouble();
      final y = (size.height * (animation + random.nextDouble() * 0.5)) % size.height;
      final color = colors[random.nextInt(colors.length)];
      final confettiSize = (random.nextDouble() * 6 + 4) * (1 - animation * 0.3);

      paint.color = color.withOpacity(1 - animation);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(random.nextDouble() * 2 * math.pi);

      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(confettiSize, confettiSize / 2)
        ..lineTo(0, confettiSize)
        ..lineTo(-confettiSize / 2, confettiSize / 2)
        ..close();

      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}
