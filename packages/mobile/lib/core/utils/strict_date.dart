/// [year]-[month]-[day], or null when that day does not exist (Feb 31,
/// month 13). `DateTime` would roll it into the next month instead.
DateTime? strictDate(int year, int month, int day) {
  final date = DateTime(year, month, day);

  return date.year == year && date.month == month && date.day == day
      ? date
      : null;
}
