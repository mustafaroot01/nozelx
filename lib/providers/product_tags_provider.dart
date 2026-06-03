import 'package:flutter/material.dart';
import 'package:auto_lube/models/product_tag_model.dart';
import 'package:auto_lube/services/product_tag_service.dart';

class ProductTagsProvider extends ChangeNotifier {
  // التصنيفات المحملة — مفهرسة بـ subcategoryId
  final Map<int, List<ProductTagModel>> _tagsBySubcategory = {};

  // التصنيف المحدد حالياً لكل قسم ثانوي (الدائري الأب)
  final Map<int, int?> _selectedTagBySubcategory = {};

  // التصنيف المساعد المختار حالياً (المستطيل الفرعي) لكل قسم ثانوي
  final Map<int, int?> _selectedSubTagBySubcategory = {};

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // جلب تصنيفات قسم ثانوي معين
  List<ProductTagModel> getTagsForSubcategory(int subcategoryId) {
    final allTags = _tagsBySubcategory[subcategoryId] ?? [];
    // نرجع فقط التصنيفات الرئيسية (التي ليس لها أب) كـ تصنيفات دائرية
    return allTags.where((t) => t.parentId == null).toList();
  }

  // التصنيف الدائري الأب المحدد حالياً
  int? getSelectedTag(int subcategoryId) =>
      _selectedTagBySubcategory[subcategoryId];

  // التصنيف المستطيل المساعد المحدد حالياً
  int? getSelectedSubTag(int subcategoryId) =>
      _selectedSubTagBySubcategory[subcategoryId];

  // جلب التصنيفات من API
  Future<void> fetchTags(int subcategoryId) async {
    // إذا محملة مسبقاً لا تعيد الجلب
    if (_tagsBySubcategory.containsKey(subcategoryId)) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final tags = await ProductTagService()
          .getTagsBySubcategory(subcategoryId);
      _tagsBySubcategory[subcategoryId] = tags;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // اختيار تصنيف دائري أب
  void selectTag(int subcategoryId, int tagId) {
    final current = _selectedTagBySubcategory[subcategoryId];
    _selectedSubTagBySubcategory[subcategoryId] = null; // تصفير التصنيف الفرعي المساعد دائماً عند تغيير الأب
    if (current == tagId) {
      _selectedTagBySubcategory[subcategoryId] = null; // إلغاء الأب
    } else {
      _selectedTagBySubcategory[subcategoryId] = tagId;
    }
    notifyListeners();
  }

  // اختيار تصنيف مستطيل فرعي
  void selectSubTag(int subcategoryId, int subTagId) {
    final current = _selectedSubTagBySubcategory[subcategoryId];
    if (current == subTagId) {
      _selectedSubTagBySubcategory[subcategoryId] = null; // إلغاء
    } else {
      _selectedSubTagBySubcategory[subcategoryId] = subTagId;
    }
    notifyListeners();
  }

  // الحصول على التصنيفات الفرعية للتصنيف الدائري المختار حالياً
  List<ProductTagModel> getSubTagsForSelected(int subcategoryId) {
    final selectedParentId = _selectedTagBySubcategory[subcategoryId];
    if (selectedParentId == null) return [];
    
    // جلب جميع تصنيفات القسم ثم البحث عن الفروع التابعة لهذا الأب المختار
    final allTags = _tagsBySubcategory[subcategoryId] ?? [];
    return allTags.where((t) => t.parentId == selectedParentId).toList();
  }

  // إعادة تعيين اختيار قسم ثانوي
  void clearSelection(int subcategoryId) {
    _selectedTagBySubcategory[subcategoryId] = null;
    _selectedSubTagBySubcategory[subcategoryId] = null;
    notifyListeners();
  }

  // مسح الكاش لإعادة التحميل
  void invalidateCache(int subcategoryId) {
    _tagsBySubcategory.remove(subcategoryId);
    notifyListeners();
  }
}
