import 'package:auto_lube/core/services/api_service.dart';

class ImageUrlHelper {
  static String get _base => ApiService.directBaseUrl;

  static String? resolve(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final u = raw.trim();
    if (u.startsWith('http')) {
      return ApiService.fixImageUrl(u);
    }
    if (u.startsWith('/static/')) return '$_base$u';
    if (u.startsWith('static/')) return '$_base/$u';
    if (u.startsWith('/')) return '$_base$u';
    return '$_base/storage/$u';
  }

  // Cloudinary — resize تلقائي حسب الاستخدام
  static String? product(String? url) =>
      _cf(url, 'w_600,h_600,c_fill,q_auto,f_auto');

  static String? productThumb(String? url) =>
      _cf(url, 'w_200,h_200,c_fill,q_auto,f_auto');

  static String? productCard(String? url) => productThumb(url);

  static String? banner(String? url) =>
      _cf(url, 'w_1080,h_480,c_fill,q_auto,f_auto');

  static String? category(String? url) =>
      _cf(url, 'w_200,h_200,c_fill,q_auto,f_auto');

  static String? service(String? url) =>
      _cf(url, 'w_600,h_400,c_fill,q_auto,f_auto');

  static String? avatar(String? url) =>
      _cf(url, 'w_200,h_200,c_fill,q_auto,f_auto');

  static String? _cf(String? url, String t) {
    final r = resolve(url);
    if (r == null) return null;
    if (!r.contains('cloudinary.com')) return r;
    return r.replaceFirst('/upload/', '/upload/$t/');
  }
}
