import 'package:flutter/material.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:auto_lube/features/profile/data/services/account_service.dart';
import 'package:google_fonts/google_fonts.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  int selectedTab = 0;

  List<Map<String, dynamic>> allOrders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => isLoading = true);
    try {
      final fetchedOrders = await AccountService.getOrders();
      setState(() {
        allOrders = fetchedOrders;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Error fetching orders: $e');
    }
  }

  final List<String> tabs = ['الكل', 'قيد التجهيز', 'تم الشحن', 'تم التوصيل'];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'delivered':
        return AppColors.success;
      case 'shipped':
        return AppColors.info;
      case 'processing':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
        return 'تم التوصيل';
      case 'shipped':
        return 'تم الشحن';
      case 'processing':
        return 'قيد التجهيز';
      case 'pending':
        return 'قيد المراجعة';
      case 'cancelled':
        return 'تم الإلغاء';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        title: Text(
          'طلباتي',
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          // Tabs
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(
                bottom: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: tabs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tab = entry.value;
                  final isSelected = selectedTab == index;
                  return GestureDetector(
                    onTap: () => setState(() => selectedTab = index),
                    child: Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppColors.primaryGradient : null,
                        color: isSelected ? null : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected
                            ? null
                            : Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        tab,
                        style: GoogleFonts.cairo(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Orders List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : allOrders.isEmpty
                    ? _buildEmptyOrders()
                    : RefreshIndicator(
                        onRefresh: _fetchOrders,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: allOrders.length,
                          itemBuilder: (context, index) {
                            final order = allOrders[index];
                            // Apply tab filter
                            if (selectedTab != 0) {
                              final status = order['status']?.toString().toLowerCase() ?? '';
                              if (selectedTab == 1 && status != 'processing') return const SizedBox.shrink();
                              if (selectedTab == 2 && status != 'shipped') return const SizedBox.shrink();
                              if (selectedTab == 3 && status != 'delivered') return const SizedBox.shrink();
                            }
                            return _buildOrderCard(order);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyOrders() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.receipt_long,
              size: 50,
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'لا توجد طلبات',
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لم تقم بأي طلبات بعد',
            style: GoogleFonts.cairo(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 180,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/products'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'تسوق الآن',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final statusColor = _getStatusColor(order['status'] as String);

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/order-details',
        arguments: {'orderId': order['id'].toString()},
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'طلب #${order['id']}',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getStatusText(order['status'] as String),
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Date
            Text(
              order['created_at'] != null 
                  ? DateTime.parse(order['created_at']).toString().split('.')[0]
                  : 'تاريخ غير معروف',
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 12),

            // Products Preview
            if (order['order_items'] != null)
              ...(order['order_items'] as List).take(2).map((item) {
                final product = item['product'] ?? {};
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${product['name_ar'] ?? product['name'] ?? 'منتج'} × ${item['quantity']}',
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${item['price']} د.ع',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }),

            if (order['order_items'] != null && (order['order_items'] as List).length > 2)
              Text(
                '+${(order['order_items'] as List).length - 2} منتجات أخرى',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),

            const SizedBox(height: 12),

            // Divider
            Container(height: 1, color: AppColors.divider),

            const SizedBox(height: 12),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(order['order_items'] as List? ?? []).length} منتجات',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'الإجمالي: ',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${order['total_amount']} د.ع',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
