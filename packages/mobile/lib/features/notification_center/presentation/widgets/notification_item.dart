import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import '../../domain/entities/app_notification.dart';

class NotificationItem extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback? onDismiss;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
    this.onDismiss,
  });

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: notification.iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(notification.icon, color: notification.iconColor, size: 24),
    );
  }

  Widget _buildTimestamp(
    bool isToday,
    DateFormat timeFormat,
    DateFormat dateFormat,
  ) {
    return Text(
      isToday
          ? timeFormat.format(notification.timestamp)
          : dateFormat.format(notification.timestamp),
      style: TextStyle(color: AppColors.textSecondaryLight),
    );
  }

  Widget _buildTitle(ThemeData theme) {
    return Text(
      notification.title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildBody(ThemeData theme) {
    return Text(
      notification.body,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: AppColors.textSecondaryLight,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildUnreadDot() {
    if (notification.isRead) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(left: 8),
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      color: AppColors.error,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 16),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  Widget _buildCardContent(
    ThemeData theme,
    bool isToday,
    DateFormat timeFormat,
    DateFormat dateFormat,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: notification.isRead
          ? null
          : AppColors.primary.withValues(alpha: 0.05),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: _buildTitle(theme)),
                        _buildTimestamp(isToday, timeFormat, dateFormat),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _buildBody(theme),
                  ],
                ),
              ),
              _buildUnreadDot(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeFormat = DateFormat.jm();
    final dateFormat = DateFormat.MMMd();
    final ts = notification.timestamp;
    final isToday =
        ts.day == DateTime.now().day &&
        ts.month == DateTime.now().month &&
        ts.year == DateTime.now().year;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss?.call(),
      background: _buildDismissBackground(),
      child: _buildCardContent(theme, isToday, timeFormat, dateFormat),
    );
  }
}
