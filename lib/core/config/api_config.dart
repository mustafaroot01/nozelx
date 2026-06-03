class ApiConfig {
  static const String baseUrl = 'http://192.168.0.107:8080';
  static const String apiUrl  = '$baseUrl/api/v1';

  // يُصلح أي مسار صورة لـ URL كامل
  static String img(String? path) {
    if (path == null || path.trim().isEmpty) return '';
    var p = path.trim();
    
    // استبدال localhost أو 127.0.0.1 برابط الـ IP الفعلي للجهاز المضيف
    if (p.contains('localhost:8000') || p.contains('127.0.0.1:8000') ||
        p.contains('localhost:8080') || p.contains('127.0.0.1:8080')) {
      p = p.replaceAll('localhost:8000', '192.168.0.107:8080')
           .replaceAll('127.0.0.1:8000', '192.168.0.107:8080')
           .replaceAll('localhost:8080', '192.168.0.107:8080')
           .replaceAll('127.0.0.1:8080', '192.168.0.107:8080');
    } else if (p.contains('127.0.0.1')) {
      p = p.replaceAll('127.0.0.1', '192.168.0.107:8080');
    } else if (p.contains('localhost')) {
      p = p.replaceAll('localhost', '192.168.0.107:8080');
    }

    if (p.startsWith('http')) return p;
    if (p.startsWith('/static/')) return '$baseUrl$p';
    if (p.startsWith('static/')) return '$baseUrl/$p';
    if (p.startsWith('/'))    return '$baseUrl$p';
    return '$baseUrl/storage/$p';
  }
}
