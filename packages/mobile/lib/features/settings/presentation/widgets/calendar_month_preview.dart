import 'package:flutter/material.dart';

import 'package:expense_tracker/core/constants/first_day_of_week.dart';
import 'package:expense_tracker/core/theme/first_day_material_localizations.dart';

/// This month as the date pickers draw it, with weeks starting on [day].
///
/// Decorative: taps are ignored. It overrides the localizations itself, so
/// it follows a new choice at once rather than after the save.
class CalendarMonthPreview extends StatelessWidget {
  /// Material 3 `CalendarDatePicker`: a 52 dp sub-header plus 7 rows of
  /// 48 dp (`_subHeaderHeight` and `_maxDayPickerHeightM3` in Flutter's
  /// calendar_date_picker.dart).
  static const double _previewHeight = 388;

  /// The seven day columns can't widen with the text (about 33 dp each on
  /// a 360 dp phone); two-digit days still fit at this scale. The option
  /// rows above still scale fully.
  static const double _maxTextScale = 1.3;

  // The preview ignores taps; CalendarDatePicker still needs a callback.
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
            // A new day reloads the override above, which redraws the grid;
            // the picker keeps its state.
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
