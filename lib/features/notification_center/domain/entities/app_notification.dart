import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';

enum NotificationType {
  budgetAlert,
  recurringDue,
  syncError,
  scanComplete,
  general,
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime timestamp;
  final bool isRead;
  final String? deepLink;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.deepLink,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? timestamp,
    bool? isRead,
    String? deepLink,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      deepLink: deepLink ?? this.deepLink,
    );
  }

  IconData get icon {
    switch (type) {
      case NotificationType.budgetAlert:
        return Icons.account_balance_wallet;
      case NotificationType.recurringDue:
        return Icons.repeat;
      case NotificationType.syncError:
        return Icons.sync_problem;
      case NotificationType.scanComplete:
        return Icons.check_circle;
      case NotificationType.general:
        return Icons.notifications;
    }
  }

  Color get iconColor {
    switch (type) {
      case NotificationType.budgetAlert:
        return AppColors.warning;
      case NotificationType.recurringDue:
        return AppColors.primary;
      case NotificationType.syncError:
        return AppColors.error;
      case NotificationType.scanComplete:
        return AppColors.success;
      case NotificationType.general:
        return AppColors.textSecondaryLight;
    }
  }
}
