/// A virtual discount coupon code (e.g. "WELCOME10").
class Coupon {
  const Coupon({
    required this.id,
    required this.code,
    required this.discountPercent,
    required this.usageLimit,
    this.usedCount = 0,
    this.isActive = true,
    required this.createdAt,
  });

  final String id;
  final String code;
  final double discountPercent;
  final int usageLimit;
  final int usedCount;
  final bool isActive;
  final DateTime createdAt;

  bool get isExhausted => usedCount >= usageLimit;
  bool get isUsable => isActive && !isExhausted;

  Coupon copyWith({
    double? discountPercent,
    int? usageLimit,
    int? usedCount,
    bool? isActive,
  }) {
    return Coupon(
      id: id,
      code: code,
      discountPercent: discountPercent ?? this.discountPercent,
      usageLimit: usageLimit ?? this.usageLimit,
      usedCount: usedCount ?? this.usedCount,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'discountPercent': discountPercent,
        'usageLimit': usageLimit,
        'usedCount': usedCount,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] as String,
      code: json['code'] as String,
      discountPercent: (json['discountPercent'] as num).toDouble(),
      usageLimit: json['usageLimit'] as int? ?? 100,
      usedCount: json['usedCount'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
