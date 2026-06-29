import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
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

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: AppColors.textSecondaryLight,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<Widget> _buildNotificationSection(
    List<AppNotification> items,
    String sectionTitle,
    ThemeData theme,
  ) {
    if (items.isEmpty) return [];

    return [
      _buildSectionHeader(sectionTitle, theme),
      ...items.map(
        (notification) => NotificationItem(
          notification: notification,
          onTap: () => onNotificationTap(notification),
          onDismiss: () => onNotificationDismiss(notification.id),
        ),
      ),
    ];
  }

  Widget _buildNotificationList(ThemeData theme) {
    final unreadNotifications = notifications.where((n) => !n.isRead).toList();
    final readNotifications = notifications.where((n) => n.isRead).toList();

    return ListView(
      children: [
        ..._buildNotificationSection(unreadNotifications, 'New', theme),
        ..._buildNotificationSection(readNotifications, 'Earlier', theme),
        const SizedBox(height: 16),
      ],
    );
  }

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
}
