import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auto_lube/core/services/api_service.dart';
import 'package:auto_lube/core/exceptions/app_exception.dart';
import 'package:auto_lube/models/product_tag_model.dart';

class ProductTagService {
  static const String baseUrl = ApiService.baseUrl;

  // جلب تصنيفات قسم ثانوي
  Future<List<ProductTagModel>> getTagsBySubcategory(int subcategoryId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/v1/product-tags?subcategory_id=$subcategoryId&is_active=true'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true && data['data'] != null) {
          final list = data['data'] as List;
          return list
              .map((e) => ProductTagModel.fromJson(e as Map<String, dynamic>))
              .toList()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        } else {
          throw AppException(data['message'] ?? 'فشل تحميل التصنيفات');
        }
      } else {
        throw AppException(data['detail'] ?? 'حدث خطأ أثناء تحميل التصنيفات');
      }
    } on AppException {
      rethrow;
    } catch (e) {
      print('Error getTagsBySubcategory Service: $e');
      throw AppException('فشل تحميل التصنيفات');
    }
  }
}
