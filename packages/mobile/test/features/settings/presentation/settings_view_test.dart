import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/constants/first_day_of_week.dart';
import 'package:expense_tracker/core/router/app_root_tab.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
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
      const Scaffold(body: SettingsView()),
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

  Future<void> pumpSettingsRouter(
    WidgetTester tester, {
    required String child,
  }) async {
    final router = GoRouter(
      initialLocation: '/settings',
      routes: [
        GoRoute(
          path: '/settings',
          builder: (_, _) => const Scaffold(body: SettingsView()),
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

  testWidgets('the notifications row shows Off when the master is off', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpSettings(tester);

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Off'), findsOneWidget);
    expect(find.byType(SwitchListTile), findsNothing);
  });

  testWidgets('the notifications row shows 4 of 5 on with defaults', (
    tester,
  ) async {
    when(
      () => settingsBloc.state,
    ).thenReturn(SettingsLoaded(makeUserSettings()));
    await tester.binding.setSurfaceSize(const Size(400, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpSettings(tester);

    expect(find.text('4 of 5 on'), findsOneWidget);
  });

  testWidgets('the notifications row opens /settings/notifications', (
    tester,
  ) async {
    await pumpSettingsRouter(tester, child: 'notifications');

    await tester.scrollUntilVisible(find.text('Notifications'), 200);

    await tester.ensureVisible(find.text('Notifications'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Notifications'));
    await tester.pumpAndSettle();

    expect(find.text('notifications-page'), findsOneWidget);
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

  testWidgets('number format sits right after Default currency with a live '
      'sample', (tester) async {
    await pumpSettings(tester);

    double top(String text) => tester.getTopLeft(find.text(text)).dy;
    final symbol = CurrencyFormatter.current.value.symbol;

    expect(find.text('${symbol}1,234.56'), findsOneWidget);
    expect(top('Number format'), greaterThan(top('Default currency')));
    expect(top('Number format'), lessThan(top('Appearance')));
  });

  testWidgets('the number format row opens /settings/number-format', (
    tester,
  ) async {
    await pumpSettingsRouter(tester, child: 'number-format');

    await tester.tap(find.text('Number format'));
    await tester.pumpAndSettle();

    expect(find.text('number-format-page'), findsOneWidget);
  });

  testWidgets('font size sits between Number format and Appearance and shows '
      'the current size', (tester) async {
    when(
      () => settingsBloc.state,
    ).thenReturn(SettingsLoaded(makeUserSettings()));
    await tester.binding.setSurfaceSize(const Size(400, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpSettings(tester);

    double top(String text) => tester.getTopLeft(find.text(text)).dy;

    expect(find.text('Medium'), findsOneWidget);
    expect(top('Font size'), greaterThan(top('Number format')));
    expect(top('Font size'), lessThan(top('Appearance')));
  });

  testWidgets('the font size row opens /settings/font-size', (tester) async {
    await pumpSettingsRouter(tester, child: 'font-size');

    await tester.scrollUntilVisible(find.text('Font size'), 200);

    await tester.ensureVisible(find.text('Font size'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Font size'));
    await tester.pumpAndSettle();

    expect(find.text('font-size-page'), findsOneWidget);
  });

  testWidgets('calendar is the last Preferences row and shows the effective '
      'first day', (tester) async {
    when(
      () => settingsBloc.state,
    ).thenReturn(SettingsLoaded(makeUserSettings()));
    await tester.binding.setSurfaceSize(const Size(400, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpSettings(tester);

    double top(String text) => tester.getTopLeft(find.text(text)).dy;

    expect(find.text('Week starts on Monday'), findsOneWidget);
    expect(top('Calendar'), greaterThan(top('Appearance')));
    expect(top('Calendar'), lessThan(top('NOTIFICATIONS')));
  });

  testWidgets('a stored first day shows on the calendar row', (tester) async {
    when(() => settingsBloc.state).thenReturn(
      SettingsLoaded(makeUserSettings(firstDayOfWeek: FirstDayOfWeek.saturday)),
    );
    await tester.binding.setSurfaceSize(const Size(400, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpSettings(tester);

    expect(find.text('Week starts on Saturday'), findsOneWidget);
  });

  testWidgets('the calendar row opens /settings/calendar', (tester) async {
    await pumpSettingsRouter(tester, child: 'calendar');

    await tester.scrollUntilVisible(find.text('Calendar'), 200);

    await tester.ensureVisible(find.text('Calendar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calendar'));
    await tester.pumpAndSettle();

    expect(find.text('calendar-page'), findsOneWidget);
  });

  testWidgets('the language row opens /settings/language', (tester) async {
    await pumpSettingsRouter(tester, child: 'language');

    await tester.scrollUntilVisible(find.text(t.settings.language.title), 200);

    await tester.ensureVisible(find.text(t.settings.language.title));
    await tester.pumpAndSettle();
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

  testWidgets('home page sits between Language and Category settings and '
      'shows the chosen tab', (tester) async {
    when(
      () => settingsBloc.state,
    ).thenReturn(SettingsLoaded(makeUserSettings(homeTab: AppRootTab.budgets)));
    await tester.binding.setSurfaceSize(const Size(400, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpSettings(tester);

    double top(String text) => tester.getTopLeft(find.text(text)).dy;

    expect(top('Home page'), greaterThan(top('Language')));
    expect(top('Home page'), lessThan(top('Category settings')));
    expect(top('Budgets'), greaterThan(top('Home page')));
    expect(top('Budgets'), lessThan(top('Category settings')));
  });

  testWidgets('the home page row opens /settings/home-page', (tester) async {
    await pumpSettingsRouter(tester, child: 'home-page');

    await tester.scrollUntilVisible(find.text('Home page'), 200);

    await tester.ensureVisible(find.text('Home page'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Home page'));
    await tester.pumpAndSettle();

    expect(find.text('home-page-page'), findsOneWidget);
  });

  testWidgets('sync sits between Recurring transactions and Export data', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpSettings(tester);

    double top(String text) => tester.getTopLeft(find.text(text)).dy;

    expect(find.text('Keep your data on all your devices'), findsNWidgets(2));
    expect(top('Sync'), greaterThan(top('Recurring transactions')));
    expect(top('Sync'), lessThan(top('Export data')));
  });

  testWidgets('the sync row opens /settings/sync', (tester) async {
    await pumpSettingsRouter(tester, child: 'sync');

    await tester.scrollUntilVisible(find.text('Sync'), 200);
    await tester.ensureVisible(find.text('Sync'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sync'));
    await tester.pumpAndSettle();

    expect(find.text('sync-page'), findsOneWidget);
  });

  testWidgets('export data sits right after Recurring transactions', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpSettings(tester);

    double top(String text) => tester.getTopLeft(find.text(text)).dy;

    expect(find.text('Save your transactions as CSV files'), findsOneWidget);
    expect(top('Export data'), greaterThan(top('Recurring transactions')));
    expect(top('Export data'), lessThan(top('AUTOMATION')));
  });

  testWidgets('the export data row opens /settings/export', (tester) async {
    await pumpSettingsRouter(tester, child: 'export');

    await tester.scrollUntilVisible(find.text('Export data'), 200);
    await tester.ensureVisible(find.text('Export data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Export data'));
    await tester.pumpAndSettle();

    expect(find.text('export-page'), findsOneWidget);
  });

  testWidgets('delete all data is the last Data & budget row', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpSettings(tester);

    double top(String text) => tester.getTopLeft(find.text(text)).dy;

    expect(
      find.text('Erase transactions, budgets and settings'),
      findsOneWidget,
    );
    expect(top('Delete all data'), greaterThan(top('Export data')));
    expect(top('Delete all data'), lessThan(top('AUTOMATION')));
  });

  testWidgets('the delete all data row opens /settings/delete-data', (
    tester,
  ) async {
    await pumpSettingsRouter(tester, child: 'delete-data');

    await tester.scrollUntilVisible(find.text('Delete all data'), 200);
    await tester.ensureVisible(find.text('Delete all data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete all data'));
    await tester.pumpAndSettle();

    expect(find.text('delete-data-page'), findsOneWidget);
  });

  testWidgets('category settings is the last General row, below Language', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpSettings(tester);

    double top(String text) => tester.getTopLeft(find.text(text)).dy;

    expect(top('Category settings'), greaterThan(top('GENERAL')));
    expect(top('Category settings'), greaterThan(top('Language')));
    expect(top('Category settings'), lessThan(top('SUPPORT')));
  });

  testWidgets('the category settings row renders in Bangla', (tester) async {
    await pumpSettings(tester, locale: AppLocale.bn);

    await tester.scrollUntilVisible(find.text('ক্যাটাগরি সেটিংস'), 200);
    expect(find.text('ক্যাটাগরি সেটিংস'), findsOneWidget);
  });

  testWidgets('the category settings row opens /settings/categories', (
    tester,
  ) async {
    await pumpSettingsRouter(tester, child: 'categories');

    await tester.scrollUntilVisible(find.text('Category settings'), 200);

    await tester.ensureVisible(find.text('Category settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Category settings'));
    await tester.pumpAndSettle();

    expect(find.text('categories-page'), findsOneWidget);
  });

  testWidgets('rows under every section are reachable', (tester) async {
    await pumpSettings(tester);

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

  testWidgets('signed in: the card and My profile come first, no Delete '
      'account, and sign out is the last row before Developer', (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    when(() => authBloc.state).thenReturn(
      const Authenticated(
        User(uid: 'u1', displayName: 'Sam', email: 'sam@example.com'),
      ),
    );
    await pumpSettings(tester);

    double top(String text) => tester.getTopLeft(find.text(text)).dy;
    expect(top('sam@example.com'), lessThan(top('PROFILE & ACCOUNT')));
    expect(top('My profile'), lessThan(top('PREFERENCES')));
    expect(find.text('Delete account'), findsNothing);
    expect(top('Sign out'), greaterThan(top('Help & Support')));
    expect(find.text('Send feedback'), findsNothing);
    expect(top('Sign out'), lessThan(top('DEVELOPER')));
    expect(find.text('Sign in'), findsNothing);
  });

  testWidgets('signed out: guest card, Sign in row, no sign out row', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await pumpSettings(tester);

    expect(find.text('Guest'), findsOneWidget);
    expect(find.text('Sign in to sync your data'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Sign out'), findsNothing);
    expect(find.text('Delete account'), findsNothing);
  });

  for (final target in ['Sam', 'My profile']) {
    testWidgets('signed in: tapping "$target" opens /settings/profile', (
      tester,
    ) async {
      when(
        () => authBloc.state,
      ).thenReturn(const Authenticated(User(uid: 'u1', displayName: 'Sam')));
      await pumpSettingsRouter(tester, child: 'profile');

      await tester.tap(find.text(target));
      await tester.pumpAndSettle();

      expect(find.text('profile-page'), findsOneWidget);
    });
  }

  group('Family group row', () {
    const signedIn = Authenticated(User(uid: 'u1', displayName: 'Sam'));

    testWidgets('is hidden when signed out', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 3000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await pumpSettings(tester);

      expect(find.text('Family group'), findsNothing);
    });

    testWidgets('sits right below My profile when signed in', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 3000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      when(() => authBloc.state).thenReturn(signedIn);
      await pumpSettings(tester);

      double top(String text) => tester.getTopLeft(find.text(text)).dy;
      expect(top('Family group'), greaterThan(top('My profile')));
      expect(top('Family group'), lessThan(top('PREFERENCES')));
      expect(find.text('Share budgets with your family'), findsOneWidget);
    });

    testWidgets('opens /settings/family', (tester) async {
      when(() => authBloc.state).thenReturn(signedIn);
      await pumpSettingsRouter(tester, child: 'family');

      await tester.tap(find.text('Family group'));
      await tester.pumpAndSettle();

      expect(find.text('family-page'), findsOneWidget);
    });
  });
}
