/// A product in the boutique's catalog.
///
/// All monetary values are virtual/simulation values — see
/// [AppConstants.virtualEconomyLabel] usage in the UI layer.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.subCategory,
    required this.price,
    this.discountPrice,
    required this.stock,
    this.sizes = const [],
    this.colors = const [],
    this.images = const [],
    this.tag,
    this.isActive = true,
    this.isNew = false,
    this.isFeatured = false,
    this.isBestSeller = false,
    this.viewCount = 0,
    this.favoriteCount = 0,
    this.salesCount = 0,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String description;
  final String category;
  final String? subCategory;
  final double price;
  final double? discountPrice;
  final int stock;
  final List<String> sizes;
  final List<String> colors;

  /// Image sources: either a gallery asset path or a remote URL.
  final List<String> images;

  final String? tag;

  /// Whether the product is currently listed for sale ("satışta mı?").
  final bool isActive;
  final bool isNew;
  final bool isFeatured;
  final bool isBestSeller;

  final int viewCount;
  final int favoriteCount;
  final int salesCount;

  final DateTime createdAt;

  String? get primaryImage => images.isNotEmpty ? images.first : null;

  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  bool get isOutOfStock => stock <= 0;

  Product copyWith({
    String? name,
    String? description,
    String? category,
    String? subCategory,
    double? price,
    double? discountPrice,
    bool clearDiscount = false,
    int? stock,
    List<String>? sizes,
    List<String>? colors,
    List<String>? images,
    String? tag,
    bool? isActive,
    bool? isNew,
    bool? isFeatured,
    bool? isBestSeller,
    int? viewCount,
    int? favoriteCount,
    int? salesCount,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      price: price ?? this.price,
      discountPrice: clearDiscount ? null : (discountPrice ?? this.discountPrice),
      stock: stock ?? this.stock,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      images: images ?? this.images,
      tag: tag ?? this.tag,
      isActive: isActive ?? this.isActive,
      isNew: isNew ?? this.isNew,
      isFeatured: isFeatured ?? this.isFeatured,
      isBestSeller: isBestSeller ?? this.isBestSeller,
      viewCount: viewCount ?? this.viewCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      salesCount: salesCount ?? this.salesCount,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'category': category,
        'subCategory': subCategory,
        'price': price,
        'discountPrice': discountPrice,
        'stock': stock,
        'sizes': sizes,
        'colors': colors,
        'images': images,
        'tag': tag,
        'isActive': isActive,
        'isNew': isNew,
        'isFeatured': isFeatured,
        'isBestSeller': isBestSeller,
        'viewCount': viewCount,
        'favoriteCount': favoriteCount,
        'salesCount': salesCount,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'Diğer',
      subCategory: json['subCategory'] as String?,
      price: (json['price'] as num).toDouble(),
      discountPrice: (json['discountPrice'] as num?)?.toDouble(),
      stock: json['stock'] as int? ?? 0,
      sizes: (json['sizes'] as List?)?.cast<String>() ?? const [],
      colors: (json['colors'] as List?)?.cast<String>() ?? const [],
      images: (json['images'] as List?)?.cast<String>() ?? const [],
      tag: json['tag'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      isNew: json['isNew'] as bool? ?? false,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isBestSeller: json['isBestSeller'] as bool? ?? false,
      viewCount: json['viewCount'] as int? ?? 0,
      favoriteCount: json['favoriteCount'] as int? ?? 0,
      salesCount: json['salesCount'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
