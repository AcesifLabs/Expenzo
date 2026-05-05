import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/features/records/domain/entities/record.dart';

/// A non-interactive, read-only tile for displaying a record/transaction.
/// Has no InkWell, no onTap, no dismiss — purely for display.
class ReadOnlyRecordTile extends StatelessWidget {
  final Record record;

  static final _dateFormat = DateFormat('MMM dd');

  const ReadOnlyRecordTile({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final isExpense = record.recordType == RecordType.expense;
    final amtColor = isExpense
        ? const Color(0xFFFF3B30)
        : const Color(0xFF34C759);
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: amtColor.withAlpha(25),
            child: Icon(
              isExpense
                  ? PhosphorIcons.trendDown(PhosphorIconsStyle.fill)
                  : PhosphorIcons.trendUp(PhosphorIconsStyle.fill),
              color: amtColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.description.isNotEmpty
                      ? record.description
                      : (isExpense ? 'Expense' : 'Income'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _dateFormat.format(record.date),
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurface.withAlpha(120),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isExpense ? '-' : '+'}\$${record.amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: amtColor,
            ),
          ),
        ],
      ),
    );
  }
}
