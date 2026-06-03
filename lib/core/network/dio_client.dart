import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class PathRewriteInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    String path = options.path;
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    
    if (!path.startsWith('/api/v1')) {
      if (path.startsWith('/api/')) {
        path = path.replaceFirst('/api/', '/api/v1/');
      } else {
        path = '/api/v1$path';
      }
    }
    
    options.path = path;
    super.onRequest(options, handler);
  }
}

class DioClient {
  static Dio? _dio;
  static Dio get instance => _dio ??= _create();

  static Dio _create() {
    // Note: We use ApiConfig.baseUrl here as the base, because PathRewriteInterceptor
    // automatically prepends '/api/v1' to the path, sobaseUrl + path forms a complete URL.
    final dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(PathRewriteInterceptor());

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (opts, handler) async {
          // أضف التوكن تلقائياً من الذاكرة أو التخزين
          if (!opts.headers.containsKey('Authorization')) {
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('auth_token');
            if (token != null) {
              opts.headers['Authorization'] = 'Bearer $token';
            }
          }
          debugPrint('→ ${opts.method} ${opts.path}');
          return handler.next(opts);
        },
        onResponse: (res, handler) {
          debugPrint('← ${res.statusCode} ${res.requestOptions.path}');
          return handler.next(res);
        },
        onError: (err, handler) async {
          debugPrint('✗ ${err.response?.statusCode} ${err.requestOptions.path}');
          if (err.response?.statusCode == 401) {
            // التوكن منتهي → مسحه
            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('auth_token');
            await prefs.remove('user_data');
          }
          return handler.next(err);
        },
      ),
    );

    return dio;
  }

  static void setToken(String token) {
    instance.options.headers['Authorization'] = 'Bearer $token';
  }

  static void clearToken() {
    instance.options.headers.remove('Authorization');
  }
}

final apiClient = DioClient.instance;
