import 'package:flutter/material.dart';
import 'package:picons/picons.dart';

class ReportsTopBar extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onCalendar;

  const ReportsTopBar({
    super.key,
    required this.title,
    this.onBack,
    this.onCalendar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack ?? () => Navigator.of(context).pop(),
            child: const Icon(
              PiconsRegular.caretLeft,
              size: 24,
              color: Color(0xFFF5F7FA),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFFF5F7FA),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onCalendar,
            child: const Icon(
              PiconsRegular.calendar,
              size: 22,
              color: Color(0xFFD1C4E9),
            ),
          ),
        ],
      ),
    );
  }
}
