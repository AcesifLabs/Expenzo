import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/core/constants/first_day_of_week.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

/// The formats Flutter's own Material delegate builds for a locale.
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

/// Material localizations whose first day of week is [day], so every date
/// picker starts its weeks there.
///
/// `showDatePicker` has no first-day parameter: it reads
/// `MaterialLocalizations.firstDayOfWeekIndex`, which comes from intl's
/// shared date symbols. Changing those in place is unsafe (intl caches the
/// last locale's symbols in a static), so this delegate returns the stock
/// English or Bangla translations with only that one getter overridden.
/// Put it before `GlobalMaterialLocalizations.delegate`; the first delegate
/// for a type wins.
class FirstDayMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  final FirstDayOfWeek day;

  /// One instance per language and day (at most six), like Flutter's own
  /// delegate keeps one per locale.
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
    // Loads Flutter's date data for the locale before the formats below
    // read it; it completes synchronously.
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
