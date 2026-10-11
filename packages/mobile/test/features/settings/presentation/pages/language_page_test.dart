import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_event.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/settings/presentation/pages/language_page.dart';
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
      () => bloc.stream,
    ).thenAnswer((_) => const Stream<SettingsState>.empty());
    when(() => bloc.close()).thenAnswer((_) async {});
    when(() => bloc.add(any())).thenReturn(null);
  });

  Future<void> pump(
    WidgetTester tester, {
    String languageCode = 'en',
    AppLocale locale = AppLocale.en,
  }) {
    when(
      () => bloc.state,
    ).thenReturn(SettingsLoaded(makeUserSettings(languageCode: languageCode)));

    return pumpLocalized(
      tester,
      const Scaffold(body: LanguageView()),
      locale: locale,
      wrap: (app) => BlocProvider<SettingsBloc>.value(value: bloc, child: app),
    );
  }

  for (final locale in AppLocale.values) {
    testWidgets('shows three options, with own-script names in '
        '${locale.languageCode}', (tester) async {
      await pump(tester, locale: locale);

      final titles = tester
          .widgetList<ListTile>(find.byType(ListTile))
          .map((tile) => (tile.title! as Text).data)
          .toList();

      // English and বাংলা are never translated.
      expect(titles, [t.settings.language.matchDevice, 'English', 'বাংলা']);
    });
  }

  testWidgets('Match device says it uses the phone language', (tester) async {
    await pump(tester);

    expect(find.text('Match device'), findsOneWidget);
    expect(find.text("Use your phone's language"), findsOneWidget);
  });

  testWidgets('the stored language has the check mark', (tester) async {
    await pump(tester, languageCode: 'bn');

    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, 'বাংলা'),
        matching: find.byIcon(PiconsRegular.checkCircle),
      ),
      findsOneWidget,
    );
    expect(find.byIcon(PiconsRegular.checkCircle), findsOneWidget);
  });

  testWidgets('tapping বাংলা saves it and returns to Settings', (tester) async {
    when(
      () => bloc.state,
    ).thenReturn(SettingsLoaded(makeUserSettings(languageCode: 'en')));
    final router = GoRouter(
      initialLocation: '/settings/language',
      routes: [
        GoRoute(
          path: '/settings',
          builder: (_, _) => const Text('settings-page'),
          routes: [
            GoRoute(
              path: 'language',
              builder: (_, _) => const Scaffold(body: LanguageView()),
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

    await tester.tap(find.text('বাংলা'));
    await tester.pumpAndSettle();

    verify(() => bloc.add(const UpdateLanguage('bn'))).called(1);
    expect(find.text('settings-page'), findsOneWidget);
  });
}
