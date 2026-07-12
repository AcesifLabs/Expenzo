import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/core/utils/color_utils.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_icons.dart';
import '../../domain/entities/record.dart';

/// Interactive record card matching the .pen ActivityScreen design.
///
/// Shows: icon (40×40) | title + category name | amount + relative time.
/// Supports dismiss-to-delete and tap-to-edit.
/// Requires [categoryInfo] to be resolved by the parent widget.
class RecordCard extends StatelessWidget {
  /// Formats a date as relative time: "Today, 4:15 PM", "Yesterday", etc.
  static String _formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateOnly).inDays;

    final timeStr = DateFormat('h:mm a').format(date);

    if (difference == 0) return 'Today, $timeStr';

    if (difference == 1) return 'Yesterday';

    if (difference < 7) return DateFormat('EEEE').format(date);

    return DateFormat('MMM d').format(date);
  }

  final Record record;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final CategoryInfo? categoryInfo;

  const RecordCard({
    super.key,
    required this.record,
    required this.onTap,
    required this.onDelete,
    this.categoryInfo,
  });

  Widget _buildLeading() {
    final iconName = categoryInfo?.emoji;
    final catColorHex = categoryInfo?.color;
    final iconColor = catColorHex != null && catColorHex.isNotEmpty
        ? ColorUtils.fromHex(catColorHex)
        : AppColors.primary;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(
          iconName != null && iconName.isNotEmpty
              ? AppIcons.getCategoryIcon(iconName)
              : PiconsLight.receipt,
          size: 20,
          color: iconColor,
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            record.description,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimaryDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            categoryInfo?.name ?? 'Uncategorized',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmount(bool isNegative) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${isNegative ? '-' : ''}\$${record.amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isNegative ? AppColors.expenseDark : AppColors.successDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatRelativeTime(record.date),
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondaryDark,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNegative = record.amount < 0;

    return AppCard(
      onTap: onTap,
      dismissibleKey: Key('record_${record.id}'),
      onDismissed: onDelete,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          _buildLeading(),
          const SizedBox(width: 12),
          _buildInfo(),
          const SizedBox(width: 12),
          _buildAmount(isNegative),
        ],
      ),
    );
  }
}

class CategoryInfo {
  final String? name;
  final String? emoji;
  final String? color;

  const CategoryInfo({this.name, this.emoji, this.color});
}
