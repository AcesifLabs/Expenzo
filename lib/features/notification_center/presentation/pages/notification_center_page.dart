import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/app_notification.dart';
import '../widgets/notification_item.dart';

class NotificationCenterPage extends StatelessWidget {
  final List<AppNotification> notifications;
  final Function(AppNotification) onNotificationTap;
  final Function(String) onNotificationDismiss;
  final VoidCallback onClearAll;

  const NotificationCenterPage({
    super.key,
    required this.notifications,
    required this.onNotificationTap,
    required this.onNotificationDismiss,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(onPressed: onClearAll, child: const Text('Clear All')),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(theme)
          : _buildNotificationList(theme),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: AppColors.textSecondaryLight,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll see alerts here when something happens',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationList(ThemeData theme) {
    final unreadNotifications = notifications.where((n) => !n.isRead).toList();
    final readNotifications = notifications.where((n) => n.isRead).toList();

    return ListView(
      children: [
        if (unreadNotifications.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'New',
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.textSecondaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...unreadNotifications.map(
            (notification) => NotificationItem(
              notification: notification,
              onTap: () => onNotificationTap(notification),
              onDismiss: () => onNotificationDismiss(notification.id),
            ),
          ),
        ],
        if (readNotifications.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Earlier',
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.textSecondaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...readNotifications.map(
            (notification) => NotificationItem(
              notification: notification,
              onTap: () => onNotificationTap(notification),
              onDismiss: () => onNotificationDismiss(notification.id),
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}
