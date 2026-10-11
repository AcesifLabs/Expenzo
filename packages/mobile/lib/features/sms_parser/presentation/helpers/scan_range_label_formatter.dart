import 'package:intl/intl.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

String formatScanRangeLabel({
  required DateTime? startDate,
  required DateTime? endDate,
}) {
  if (startDate != null && endDate != null) {
    if (_isSameDay(startDate, endDate)) {
      return _formatDate(startDate);
    }

    return '${_formatDate(startDate)} – ${_formatDate(endDate)}';
  }

  if (startDate != null) {
    return t.smsParser.range.from(date: _formatDate(startDate));
  }

  if (endDate != null) {
    return t.smsParser.range.until(date: _formatDate(endDate));
  }

  return t.smsParser.range.allTime;
}

String _formatDate(DateTime date) => DateFormat.MMMd().format(date);

bool _isSameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
