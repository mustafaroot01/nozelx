class CurrencyFormatter {
  static const String _symbol = 'د.ع';
  static const String _locale = 'ar_IQ';

  // تنسيق رقم كامل: 25000 → "25,000 د.ع"
  static String format(double amount) {
    final formatted = amount
        .toInt()
        .toString()
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '$formatted $_symbol';
  }

  // تنسيق مختصر: 1500000 → "1.5M د.ع"
  static String formatCompact(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M $_symbol';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}K $_symbol';
    return format(amount);
  }

  // نص الخصم: "وفّرت 5,000 د.ع"
  static String savedText(double amount) => 'وفّرت ${format(amount)}';

  // لضمان التوافق مع الكود القديم في باقي الشاشات
  static String formatIQD(double price) => format(price);
}
