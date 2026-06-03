class ProductTagModel {
  final int id;
  final String name;           // اسم التصنيف يظهر تحت الدائرة
  final String? imageUrl;      // صورة داخل الدائرة
  final String? iconEmoji;     // بديل للصورة — emoji مثل 👕
  final int subcategoryId;     // ينتمي لأي قسم ثانوي
  final int? parentId;         // معرف التصنيف الأب في حال كان فرعياً
  final int sortOrder;         // ترتيب الظهور
  final bool isActive;
  final int productsCount;     // عدد المنتجات فيه
  final List<ProductTagModel> subTags; // التصنيفات الفرعية التابعة له

  const ProductTagModel({
    required this.id,
    required this.name,
    required this.subcategoryId,
    this.parentId,
    this.imageUrl,
    this.iconEmoji,
    this.sortOrder = 0,
    this.isActive = true,
    this.productsCount = 0,
    this.subTags = const [],
  });

  factory ProductTagModel.fromJson(Map<String, dynamic> json) =>
      ProductTagModel(
        id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
        name: json['name'] as String? ?? '',
        subcategoryId: json['subcategory_id'] is int 
            ? json['subcategory_id'] as int 
            : int.parse(json['subcategory_id'].toString()),
        parentId: json['parent_id'] is int 
            ? json['parent_id'] as int 
            : (json['parent_id'] != null ? int.tryParse(json['parent_id'].toString()) : null),
        imageUrl: json['image_url'] as String?,
        iconEmoji: json['icon_emoji'] as String?,
        sortOrder: json['sort_order'] is int 
            ? json['sort_order'] as int 
            : int.tryParse(json['sort_order']?.toString() ?? '') ?? 0,
        isActive: json['is_active'] is bool 
            ? json['is_active'] as bool 
            : (json['is_active']?.toString() == '1' || json['is_active']?.toString() == 'true'),
        productsCount: json['products_count'] is int 
            ? json['products_count'] as int 
            : int.tryParse(json['products_count']?.toString() ?? '') ?? 0,
        subTags: (json['sub_tags'] as List<dynamic>?)
                ?.map((e) => ProductTagModel.fromJson(e as Map<String, dynamic>))
                .toList() ?? const [],
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'subcategory_id': subcategoryId,
    'parent_id': parentId,
    'image_url': imageUrl,
    'icon_emoji': iconEmoji,
    'sort_order': sortOrder,
    'is_active': isActive,
    'products_count': productsCount,
    'sub_tags': subTags.map((e) => e.toJson()).toList(),
  };
}
