import 'package:expense_tracker/i18n/strings.g.dart';

enum FirstDayOfWeek {
  sunday(DateTime.sunday),
  monday(DateTime.monday),
  saturday(DateTime.saturday);

  final int weekday;

  const FirstDayOfWeek(this.weekday);

  int get materialIndex => weekday % 7;

  String get displayName {
    final labels = t.enums.firstDayOfWeek;

    return switch (this) {
      FirstDayOfWeek.sunday => labels.sunday,
      FirstDayOfWeek.monday => labels.monday,
      FirstDayOfWeek.saturday => labels.saturday,
    };
  }

  static FirstDayOfWeek? fromName(String? name) {
    for (final day in values) {
      if (day.name == name) return day;
    }

    return null;
  }

  static FirstDayOfWeek defaultFor(String appLanguageCode) =>
      appLanguageCode == AppLocale.bn.languageCode ? saturday : monday;
}
