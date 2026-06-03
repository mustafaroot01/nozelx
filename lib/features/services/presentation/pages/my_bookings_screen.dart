import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/core/utils/currency_formatter.dart';
import 'package:auto_lube/core/widgets/shimmer_widget.dart';
import 'package:auto_lube/features/services/data/services_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  bool _isLoading = true;
  List<ServiceAppointment> _appointments = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }



  Future<void> _loadAppointments() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      int userId = 0;
      if (userJson != null) {
        // Just dummy mapping since token handles user retrieval on backend,
        // but ServicesApi still takes a potential argument
      }

      final data = await ServicesApi.getUserAppointments(userId);
      if (mounted) {
        setState(() {
          _appointments = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _appointments = [];
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'oil':
        return Icons.local_gas_station;
      case 'air':
        return Icons.air;
      case 'search':
        return Icons.search;
      case 'local_car_wash':
        return Icons.local_car_wash;
      case 'ac_unit':
        return Icons.ac_unit;
      case 'tire_repair':
        return Icons.tire_repair;
      case 'water_drop':
        return Icons.water_drop;
      case 'battery_charging_full':
        return Icons.battery_charging_full;
      case 'build':
      default:
        return Icons.build;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'new':
      case 'pending':
        return AppColors.warning;
      case 'confirmed':
        return AppColors.info;
      case 'in_progress':
        return AppColors.primary;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(
          'حجوزاتي ومواعيدي',
          style: GoogleFonts.cairo(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _loadAppointments,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: RefreshIndicator(
          onRefresh: _loadAppointments,
          color: AppColors.primary,
          child: _isLoading
              ? _buildShimmerLoading()
              : _errorMessage != null
                  ? _buildErrorState()
                  : _appointments.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _appointments.length,
                          itemBuilder: (context, index) {
                            final appointment = _appointments[index];
                            return _buildBookingCard(appointment);
                          },
                        ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(ServiceAppointment appointment) {
    final statusColor = _getStatusColor(appointment.status);
    final formattedPrice = CurrencyFormatter.format(
      (appointment.servicePrice ?? 0).toDouble(),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header with status badge
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _getIconData(appointment.serviceIcon),
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.serviceName ?? 'خدمة حجز مواعيد',
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'مدة الخدمة: ${appointment.serviceDuration ?? 30} دقيقة',
                          style: GoogleFonts.cairo(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: statusColor.withOpacity(0.2)),
                  ),
                  child: Text(
                    appointment.statusText,
                    style: GoogleFonts.cairo(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFF2F2F7)),

          // Booking Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Date & Time Row
                _buildInfoRow(
                  Icons.calendar_today_rounded,
                  'التوقيت المفضل',
                  '${appointment.preferredDate.year}-${appointment.preferredDate.month}-${appointment.preferredDate.day}  |  ${appointment.preferredTime}',
                ),
                const SizedBox(height: 12),

                // Car details Row
                if (appointment.carModel != null && appointment.carModel!.isNotEmpty)
                  _buildInfoRow(
                    Icons.directions_car_rounded,
                    'معلومات السيارة',
                    '${appointment.carModel} ${appointment.carNumber != null ? '(${appointment.carNumber})' : ''}',
                  ),

                // Notes Row if exists
                if (appointment.notes != null && appointment.notes!.trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.notes_rounded,
                    'ملاحظاتك',
                    appointment.notes!,
                    isMultiLine: true,
                  ),
                ],
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFF2F2F7)),

          // Card Footer with price
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'التكلفة الإجمالية:',
                  style: GoogleFonts.cairo(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  formattedPrice,
                  style: GoogleFonts.cairo(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isMultiLine = false}) {
    return Row(
      crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.textSecondary.withOpacity(0.8), size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.cairo(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
                maxLines: isMultiLine ? 4 : 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const ShimmerBox(width: double.infinity, height: double.infinity),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 64),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'فشل تحميل المواعيد',
              style: GoogleFonts.cairo(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAppointments,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'إعادة المحاولة',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.01),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.calendar_today_outlined,
                color: AppColors.textSecondary,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد حجوزات نشطة',
              style: GoogleFonts.cairo(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'حجوزات صيانة وغسيل السيارات الخاصة بك ستظهر هنا لتتبع حالتها وموعدها.',
              style: GoogleFonts.cairo(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
