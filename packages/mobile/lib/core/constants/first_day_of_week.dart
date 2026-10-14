import 'package:expense_tracker/i18n/strings.g.dart';

/// The First day of week setting (Settings > Calendar). Drives the date
/// pickers, Reports weeks and the weekly summary; budgets keep their own
/// rolling periods. Declared in the Calendar screen's order.
enum FirstDayOfWeek {
  sunday(DateTime.sunday),
  monday(DateTime.monday),
  saturday(DateTime.saturday);

  /// A [DateTime.weekday] value.
  final int weekday;

  const FirstDayOfWeek(this.weekday);

  /// Material's numbering for `MaterialLocalizations.firstDayOfWeekIndex`:
  /// 0 is Sunday.
  int get materialIndex => weekday % 7;

  String get displayName {
    final labels = t.enums.firstDayOfWeek;

    return switch (this) {
      FirstDayOfWeek.sunday => labels.sunday,
      FirstDayOfWeek.monday => labels.monday,
      FirstDayOfWeek.saturday => labels.saturday,
    };
  }

  /// The value stored under [name], or null for a missing or unknown one.
  static FirstDayOfWeek? fromName(String? name) {
    for (final day in values) {
      if (day.name == name) return day;
    }

    return null;
  }

  /// The day used until the user picks one: Saturday for Bangla, as weeks
  /// in Bangladesh start on Saturday, otherwise Monday.
  static FirstDayOfWeek defaultFor(String appLanguageCode) =>
      appLanguageCode == AppLocale.bn.languageCode ? saturday : monday;
}
