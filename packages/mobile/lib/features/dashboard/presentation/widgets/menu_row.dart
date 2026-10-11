import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';

class MenuRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final IconData? trailing;

  const MenuRow({
    super.key,
    required this.icon,
    required this.text,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: AppSpacing.smd),
        Expanded(child: Text(text, style: AppTypography.bodyMedium)),
        if (trailing != null) Icon(trailing, size: 18),
      ],
    );
  }
}
