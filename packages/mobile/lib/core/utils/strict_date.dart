DateTime? strictDate(int year, int month, int day) {
  final date = DateTime(year, month, day);

  return date.year == year && date.month == month && date.day == day
      ? date
      : null;
}
