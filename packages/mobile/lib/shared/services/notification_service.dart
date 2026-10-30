import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/reports/domain/entities/weekly_summary.dart';
import 'package:expense_tracker/features/sms_parser/domain/entities/auto_imported_record.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class NotificationService {
  static const String _channelId = 'app_notifications';
  static const String _scheme = 'expenso';

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  static final NotificationService _instance = NotificationService._internal();

  static String get _channelName => t.notifications.channel.name;
  static String get _channelDescription => t.notifications.channel.description;

  factory NotificationService() => _instance;
  NotificationService._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
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

    final androidChannel = AndroidNotificationChannel(
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

  Future<bool> canNotify() async {
    if (!_isInitialized) await initialize();
    final android = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    return await android?.areNotificationsEnabled() ?? true;
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
      visibility: type == NotificationType.autoImport
          ? NotificationVisibility.private
          : null,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      idFor(type, deepLink),
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
    required bool isOver,
  }) async {
    final deepLink = '$_scheme://budgets/$budgetId';

    final strings = t.notifications.budget;
    final body = isOver
        ? strings.over(budget: budgetName)
        : strings.used(
            budget: budgetName,
            percent: percentage.toStringAsFixed(0),
          );

    await showNotification(
      title: strings.title,
      body: body,
      type: NotificationType.budgetAlert,
      deepLink: deepLink,
    );
  }

  Future<void> showRecurringDue({
    required String recurringId,
    required String description,
  }) async {
    final deepLink = '$_scheme://recurring/$recurringId';

    await showNotification(
      title: t.notifications.recurringDue.title,
      body: description,
      type: NotificationType.recurringDue,
      deepLink: deepLink,
    );
  }

  Future<void> showWeeklySummary(WeeklySummary summary) async {
    await showNotification(
      title: t.notifications.weeklySummary.title,
      body: weeklySummaryBody(summary),
      type: NotificationType.weeklySummary,
      deepLink: '$_scheme://reports',
    );
  }

  Future<void> showScanComplete({
    required int foundCount,
    required String sourceType,
  }) async {
    final isSms = sourceType == ExpenseSource.sms.name;
    final deepLink = isSms ? '$_scheme://scan/sms' : '$_scheme://scan/email';
    final strings = t.notifications.scan;

    await showNotification(
      title: isSms ? strings.smsTitle : strings.emailTitle,
      body: strings.found(n: foundCount),
      type: NotificationType.scanComplete,
      deepLink: deepLink,
    );
  }

  Future<void> showAutoImportedRecord(AutoImportedRecord record) async {
    await showNotification(
      title: autoImportedRecordTitle(record.recordType),
      body: autoImportedRecordBody(
        amount: record.amount,
        description: record.description,
        sender: record.sender,
      ),
      type: NotificationType.autoImport,
      deepLink: autoImportedRecordLink(record.sourceId),
    );
  }

  Future<void> showAutoImportSummary({required int count}) async {
    final strings = t.notifications.autoImport;

    await showNotification(
      title: strings.summaryTitle,
      body: strings.summary(n: count),
      type: NotificationType.autoImport,
    );
  }

  Future<void> showSyncError({required String message}) async {
    await showNotification(
      title: t.notifications.syncError.title,
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

  @visibleForTesting
  static String weeklySummaryBody(WeeklySummary summary) {
    final strings = t.notifications.weeklySummary;
    if (summary.thisWeekTotal == 0) return strings.nothing;

    final amount = CurrencyFormatter.format(summary.thisWeekTotal);
    final change = summary.changePercent;
    if (change == null) return strings.noComparison(amount: amount);

    final percent = change.round();
    if (percent == 0) return strings.same(amount: amount);
    final shown = percent.abs().toString();

    return percent > 0
        ? strings.up(amount: amount, percent: shown)
        : strings.down(amount: amount, percent: shown);
  }

  @visibleForTesting
  static String autoImportedRecordTitle(RecordType type) {
    final strings = t.notifications.autoImport;

    return type == RecordType.income
        ? strings.incomeTitle
        : strings.expenseTitle;
  }

  // The SMS source id is not a record id and holds characters such as '|'
  // and spaces, so it goes in an encoded query parameter, not the path.
  @visibleForTesting
  static String autoImportedRecordLink(String sourceId) => Uri(
    scheme: _scheme,
    host: 'records',
    queryParameters: {'sourceId': sourceId},
  ).toString();

  @visibleForTesting
  static String autoImportedRecordBody({
    required double amount,
    required String? description,
    required String sender,
  }) {
    final strings = t.notifications.autoImport;
    final formatted = CurrencyFormatter.format(amount.abs());
    final trimmed = description?.trim();

    return trimmed == null || trimmed.isEmpty
        ? strings.bodyFromSender(amount: formatted, sender: sender)
        : strings.body(amount: formatted, description: trimmed);
  }

  @visibleForTesting
  static int idFor(NotificationType type, String? deepLink) {
    final perItem =
        type == NotificationType.recurringDue ||
        type == NotificationType.autoImport;
    if (perItem && deepLink != null) {
      return deepLink.hashCode;
    }

    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
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
      appLogger.error('Notification payload is not a valid deep link', e, s);

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
      case NotificationType.weeklySummary:
        return 'weekly_summary';
      case NotificationType.autoImport:
        return 'auto_import';
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
  weeklySummary,
  autoImport,
  general,
}
