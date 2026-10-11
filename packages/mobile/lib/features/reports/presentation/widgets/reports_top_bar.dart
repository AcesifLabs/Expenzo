import 'package:flutter/material.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_page_header.dart';

/// The Reports header: the shared page header plus a labelled date-range
/// button.
class ReportsTopBar extends StatelessWidget {
  final String title;

  /// The current range, shown on the date-range button ("Last 30 days").
  final String rangeLabel;

  /// Gets the button's own context, so a menu can open under it.
  final ValueChanged<BuildContext>? onCalendar;
  final bool showBackButton;

  const ReportsTopBar({
    super.key,
    required this.title,
    required this.rangeLabel,
    this.onCalendar,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final onCalendar = this.onCalendar;

    return AppPageHeader(
      title: title,
      leading: showBackButton ? const AppBackButton() : null,
      actions: [
        Builder(
          builder: (buttonContext) => TextButton.icon(
            onPressed: onCalendar == null
                ? null
                : () => onCalendar(buttonContext),
            icon: const Icon(PiconsRegular.calendar, size: 20),
            label: Text(rangeLabel),
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
          ),
        ),
      ],
    );
  }
}
