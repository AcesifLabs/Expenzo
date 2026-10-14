import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/shared/presentation/widgets/category_tile.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import '../../domain/entities/record.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

/// Interactive record card matching the .pen ActivityScreen design.
///
/// Shows: category tile | name, then "category · time" | signed amount.
/// The Activity list groups cards under day headings, so only the time shows.
/// Supports dismiss-to-delete and tap-to-edit.
/// Requires [categoryInfo] to be resolved by the parent widget.
class RecordCard extends StatelessWidget {
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

  Widget _buildLeading(AppPalette palette) {
    final iconKey = categoryInfo?.emoji;
    final colorHex = categoryInfo?.color;
    if (iconKey != null && iconKey.isNotEmpty && colorHex != null) {
      return CategoryTile(colorHex: colorHex, iconKey: iconKey);
    }

    // Uncategorized: a neutral tile so the row still lines up.
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: palette.surfaceHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
      ),
      child: Icon(
        PiconsRegular.receipt,
        size: 20,
        color: palette.textSecondary,
      ),
    );
  }

  Widget _buildInfo(AppPalette palette) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            record.description,
            style: AppTypography.bodyLarge.copyWith(color: palette.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${categoryInfo?.name ?? t.categories.uncategorized} · '
            '${DateFormat('h:mm a').format(record.date)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyMedium.copyWith(
              color: palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Stays on one line and shrinks to share the row at large text sizes.
  Widget _buildAmount(AppPalette palette, bool isNegative) {
    return Flexible(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerEnd,
        child: Text(
          CurrencyFormatter.formatSigned(record.amount),
          semanticsLabel: CurrencyFormatter.semanticsLabel(
            record.amount,
            isExpense: isNegative,
          ),
          style: AppTypography.titleMedium.copyWith(
            color: isNegative ? palette.expense : palette.income,
            fontFeatures: AppTypography.tabularFigures,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isNegative = record.amount < 0;

    return AppCard(
      onTap: onTap,
      dismissibleKey: Key('record_${record.id}'),
      onDismissed: onDelete,
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.smd,
        horizontal: AppSpacing.md,
      ),
      child: Row(
        children: [
          _buildLeading(palette),
          const SizedBox(width: AppSpacing.smd),
          _buildInfo(palette),
          const SizedBox(width: AppSpacing.smd),
          _buildAmount(palette, isNegative),
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
