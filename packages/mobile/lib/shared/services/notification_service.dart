import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:expense_tracker/core/constants/source_types.dart';

class NotificationService {
  static const String _channelId = 'app_notifications';
  static const String _channelName = 'App Notifications';
  static const String _channelDescription = 'All app notifications';

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    _isInitialized = true;
    if (kDebugMode) {
      debugPrint('NotificationService initialized');
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    NotificationType type = NotificationType.general,
    String? deepLink,
  }) async {
    if (!_isInitialized) await initialize();

    final tag = _getTagForType(type);
    final payload = jsonEncode({'type': type.name, 'deepLink': deepLink});

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      tag: tag,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> showBudgetAlert({
    required String budgetId,
    required String budgetName,
    required double percentage,
  }) async {
    final deepLink = 'expenso://budgets/$budgetId';

    final body = percentage >= 100
        ? 'Budget "$budgetName" has been exceeded!'
        : 'Budget "$budgetName" is at ${percentage.toStringAsFixed(0)}%';

    await showNotification(
      title: 'Budget Alert',
      body: body,
      type: NotificationType.budgetAlert,
      deepLink: deepLink,
    );
  }

  Future<void> showRecurringDue({
    required String recurringId,
    required String description,
  }) async {
    final deepLink = 'expenso://recurring/$recurringId';

    await showNotification(
      title: 'Recurring Expense Due',
      body: description,
      type: NotificationType.recurringDue,
      deepLink: deepLink,
    );
  }

  Future<void> showScanComplete({
    required int foundCount,
    required String sourceType,
  }) async {
    final deepLink = sourceType == ExpenseSource.sms.name
        ? 'expenso://scan/sms'
        : 'expenso://scan/email';

    await showNotification(
      title: '${sourceType.toUpperCase()} Scan Complete',
      body: '$foundCount new expenses found',
      type: NotificationType.scanComplete,
      deepLink: deepLink,
    );
  }

  Future<void> showSyncError({required String message}) async {
    await showNotification(
      title: 'Sync Error',
      body: message,
      type: NotificationType.syncError,
    );
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    final deepLink = _parseDeepLink(payload);
    if (!kDebugMode) return;

    if (deepLink != null) {
      debugPrint('Notification tapped with deep link: $deepLink');
      debugPrint(
        'Notification deep link received but navigation is not wired here: $deepLink',
      );
    }
  }

  static String? _parseDeepLink(String payload) {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;

      return data['deepLink'] as String?;
    } catch (e, s) {
      debugPrint('Error: $e\n$s');
      if (kDebugMode) {
        debugPrint('Failed to parse notification payload: $e');
      }

      return null;
    }
  }

  String _getTagForType(NotificationType type) {
    switch (type) {
      case NotificationType.budgetAlert:
        return 'budget_alert';
      case NotificationType.recurringDue:
        return 'recurring_due';
      case NotificationType.syncError:
        return 'sync_error';
      case NotificationType.scanComplete:
        return 'scan_complete';
      case NotificationType.general:
        return 'general';
    }
  }
}

enum NotificationType {
  budgetAlert,
  recurringDue,
  syncError,
  scanComplete,
  general,
}
