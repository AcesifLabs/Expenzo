import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/first_day_of_week.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

typedef _Formats = ({
  DateFormat fullYear,
  DateFormat compactDate,
  DateFormat shortDate,
  DateFormat mediumDate,
  DateFormat longDate,
  DateFormat yearMonth,
  DateFormat shortMonthDay,
  NumberFormat decimal,
  NumberFormat twoDigitZeroPadded,
});

class FirstDayMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  final FirstDayOfWeek day;

  static final _loaded = <(String, FirstDayOfWeek), MaterialLocalizations>{};

  const FirstDayMaterialLocalizationsDelegate(this.day);

  @override
  bool isSupported(Locale locale) =>
      locale.languageCode == AppLocale.en.languageCode ||
      locale.languageCode == AppLocale.bn.languageCode;

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    final languageCode = locale.languageCode;

    return SynchronousFuture(
      _loaded.putIfAbsent((languageCode, day), () => _build(locale)),
    );
  }

  @override
  bool shouldReload(FirstDayMaterialLocalizationsDelegate old) =>
      old.day != day;

  MaterialLocalizations _build(Locale locale) {
    GlobalMaterialLocalizations.delegate.load(locale).ignore();
    final languageCode = locale.languageCode;
    final formats = _formatsFor(languageCode);
    final index = day.materialIndex;

    return languageCode == AppLocale.bn.languageCode
        ? _BnFirstDay(index, formats)
        : _EnFirstDay(index, formats);
  }

  static _Formats _formatsFor(String localeName) => (
    fullYear: DateFormat.y(localeName),
    compactDate: DateFormat.yMd(localeName),
    shortDate: DateFormat.yMMMd(localeName),
    mediumDate: DateFormat.MMMEd(localeName),
    longDate: DateFormat.yMMMMEEEEd(localeName),
    yearMonth: DateFormat.yMMMM(localeName),
    shortMonthDay: DateFormat.MMMd(localeName),
    decimal: NumberFormat.decimalPattern(localeName),
    twoDigitZeroPadded: NumberFormat('00', localeName),
  );
}

class _EnFirstDay extends MaterialLocalizationEn {
  final int _firstDayOfWeekIndex;

  @override
  int get firstDayOfWeekIndex => _firstDayOfWeekIndex;

  _EnFirstDay(this._firstDayOfWeekIndex, _Formats formats)
    : super(
        fullYearFormat: formats.fullYear,
        compactDateFormat: formats.compactDate,
        shortDateFormat: formats.shortDate,
        mediumDateFormat: formats.mediumDate,
        longDateFormat: formats.longDate,
        yearMonthFormat: formats.yearMonth,
        shortMonthDayFormat: formats.shortMonthDay,
        decimalFormat: formats.decimal,
        twoDigitZeroPaddedFormat: formats.twoDigitZeroPadded,
      );
}

class _BnFirstDay extends MaterialLocalizationBn {
  final int _firstDayOfWeekIndex;

  @override
  int get firstDayOfWeekIndex => _firstDayOfWeekIndex;

  _BnFirstDay(this._firstDayOfWeekIndex, _Formats formats)
    : super(
        fullYearFormat: formats.fullYear,
        compactDateFormat: formats.compactDate,
        shortDateFormat: formats.shortDate,
        mediumDateFormat: formats.mediumDate,
        longDateFormat: formats.longDate,
        yearMonthFormat: formats.yearMonth,
        shortMonthDayFormat: formats.shortMonthDay,
        decimalFormat: formats.decimal,
        twoDigitZeroPaddedFormat: formats.twoDigitZeroPadded,
      );
}
