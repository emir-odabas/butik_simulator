import 'dart:convert';

import '../../datasources/local/local_storage_service.dart';
import '../../models/app_notification.dart';
import '../notification_repository.dart';

class LocalNotificationRepository implements NotificationRepository {
  LocalNotificationRepository(this._storage);

  final LocalStorageService _storage;

  static const _storageKey = 'notifications';

  /// Keeps storage from growing forever in a long-running simulation.
  static const _maxStored = 50;

  @override
  Future<List<AppNotification>> getAll() async {
    final raw = _storage.read(_storageKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List;
    return decoded.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> add(AppNotification notification) async {
    final current = await getAll();
    final updated = [notification, ...current].take(_maxStored).toList();
    await _persist(updated);
  }

  @override
  Future<void> markRead(String id) async {
    final current = await getAll();
    final updated = [
      for (final n in current)
        if (n.id == id) n.copyWith(isRead: true) else n,
    ];
    await _persist(updated);
  }

  @override
  Future<void> markAllRead() async {
    final current = await getAll();
    await _persist([for (final n in current) n.copyWith(isRead: true)]);
  }

  Future<void> _persist(List<AppNotification> notifications) {
    final encoded = jsonEncode(notifications.map((n) => n.toJson()).toList());
    return _storage.write(_storageKey, encoded);
  }
}
