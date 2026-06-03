import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:auto_lube/providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/app_network_image.dart';
import '../../models/service_model.dart';
import '../../providers/service_provider.dart';
import 'service_request_screen.dart';

class ServiceDetailScreen extends StatelessWidget {
  final ServiceModel service;
  const ServiceDetailScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: CustomScrollView(
        slivers: [
          // ── Hero AppBar ────────────────────────
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.35),
                child: const BackButton(color: Colors.white),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                service.name,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                  shadows: [const Shadow(blurRadius: 10, color: Colors.black45, offset: Offset(1, 1))],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  AppNetworkImage(
                    imageUrl: service.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black54, Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // ── Scrollable Body details ──────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Title & Emoji Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD0E4F7)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          service.iconEmoji ?? '🛠️',
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.name,
                                style: GoogleFonts.cairo(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0D1B2A),
                                ),
                              ),
                              Text(
                                service.category ?? 'خدمة عامة',
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  color: const Color(0xFF1565C0),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Gallery Photos Slider (horizontal)
                  if (service.galleryUrls.isNotEmpty) ...[
                    Text(
                      '🖼️ معرض الأعمال المنفّذة',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0D1B2A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: service.galleryUrls.length,
                        itemBuilder: (context, idx) {
                          return Container(
                            width: 180,
                            margin: const EdgeInsets.only(left: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFD0E4F7)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: AppNetworkImage(
                                imageUrl: service.galleryUrls[idx],
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Description Card
                  Text(
                    '📝 تفاصيل الخدمة',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0D1B2A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD0E4F7)),
                    ),
                    child: Text(
                      service.description.isNotEmpty ? service.description : 'لا يوجد تفاصيل تفصيلية لهذه الخدمة حالياً.',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: const Color(0xFF4A6080),
                        height: 1.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Options listing
                  if (service.options.isNotEmpty) ...[
                    Text(
                      '✨ الباقات والخيارات الإضافية المتاحة',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0D1B2A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: service.options.map((opt) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFD0E4F7)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      opt.name,
                                      style: GoogleFonts.cairo(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF0D1B2A),
                                      ),
                                    ),
                                    if (opt.description != null)
                                      Text(
                                        opt.description!,
                                        style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          color: const Color(0xFF8AACCC),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Text(
                                '+ ${CurrencyFormatter.format(opt.extraPrice)}',
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1D9E75),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Working Hours display
                  Text(
                    '⏰ أوقات وساعات تقديم الخدمة المتاحة',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0D1B2A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD0E4F7)),
                    ),
                    child: Column(
                      children: [
                        _buildWorkingHoursRow('السبت - الخميس', service.workingHours['sat'] ?? '08:00 - 20:00'),
                        const Divider(color: Color(0xFFE2EFFC)),
                        _buildWorkingHoursRow('الجمعة', service.workingHours['fri'] ?? '14:00 - 20:00'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80), // spacer for bottom button
                ],
              ),
            ),
          )
        ],
      ),
      bottomSheet: Consumer<ServiceProvider>(
        builder: (ctx, provider, _) {
          final isSelected = provider.isServiceSelected(service);
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: const Color(0xFFD0E4F7))),
            ),
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'التكلفة الإجمالية الأساسية',
                      style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF8AACCC)),
                    ),
                    Text(
                      CurrencyFormatter.format(service.basePrice),
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF1D9E75),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Toggle multi-select
                IconButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    provider.toggleServiceSelection(service);
                  },
                  icon: Icon(
                    isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                    color: isSelected ? const Color(0xFF1D9E75) : const Color(0xFF64748B),
                    size: 26,
                  ),
                  tooltip: 'إضافة للطلب المتعدد',
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final auth = Provider.of<AuthProvider>(context, listen: false);
                    if (!auth.isLoggedIn) {
                      Navigator.pushNamed(context, '/login');
                      return;
                    }
                    provider.clearServiceSelection();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ServiceRequestScreen(services: [service]),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    'احجز الخدمة الآن',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWorkingHoursRow(String day, String hours) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          day,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4A6080),
          ),
        ),
        Text(
          hours.replaceAll('-', ' إلى '),
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1565C0),
          ),
        ),
      ],
    );
  }
}
