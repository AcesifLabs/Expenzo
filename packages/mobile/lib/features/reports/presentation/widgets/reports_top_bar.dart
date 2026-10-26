import 'package:flutter/material.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_page_header.dart';

class ReportsTopBar extends StatelessWidget {
  final String title;

  final String rangeLabel;

  final ValueChanged<BuildContext> onCalendar;
  final bool showBackButton;

  const ReportsTopBar({
    super.key,
    required this.title,
    required this.rangeLabel,
    required this.onCalendar,
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
            onPressed: () => onCalendar(buttonContext),
            icon: const Icon(PiconsRegular.calendar, size: 20),
            label: Text(rangeLabel),
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
          ),
        ),
      ],
    );
  }
}
