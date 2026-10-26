import 'package:flutter/material.dart';

import 'package:expense_tracker/core/constants/first_day_of_week.dart';
import 'package:expense_tracker/core/theme/first_day_material_localizations.dart';

class CalendarMonthPreview extends StatelessWidget {
  static const double _previewHeight = 388;

  static const double _maxTextScale = 1.3;

  static void _ignoreDate(DateTime _) {
    return;
  }

  final FirstDayOfWeek day;
  final DateTime today;

  const CalendarMonthPreview({
    super.key,
    required this.day,
    required this.today,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime(today.year, today.month, today.day);

    return Localizations.override(
      context: context,
      delegates: [FirstDayMaterialLocalizationsDelegate(day)],
      child: IgnorePointer(
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: _maxTextScale,
          child: SizedBox(
            height: _previewHeight,

            child: CalendarDatePicker(
              initialDate: date,
              firstDate: DateTime(today.year, today.month),
              lastDate: DateTime(today.year, today.month + 1, 0),
              onDateChanged: _ignoreDate,
            ),
          ),
        ),
      ),
    );
  }
}
