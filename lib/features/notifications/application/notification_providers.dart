import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/id_generator.dart';
import '../../../data/datasources/local/local_storage_providers.dart';
import '../../../data/models/app_notification.dart';
import '../../../data/repositories/local/local_notification_repository.dart';
import '../../../data/repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return LocalNotificationRepository(ref.watch(localStorageServiceProvider));
});

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<AppNotification>>(NotificationsNotifier.new);

class NotificationsNotifier extends AsyncNotifier<List<AppNotification>> {
  @override
  Future<List<AppNotification>> build() {
    return ref.watch(notificationRepositoryProvider).getAll();
  }

  Future<void> add(NotificationType type, String title, String message) async {
    final notification = AppNotification(
      id: IdGenerator.generate(),
      type: type,
      title: title,
      message: message,
      createdAt: DateTime.now(),
    );
    await ref.read(notificationRepositoryProvider).add(notification);
    state = await AsyncValue.guard(() => ref.read(notificationRepositoryProvider).getAll());
  }

  Future<void> markRead(String id) async {
    await ref.read(notificationRepositoryProvider).markRead(id);
    state = await AsyncValue.guard(() => ref.read(notificationRepositoryProvider).getAll());
  }

  Future<void> markAllRead() async {
    await ref.read(notificationRepositoryProvider).markAllRead();
    state = await AsyncValue.guard(() => ref.read(notificationRepositoryProvider).getAll());
  }
}

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider).valueOrNull ?? const [];
  return notifications.where((n) => !n.isRead).length;
});
