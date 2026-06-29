import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/features/records/domain/entities/record.dart';

class ReadOnlyRecordTile extends StatelessWidget {
  final Record record;
  final NumberFormat? amountFormat;
  final EdgeInsetsGeometry padding;
  final double avatarRadius;
  final double iconSize;

  static final _dateFormat = DateFormat('MMM dd');

  const ReadOnlyRecordTile({
    super.key,
    required this.record,
    this.amountFormat,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    this.avatarRadius = 18,
    this.iconSize = 16,
  });

  String _formatAmount() {
    final localAmountFormat = amountFormat;
    if (localAmountFormat != null) {
      return localAmountFormat.format(record.amount);
    }
    final prefix = record.recordType == RecordType.expense ? '-' : '+';

    return '$prefix\$${record.amount.abs().toStringAsFixed(2)}';
  }

  String _description() {
    if (record.description.isNotEmpty) return record.description;

    return record.recordType == RecordType.expense ? 'Expense' : 'Income';
  }

  Widget _leadingIcon(Color amtColor) {
    return CircleAvatar(
      radius: avatarRadius,
      backgroundColor: amtColor.withAlpha(25),
      child: Icon(
        record.recordType == RecordType.expense
            ? PiconsFill.trendDown
            : PiconsFill.trendUp,
        color: amtColor,
        size: iconSize,
      ),
    );
  }

  Widget _titleAndDate(ColorScheme colors) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _description(),
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
    );
  }

  Widget _amountText(Color amtColor) {
    return Text(
      _formatAmount(),
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: amtColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = record.recordType == RecordType.expense;
    final amtColor = isExpense
        ? const Color(0xFFFF3B30)
        : const Color(0xFF34C759);
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: padding,
      child: Row(
        children: [
          _leadingIcon(amtColor),
          const SizedBox(width: 12),
          _titleAndDate(colors),
          _amountText(amtColor),
        ],
      ),
    );
  }
}
