/// The player's boutique profile.
///
/// `level`, `xp`, `virtualBalance` and the daily/total stat fields are
/// placeholders wired up to real gamification and simulation logic in
/// later phases (XP/level in Phase 4, virtual economy in Phase 5) — for
/// now they persist locally and the dashboard simply displays them.
class StoreProfile {
  const StoreProfile({
    this.id = 'main',
    required this.name,
    required this.description,
    this.logoUrl,
    this.level = 1,
    this.xp = 0,
    this.xpForNextLevel = 500,
    this.virtualBalance = 0,
    this.todayRevenue = 0,
    this.totalRevenue = 0,
    this.todayOrders = 0,
    this.favoriteCount = 0,
    this.visitorCount = 0,
    this.rating = 0,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String description;
  final String? logoUrl;

  final int level;
  final int xp;
  final int xpForNextLevel;

  final double virtualBalance;
  final double todayRevenue;
  final double totalRevenue;
  final int todayOrders;
  final int favoriteCount;
  final int visitorCount;
  final double rating;

  final DateTime createdAt;

  double get levelProgress =>
      xpForNextLevel == 0 ? 0 : (xp / xpForNextLevel).clamp(0, 1).toDouble();

  StoreProfile copyWith({
    String? name,
    String? description,
    String? logoUrl,
    bool clearLogo = false,
    int? level,
    int? xp,
    int? xpForNextLevel,
    double? virtualBalance,
    double? todayRevenue,
    double? totalRevenue,
    int? todayOrders,
    int? favoriteCount,
    int? visitorCount,
    double? rating,
  }) {
    return StoreProfile(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: clearLogo ? null : (logoUrl ?? this.logoUrl),
      level: level ?? this.level,
      xp: xp ?? this.xp,
      xpForNextLevel: xpForNextLevel ?? this.xpForNextLevel,
      virtualBalance: virtualBalance ?? this.virtualBalance,
      todayRevenue: todayRevenue ?? this.todayRevenue,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      todayOrders: todayOrders ?? this.todayOrders,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      visitorCount: visitorCount ?? this.visitorCount,
      rating: rating ?? this.rating,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'logoUrl': logoUrl,
        'level': level,
        'xp': xp,
        'xpForNextLevel': xpForNextLevel,
        'virtualBalance': virtualBalance,
        'todayRevenue': todayRevenue,
        'totalRevenue': totalRevenue,
        'todayOrders': todayOrders,
        'favoriteCount': favoriteCount,
        'visitorCount': visitorCount,
        'rating': rating,
        'createdAt': createdAt.toIso8601String(),
      };

  factory StoreProfile.fromJson(Map<String, dynamic> json) {
    return StoreProfile(
      id: json['id'] as String? ?? 'main',
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      logoUrl: json['logoUrl'] as String?,
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      xpForNextLevel: json['xpForNextLevel'] as int? ?? 500,
      virtualBalance: (json['virtualBalance'] as num?)?.toDouble() ?? 0,
      todayRevenue: (json['todayRevenue'] as num?)?.toDouble() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      todayOrders: json['todayOrders'] as int? ?? 0,
      favoriteCount: json['favoriteCount'] as int? ?? 0,
      visitorCount: json['visitorCount'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
