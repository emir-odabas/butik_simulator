/// A time-boxed discount campaign (e.g. "%20 Yaz İndirimi").
///
/// Whether a campaign is currently running combines two things: the
/// owner's manual on/off switch ([isEnabled]) and today falling inside
/// [startDate]..[endDate] — see [isCurrentlyActive].
class Campaign {
  const Campaign({
    required this.id,
    required this.name,
    required this.description,
    required this.discountPercent,
    required this.startDate,
    required this.endDate,
    this.productIds = const [],
    this.isEnabled = true,
  });

  final String id;
  final String name;
  final String description;
  final double discountPercent;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> productIds;
  final bool isEnabled;

  bool get isCurrentlyActive {
    if (!isEnabled) return false;
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  bool get isUpcoming => isEnabled && DateTime.now().isBefore(startDate);
  bool get isExpired => DateTime.now().isAfter(endDate);

  Campaign copyWith({
    String? name,
    String? description,
    double? discountPercent,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? productIds,
    bool? isEnabled,
  }) {
    return Campaign(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      discountPercent: discountPercent ?? this.discountPercent,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      productIds: productIds ?? this.productIds,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'discountPercent': discountPercent,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'productIds': productIds,
        'isEnabled': isEnabled,
      };

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      discountPercent: (json['discountPercent'] as num).toDouble(),
      startDate: DateTime.tryParse(json['startDate'] as String? ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate'] as String? ?? '') ??
          DateTime.now().add(const Duration(days: 7)),
      productIds: (json['productIds'] as List?)?.cast<String>() ?? const [],
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }
}
