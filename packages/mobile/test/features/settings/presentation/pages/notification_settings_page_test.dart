import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/constants/first_day_of_week.dart';
import 'package:expense_tracker/features/settings/domain/entities/notification_toggle.dart';
import 'package:expense_tracker/features/settings/domain/entities/user_settings.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_event.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/settings/presentation/pages/notification_settings_page.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import '../../../../support/factories/user_settings_factory.dart';
import '../../../../support/pump_localized.dart';

class _MockSettingsBloc extends Mock implements SettingsBloc {}

class _FakeSettingsEvent extends Fake implements SettingsEvent {}

void main() {
  late _MockSettingsBloc bloc;

  setUpAll(() async {
    registerFallbackValue(_FakeSettingsEvent());
    await initializeDateFormatting();
  });

  setUp(() {
    bloc = _MockSettingsBloc();
    when(
      () => bloc.stream,
    ).thenAnswer((_) => const Stream<SettingsState>.empty());
    when(() => bloc.close()).thenAnswer((_) async {});
    when(() => bloc.add(any())).thenReturn(null);
  });

  tearDown(() => LocaleSettings.setLocaleSync(AppLocale.en));

  Future<void> pump(
    WidgetTester tester, {
    UserSettings? settings,
    AppLocale locale = AppLocale.en,
    bool permissionGranted = true,
    bool requestGranted = true,
    Future<void> Function()? openSystemSettings,
  }) async {
    when(
      () => bloc.state,
    ).thenReturn(SettingsLoaded(settings ?? makeUserSettings()));
    await pumpLocalized(
      tester,
      Scaffold(
        body: NotificationSettingsView(
          requestNotificationPermission: () async => requestGranted,
          notificationPermissionGranted: () async => permissionGranted,
          openSystemSettings: openSystemSettings ?? () async {},
        ),
      ),
      locale: locale,
      wrap: (app) => BlocProvider<SettingsBloc>.value(value: bloc, child: app),
    );
    await tester.pumpAndSettle();
  }

  Switch switchFor(WidgetTester tester, String title) => tester.widget<Switch>(
    find.descendant(
      of: find.widgetWithText(ListTile, title),
      matching: find.byType(Switch),
    ),
  );

  testWidgets('renders four toggles with stored values, weekly off by '
      'default', (tester) async {
    await pump(tester);

    expect(find.byType(Switch), findsNWidgets(5));
    expect(switchFor(tester, 'Over budget alert').value, isTrue);
    expect(switchFor(tester, '80% threshold').value, isTrue);
    expect(switchFor(tester, 'Weekly summary').value, isFalse);
    expect(switchFor(tester, 'Reminder alerts').value, isTrue);
    expect(
      find.text("Sunday evening: this week's spending compared with last week"),
      findsOneWidget,
    );
    expect(find.textContaining('Push'), findsNothing);
    expect(find.textContaining('Email'), findsNothing);
  });

  testWidgets('tapping 80% threshold dispatches its toggle', (tester) async {
    await pump(tester);

    await tester.tap(
      find.descendant(
        of: find.widgetWithText(ListTile, '80% threshold'),
        matching: find.byType(Switch),
      ),
    );
    await tester.pump();

    verify(
      () => bloc.add(
        const UpdateNotificationToggle(
          NotificationToggle.budgetNearLimit,
          false,
        ),
      ),
    ).called(1);
  });

  testWidgets('master off disables the four toggles', (tester) async {
    await pump(
      tester,
      settings: makeUserSettings(
        notificationsEnabled: false,
        weeklySummaryEnabled: true,
      ),
    );

    for (final title in [
      'Over budget alert',
      '80% threshold',
      'Weekly summary',
      'Reminder alerts',
    ]) {
      expect(switchFor(tester, title).onChanged, isNull, reason: title);
    }
    expect(switchFor(tester, 'Weekly summary').value, isTrue);
    expect(switchFor(tester, 'Allow notifications').onChanged, isNotNull);
  });

  testWidgets('master on with permission denied shows the SnackBar and '
      'dispatches nothing', (tester) async {
    await pump(
      tester,
      settings: makeUserSettings(notificationsEnabled: false),
      requestGranted: false,
    );

    await tester.tap(
      find.descendant(
        of: find.widgetWithText(ListTile, 'Allow notifications'),
        matching: find.byType(Switch),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(t.settings.notificationsBlocked), findsOneWidget);
    verifyNever(() => bloc.add(any()));
  });

  testWidgets('master on with permission granted dispatches it', (
    tester,
  ) async {
    await pump(tester, settings: makeUserSettings(notificationsEnabled: false));

    await tester.tap(
      find.descendant(
        of: find.widgetWithText(ListTile, 'Allow notifications'),
        matching: find.byType(Switch),
      ),
    );
    await tester.pumpAndSettle();

    verify(() => bloc.add(const UpdateNotificationsEnabled(true))).called(1);
  });

  testWidgets('blocked permission with the master on shows the blocked row; '
      'Open settings calls the opener', (tester) async {
    var opened = 0;
    await pump(
      tester,
      permissionGranted: false,
      openSystemSettings: () async => opened++,
    );

    expect(find.text('Notifications are blocked'), findsOneWidget);
    await tester.tap(find.text('Open settings'));
    await tester.pump();

    expect(opened, 1);
  });

  testWidgets('no blocked row while the master is off', (tester) async {
    await pump(
      tester,
      settings: makeUserSettings(notificationsEnabled: false),
      permissionGranted: false,
    );

    expect(find.text('Notifications are blocked'), findsNothing);
  });

  testWidgets('renders in Bangla', (tester) async {
    await pump(tester, locale: AppLocale.bn);

    expect(find.text('নোটিফিকেশন চালু রাখুন'), findsOneWidget);
    expect(find.text('80% সীমা'), findsOneWidget);

    expect(find.textContaining('শুক্রবার সন্ধ্যায়'), findsOneWidget);
  });

  testWidgets('the weekly subtitle names the day before the first day', (
    tester,
  ) async {
    await pump(
      tester,
      settings: makeUserSettings(firstDayOfWeek: FirstDayOfWeek.saturday),
    );

    expect(
      find.text("Friday evening: this week's spending compared with last week"),
      findsOneWidget,
    );
  });

  testWidgets('no overflow at the 2.0x text scale cap', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pump(tester, permissionGranted: false, locale: AppLocale.bn);

    expect(tester.takeException(), isNull);
  });
}
