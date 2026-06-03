import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/service_model.dart';
import '../../providers/service_provider.dart';
import '../../providers/auth_provider.dart';
import '../../features/services/presentation/pages/service_success_screen.dart';

class ServiceRequestScreen extends StatefulWidget {
  final List<ServiceModel> services;
  
  // Backwards compatibility constructor
  ServiceRequestScreen({
    super.key,
    ServiceModel? service,
    List<ServiceModel>? services,
  }) : services = services ?? (service != null ? [service] : const []);

  @override
  State<ServiceRequestScreen> createState() => _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends State<ServiceRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  final Map<int, ServiceOptionModel?> _selectedOptions = {};
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  String _paymentMethod = 'cash';
  bool _submitting = false;

  String _cleanPhone(String phone) {
    String cleaned = phone.replaceAll(RegExp(r'\D'), ''); // Only digits
    if (cleaned.startsWith('964')) {
      cleaned = cleaned.substring(3);
    }
    if (cleaned.startsWith('7') && cleaned.length == 10) {
      cleaned = '0$cleaned';
    }
    return cleaned;
  }

  @override
  void initState() {
    super.initState();
    // Initialize default options to null for each service
    for (var s in widget.services) {
      _selectedOptions[s.id] = null;
    }
    
    // Autofill user profile if logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isLoggedIn && auth.user != null) {
        _nameCtrl.text = auth.user!.name;
        _phoneCtrl.text = _cleanPhone(auth.user!.phone);
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    // Get minimum booking days constraint
    final advanceDays = widget.services.isNotEmpty 
        ? widget.services.map((s) => s.advanceBookingDays).reduce((a, b) => a < b ? a : b)
        : 30;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(Duration(days: advanceDays)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1565C0),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0D1B2A),
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
              primary: Color(0xFF1565C0),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF0D1B2A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (picked.hour < 8 || picked.hour > 20) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'أوقات العمل المتاحة بين الساعة 8:00 صباحاً و 8:00 مساءً',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  double _getTotalPrice() {
    double total = 0.0;
    for (var s in widget.services) {
      total += s.basePrice;
      final opt = _selectedOptions[s.id];
      if (opt != null) {
        total += opt.extraPrice;
      }
    }
    return total;
  }

  void _submit() async {
    if (widget.services.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'الرجاء اختيار خدمة واحدة على الأقل',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'الرجاء التحقق من صحة الاسم ورقم الهاتف المدخلين',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    final dateStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    final timeStr = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    final servicesPayload = widget.services.map((s) {
      final opt = _selectedOptions[s.id];
      final double servicePrice = s.basePrice + (opt?.extraPrice ?? 0.0);
      return {
        'service_id': s.id,
        'service_option_id': opt?.id,
        'total_price': servicePrice,
      };
    }).toList();

    final payload = {
      'services': servicesPayload,
      'customer_name': _nameCtrl.text.trim(),
      'customer_phone': _cleanPhone(_phoneCtrl.text.trim()),
      'address': 'داخل المركز', // Automatically set to "داخل المركز"
      'scheduled_date': dateStr,
      'scheduled_time': timeStr,
      'notes': _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      'total_price': _getTotalPrice(),
      'payment_method': _paymentMethod,
    };

    final provider = context.read<ServiceProvider>();
    final result = await provider.bookService(payload);

    setState(() => _submitting = false);

    if (result['status'] == 'success') {
      // Clear multi-select cart on successful booking
      provider.clearServiceSelection();

      if (mounted) {
        final names = widget.services.map((s) => s.name).join(' + ');
        final optionsText = widget.services.map((s) => _selectedOptions[s.id]?.name ?? 'بدون إضافات').join(' ، ');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ServiceSuccessScreen(
              serviceName: names,
              date: _selectedDate,
              time: _selectedTime,
              totalCost: _getTotalPrice(),
              selectedOptionTitle: optionsText,
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'فشل تقديم طلب الحجز',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = const Color(0xFF1565C0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          'حجز موعد بالمركز',
          style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Services list header
              Text(
                '🛠️ الخدمات المختارة للحجز',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 8),

              // Services details list
              Column(
                children: widget.services.map((service) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(service.iconEmoji ?? '🛠️', style: const TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.name,
                                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF0F172A)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'حضور داخل المركز المعتمد',
                                style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey[500], fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'السعر الأساسي',
                              style: GoogleFonts.cairo(fontSize: 10, color: Colors.grey[400]),
                            ),
                            Text(
                              CurrencyFormatter.format(service.basePrice),
                              style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF1D9E75), fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Customer Details Block
              Text(
                '👤 بيانات الحجز والاتصال',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    // Name Field
                    TextFormField(
                      controller: _nameCtrl,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.cairo(fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'الاسم الكامل للعميل',
                        labelStyle: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[500]),
                        prefixIcon: Icon(Icons.person_outline_rounded, color: primaryBlue, size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'الرجاء إدخال الاسم الكامل' : null,
                    ),
                    const SizedBox(height: 14),
                    // Phone Field
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      textAlign: TextAlign.left,
                      style: GoogleFonts.cairo(fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'رقم الهاتف (11 رقم يبدأ بـ 07)',
                        labelStyle: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[500]),
                        prefixIcon: Icon(Icons.phone_iphone_rounded, color: primaryBlue, size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'الرجاء إدخال رقم الهاتف';
                        final cleaned = _cleanPhone(v.trim());
                        if (cleaned.length != 11 || !cleaned.startsWith('07')) {
                          return 'رقم الهاتف غير صحيح (11 رقماً ويبدأ بـ 07)';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Date & Time Selectors
              Text(
                '📅 موعد الحضور للمركز',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _selectDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.calendar_month_rounded, color: primaryBlue, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF334155)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _selectTime,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.access_time_filled_rounded, color: primaryBlue, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')} ${_selectedTime.period == DayPeriod.am ? 'صباحاً' : 'مساءً'}',
                                style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF334155)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Options selectors per service
              for (var service in widget.services) ...[
                if (service.options.isNotEmpty) ...[
                  Text(
                    '✨ باقات إضافية لخدمة: ${service.name}',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        RadioListTile<ServiceOptionModel?>(
                          value: null,
                          groupValue: _selectedOptions[service.id],
                          onChanged: (val) => setState(() => _selectedOptions[service.id] = val),
                          title: Text('بدون إضافات', style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF334155))),
                          subtitle: Text('تقديم الخدمة الأساسية والمدة المقررة فقط', style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey[500])),
                          activeColor: primaryBlue,
                        ),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        ...service.options.map((opt) {
                          return Column(
                            children: [
                              RadioListTile<ServiceOptionModel?>(
                                value: opt,
                                groupValue: _selectedOptions[service.id],
                                onChanged: (val) => setState(() => _selectedOptions[service.id] = val),
                                title: Text(opt.name, style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF334155))),
                                subtitle: Text(
                                  '${opt.description ?? ""} (+ ${CurrencyFormatter.format(opt.extraPrice)})',
                                  style: GoogleFonts.cairo(fontSize: 11, color: primaryBlue, fontWeight: FontWeight.w500),
                                ),
                                activeColor: primaryBlue,
                              ),
                              if (opt != service.options.last)
                                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ],

              // Notes & Payment details
              Text(
                '📝 ملاحظات وطريقة الدفع',
                style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Notes field
                    TextFormField(
                      controller: _notesCtrl,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      style: GoogleFonts.cairo(fontSize: 12),
                      decoration: InputDecoration(
                        labelText: 'أي ملاحظات أو طلبات خاصة للمركز (اختياري)',
                        labelStyle: GoogleFonts.cairo(fontSize: 11, color: Colors.grey[500]),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'طريقة الدفع المعمدة بالمركز',
                      style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _paymentMethod,
                      style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF334155), fontWeight: FontWeight.bold),
                      onChanged: (val) => setState(() => _paymentMethod = val!),
                      items: [
                        DropdownMenuItem(
                          value: 'cash',
                          child: Text('دفع كاش مباشر في المركز', style: GoogleFonts.cairo(fontSize: 13)),
                        ),
                        DropdownMenuItem(
                          value: 'zaincash',
                          child: Text('دفع عبر زين كاش محفظة إلكترونية', style: GoogleFonts.cairo(fontSize: 13)),
                        ),
                      ],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Total & Submit button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.05),
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
                        Text('سعر الخدمات الأساسية', style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[500])),
                        Text(
                          CurrencyFormatter.format(widget.services.fold(0.0, (sum, s) => sum + s.basePrice)),
                          style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF334155)),
                        ),
                      ],
                    ),
                    if (_selectedOptions.values.any((opt) => opt != null)) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('إجمالي إضافات الباقات', style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[500])),
                          Text(
                            '+ ${CurrencyFormatter.format(_selectedOptions.values.fold(0.0, (sum, opt) => sum + (opt?.extraPrice ?? 0.0)))}',
                            style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.w600, color: primaryBlue),
                          ),
                        ],
                      ),
                    ],
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('المبلغ الكلي المستحق بالمركز', style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                        Text(
                          CurrencyFormatter.format(_getTotalPrice()),
                          style: GoogleFonts.cairo(fontSize: 17, fontWeight: FontWeight.w900, color: const Color(0xFF1D9E75)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          shadowColor: primaryBlue.withOpacity(0.3),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : Text(
                                'تأكيد وحجز الموعد',
                                style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
