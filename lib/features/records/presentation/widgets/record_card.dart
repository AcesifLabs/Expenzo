import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:expense_tracker/core/utils/color_utils.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';
import '../../domain/entities/record.dart';
import 'source_badge.dart';

class RecordCard extends StatelessWidget {
  final Record record;
  final String? categoryEmoji;
  final String? categoryName;
  final String? categoryColor;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  static final _dateFormat = DateFormat('MMM dd, yyyy');

  const RecordCard({
    super.key,
    required this.record,
    this.categoryEmoji,
    this.categoryName,
    this.categoryColor,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isNegative = record.amount < 0;

    final catColor = categoryColor != null
        ? ColorUtils.fromHex(categoryColor!)
        : Theme.of(context).colorScheme.primary;

    final leadingBg = categoryColor != null
        ? ColorUtils.fromHexWithAlpha(categoryColor!)
        : catColor.withAlpha(25);

    return AppCard(
      onTap: onTap,
      dismissibleKey: Key('record_${record.id}'),
      onDismissed: onDelete,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: leadingBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                PhosphorIcons.receipt(PhosphorIconsStyle.light),
                size: 22,
                color: catColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Description + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.description,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _dateFormat.format(record.date),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Amount + badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${isNegative ? '-' : ''}\$${record.amount.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isNegative
                      ? const Color(0xFFFF3B30)
                      : const Color(0xFF34C759),
                ),
              ),
              const SizedBox(height: 4),
              SourceBadge(
                source: record.source,
                categoryName: categoryName,
                categoryIconName: categoryEmoji,
                categoryColor: categoryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
