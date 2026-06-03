import 'package:flutter/material.dart';
import 'package:auto_lube/core/theme/colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:auto_lube/core/config/app_settings.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  String _selectedCategory = 'الكل';

  final List<Map<String, dynamic>> faqs = [
    {
      'category': 'الطلبات',
      'question': 'كيف أتبع طلبي؟',
      'answer':
          'يمكنك تتبع طلبك من خلال الدخول على "طلباتي" في حسابك أو من خلال رقم التتبع الذي إرسال لك عبر SMS.',
    },
    {
      'category': 'الدفع',
      'question': 'ما طرق الدفع المتاحة؟',
      'answer':
          'نقبل الدفع نقداً عند الاستلام، والبطاقات الائتمانية (فيزا، ماستركارد)، والمحافظ الإلكترونية.',
    },
    {
      'category': 'التوصيل',
      'question': 'كم يستغرق التوصيل؟',
      'answer':
          'التوصيل يستغرق 2-5 أيام عمل داخل بغداد، و3-7 أيام للمحافظات الأخرى.',
    },
    {
      'category': 'الإرجاع',
      'question': 'هل يمكن إرجاع المنتج؟',
      'answer':
          'نعم، يمكنك إرجاع المنتج خلال 14 يوماً من تاريخ الاستلام إذا كان في حالته الأصلية.',
    },
    {
      'category': 'الطلبات',
      'question': 'كيف ألغي طلبي؟',
      'answer':
          'يمكنك إلغاء طلبك قبل الشحن بالاتصال بخدمة العملاء أو من خلال حسابك.',
    },
    {
      'category': 'الحساب',
      'question': 'كيف أنشئ حساباً؟',
      'answer':
          'يمكنك إنشاء حساب من خلال الضغط على "تسجيل الدخول" ثم اختيار "إنشاء حساب جديد".',
    },
  ];

  final List<String> categories = [
    'الكل',
    'الطلبات',
    'الدفع',
    'التوصيل',
    'الإرجاع',
    'الحساب',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        title: Text(
          'المساعدة والدعم',
          style: GoogleFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              decoration: InputDecoration(
                icon: const Icon(Icons.search, color: AppColors.textSecondary),
                hintText: 'ابحث عن سؤالك...',
                hintStyle: GoogleFonts.cairo(color: AppColors.textTertiary),
                border: InputBorder.none,
              ),
            ),
          ),
          // Categories
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedCategory == categories[index];
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedCategory = categories[index]),
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        categories[index],
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // FAQs
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _selectedCategory == 'الكل'
                  ? faqs.length
                  : faqs
                        .where((f) => f['category'] == _selectedCategory)
                        .length,
              itemBuilder: (context, index) {
                final filteredFaqs = _selectedCategory == 'الكل'
                    ? faqs
                    : faqs
                          .where((f) => f['category'] == _selectedCategory)
                          .toList();
                return _buildFAQItem(filteredFaqs[index]);
              },
            ),
          ),
          // Contact Options
          _buildContactOptions(),
        ],
      ),
    );
  }

  Widget _buildFAQItem(Map<String, dynamic> faq) {
    return ExpansionTile(
      title: Text(
        faq['question'] as String,
        style: GoogleFonts.cairo(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            faq['answer'] as String,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildContactButton(
              icon: Icons.chat,
              label: 'دردشة',
              color: AppColors.primary,
              onTap: () => _launchURL('https://wa.me/${AppSettings().storePhone.replaceAll('+', '').replaceAll(' ', '').trim()}'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildContactButton(
              icon: Icons.phone,
              label: 'اتصال',
              color: AppColors.success,
              onTap: () => _launchURL('tel:${AppSettings().storePhone.trim()}'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildContactButton(
              icon: Icons.email,
              label: 'بريد',
              color: AppColors.warning,
              onTap: () => _launchURL('mailto:${AppSettings().storeEmail.trim()}'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: GoogleFonts.cairo(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'لا يمكن فتح الرابط حالياً',
              style: GoogleFonts.cairo(),
            ),
          ),
        );
      }
    }
  }
}
