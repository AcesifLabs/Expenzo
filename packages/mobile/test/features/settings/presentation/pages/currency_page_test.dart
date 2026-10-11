import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_event.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/settings/presentation/pages/currency_page.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import '../../../../support/factories/user_settings_factory.dart';
import '../../../../support/pump_localized.dart';

class _MockSettingsBloc extends Mock implements SettingsBloc {}

class _FakeSettingsEvent extends Fake implements SettingsEvent {}

void main() {
  late _MockSettingsBloc bloc;

  setUpAll(() => registerFallbackValue(_FakeSettingsEvent()));

  setUp(() {
    bloc = _MockSettingsBloc();
    when(
      () => bloc.state,
    ).thenReturn(SettingsLoaded(makeUserSettings(currencyCode: 'USD')));
    when(
      () => bloc.stream,
    ).thenAnswer((_) => const Stream<SettingsState>.empty());
    when(() => bloc.close()).thenAnswer((_) async {});
    when(() => bloc.add(any())).thenReturn(null);
  });

  /// The page pushed on top of a parent route, so `context.pop()` works.
  Future<void> pump(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/settings/currency',
      routes: [
        GoRoute(
          path: '/settings',
          builder: (_, _) => const Text('settings-page'),
          routes: [
            GoRoute(
              path: 'currency',
              builder: (_, _) => const Scaffold(body: CurrencyView()),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      BlocProvider<SettingsBloc>.value(
        value: bloc,
        child: translated(MaterialApp.router(routerConfig: router)),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> search(WidgetTester tester, String query) async {
    await tester.enterText(find.byType(TextField), query);
    await tester.pumpAndSettle();
  }

  testWidgets('the stored currency has the check mark', (tester) async {
    await pump(tester);

    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, 'USD'),
        matching: find.byIcon(PiconsRegular.checkCircle),
      ),
      findsOneWidget,
    );
    expect(find.byIcon(PiconsRegular.checkCircle), findsOneWidget);
  });

  testWidgets('searching "euro" leaves only EUR', (tester) async {
    await pump(tester);
    await search(tester, 'euro');

    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('EUR'), findsOneWidget);
  });

  testWidgets('a search with no match says so', (tester) async {
    await pump(tester);
    await search(tester, 'zzz');

    expect(find.text('No currency matches "zzz"'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('tapping a currency saves it and returns to Settings', (
    tester,
  ) async {
    await pump(tester);
    await search(tester, 'GBP');

    await tester.tap(find.widgetWithText(ListTile, 'GBP'));
    await tester.pumpAndSettle();

    verify(() => bloc.add(const UpdateCurrency('GBP'))).called(1);
    expect(find.text('settings-page'), findsOneWidget);
  });

  testWidgets('does not overflow at the 2.0x text scale cap in Bangla', (
    tester,
  ) async {
    await pumpLocalized(
      tester,
      Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: const Scaffold(body: CurrencyView()),
        ),
      ),
      locale: AppLocale.bn,
      wrap: (app) => BlocProvider<SettingsBloc>.value(value: bloc, child: app),
    );

    expect(tester.takeException(), isNull);
  });
}
