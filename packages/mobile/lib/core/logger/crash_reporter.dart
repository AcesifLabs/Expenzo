import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker/talker.dart';

import 'crash_scrubber.dart';

typedef SentryStarter =
    Future<void> Function(
      FlutterOptionsConfiguration configure, {
      AppRunner? appRunner,
    });

class CrashReporter {
  static const prefsKey = 'crash_reports_enabled';

  final SentryStarter _startSentry;
  final Future<void> Function() _closeSentry;

  bool _enabled = true;
  bool _started = false;
  String _dsn = '';
  SharedPreferences? _prefs;

  bool get isActive => _started && _enabled;

  CrashReporter({
    SentryStarter? startSentry,
    Future<void> Function()? closeSentry,
  }) : _startSentry = startSentry ?? SentryFlutter.init,
       _closeSentry = closeSentry ?? Sentry.close;

  Future<void> start({
    required String dsn,
    required SharedPreferences prefs,
    required AppRunner appRunner,
  }) async {
    _dsn = dsn;
    _prefs = prefs;
    _enabled = prefs.getBool(prefsKey) ?? true;
    if (dsn.isEmpty || !_enabled) {
      await appRunner();

      return;
    }
    _started = true;
    await _startSentry(
      (options) => configure(options, dsn: dsn),
      appRunner: appRunner,
    );
  }

  Future<void> setEnabled({required bool enabled}) async {
    if (enabled == _enabled) return;
    _enabled = enabled;
    await _prefs?.setBool(prefsKey, enabled);
    if (!enabled && _started) {
      _started = false;
      await _closeSentry();
    } else if (enabled && !_started && _dsn.isNotEmpty) {
      _started = true;
      await _startSentry((options) => configure(options, dsn: _dsn));
    }
  }

  Future<void> capture(
    Object error,
    StackTrace? stackTrace, {
    String? reference,
  }) async {
    if (!isActive) return;
    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      withScope: reference == null
          ? null
          : (scope) => scope.setTag('ref', reference),
    );
  }

  SentryEvent? beforeSend(SentryEvent event, Hint _) =>
      _enabled ? scrubEvent(event) : null;

  @visibleForTesting
  void configure(SentryFlutterOptions options, {required String dsn}) {
    options
      ..dsn = dsn
      ..environment = kReleaseMode ? 'production' : 'debug'
      ..sendDefaultPii = false
      ..attachScreenshot = false
      ..enablePrintBreadcrumbs = false
      ..enableUserInteractionBreadcrumbs = false
      ..enableAutoNativeBreadcrumbs = false
      ..anrEnabled = true
      ..beforeSend = beforeSend
      ..beforeBreadcrumb = (crumb, _) => scrubBreadcrumb(crumb);
  }
}

final crashReporter = CrashReporter();

class CrashReportingTalkerObserver extends TalkerObserver {
  final CrashReporter reporter;

  CrashReportingTalkerObserver(this.reporter);

  @override
  void onLog(TalkerData log) {
    final level = log.logLevel;
    if (level == LogLevel.error || level == LogLevel.critical) {
      _forward(log.exception ?? log.error, log.stackTrace);
    }
  }

  @override
  void onError(TalkerError err) => _forward(err.error, err.stackTrace);

  @override
  void onException(TalkerException err) =>
      _forward(err.exception, err.stackTrace);

  void _forward(Object? error, StackTrace? stackTrace) {
    if (error != null) unawaited(reporter.capture(error, stackTrace));
  }
}
