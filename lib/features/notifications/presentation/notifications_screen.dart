import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../data/models/app_notification.dart';
import '../application/notification_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirimler'),
        actions: [
          TextButton(
            onPressed: () => ref.read(notificationsProvider.notifier).markAllRead(),
            child: const Text('Tümünü okundu işaretle'),
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Bildirimler yüklenemedi: $error')),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: EmptyState(
                icon: Icons.notifications_none_outlined,
                title: 'Henüz bildirimin yok',
                message: 'Mağazanda bir şeyler olduğunda burada göreceksin.',
              ),
            );
          }

          final sorted = [...notifications]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: sorted.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.xs),
            itemBuilder: (context, index) => _NotificationTile(notification: sorted[index]),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = notification.type.color();

    return Material(
      color: notification.isRead
          ? theme.colorScheme.surface
          : theme.colorScheme.primary.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        onTap: () {
          if (!notification.isRead) {
            ref.read(notificationsProvider.notifier).markRead(notification.id);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(notification.type.icon, size: 18, color: color),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(notification.message, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 2),
                    Text(_relativeTime(notification.createdAt), style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Small locale-independent "x dakika önce" formatter — avoids pulling
  /// in intl's date-symbol data for something this simple.
  String _relativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dakika önce';
    if (diff.inHours < 24) return '${diff.inHours} saat önce';
    return '${diff.inDays} gün önce';
  }
}
