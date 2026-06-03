import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/core/services/user_stats_service.dart';
import 'package:auto_lube/features/services/data/services_data.dart';
import 'package:auto_lube/core/utils/currency_formatter.dart';
import 'package:auto_lube/core/widgets/app_network_image.dart';
import 'package:auto_lube/core/utils/image_url_helper.dart';
import 'service_success_screen.dart';

class BookingOption {
  final String id;
  final String title;
  final String description;
  final double price;

  const BookingOption({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
  });
}

class BookingScreen extends StatefulWidget {
  final CenterService service;
  final List<CenterService> selectedServices;

  const BookingScreen({
    super.key,
    required this.service,
    this.selectedServices = const [],
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _carModelController = TextEditingController();
  final _carNumberController = TextEditingController();
  final _notesController = TextEditingController();

  final List<String> _districts = [
    'السماوة',
    'الرميثة',
    'الخضر',
    'الوركاء',
    'السلمان',
    'بصية',
    'أخرى',
  ];

  final List<BookingOption> _options = const [
    BookingOption(
      id: 'standard',
      title: 'الخدمة القياسية',
      description: 'الخدمة الأساسية المطلوبة مع فحص عام للمركبة',
      price: 0,
    ),
    BookingOption(
      id: 'premium',
      title: 'العناية المميزة',
      description: 'إضافة تلميع وتنظيف داخلي للمركبة مع فحص دقيق للزيوت والفرامل',
      price: 5000,
    ),
    BookingOption(
      id: 'home',
      title: 'الخدمة المنزلية',
      description: 'حضور فريق الخدمة الميداني إلى موقعك للقيام بكافة الأعمال',
      price: 10000,
    ),
  ];

  String? _selectedDistrict;
  String _selectedOptionId = 'standard';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _carModelController.dispose();
    _carNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'صباحاً' : 'مساءً';
    return '$hour:$minute $period';
  }

  double _getOptionPrice() {
    return _options.firstWhere((o) => o.id == _selectedOptionId).price;
  }

  double _getTotalCost() {
    final services = widget.selectedServices.isNotEmpty 
        ? widget.selectedServices 
        : [widget.service];
    final servicesPrice = services.fold<double>(0.0, (sum, s) => sum + s.price);
    return servicesPrice + _getOptionPrice();
  }

  String _getSelectedOptionTitle() {
    return _options.firstWhere((o) => o.id == _selectedOptionId).title;
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = await UserStatsService.getCurrentUserId();
      if (userId <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('يرجى تسجيل الدخول أولاً لإكمال الحجز', style: GoogleFonts.cairo()),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final dateStr =
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
      final timeStr =
          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00';

      final servicesToBook = widget.selectedServices.isNotEmpty 
          ? widget.selectedServices 
          : [widget.service];

      List<Future<Map<String, dynamic>>> bookingFutures = [];
      
      for (final s in servicesToBook) {
        final customNotes = 'باقة الخدمة: ${_getSelectedOptionTitle()}. ' + _notesController.text.trim();
        bookingFutures.add(ServicesApi.bookAppointment(
          userId: userId,
          serviceId: s.id,
          carModel: _carModelController.text.trim(),
          carNumber: _carNumberController.text.trim(),
          preferredDate: dateStr,
          preferredTime: timeStr,
          customerName: _nameController.text.trim(),
          customerPhone: _phoneController.text.trim(),
          customerDistrict: _selectedDistrict,
          notes: customNotes,
        ));
      }

      final results = await Future.wait(bookingFutures);
      final allSuccess = results.every((res) => res['success'] == true);

      if (mounted) {
        setState(() => _isLoading = false);

        if (allSuccess) {
          // Push ServiceSuccessScreen with combined service names
          final serviceNames = servicesToBook.map((s) => s.name).join(' + ');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceSuccessScreen(
                serviceName: serviceNames,
                date: _selectedDate,
                time: _selectedTime,
                totalCost: _getTotalCost(),
                selectedOptionTitle: _getSelectedOptionTitle(),
              ),
            ),
          );
        } else {
          // If some failed
          final failedMsg = results.firstWhere((res) => res['success'] == false, orElse: () => {'message': 'فشل تأكيد الحجز'})['message'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failedMsg ?? 'فشل تأكيد الحجز، يرجى المحاولة لاحقاً', style: GoogleFonts.cairo()),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء الاتصال بالخادم، يرجى المحاولة مرة أخرى', style: GoogleFonts.cairo()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double basePrice = widget.service.price.toDouble();
    final double totalCost = _getTotalCost();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'حجز موعد الخدمة',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _SelectedServiceHeader(
                  service: widget.service,
                  selectedServices: widget.selectedServices,
                ),
                const SizedBox(height: 16),
                _OptionsSelector(
                  options: _options,
                  selectedId: _selectedOptionId,
                  onSelected: (id) => setState(() => _selectedOptionId = id),
                ),
                const SizedBox(height: 16),
                _DateTimePickerCard(
                  selectedDate: _selectedDate,
                  selectedTime: _selectedTime,
                  onTapDate: _selectDate,
                  onTapTime: _selectTime,
                  formatDate: _formatDate,
                  formatTime: _formatTime,
                ),
                const SizedBox(height: 16),
                _buildContactInfo(),
                const SizedBox(height: 16),
                _buildCarInfo(),
                const SizedBox(height: 16),
                _buildCostSummary(basePrice, _getOptionPrice(), totalCost),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(totalCost),
    );
  }

  Widget _buildContactInfo() {
    return _SectionCard(
      icon: Icons.person_outline,
      title: 'معلومات الاتصال بالعميل',
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'الاسم الكامل ثلاثي',
            icon: Icons.badge_outlined,
            validator: (v) => v == null || v.trim().isEmpty ? 'يرجى إدخال اسمك الكامل' : null,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _phoneController,
            label: 'رقم الهاتف الفعال',
            icon: Icons.phone_android_outlined,
            keyboardType: TextInputType.phone,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'يرجى إدخال رقم الهاتف';
              if (v.trim().length < 10) return 'رقم الهاتف غير صالح';
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildDistrictDropdown(),
        ],
      ),
    );
  }

  Widget _buildCarInfo() {
    return _SectionCard(
      icon: Icons.directions_car_filled_outlined,
      title: 'بيانات سيارتك',
      child: Column(
        children: [
          _buildTextField(
            controller: _carModelController,
            label: 'نوع وموديل السيارة (مثال: كيا سورينتو 2021)',
            icon: Icons.car_repair_outlined,
            validator: (v) => v == null || v.trim().isEmpty ? 'يرجى إدخال موديل السيارة' : null,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _carNumberController,
            label: 'رقم لوحة السيارة (مثال: بغداد 12345 أ)',
            icon: Icons.numbers_outlined,
            validator: (v) => v == null || v.trim().isEmpty ? 'يرجى إدخال رقم السيارة' : null,
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceBlue.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryPale),
            ),
            child: TextFormField(
              controller: _notesController,
              maxLines: 2,
              style: GoogleFonts.cairo(fontSize: 14),
              decoration: InputDecoration(
                labelText: 'أي ملاحظات أو طلبات خاصة (اختياري)',
                labelStyle: GoogleFonts.cairo(fontSize: 13, color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.note_alt_outlined, color: AppColors.primary, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistrictDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceBlue.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryPale),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedDistrict,
        hint: Text('المنطقة / القضاء', style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textSecondary)),
        items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d, style: GoogleFonts.cairo(fontSize: 13)))).toList(),
        onChanged: (v) => setState(() => _selectedDistrict = v),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        validator: (v) => v == null || v.isEmpty ? 'يرجى تحديد المنطقة' : null,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceBlue.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryPale),
      ),
      child: TextFormField(
        controller: controller,
        style: GoogleFonts.cairo(fontSize: 14),
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.cairo(fontSize: 13, color: AppColors.textSecondary),
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildCostSummary(double base, double option, double total) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفاصيل التكلفة التقديرية',
            style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('تكلفة الخدمة الأساسية', base),
          if (option > 0) _buildSummaryRow('تكلفة الباقة الإضافية', option, isHighlight: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الإجمالي التقريبي الكلي', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text(CurrencyFormatter.formatIQD(total), style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double val, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textSecondary)),
          Text(
            CurrencyFormatter.formatIQD(val),
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
              color: isHighlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(double totalCost) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('تكلفة الحجز التقريبية', style: GoogleFonts.cairo(fontSize: 12, color: AppColors.textSecondary)),
                Text(
                  CurrencyFormatter.formatIQD(totalCost),
                  style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: SizedBox(
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
                    onPressed: _isLoading ? null : _submitBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.event_note),
                              const SizedBox(width: 8),
                              Text(
                                'تأكيد وحجز الموعد',
                                style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── WIDGET: SELECTED SERVICE HEADER ─────────────────────────────────────────────
class _SelectedServiceHeader extends StatelessWidget {
  final CenterService service;
  final List<CenterService> selectedServices;

  const _SelectedServiceHeader({
    required this.service,
    this.selectedServices = const [],
  });

  @override
  Widget build(BuildContext context) {
    final services = selectedServices.isNotEmpty ? selectedServices : [service];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryPale),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الخدمات المطلوبة',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: services.length,
            separatorBuilder: (_, __) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1),
            ),
            itemBuilder: (context, index) {
              final s = services[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.primaryGhost,
                      border: Border.all(color: AppColors.primaryPale),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: s.image != null && s.image!.isNotEmpty
                          ? AppNetworkImage(imageUrl: ImageUrlHelper.service(s.image), fit: BoxFit.cover)
                          : const Center(child: Icon(Icons.settings, color: AppColors.primary, size: 24)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.name,
                          style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        Text(
                          'مدة الخدمة: ${s.durationMinutes} دقيقة',
                          style: GoogleFonts.cairo(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    s.price == 0 ? 'مجاني' : '${CurrencyFormatter.formatIQD(s.price.toDouble())}',
                    style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── WIDGET: OPTIONS SELECTOR ────────────────────────────────────────────────────
class _OptionsSelector extends StatelessWidget {
  final List<BookingOption> options;
  final String selectedId;
  final ValueChanged<String> onSelected;

  const _OptionsSelector({
    required this.options,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Text(
            'اختر باقة الخدمة الإضافية',
            style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final opt = options[index];
              final isSelected = opt.id == selectedId;
              return Padding(
                padding: const EdgeInsets.only(left: 12),
                child: GestureDetector(
                  onTap: () => onSelected(opt.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 170,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [BoxShadow(color: AppColors.primary.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))]
                          : [],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              opt.title,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                            if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary, size: 18),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Text(
                            opt.description,
                            style: GoogleFonts.cairo(fontSize: 10, color: AppColors.textSecondary, height: 1.3),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          opt.price == 0 ? 'مجانياً' : '+ ' + CurrencyFormatter.formatIQD(opt.price),
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: opt.price == 0 ? AppColors.success : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── WIDGET: DATETIME PICKER CARD ────────────────────────────────────────────────
class _DateTimePickerCard extends StatelessWidget {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final VoidCallback onTapDate;
  final VoidCallback onTapTime;
  final String Function(DateTime) formatDate;
  final String Function(TimeOfDay) formatTime;

  const _DateTimePickerCard({
    required this.selectedDate,
    required this.selectedTime,
    required this.onTapDate,
    required this.onTapTime,
    required this.formatDate,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تحديد موعد الخدمة',
            style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onTapDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGhost,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryPale),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('التاريخ المفضل', style: GoogleFonts.cairo(fontSize: 10, color: AppColors.textSecondary)),
                              const SizedBox(height: 2),
                              Text(
                                formatDate(selectedDate),
                                style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: onTapTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGhost,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryPale),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time_filled, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('الوقت المفضل', style: GoogleFonts.cairo(fontSize: 10, color: AppColors.textSecondary)),
                              const SizedBox(height: 2),
                              Text(
                                formatTime(selectedTime),
                                style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── WIDGET: SECTION CARD (REUSABLE) ─────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGhost,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
