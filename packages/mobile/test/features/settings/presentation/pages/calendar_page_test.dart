import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/constants/first_day_of_week.dart';
import 'package:expense_tracker/features/settings/domain/entities/user_settings.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_event.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/settings/presentation/pages/calendar_page.dart';
import 'package:expense_tracker/features/settings/presentation/widgets/calendar_month_preview.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import '../../../../support/factories/user_settings_factory.dart';
import '../../../../support/pump_localized.dart';

class _MockSettingsBloc extends Mock implements SettingsBloc {}

class _FakeSettingsEvent extends Fake implements SettingsEvent {}

DateTime _today() => DateTime(2026, 10, 14);

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
    UserSettings? settings,
    AppLocale locale = AppLocale.en,
  }) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    when(
      () => bloc.state,
    ).thenReturn(SettingsLoaded(settings ?? makeUserSettings()));
    await pumpLocalized(
      tester,
      const Scaffold(body: CalendarView(clock: _today)),
      locale: locale,
      wrap: (app) => BlocProvider<SettingsBloc>.value(value: bloc, child: app),
    );
    await tester.pumpAndSettle();
  }

  Finder checkedRow(String label) => find.descendant(
    of: find.widgetWithText(ListTile, label),
    matching: find.byIcon(PiconsRegular.checkCircle),
  );

  Set<int> firstColumnWeekdays(WidgetTester tester) {
    final preview = find.byType(CalendarMonthPreview);
    final localizations = MaterialLocalizations.of(
      tester.element(find.byType(CalendarDatePicker)),
    );
    final xs = <int, double>{
      for (var d = 1; d <= 31; d++)
        d: tester
            .getCenter(
              find.descendant(
                of: preview,
                matching: find.text(localizations.formatDecimal(d)),
              ),
            )
            .dx
            .roundToDouble(),
    };
    final left = xs.values.reduce((a, b) => a < b ? a : b);

    return {
      for (final e in xs.entries)
        if (e.value == left) DateTime(2026, 10, e.key).weekday,
    };
  }

  testWidgets('shows three options in order with the stored one selected', (
    tester,
  ) async {
    await pump(
      tester,
      settings: makeUserSettings(firstDayOfWeek: FirstDayOfWeek.sunday),
    );

    final ys = [
      for (final label in ['Sunday', 'Monday', 'Saturday'])
        tester.getTopLeft(find.widgetWithText(ListTile, label)).dy,
    ];
    expect(ys, orderedEquals([...ys]..sort()));
    expect(checkedRow('Sunday'), findsOneWidget);
    expect(find.byIcon(PiconsRegular.checkCircle), findsOneWidget);
    expect(find.text('FIRST DAY OF WEEK'), findsOneWidget);
  });

  testWidgets('unset in English selects Monday', (tester) async {
    await pump(tester);

    expect(checkedRow('Monday'), findsOneWidget);
    expect(firstColumnWeekdays(tester), {DateTime.monday});
  });

  testWidgets('unset in Bangla selects Saturday', (tester) async {
    await pump(tester, locale: AppLocale.bn);

    expect(find.text('ক্যালেন্ডার'), findsOneWidget);
    expect(checkedRow('শনিবার'), findsOneWidget);
    expect(firstColumnWeekdays(tester), {DateTime.saturday});
  });

  testWidgets('tapping Monday stores Monday', (tester) async {
    await pump(
      tester,
      settings: makeUserSettings(firstDayOfWeek: FirstDayOfWeek.sunday),
    );

    await tester.tap(find.text('Monday'));

    verify(
      () => bloc.add(const UpdateFirstDayOfWeek(FirstDayOfWeek.monday)),
    ).called(1);
  });

  testWidgets('the preview starts its weeks on the stored day', (tester) async {
    await pump(
      tester,
      settings: makeUserSettings(firstDayOfWeek: FirstDayOfWeek.saturday),
    );

    expect(firstColumnWeekdays(tester), {DateTime.saturday});
    expect(tester.getSize(find.byType(CalendarDatePicker)).height, 388);
  });

  testWidgets('a new day redraws the preview without remounting it', (
    tester,
  ) async {
    final controller = StreamController<SettingsState>.broadcast();
    addTearDown(controller.close);
    when(() => bloc.stream).thenAnswer((_) => controller.stream);
    await pump(tester);
    expect(firstColumnWeekdays(tester), {DateTime.monday});

    final saturday = makeUserSettings(firstDayOfWeek: FirstDayOfWeek.saturday);
    when(() => bloc.state).thenReturn(SettingsLoaded(saturday));
    controller.add(SettingsLoaded(saturday));
    await tester.pumpAndSettle();

    expect(firstColumnWeekdays(tester), {DateTime.saturday});
  });

  testWidgets('has no Calendar type or week number rows', (tester) async {
    await pump(tester);

    expect(find.textContaining('Hijri'), findsNothing);
    expect(find.textContaining('week number'), findsNothing);
  });
}
