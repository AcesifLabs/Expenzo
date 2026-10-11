import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_event.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/settings/presentation/pages/settings_page.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import '../../../support/factories/user_settings_factory.dart';
import '../../../support/pump_localized.dart';

class _MockSettingsBloc extends Mock implements SettingsBloc {}

class _MockAuthBloc extends Mock implements AuthBloc {}

class _FakeSettingsEvent extends Fake implements SettingsEvent {}

void main() {
  late _MockSettingsBloc settingsBloc;
  late _MockAuthBloc authBloc;

  setUpAll(() => registerFallbackValue(_FakeSettingsEvent()));

  setUp(() {
    settingsBloc = _MockSettingsBloc();
    authBloc = _MockAuthBloc();
    when(() => settingsBloc.state).thenReturn(
      SettingsLoaded(
        makeUserSettings(theme: 'dark', notificationsEnabled: false),
      ),
    );
    when(
      () => settingsBloc.stream,
    ).thenAnswer((_) => const Stream<SettingsState>.empty());
    when(() => settingsBloc.close()).thenAnswer((_) async {});
    when(() => settingsBloc.add(any())).thenReturn(null);
    when(() => authBloc.state).thenReturn(const AuthInitial());
    when(
      () => authBloc.stream,
    ).thenAnswer((_) => const Stream<AuthState>.empty());
    when(() => authBloc.close()).thenAnswer((_) async {});
  });

  Future<void> pumpSettings(
    WidgetTester tester, {
    AppLocale locale = AppLocale.en,
  }) {
    return pumpLocalized(
      tester,
      Scaffold(
        body: SettingsView(requestNotificationPermission: () async => true),
      ),
      locale: locale,
      wrap: (app) => MultiBlocProvider(
        providers: [
          BlocProvider<SettingsBloc>.value(value: settingsBloc),
          BlocProvider<AuthBloc>.value(value: authBloc),
        ],
        child: app,
      ),
    );
  }

  Finder inDialog(String text) =>
      find.descendant(of: find.byType(SimpleDialog), matching: find.text(text));

  testWidgets('budget alerts is a switch showing the stored value', (
    tester,
  ) async {
    await pumpSettings(tester);

    final alerts = find.widgetWithText(SwitchListTile, 'Budget alerts');
    expect(tester.widget<SwitchListTile>(alerts).value, isFalse);

    await tester.tap(alerts);
    verify(
      () => settingsBloc.add(const UpdateNotificationsEnabled(true)),
    ).called(1);
  });

  testWidgets('appearance can go back to matching the device', (tester) async {
    await pumpSettings(tester);
    expect(find.text('Dark'), findsOneWidget);

    await tester.tap(find.text('Appearance'));
    await tester.pumpAndSettle();
    await tester.tap(inDialog('Match device'));
    await tester.pumpAndSettle();

    verify(() => settingsBloc.add(const UpdateTheme('system'))).called(1);
  });

  testWidgets('language can be set to Bangla', (tester) async {
    await pumpSettings(tester);

    await tester.tap(find.text(t.settings.language.title));
    await tester.pumpAndSettle();
    await tester.tap(inDialog('বাংলা'));
    await tester.pumpAndSettle();

    verify(() => settingsBloc.add(const UpdateLanguage('bn'))).called(1);
  });

  testWidgets('the language row renders in Bangla', (tester) async {
    await pumpSettings(tester, locale: AppLocale.bn);

    expect(find.text('ভাষা'), findsOneWidget);
  });

  testWidgets('auto-import is reachable from settings', (tester) async {
    await pumpSettings(tester);

    // Automation and account rows sit below the fold on a small screen.
    await tester.scrollUntilVisible(find.text('Auto-import from SMS'), 200);
    expect(find.text('Auto-import from SMS'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Recurring'), 200);
    expect(find.text('Recurring'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Sign in'), 200);
    expect(find.text('Sign in'), findsOneWidget);
  });
}
