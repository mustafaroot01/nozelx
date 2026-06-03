import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/core/utils/currency_formatter.dart';
import 'package:auto_lube/providers/cart_provider.dart';
import 'package:auto_lube/providers/app_settings_provider.dart';
import 'package:auto_lube/core/services/api_service.dart';
import 'package:auto_lube/core/widgets/app_network_image.dart';
import 'package:auto_lube/core/utils/image_url_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // ── Keys & Controllers ──────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // ── State ────────────────────────────────────────
  String _paymentMethod = 'cash';
  bool _isLoading = false;
  
  // ── Iraqi Governorates ───────────────────────────
  final List<String> _governorates = [
    'بغداد',
    'البصرة',
    'نينوى',
    'أربيل',
    'النجف',
    'كربلاء',
    'ذي قار',
    'بابل',
    'الأنبار',
    'السليمانية',
    'دهوك',
    'ديالى',
    'صلاح الدين',
    'كركوك',
    'واسط',
    'ميسان',
    'القادسية',
    'المثنى',
  ];
  String? _selectedGovernorate;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    AppSettingsProvider().fetchSettings().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataStr = prefs.getString('current_user');
      if (userDataStr != null) {
        final userData = json.decode(userDataStr);
        setState(() {
          _nameCtrl.text = userData['name'] ?? '';
          _phoneCtrl.text = userData['phone'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading user data in checkout: $e');
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // جلب CartProvider بشكل آمن
    final cart = context.watch<CartProvider>();
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),

      // ── AppBar ────────────────────────────────────
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
          'إتمام الطلب',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // ── الزر الثابت في الأسفل ─────────────────────
      bottomNavigationBar: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding + 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // الإجمالي
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'المبلغ الإجمالي',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                Text(
                  CurrencyFormatter.format(cart.total),
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // زر التأكيد
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitOrder,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.check_circle_outline_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                  label: Text(
                    _isLoading ? 'جارٍ التأكيد...' : 'تأكيد وشراء الطلب',
                    style: GoogleFonts.cairo(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    disabledBackgroundColor: const Color(0xFFD1D5DB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Body — SingleChildScrollView إلزامي ───────
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── ملخص الطلب المصغر ────────────────
                _buildOrderSummary(cart),
                const SizedBox(height: 16),

                // ── بيانات المستلم ───────────────────
                _buildSectionCard(
                  icon: Icons.person_outline_rounded,
                  title: 'بيانات المستلم',
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _nameCtrl,
                        label: 'الاسم الكامل',
                        icon: Icons.badge_outlined,
                        validator: (v) => v!.trim().isEmpty ? 'الاسم مطلوب' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _phoneCtrl,
                        label: 'رقم الهاتف',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          if (v!.trim().isEmpty) {
                            return 'رقم الهاتف مطلوب';
                          }
                          if (v.trim().length < 10) {
                            return 'رقم هاتف غير صحيح';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── عنوان التوصيل ────────────────────
                _buildSectionCard(
                  icon: Icons.location_on_outlined,
                  title: 'عنوان التوصيل',
                  child: Column(
                    children: [
                      _buildGovernorateDropdown(),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: _addressCtrl,
                        label: 'الحي / الشارع / أقرب نقطة دالة / رقم المنزل',
                        icon: Icons.map_outlined,
                        maxLines: 3,
                        validator: (v) => v!.trim().isEmpty ? 'تفاصيل العنوان مطلوبة' : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── طريقة الدفع ──────────────────────
                _buildSectionCard(
                  icon: Icons.payments_outlined,
                  title: 'طريقة الدفع',
                  child: _buildPaymentTile(
                    value: 'cash',
                    label: 'كاش عند الاستلام',
                    icon: Icons.money_rounded,
                  ),
                ),
                const SizedBox(height: 14),

                // ── ملاحظات ──────────────────────────
                _buildSectionCard(
                  icon: Icons.note_alt_outlined,
                  title: 'ملاحظات للمندوب (اختياري)',
                  child: _buildTextField(
                    controller: _notesCtrl,
                    label: 'أي تعليمات خاصة...',
                    icon: Icons.comment_outlined,
                    maxLines: 2,
                    validator: null,
                  ),
                ),
                const SizedBox(height: 14),

                // ── ملخص المبالغ ─────────────────────
                _buildPriceSummary(cart),

                // مسافة من الزر السفلي
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── ملخص الطلب المصغر ────────────────────────────
  Widget _buildOrderSummary(CartProvider cart) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBDEFB)),
      ),
      child: Row(
        children: [
          // صور المنتجات (حلقات متداخلة)
          if (cart.items.isNotEmpty)
            SizedBox(
              width: 60,
              height: 40,
              child: Stack(
                children: cart.items
                    .take(3)
                    .toList()
                    .asMap()
                    .entries
                    .map(
                      (e) => Positioned(
                        right: e.key * 18.0,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: AppNetworkImage(
                              imageUrl: ImageUrlHelper.productThumb(e.value.imageUrl),
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${cart.itemsCount} ${cart.itemsCount == 1 ? "منتج" : "منتجات"} في طلبك',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0D1B2A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'الإجمالي: ${CurrencyFormatter.format(cart.total)}',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: const Color(0xFF1565C0),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── بطاقة قسم ────────────────────────────────────
  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD0E4F7)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان القسم
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF1565C0), size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0D1B2A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // المحتوى
          child,
        ],
      ),
    );
  }

  Widget _buildGovernorateDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedGovernorate,
      items: _governorates.map((gov) {
        return DropdownMenuItem<String>(
          value: gov,
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              gov,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: const Color(0xFF0D1B2A),
              ),
            ),
          ),
        );
      }).toList(),
      onChanged: (val) {
        setState(() {
          _selectedGovernorate = val;
        });
      },
      validator: (v) => v == null ? 'يرجى اختيار المحافظة' : null,
      decoration: InputDecoration(
        labelText: 'المحافظة',
        prefixIcon: const Icon(Icons.map_outlined, color: Color(0xFF1565C0), size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FBFF),
        labelStyle: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF6B7280)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD0E4F7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD0E4F7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE24B4A)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
      ),
      isExpanded: true,
      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF1565C0)),
      dropdownColor: Colors.white,
    );
  }

  // ── حقل النص ─────────────────────────────────────
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      validator: validator,
      style: GoogleFonts.cairo(
        fontSize: 13,
        color: const Color(0xFF0D1B2A),
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1565C0), size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FBFF),
        labelStyle: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF6B7280)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD0E4F7)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD0E4F7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE24B4A)),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: maxLines > 1 ? 14 : 10,
        ),
      ),
    );
  }

  // ── خيار طريقة الدفع ─────────────────────────────
  Widget _buildPaymentTile({
    required String value,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _paymentMethod == value;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _paymentMethod = value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE3F2FD) : const Color(0xFFF8FBFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF1565C0) : const Color(0xFFD0E4F7),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF1565C0) : const Color(0xFF8AACCC),
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected ? const Color(0xFF1565C0) : const Color(0xFF4A6080),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFF1565C0) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFF1565C0) : const Color(0xFFD0E4F7),
                  width: 2,
                ),
              ),
              child: isSelected ? const Icon(Icons.check_rounded, color: Colors.white, size: 12) : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── ملخص المبالغ ──────────────────────────────────
  Widget _buildPriceSummary(CartProvider cart) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD0E4F7)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _priceRow('المجموع الفرعي', CurrencyFormatter.format(cart.subtotal)),
          const SizedBox(height: 8),
          _priceRow('رسوم التوصيل', CurrencyFormatter.format(cart.deliveryFee)),
          if (cart.couponDiscount > 0) ...[
            const SizedBox(height: 8),
            _priceRow(
              'خصم الكوبون',
              '- ${CurrencyFormatter.format(cart.couponDiscount)}',
              valueColor: const Color(0xFF1D9E75),
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFE3F2FD)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الإجمالي الكلي',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0D1B2A),
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: cart.total),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                builder: (_, val, __) => Text(
                  CurrencyFormatter.format(val),
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1565C0),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF6B7280))),
        Text(value,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: valueColor ?? const Color(0xFF0D1B2A),
            )),
      ],
    );
  }

  // ── إرسال الطلب ───────────────────────────────────
  Future<void> _submitOrder() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);

    try {
      final cart = context.read<CartProvider>();
      final prefs = await SharedPreferences.getInstance();
      final userDataStr = prefs.getString('current_user');
      Map<String, dynamic>? currentUser;
      if (userDataStr != null) {
        currentUser = json.decode(userDataStr);
      }
      final userId = currentUser != null ? int.tryParse(currentUser['id'].toString()) ?? 0 : 0;

      final result = await ApiService.createOrder(
        userId: userId,
        items: cart.items.map((e) => {'product_id': e.productId, 'quantity': e.quantity, 'price': e.price}).toList(),
        subtotal: cart.subtotal,
        discount: cart.totalDiscount,
        deliveryFee: cart.deliveryFee,
        total: cart.total,
        couponCode: cart.appliedCoupon?.code ?? '',
        paymentMethod: _paymentMethod,
        notes: _notesCtrl.text.trim(),
        customerName: _nameCtrl.text.trim(),
        customerPhone: _phoneCtrl.text.trim(),
        customerAddress: _addressCtrl.text.trim(),
        governorate: _selectedGovernorate ?? '',
      );

      if (result['success'] == true) {
        final orderData = result['data'] is Map ? result['data'] as Map<String, dynamic> : null;
        final orderId = orderData?['id']?.toString() ?? '';
        final totalAmount = double.tryParse(orderData?['total_amount']?.toString() ?? '') ?? cart.total;

        await cart.clearCart();

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/order-success',
            (route) => route.isFirst,
            arguments: {
              'orderNumber': '#$orderId',
              'totalAmount': totalAmount,
            },
          );
        }
      } else {
        throw Exception(result['message'] ?? 'فشل في إرسال الطلب');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطأ أثناء إرسال الطلب: ${e.toString().replaceAll('Exception: ', '')}',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: const Color(0xFFE24B4A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
