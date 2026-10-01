import 'package:flutter/material.dart';

/// What kind of event an [AppNotification] represents. Drives the icon
/// shown in the notification list.
enum NotificationType {
  newOrder,
  orderCompleted,
  questCompleted,
  achievementUnlocked,
  levelUp;

  IconData get icon => switch (this) {
        NotificationType.newOrder => Icons.receipt_long_outlined,
        NotificationType.orderCompleted => Icons.payments_outlined,
        NotificationType.questCompleted => Icons.flag_outlined,
        NotificationType.achievementUnlocked => Icons.emoji_events_outlined,
        NotificationType.levelUp => Icons.arrow_upward_outlined,
      };

  Color color() => switch (this) {
        NotificationType.newOrder => Colors.blue,
        NotificationType.orderCompleted => Colors.green,
        NotificationType.questCompleted => Colors.orange,
        NotificationType.achievementUnlocked => Colors.purple,
        NotificationType.levelUp => Colors.pink,
      };

  static NotificationType fromName(String name) {
    return NotificationType.values.firstWhere(
      (t) => t.name == name,
      orElse: () => NotificationType.newOrder,
    );
  }
}

/// A single in-app notification-center entry. Purely local/simulated —
/// there is no real push notification behind this, just events the app
/// itself generates (a new order came in, a quest was completed, ...).
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.isRead = false,
    required this.createdAt,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      message: message,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'message': message,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      type: NotificationType.fromName(json['type'] as String? ?? 'newOrder'),
      title: json['title'] as String,
      message: json['message'] as String,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
