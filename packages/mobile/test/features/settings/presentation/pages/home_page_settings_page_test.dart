import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/router/app_root_tab.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_event.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/settings/presentation/pages/home_page_settings_page.dart';
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
    SettingsState? state,
    AppLocale locale = AppLocale.en,
  }) async {
    when(
      () => bloc.state,
    ).thenReturn(state ?? SettingsLoaded(makeUserSettings()));
    await pumpLocalized(
      tester,
      const Scaffold(body: HomePageSettingsView()),
      locale: locale,
      wrap: (app) => BlocProvider<SettingsBloc>.value(value: bloc, child: app),
    );
    await tester.pumpAndSettle();
  }

  Finder checkedRow(String label) => find.descendant(
    of: find.widgetWithText(ListTile, label),
    matching: find.byIcon(PiconsRegular.checkCircle),
  );

  testWidgets('shows the four tabs in nav bar order with Home selected', (
    tester,
  ) async {
    await pump(tester);

    final ys = [
      for (final label in ['Home', 'Activity', 'Budgets', 'Reports'])
        tester.getTopLeft(find.widgetWithText(ListTile, label)).dy,
    ];
    expect(ys, orderedEquals([...ys]..sort()));
    expect(checkedRow('Home'), findsOneWidget);
    expect(find.byIcon(PiconsRegular.checkCircle), findsOneWidget);
    expect(find.text('DEFAULT HOME PAGE'), findsOneWidget);
    expect(
      find.text('Choose which screen to show when you open the app'),
      findsOneWidget,
    );
    expect(find.textContaining('Scan'), findsNothing);
  });

  testWidgets('the stored tab is selected', (tester) async {
    await pump(
      tester,
      state: SettingsLoaded(makeUserSettings(homeTab: AppRootTab.reports)),
    );

    expect(checkedRow('Reports'), findsOneWidget);
  });

  testWidgets('tapping Budgets stores Budgets', (tester) async {
    await pump(tester);

    await tester.tap(find.text('Budgets'));

    verify(() => bloc.add(const UpdateHomeTab(AppRootTab.budgets))).called(1);
  });

  testWidgets('a load error offers Try again, which reloads', (tester) async {
    await pump(tester, state: const SettingsError('boom'));

    await tester.tap(find.text(t.common.tryAgain));

    verify(() => bloc.add(const LoadSettings())).called(1);
  });

  testWidgets('renders in Bangla with the nav bar words', (tester) async {
    await pump(tester, locale: AppLocale.bn);

    expect(find.text('হোম পেজ'), findsOneWidget);
    for (final label in ['হোম', 'লেনদেন', 'বাজেট', 'রিপোর্ট']) {
      expect(find.widgetWithText(ListTile, label), findsOneWidget);
    }
  });
}
