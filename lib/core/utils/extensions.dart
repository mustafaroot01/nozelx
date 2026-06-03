import 'package:flutter/material.dart';

/// Extension methods for BuildContext
extension BuildContextExtensions on BuildContext {
  // Theme
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colors => theme.colorScheme;

  // Media Query
  MediaQueryData get mq => MediaQuery.of(this);
  double get width => mq.size.width;
  double get height => mq.size.height;
  double get paddingTop => mq.padding.top;
  double get paddingBottom => mq.padding.bottom;

  // Navigation
  NavigatorState get navigator => Navigator.of(this);
  void pop<T>([T? result]) => navigator.pop<T>(result);
  Future<T?> push<T>(Widget page) async =>
      navigator.push<T>(MaterialPageRoute(builder: (_) => page));
  Future<T?> pushReplacement<T>(Widget page) async =>
      navigator.pushReplacement<T, T>(MaterialPageRoute(builder: (_) => page));
  void pushNamedAndRemoveUntil(String routeName) =>
      navigator.pushNamedAndRemoveUntil(routeName, (route) => false);
  bool get canPop => navigator.canPop();

  // Scaffold
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colors.error : colors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Localization
  TextDirection get textDirection => Directionality.of(this);
  bool get isRTL => textDirection == TextDirection.rtl;
}

/// Extension methods for String
extension StringExtensions on String {
  // Validation
  bool get isValidEmail =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);

  bool get isValidPhone => RegExp(r'^[0-9]{10}$').hasMatch(this);

  bool get isValidPassword => length >= 6;

  // Formatting
  String get capitalize => '${this[0].toUpperCase()}${substring(1)}';

  String get capitalizeWords => split(' ').map((e) => e.capitalize).join(' ');

  String get toArabicDigits {
    const english = '0123456789';
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    return split('')
        .map((e) {
          final index = english.indexOf(e);
          return index >= 0 ? arabic[index] : e;
        })
        .join('');
  }

  String get removeDiacritics => replaceAll(RegExp('[\u064B-\u065F]'), '');

  // Truncation
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$ellipsis';
  }
}

/// Extension methods for num
extension NumExtensions on num {
  // Formatting
  String get toCurrency {
    final formatted = _formatNumber(this);
    return '$formatted ر.س';
  }

  String get toCompactCurrency {
    if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M ر.س';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K ر.س';
    }
    return toCurrency;
  }

  String toPercent({int decimalPlaces = 0}) {
    return '${(this * 100).toStringAsFixed(decimalPlaces)}%';
  }

  String toPriceFormat() {
    final formatted = _formatNumber(this);
    return '$formatted ر.س';
  }
}

String _formatNumber(num number) {
  final str = number.toStringAsFixed(0);
  final buffer = StringBuffer();
  int count = 0;
  for (int i = str.length - 1; i >= 0; i--) {
    if (count > 0 && count % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(str[i]);
    count++;
  }
  return buffer.toString().split('').reversed.join('');
}

/// Extension methods for DateTime
extension DateTimeExtensions on DateTime {
  // Formatting
  String get toArabicDate {
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '$day ${months[month - 1]} $year';
  }

  String get toShortDate {
    return '$day/$month/$year';
  }

  String get toTime {
    final hour = this.hour > 12
        ? this.hour - 12
        : (this.hour == 0 ? 12 : this.hour);
    final period = this.hour >= 12 ? 'م' : 'ص';
    return '$hour:${minute.toString().padLeft(2, '0')} $period';
  }

  String get toDateTime {
    return '$toArabicDate - $toTime';
  }

  String get toRelativeTime {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 30) {
      return toShortDate;
    } else if (difference.inDays > 0) {
      return '${difference.inDays} أيام';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ساعات';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} دقائق';
    }
    return 'الآن';
  }

  // Comparison
  bool get isToday {
    final today = DateTime.now();
    return year == today.year && month == today.month && day == today.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }
}

/// Extension methods for List
extension ListExtensions<T> on List<T> {
  /// Returns a new list with items at [indices] removed
  List<T> removeAtIndices(Iterable<int> indices) {
    final sortedIndices = indices.toList()..sort();
    final result = List<T>.from(this);
    for (int i = sortedIndices.length - 1; i >= 0; i--) {
      result.removeAt(sortedIndices[i]);
    }
    return result;
  }

  /// Safely access element at index
  T? safeGet(int index) {
    if (index >= 0 && index < length) {
      return this[index];
    }
    return null;
  }

  /// Group items by key
  Map<K, List<T>> groupBy<K>(K Function(T item) key) {
    return fold<Map<K, List<T>>>({}, (map, item) {
      final keyValue = key(item);
      if (!map.containsKey(keyValue)) {
        map[keyValue] = [];
      }
      map[keyValue]!.add(item);
      return map;
    });
  }
}

/// Extension methods for Widget
extension WidgetExtensions on Widget {
  /// Add padding
  Widget padding([double value = 16]) {
    return Padding(padding: EdgeInsets.all(value), child: this);
  }

  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }

  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
      ),
      child: this,
    );
  }

  /// Add margin
  Widget margin([double value = 16]) {
    return Container(margin: EdgeInsets.all(value), child: this);
  }

  Widget marginSymmetric({double horizontal = 0, double vertical = 0}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }

  /// Add background color
  Widget backgroundColor(Color color) {
    return Container(color: color, child: this);
  }

  /// Add border radius
  Widget borderRadius({double radius = 16}) {
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: this);
  }

  /// Add box shadow
  Widget boxShadow({
    Color color = const Color(0x40000000),
    Offset offset = const Offset(0, 4),
    double blurRadius = 8,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: color, offset: offset, blurRadius: blurRadius),
        ],
      ),
      child: this,
    );
  }

  /// Add expanded (for flex layouts)
  Widget expanded() {
    return Expanded(child: this);
  }

  /// Add flexible (for flex layouts)
  Widget flexible({int flex = 1, FlexFit fit = FlexFit.loose}) {
    return Flexible(flex: flex, fit: fit, child: this);
  }

  /// Center widget
  Widget center() {
    return Center(child: this);
  }

  /// Make it a Card
  Widget card({double radius = 16, Color? color}) {
    return Card(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      child: this,
    );
  }
}

/// Extension for TextStyle
extension TextStyleExtensions on TextStyle {
  TextStyle withColor(Color color) {
    return copyWith(color: color);
  }

  TextStyle bold() {
    return copyWith(fontWeight: FontWeight.bold);
  }

  TextStyle semiBold() {
    return copyWith(fontWeight: FontWeight.w600);
  }

  TextStyle medium() {
    return copyWith(fontWeight: FontWeight.w500);
  }

  TextStyle italic() {
    return copyWith(fontStyle: FontStyle.italic);
  }

  TextStyle withSize(double size) {
    return copyWith(fontSize: size);
  }
}

/// Spacing helper widgets
class Spacing extends StatelessWidget {
  final double size;

  const Spacing(this.size, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: size, height: size);
  }

  static const Widget xs = SizedBox(width: 4, height: 4);
  static const Widget small = SizedBox(width: 8, height: 8);
  static const Widget medium = SizedBox(width: 16, height: 16);
  static const Widget large = SizedBox(width: 24, height: 24);
  static const Widget xl = SizedBox(width: 32, height: 32);
  static const Widget xxl = SizedBox(width: 48, height: 48);
}
