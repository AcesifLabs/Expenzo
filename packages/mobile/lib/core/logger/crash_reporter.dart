import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker/talker.dart';

import 'crash_scrubber.dart';

/// Starts Sentry; replaced in tests.
typedef SentryStarter =
    Future<void> Function(
      FlutterOptionsConfiguration configure, {
      AppRunner? appRunner,
    });

/// Sends Crash Reports to Sentry (ADR 0013). Nothing is sent without a DSN
/// or while the user has turned reports off: then Sentry isn't started at
/// all, so native crash, ANR and session reports stay off too.
class CrashReporter {
  /// The user's choice, kept in its own key so it can be read before the
  /// settings load (they need the app running).
  static const prefsKey = 'crash_reports_enabled';

  final SentryStarter _startSentry;
  final Future<void> Function() _closeSentry;

  bool _enabled = true;
  bool _started = false;
  String _dsn = '';
  SharedPreferences? _prefs;

  /// True when a reported error would be sent.
  bool get isActive => _started && _enabled;

  CrashReporter({
    SentryStarter? startSentry,
    Future<void> Function()? closeSentry,
  }) : _startSentry = startSentry ?? SentryFlutter.init,
       _closeSentry = closeSentry ?? Sentry.close;

  /// Runs [appRunner], inside Sentry when there is a [dsn] and the choice
  /// saved in [prefs] allows it. An empty [dsn] (local builds, CI) only runs
  /// the app.
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

  /// Follows the user's Settings choice at once: off closes Sentry, on
  /// starts it if the app began with reports off.
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

  /// Reports a caught [error]. [reference] is the id the error screen shows
  /// the user, so support can find the event.
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

  /// Scrubbed [event], or null while reports are off.
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
      // Native breadcrumbs skip the Dart scrubber.
      ..enableAutoNativeBreadcrumbs = false
      ..anrEnabled = true
      ..beforeSend = beforeSend
      ..beforeBreadcrumb = (crumb, _) => scrubBreadcrumb(crumb);
  }
}

final crashReporter = CrashReporter();

/// Sends `appLogger` errors that carry an exception to [crashReporter].
/// Uncaught errors reach Sentry through its own Flutter integrations.
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
