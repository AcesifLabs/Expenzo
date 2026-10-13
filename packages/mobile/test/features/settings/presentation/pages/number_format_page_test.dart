import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/constants/digit_grouping.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/utils/number_display_format.dart';
import 'package:expense_tracker/features/settings/domain/entities/user_settings.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_event.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/settings/presentation/pages/number_format_page.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/currency_scope.dart';
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

  tearDown(
    () => CurrencyFormatter.displayFormat.value = NumberDisplayFormat.standard,
  );

  Future<void> pump(
    WidgetTester tester, {
    UserSettings? settings,
    AppLocale locale = AppLocale.en,
  }) {
    when(
      () => bloc.state,
    ).thenReturn(SettingsLoaded(settings ?? makeUserSettings()));

    return pumpLocalized(
      tester,
      const CurrencyScope(child: Scaffold(body: NumberFormatView())),
      locale: locale,
      wrap: (app) => BlocProvider<SettingsBloc>.value(value: bloc, child: app),
    );
  }

  Finder checkIn(String rowTitle) => find.descendant(
    of: find.widgetWithText(ListTile, rowTitle),
    matching: find.byIcon(PiconsRegular.checkCircle),
  );

  testWidgets('shows the stored selection', (tester) async {
    await pump(
      tester,
      settings: makeUserSettings(
        decimalPlaces: 0,
        digitGrouping: DigitGrouping.dot,
      ),
    );

    expect(checkIn('0 places'), findsOneWidget);
    expect(checkIn('123.456.789'), findsOneWidget);
    expect(find.byIcon(PiconsRegular.checkCircle), findsNWidgets(2));
  });

  testWidgets('grouping rows show the sample as title and the label below', (
    tester,
  ) async {
    await pump(tester);

    for (final (sample, label) in [
      ('123,456,789', 'Comma separator'),
      ('123.456.789', 'Dot separator'),
      ('123 456 789', 'Space separator'),
    ]) {
      expect(
        find.descendant(
          of: find.widgetWithText(ListTile, sample),
          matching: find.text(label),
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('tapping the dot sample saves dot grouping', (tester) async {
    await pump(tester);

    await tester.tap(find.text('123.456.789'));
    verify(
      () =>
          bloc.add(const UpdateNumberFormat(digitGrouping: DigitGrouping.dot)),
    ).called(1);
  });

  testWidgets('tapping 0 places saves zero decimal places', (tester) async {
    await pump(tester);

    await tester.tap(find.text('0 places'));
    verify(
      () => bloc.add(const UpdateNumberFormat(decimalPlaces: 0)),
    ).called(1);
  });

  testWidgets('with a zero-digit currency, 2 places is disabled and says why', (
    tester,
  ) async {
    await pump(tester, settings: makeUserSettings(currencyCode: 'JPY'));

    expect(find.text('JPY has no decimal places'), findsOneWidget);
    await tester.tap(find.text('2 places'));
    verifyNever(() => bloc.add(any()));
  });

  testWidgets('the preview follows the number format at once', (tester) async {
    await pump(tester);
    final symbol = CurrencyFormatter.current.value.symbol;
    expect(find.text('${symbol}1,234.56'), findsOneWidget);
    expect(find.text('1,234.56'), findsWidgets);

    CurrencyFormatter.displayFormat.value = const NumberDisplayFormat(
      decimalPlaces: 2,
      grouping: DigitGrouping.dot,
    );
    await tester.pump();

    expect(find.text('${symbol}1.234,56'), findsOneWidget);
  });

  testWidgets('renders in Bangla without overflow at the 2.0x text scale', (
    tester,
  ) async {
    when(() => bloc.state).thenReturn(SettingsLoaded(makeUserSettings()));
    await pumpLocalized(
      tester,
      Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(2)),
          child: const Scaffold(body: NumberFormatView()),
        ),
      ),
      locale: AppLocale.bn,
      wrap: (app) => BlocProvider<SettingsBloc>.value(value: bloc, child: app),
    );

    expect(find.text('সংখ্যার ফরম্যাট'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('ফাঁকা জায়গা দিয়ে আলাদা'), 200);
    expect(tester.takeException(), isNull);
  });
}
