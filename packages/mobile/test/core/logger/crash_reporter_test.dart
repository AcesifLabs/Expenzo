import 'package:expense_tracker/core/logger/crash_reporter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker/talker.dart';

void main() {
  test('configure turns off everything that can carry user data', () {
    final options = SentryFlutterOptions();
    CrashReporter().configure(options, dsn: 'https://key@example.com/1');

    expect(options.sendDefaultPii, isFalse);
    expect(options.attachScreenshot, isFalse);
    expect(options.enablePrintBreadcrumbs, isFalse);
    expect(options.enableUserInteractionBreadcrumbs, isFalse);
    expect(options.enableAutoNativeBreadcrumbs, isFalse);
    expect(options.anrEnabled, isTrue);
  });

  test('beforeSend scrubs while reports are on', () {
    final reporter = CrashReporter();
    final event = reporter.beforeSend(
      SentryEvent(message: SentryMessage('Tk 1,500.00 failed')),
      Hint(),
    );

    expect(event?.message?.formatted, '[redacted] failed');
  });

  group('opting out', () {
    const dsn = 'https://key@example.com/1';
    late List<String> calls;
    late CrashReporter reporter;

    setUp(() {
      calls = [];
      reporter = CrashReporter(
        startSentry: (configure, {appRunner}) async {
          calls.add('start');
          await appRunner?.call();
        },
        closeSentry: () async => calls.add('close'),
      );
    });

    Future<SharedPreferences> prefsWith(bool? enabled) async {
      SharedPreferences.setMockInitialValues({
        CrashReporter.prefsKey: ?enabled,
      });

      return SharedPreferences.getInstance();
    }

    test('a user who opted out never has Sentry started, so native crash, '
        'ANR and session reports stay off too', () async {
      var ran = false;
      await reporter.start(
        dsn: dsn,
        prefs: await prefsWith(false),
        appRunner: () => ran = true,
      );

      expect(ran, isTrue);
      expect(calls, isEmpty);
      expect(reporter.isActive, isFalse);
    });

    test('reports are on until the user says otherwise', () async {
      await reporter.start(
        dsn: dsn,
        prefs: await prefsWith(null),
        appRunner: () {},
      );

      expect(calls, ['start']);
      expect(reporter.isActive, isTrue);
    });

    test('turning reports off closes Sentry and is remembered', () async {
      final prefs = await prefsWith(true);
      await reporter.start(dsn: dsn, prefs: prefs, appRunner: () {});

      await reporter.setEnabled(enabled: false);

      expect(calls, ['start', 'close']);
      expect(reporter.isActive, isFalse);
      expect(prefs.getBool(CrashReporter.prefsKey), isFalse);
      expect(reporter.beforeSend(SentryEvent(), Hint()), isNull);
    });

    test('turning reports back on starts Sentry without a restart', () async {
      await reporter.start(
        dsn: dsn,
        prefs: await prefsWith(false),
        appRunner: () {},
      );

      await reporter.setEnabled(enabled: true);

      expect(calls, ['start']);
      expect(reporter.isActive, isTrue);
    });
  });

  test('an empty DSN only runs the app and reports nothing', () async {
    SharedPreferences.setMockInitialValues({});
    final reporter = CrashReporter();
    var ran = false;
    await reporter.start(
      dsn: '',
      prefs: await SharedPreferences.getInstance(),
      appRunner: () => ran = true,
    );

    expect(ran, isTrue);
    expect(reporter.isActive, isFalse);
  });

  group('CrashReportingTalkerObserver', () {
    test('forwards error logs that carry an exception', () {
      final reporter = _RecordingReporter();
      final talker = Talker(
        settings: TalkerSettings(useConsoleLogs: false),
        observer: CrashReportingTalkerObserver(reporter),
      );
      final error = StateError('db closed');

      talker
        ..error('Save failed', error, StackTrace.current)
        ..error('No exception here')
        ..warning('Slow query', error);

      expect(reporter.captured, [error]);
    });
  });
}

class _RecordingReporter extends CrashReporter {
  final captured = <Object>[];

  @override
  Future<void> capture(
    Object error,
    StackTrace? stackTrace, {
    String? reference,
  }) async => captured.add(error);
}
