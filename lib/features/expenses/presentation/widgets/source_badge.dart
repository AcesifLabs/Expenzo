import 'package:flutter/material.dart';
import '../../domain/entities/expense_source.dart';

class SourceBadge extends StatelessWidget {
  final ExpenseSource source;

  const SourceBadge({super.key, required this.source});

  static const _colorMap = {
    ExpenseSource.manual: Colors.grey,
    ExpenseSource.sms: Colors.blue,
    ExpenseSource.email: Colors.green,
    ExpenseSource.recurring: Colors.purple,
  };

  @override
  Widget build(BuildContext context) {
    final bgColor = _colorMap[source] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(source.icon, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 2),
          Text(
            source.displayName,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
