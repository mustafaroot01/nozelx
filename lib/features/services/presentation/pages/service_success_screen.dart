import 'package:flutter/material.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/core/utils/currency_formatter.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceSuccessScreen extends StatefulWidget {
  final String serviceName;
  final DateTime date;
  final TimeOfDay time;
  final double totalCost;
  final String selectedOptionTitle;

  const ServiceSuccessScreen({
    super.key,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.totalCost,
    required this.selectedOptionTitle,
  });

  @override
  State<ServiceSuccessScreen> createState() => _ServiceSuccessScreenState();
}

class _ServiceSuccessScreenState extends State<ServiceSuccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    Future.delayed(const Duration(milliseconds: 150), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final months = [
      'كانون الثاني', 'شباط', 'آذار', 'نيسان', 'أيار', 'حزيران',
      'تموز', 'آب', 'أيلول', 'تشرين الأول', 'تشرين الثاني', 'كانون الأول'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'صباحاً' : 'مساءً';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              // ScaleTransition scheduling success checkmark
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.event_available,
                      color: Colors.white,
                      size: 64,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Success Text
              Text(
                'تم تأكيد موعد حجزك بنجاح!',
                style: GoogleFonts.cairo(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'تم حجز موعد الخدمة بنجاح. سيقوم فريق خدمة العملاء بالتواصل معك قريباً للتأكيد النهائي.',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Booking details card
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
                    _buildDetailRow('الخدمة المطلوبة:', widget.serviceName, isBold: true),
                    const Divider(height: 20),
                    _buildDetailRow('باقة الخدمة:', widget.selectedOptionTitle),
                    const Divider(height: 20),
                    _buildDetailRow('تاريخ الحجز:', _formatDate(widget.date)),
                    const Divider(height: 20),
                    _buildDetailRow('الوقت المختار:', _formatTime(widget.time)),
                    const Divider(height: 20),
                    _buildDetailRow('التكلفة التقريبية:', CurrencyFormatter.formatIQD(widget.totalCost), isPrice: true),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Action Buttons
              Column(
                children: [
                  // Go to bookings button (Blue Gradient)
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
                            '/my-bookings',
                            (route) => route.isFirst,
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
                            const Icon(Icons.bookmark_outline),
                            const SizedBox(width: 8),
                            Text(
                              'الذهاب لجدول حجوزاتي',
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
                  const SizedBox(height: 12),

                  // Return Home button (Blue Outline)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (route) => false,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.home_outlined),
                          const SizedBox(width: 8),
                          Text(
                            'العودة للرئيسية',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String val, {bool isBold = false, bool isPrice = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textSecondary),
        ),
        Text(
          val,
          style: GoogleFonts.cairo(
            fontSize: isPrice ? 15 : 13,
            fontWeight: (isBold || isPrice) ? FontWeight.bold : FontWeight.normal,
            color: isPrice ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
