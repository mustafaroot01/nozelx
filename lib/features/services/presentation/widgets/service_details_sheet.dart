import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/core/widgets/app_network_image.dart';
import 'package:auto_lube/features/services/data/services_data.dart';

class ServiceDetailsSheet extends StatefulWidget {
  final CenterService service;
  final List<CenterService> selectedServices;
  final Function(CenterService) onAddService;
  final VoidCallback onBookNow;

  const ServiceDetailsSheet({
    super.key,
    required this.service,
    required this.selectedServices,
    required this.onAddService,
    required this.onBookNow,
  });

  @override
  State<ServiceDetailsSheet> createState() => _ServiceDetailsSheetState();
}

class _ServiceDetailsSheetState extends State<ServiceDetailsSheet> {
  bool get _isServiceSelected =>
      widget.selectedServices.any((s) => s.id == widget.service.id);

  IconData _getIconData(String iconName) {
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

  Color _getServiceColor(int index) {
    final colors = [
      const Color(0xFF0FB9F1),
      const Color(0xFF2ED573),
      const Color(0xFFFF6B6B),
      const Color(0xFFFFA502),
      const Color(0xFFA55EEA),
      const Color(0xFF575FCF),
      const Color(0xFF3C40C6),
      const Color(0xFFE5771F),
    ];
    return colors[index % colors.length];
  }

  String _formatPrice(int price) {
    if (price == 0) return 'مجاني';
    return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} د.ع';
  }

  void _toggleService() {
    if (_isServiceSelected) {
      // Remove from selected services
      Navigator.pop(context);
    } else {
      // Add service to selected list
      widget.onAddService(widget.service);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final serviceColor = _getServiceColor(widget.service.id);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header with Handle Bar and Close Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 32), // Spacer to balance close button
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 22),
                  onPressed: () => Navigator.pop(context),
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Image or Icon
                  if (widget.service.image != null &&
                      widget.service.image!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AppNetworkImage(
                        imageUrl: widget.service.image!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: _buildServiceIcon(serviceColor),
                      ),
                    )
                  else
                    _buildServiceIcon(serviceColor),

                  const SizedBox(height: 16),

                  // Service Name
                  Text(
                    widget.service.name,
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Service Description
                  if (widget.service.description != null &&
                      widget.service.description!.isNotEmpty)
                    Text(
                      widget.service.description!,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Price and Duration
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: serviceColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.attach_money,
                              size: 18,
                              color: serviceColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatPrice(widget.service.price),
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: serviceColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.service.durationMinutes} دقيقة',
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Selected Services Count
                  if (widget.selectedServices.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'لديك ${widget.selectedServices.length} خدمة مختارة',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Buttons inside SafeArea to prevent overlapping home indicator
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  // Add/Remove Service Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _toggleService,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isServiceSelected
                            ? AppColors.error
                            : AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_isServiceSelected ? Icons.remove : Icons.add),
                          const SizedBox(width: 8),
                          Text(
                            _isServiceSelected
                                ? 'إلغاء إضافة الخدمة'
                                : 'إضافة خدمة أخرى',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Book Now Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onBookNow();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            widget.selectedServices.isEmpty
                                ? 'حجز هذه الخدمة'
                                : 'حجز ${widget.selectedServices.length} خدمة',
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceIcon(Color color) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getIconData(widget.service.icon),
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          Text(
            widget.service.name,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
