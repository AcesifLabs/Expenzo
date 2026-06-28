import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BalanceRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;
  final NumberFormat currencyFmt;

  const BalanceRow({
    super.key,
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
    required this.currencyFmt,
  });

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: onSurface.withAlpha(140)),
            ),
            Text(
              currencyFmt.format(amount),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: onSurface,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
