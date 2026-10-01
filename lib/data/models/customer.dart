/// A simulated customer. Never a real person — see the "sanal müşteri
/// sistemi" requirement: customers exist only to make the storefront and
/// order flow feel alive.
class Customer {
  const Customer({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.favoriteProductIds = const [],
    this.totalSpent = 0,
    this.preferredCategories = const [],
    required this.joinedAt,
  });

  final String id;
  final String name;
  final String? avatarUrl;
  final List<String> favoriteProductIds;
  final double totalSpent;
  final List<String> preferredCategories;
  final DateTime joinedAt;

  Customer copyWith({
    List<String>? favoriteProductIds,
    double? totalSpent,
  }) {
    return Customer(
      id: id,
      name: name,
      avatarUrl: avatarUrl,
      favoriteProductIds: favoriteProductIds ?? this.favoriteProductIds,
      totalSpent: totalSpent ?? this.totalSpent,
      preferredCategories: preferredCategories,
      joinedAt: joinedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarUrl': avatarUrl,
        'favoriteProductIds': favoriteProductIds,
        'totalSpent': totalSpent,
        'preferredCategories': preferredCategories,
        'joinedAt': joinedAt.toIso8601String(),
      };

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      favoriteProductIds: (json['favoriteProductIds'] as List?)?.cast<String>() ?? const [],
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0,
      preferredCategories: (json['preferredCategories'] as List?)?.cast<String>() ?? const [],
      joinedAt: DateTime.tryParse(json['joinedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
