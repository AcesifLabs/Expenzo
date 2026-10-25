import 'package:expense_tracker/core/utils/strict_date.dart';

import '../entities/date_order.dart';

const _months = {
  'jan': 1,
  'feb': 2,
  'mar': 3,
  'apr': 4,
  'may': 5,
  'jun': 6,
  'jul': 7,
  'aug': 8,
  'sep': 9,
  'oct': 10,
  'nov': 11,
  'dec': 12,
};

/// `05-Oct-2026`, `5 Oct 26`, `05 October 2026`.
final _withMonthName = RegExp(
  r'(\d{1,2})[-\s/.]([A-Za-z]{3})[A-Za-z]*[-\s/.,]*(\d{4}|\d{2})\b',
);

/// `2026-10-05`, `2026/10/05`.
final _yearFirst = RegExp(r'(\d{4})[-/.](\d{1,2})[-/.](\d{1,2})');

/// `05/10/2026`, `5-10-26`, `05.10.2026`.
final _numeric = RegExp(r'(\d{1,2})[-/.](\d{1,2})[-/.](\d{4}|\d{2})\b');

/// The first date in [text], or null when there is none or it does not
/// exist (Feb 31 is null, not Mar 3). All-numeric dates are read in
/// [order]; dates with a month name or the year first don't need it.
DateTime? parseRuleDate(String text, DateOrder order) {
  if (_withMonthName.firstMatch(text) case final m?) {
    final month = _months[_group(m, 2).toLowerCase()];

    return month == null
        ? null
        : strictDate(_year(_group(m, 3)), month, int.parse(_group(m, 1)));
  }
  if (_yearFirst.firstMatch(text) case final m?) {
    return strictDate(
      int.parse(_group(m, 1)),
      int.parse(_group(m, 2)),
      int.parse(_group(m, 3)),
    );
  }
  if (_numeric.firstMatch(text) case final m?) {
    final first = int.parse(_group(m, 1));
    final second = int.parse(_group(m, 2));
    final year = _year(_group(m, 3));

    return order == DateOrder.dmy
        ? strictDate(year, second, first)
        : strictDate(year, first, second);
  }

  return null;
}

String _group(Match match, int index) => match.group(index) ?? '';

/// Two-digit years are this century's.
int _year(String digits) {
  final year = int.parse(digits);

  return digits.length == 2 ? 2000 + year : year;
}
