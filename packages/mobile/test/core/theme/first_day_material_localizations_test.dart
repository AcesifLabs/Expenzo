import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/constants/first_day_of_week.dart';
import 'package:expense_tracker/core/theme/first_day_material_localizations.dart';

final _month = DateTime(2026, 10);

Future<BuildContext> _pumpPicker(
  WidgetTester tester,
  FirstDayOfWeek day, {
  Locale locale = const Locale('en'),
}) async {
  late BuildContext pickerContext;
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('bn')],
      localizationsDelegates: [
        FirstDayMaterialLocalizationsDelegate(day),
        ...GlobalMaterialLocalizations.delegates,
      ],
      home: Scaffold(
        body: Builder(
          builder: (context) {
            pickerContext = context;

            return CalendarDatePicker(
              initialDate: _month,
              firstDate: _month,
              lastDate: DateTime(2026, 10, 31),
              onDateChanged: (_) {},
            );
          },
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  return pickerContext;
}

Set<int> _firstColumnWeekdays(WidgetTester tester, BuildContext context) {
  final localizations = MaterialLocalizations.of(context);
  final xs = <int, double>{
    for (var d = 1; d <= 31; d++)
      d: tester
          .getCenter(find.text(localizations.formatDecimal(d)))
          .dx
          .roundToDouble(),
  };
  final left = xs.values.reduce((a, b) => a < b ? a : b);

  return {
    for (final e in xs.entries)
      if (e.value == left) DateTime(2026, 10, e.key).weekday,
  };
}

void main() {
  for (final day in FirstDayOfWeek.values) {
    testWidgets('${day.name}: the picker starts its weeks there', (
      tester,
    ) async {
      final context = await _pumpPicker(tester, day);

      expect(
        MaterialLocalizations.of(context).firstDayOfWeekIndex,
        day.materialIndex,
      );
      expect(_firstColumnWeekdays(tester, context), {day.weekday});
    });
  }

  testWidgets('Bangla follows the setting too', (tester) async {
    final context = await _pumpPicker(
      tester,
      FirstDayOfWeek.saturday,
      locale: const Locale('bn'),
    );

    expect(MaterialLocalizations.of(context).firstDayOfWeekIndex, 6);
    expect(_firstColumnWeekdays(tester, context), {DateTime.saturday});
  });

  testWidgets('other translations match the stock ones', (tester) async {
    final context = await _pumpPicker(tester, FirstDayOfWeek.sunday);
    final stock = await GlobalMaterialLocalizations.delegate.load(
      const Locale('en'),
    );
    final ours = MaterialLocalizations.of(context);

    expect(ours.okButtonLabel, stock.okButtonLabel);
    expect(ours.narrowWeekdays, stock.narrowWeekdays);
    expect(ours.formatMonthYear(_month), stock.formatMonthYear(_month));
  });

  test('reloads only when the day changes', () {
    const monday = FirstDayMaterialLocalizationsDelegate(FirstDayOfWeek.monday);

    expect(
      const FirstDayMaterialLocalizationsDelegate(
        FirstDayOfWeek.monday,
      ).shouldReload(monday),
      isFalse,
    );
    expect(
      const FirstDayMaterialLocalizationsDelegate(
        FirstDayOfWeek.saturday,
      ).shouldReload(monday),
      isTrue,
    );
  });

  test('supports only the app languages', () {
    const delegate = FirstDayMaterialLocalizationsDelegate(
      FirstDayOfWeek.monday,
    );

    expect(delegate.isSupported(const Locale('en')), isTrue);
    expect(delegate.isSupported(const Locale('bn')), isTrue);
    expect(delegate.isSupported(const Locale('fr')), isFalse);
  });

  test('reuses one instance per language and day', () async {
    const saturday = FirstDayMaterialLocalizationsDelegate(
      FirstDayOfWeek.saturday,
    );
    const sunday = FirstDayMaterialLocalizationsDelegate(FirstDayOfWeek.sunday);
    final first = await saturday.load(const Locale('en'));

    expect(await saturday.load(const Locale('en')), same(first));
    expect(await saturday.load(const Locale('bn')), isNot(same(first)));
    expect(await sunday.load(const Locale('en')), isNot(same(first)));
  });
}
