import 'dart:async';
import 'package:flutter/material.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/core/widgets/app_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_lube/features/profile/data/services/account_service.dart';
import 'package:auto_lube/core/utils/currency_formatter.dart';
import 'package:auto_lube/core/services/api_service.dart';
import 'package:auto_lube/core/services/live_update_service.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  Map<String, dynamic>? _orderData;
  bool _isLoading = true;
  String? _error;
  StreamSubscription? _orderSubscription;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetails();
    _subscribeToOrderUpdates();
  }

  void _subscribeToOrderUpdates() {
    _orderSubscription = LiveUpdateService.orderUpdates.listen((event) {
      if (event['order_id']?.toString() == widget.orderId) {
        debugPrint('Real-time update received for order ${widget.orderId}: $event');
        _fetchOrderDetails();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم تحديث حالة الطلب إلى: ${_getStatusText(event['status']?.toString() ?? '')}',
                style: GoogleFonts.cairo(),
              ),
              backgroundColor: _getStatusColor(event['status']?.toString() ?? 'pending'),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchOrderDetails() async {
    try {
      final orderIdInt = int.tryParse(widget.orderId);
      if (orderIdInt == null) {
        setState(() {
          _error = 'رقم الطلب غير صالح';
          _isLoading = false;
        });
        return;
      }
      final data = await AccountService.getOrderById(orderIdInt);
      if (data != null) {
        setState(() {
          _orderData = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'فشل جلب تفاصيل الطلب';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'خطأ في الاتصال: $e';
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
      case 'completed':
        return AppColors.success;
      case 'shipped':
        return AppColors.info;
      case 'processing':
        return AppColors.warning;
      case 'pending':
        return AppColors.primary;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'تم الطلب';
      case 'processing':
        return 'قيد التجهيز';
      case 'shipped':
        return 'تم الشحن';
      case 'delivered':
      case 'completed':
        return 'تم التوصيل';
      case 'cancelled':
        return 'تم الإلغاء';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
      case 'completed':
        return Icons.check_circle;
      case 'shipped':
        return Icons.local_shipping;
      case 'processing':
        return Icons.inventory;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }

  String _formatDate(dynamic dateVal) {
    if (dateVal == null) return '';
    final parsed = DateTime.tryParse(dateVal.toString());
    if (parsed == null) return dateVal.toString();
    return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')} ${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
  }

  String _getProductImageUrl(Map<String, dynamic> product) {
    final image = product['image'] ?? product['image_url'] ?? '';
    if (image.toString().isEmpty) {
      return '';
    }
    if (image.toString().startsWith('http')) {
      return image.toString();
    }
    return '${ApiService.storageUrl}/${image.toString().replaceFirst(RegExp(r'^/'), '')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: BackButton(onPressed: () => Navigator.of(context).pop()),
          title: Text(
            'تفاصيل الطلب #${widget.orderId}',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    if (_error != null || _orderData == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: BackButton(onPressed: () => Navigator.of(context).pop()),
          title: Text(
            'تفاصيل الطلب #${widget.orderId}',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.error,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _error ?? 'فشل تحميل تفاصيل الطلب',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _fetchOrderDetails();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: Text(
                  'إعادة المحاولة',
                  style: GoogleFonts.cairo(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final orderData = _orderData!;
    final status = orderData['status']?.toString() ?? 'pending';
    final statusColor = _getStatusColor(status);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        title: Text(
          'تفاصيل الطلب #${orderData['id']}',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Status Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    statusColor.withOpacity(0.1),
                    statusColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Icon(
                      _getStatusIcon(status),
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getStatusText(status),
                    style: GoogleFonts.cairo(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'تاريخ الطلب: ${_formatDate(orderData['created_at'])}',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Timeline
            _buildTimeline(orderData),

            // Delivery Address
            _buildSectionTitle('عنوان التوصيل'),
            _buildAddressCard(orderData),

            // Payment Method
            _buildSectionTitle('طريقة الدفع'),
            _buildPaymentCard(orderData),

            // Order Items
            _buildSectionTitle('المنتجات'),
            _buildProductsList(orderData),

            // Order Summary
            _buildSectionTitle('ملخص الطلب'),
            _buildOrderSummary(orderData),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(Map<String, dynamic> orderData) {
    final String status = orderData['status']?.toString().toLowerCase() ?? 'pending';
    final String createdAtStr = _formatDate(orderData['created_at']);
    final String updatedAtStr = _formatDate(orderData['updated_at']);

    List<Map<String, dynamic>> timeline = [];
    if (status == 'cancelled') {
      timeline = [
        {'status': 'تم الطلب', 'date': createdAtStr, 'completed': true},
        {'status': 'تم الإلغاء', 'date': updatedAtStr, 'completed': true, 'isError': true},
      ];
    } else {
      timeline = [
        {
          'status': 'تم الطلب',
          'date': createdAtStr,
          'completed': true,
        },
        {
          'status': 'قيد التجهيز',
          'date': (status == 'processing' || status == 'shipped' || status == 'delivered' || status == 'completed') ? updatedAtStr : '',
          'completed': status == 'processing' || status == 'shipped' || status == 'delivered' || status == 'completed',
        },
        {
          'status': 'تم الشحن',
          'date': (status == 'shipped' || status == 'delivered' || status == 'completed') ? updatedAtStr : '',
          'completed': status == 'shipped' || status == 'delivered' || status == 'completed',
        },
        {
          'status': 'تم التوصيل',
          'date': (status == 'delivered' || status == 'completed') ? updatedAtStr : '',
          'completed': status == 'delivered' || status == 'completed',
        },
      ];
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تتبع الطلب',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: timeline.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == timeline.length - 1;
              final isCompleted = item['completed'] as bool;
              final isError = item['isError'] == true;
              final indicatorColor = isCompleted 
                  ? (isError ? AppColors.error : AppColors.success) 
                  : AppColors.border;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline indicator
                  Column(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: indicatorColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 40,
                          color: isCompleted
                              ? indicatorColor.withOpacity(0.3)
                              : AppColors.border,
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['status'] as String,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: isCompleted
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isCompleted
                                  ? (isError ? AppColors.error : AppColors.textPrimary)
                                  : AppColors.textTertiary,
                            ),
                          ),
                          if ((item['date'] as String).isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              item['date'] as String,
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Text(
        title,
        style: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> orderData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.location_on, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderData['customer_name']?.toString() ?? 'العميل',
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (orderData['customer_address'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    orderData['customer_address'].toString(),
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (orderData['customer_phone'] != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    orderData['customer_phone'].toString(),
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> orderData) {
    final paymentMethod = orderData['payment_method']?.toString() ?? 'الدفع عند الاستلام';
    String displayPaymentMethod = paymentMethod;
    if (paymentMethod == 'cash') {
      displayPaymentMethod = 'الدفع عند الاستلام';
    } else if (paymentMethod == 'wallet') {
      displayPaymentMethod = 'المحفظة الإلكترونية';
    } else if (paymentMethod == 'card') {
      displayPaymentMethod = 'بطاقة ائتمانية';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.payment, color: AppColors.secondary),
          ),
          const SizedBox(width: 12),
          Text(
            displayPaymentMethod,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(Map<String, dynamic> orderData) {
    final itemsList = orderData['order_items'] ?? orderData['orderItems'] ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: (itemsList as List).map((item) {
          final product = item['product'] ?? {};
          final quantity = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
          final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
          final String imageUrl = _getProductImageUrl(product);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.background,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imageUrl.isNotEmpty
                        ? AppNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: const Icon(
                              Icons.image_not_supported,
                              color: AppColors.textSecondary,
                            ),
                          )
                        : const Icon(
                            Icons.image,
                            color: AppColors.textSecondary,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name_ar'] ?? product['name'] ?? 'منتج',
                        style: GoogleFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'الكمية: $quantity',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  CurrencyFormatter.formatIQD(price),
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrderSummary(Map<String, dynamic> orderData) {
    final itemsList = orderData['order_items'] ?? orderData['orderItems'] ?? [];
    double subtotal = 0.0;
    for (var item in itemsList) {
      final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0.0;
      final qty = int.tryParse(item['quantity']?.toString() ?? '1') ?? 1;
      subtotal += price * qty;
    }

    final total = double.tryParse(orderData['total_amount']?.toString() ?? '0') ?? 0.0;
    final deliveryFee = total > subtotal ? total - subtotal : 0.0;
    final discount = subtotal > total ? subtotal - total : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildSummaryRow('المجموع الفرعي', subtotal),
          if (deliveryFee > 0) ...[
            const SizedBox(height: 12),
            _buildSummaryRow('رسوم التوصيل', deliveryFee),
          ],
          if (discount > 0) ...[
            const SizedBox(height: 12),
            _buildSummaryRow('الخصم', discount, isDiscount: true),
          ],
          const SizedBox(height: 16),
          Container(height: 1, color: AppColors.divider),
          const SizedBox(height: 16),
          _buildSummaryRow('الإجمالي', total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isTotal = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: isTotal ? 18 : 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          isDiscount ? '- ${CurrencyFormatter.formatIQD(value)}' : CurrencyFormatter.formatIQD(value),
          style: GoogleFonts.cairo(
            fontSize: isTotal ? 20 : 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal 
                ? AppColors.primary 
                : (isDiscount ? AppColors.success : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
