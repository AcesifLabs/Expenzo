import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_icons.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
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

    return Dismissible(
      key: Key('record_${record.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        color: AppColors.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: Icon(
          PhosphorIcons.trash(PhosphorIconsStyle.regular),
          color: Colors.white,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: categoryColor != null
                        ? Color(
                            int.parse(categoryColor!.replaceFirst('#', '0xFF')),
                          ).withValues(alpha: 0.15)
                        : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      AppIcons.getCategoryIcon(categoryEmoji ?? 'package'),
                      size: 24,
                      color: categoryColor != null
                          ? Color(
                              int.parse(
                                categoryColor!.replaceFirst('#', '0xFF'),
                              ),
                            )
                          : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${isNegative ? '-' : ''}৳${record.amount.abs().toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isNegative ? AppColors.error : AppColors.success,
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
          ),
        ),
      ),
    );
  }
}
