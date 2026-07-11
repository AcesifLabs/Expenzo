String formatScanRangeLabel({
  required DateTime? startDate,
  required DateTime? endDate,
}) {
  if (startDate == null && endDate == null) {
    return 'All Time';
  }

  if (startDate != null && endDate != null) {
    if (_isSameDay(startDate, endDate)) {
      return _formatDate(startDate);
    }

    return '${_formatDate(startDate)} – ${_formatDate(endDate)}';
  }

  if (startDate != null) {
    return 'From ${_formatDate(startDate)}';
  }

  final safeEndDate = endDate;
  if (safeEndDate != null) {
    return 'Until ${_formatDate(safeEndDate)}';
  }

  return 'All Time';
}

String _formatDate(DateTime date) {
  const monthNames = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${monthNames[date.month - 1]} ${date.day}';
}

bool _isSameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
