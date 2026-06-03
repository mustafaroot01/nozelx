import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/colors.dart';
import '../../data/models/service_model.dart';
import '../providers/service_provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_lube/core/widgets/app_network_image.dart';
import 'package:auto_lube/core/utils/image_url_helper.dart';

class ServiceDetailSheet extends StatefulWidget {
  final ServiceModel service;

  const ServiceDetailSheet({super.key, required this.service});

  @override
  State<ServiceDetailSheet> createState() => _ServiceDetailSheetState();

  static Future<void> show(BuildContext context, ServiceModel service) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ServiceDetailSheet(service: service),
    );
  }
}

class _ServiceDetailSheetState extends State<ServiceDetailSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _prefillUserData();
  }

  Future<void> _prefillUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataStr = prefs.getString('current_user');
    if (userDataStr != null) {
      final userData = json.decode(userDataStr);
      setState(() {
        _nameController.text = userData['name'] ?? '';
        _phoneController.text = userData['phone'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final bookingData = {
      'service_id': widget.service.id,
      'customer_name': _nameController.text,
      'customer_phone': _phoneController.text,
      'notes': _notesController.text,
    };

    final result = await Provider.of<ServiceProvider>(context, listen: false).bookService(bookingData);

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (result['status'] == 'success') {
      Navigator.pop(context);
      _showSuccessDialog(result['message']);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'فشل إرسال الطلب')),
      );
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Icon(Icons.check_circle, color: AppColors.success, size: 48),
        content: Text(message, textAlign: TextAlign.center, style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('حسناً', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDragHandle(),
          _buildImage(),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 12),
                  _buildDescription(),
                  const Divider(height: 32),
                  _buildBookingForm(),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
    );
  }

  Widget _buildImage() {
    final imageUrl = widget.service.image ?? '';

    return AppNetworkImage(
      imageUrl: ImageUrlHelper.service(imageUrl),
      width: double.infinity,
      height: 200,
      fit: BoxFit.cover,
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            widget.service.titleAr,
            style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        if (widget.service.price != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${widget.service.price!.toInt()} د.ع',
              style: GoogleFonts.cairo(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.service.descriptionAr ?? '',
      style: GoogleFonts.cairo(fontSize: 14, color: AppColors.textSecondary, height: 1.6),
    );
  }

  Widget _buildBookingForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('معلومات الحجز', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTextField(controller: _nameController, label: 'الاسم الكامل', icon: Icons.person),
          const SizedBox(height: 12),
          _buildTextField(controller: _phoneController, label: 'رقم الهاتف', icon: Icons.phone, keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          _buildTextField(controller: _notesController, label: 'ملاحظات إضافية', icon: Icons.note, maxLines: 3),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.cairo(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.cairo(fontSize: 14, color: AppColors.textTertiary),
        prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.surfaceVariant.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      validator: (v) => v?.isEmpty ?? true ? 'هذا الحقل مطلوب' : null,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text('حجز الآن', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
