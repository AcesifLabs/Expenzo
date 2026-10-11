import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/features/auth/domain/entities/user.dart';
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

  /// Settings inside a router whose `/settings` route has one child page,
  /// so a row's `context.push('/settings/<child>')` can be checked.
  Future<void> pumpSettingsRouter(
    WidgetTester tester, {
    required String child,
  }) async {
    final router = GoRouter(
      initialLocation: '/settings',
      routes: [
        GoRoute(
          path: '/settings',
          builder: (_, _) => Scaffold(
            body: SettingsView(requestNotificationPermission: () async => true),
          ),
          routes: [
            GoRoute(path: child, builder: (_, _) => Text('$child-page')),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<SettingsBloc>.value(value: settingsBloc),
          BlocProvider<AuthBloc>.value(value: authBloc),
        ],
        child: translated(MaterialApp.router(routerConfig: router)),
      ),
    );
  }

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

  testWidgets('the appearance row opens /settings/appearance', (tester) async {
    await pumpSettingsRouter(tester, child: 'appearance');

    await tester.tap(find.text('Appearance'));
    await tester.pumpAndSettle();

    expect(find.text('appearance-page'), findsOneWidget);
  });

  testWidgets('the currency row opens /settings/currency', (tester) async {
    await pumpSettingsRouter(tester, child: 'currency');

    await tester.tap(find.text('Default currency'));
    await tester.pumpAndSettle();

    expect(find.text('currency-page'), findsOneWidget);
  });

  testWidgets('the language row opens /settings/language', (tester) async {
    await pumpSettingsRouter(tester, child: 'language');

    await tester.scrollUntilVisible(find.text(t.settings.language.title), 200);
    await tester.tap(find.text(t.settings.language.title));
    await tester.pumpAndSettle();

    expect(find.text('language-page'), findsOneWidget);
  });

  testWidgets('the language row renders in Bangla', (tester) async {
    await pumpSettings(tester, locale: AppLocale.bn);

    await tester.scrollUntilVisible(find.text('ভাষা'), 200);
    expect(find.text('ভাষা'), findsOneWidget);
    expect(find.text('সাধারণ'.toUpperCase()), findsOneWidget);
  });

  testWidgets('rows under every section are reachable', (tester) async {
    await pumpSettings(tester);

    // Lower rows sit below the fold on a small screen.
    for (final label in [
      'Sign in',
      'Recurring transactions',
      'Auto-import from SMS',
      'Language',
    ]) {
      await tester.scrollUntilVisible(find.text(label), 200);
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('section headers appear in design order', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpSettings(tester);

    double top(String text) => tester.getTopLeft(find.text(text)).dy;
    final order = [
      'PROFILE & ACCOUNT',
      'PREFERENCES',
      'NOTIFICATIONS',
      'DATA & BUDGET',
      'AUTOMATION',
      'GENERAL',
      'SUPPORT',
    ].map(top).toList();

    expect(order, [...order]..sort());
  });

  testWidgets('signed in: delete account is in the account section and '
      'sign out is the last row before Developer', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    when(
      () => authBloc.state,
    ).thenReturn(const Authenticated(User(uid: 'u1', displayName: 'Sam')));
    await pumpSettings(tester);

    double top(String text) => tester.getTopLeft(find.text(text)).dy;
    expect(top('Delete account'), lessThan(top('PREFERENCES')));
    expect(top('Sign out'), greaterThan(top('Send feedback')));
    expect(top('Sign out'), lessThan(top('DEVELOPER')));
    expect(find.text('Sign in'), findsNothing);
  });

  testWidgets('signed out: no sign out row', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpSettings(tester);

    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Sign out'), findsNothing);
  });
}
