import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/features/records/domain/entities/record.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';

/// A read-only record tile for dashboard summary lists.
///
/// Unlike [RecordCard] which supports interactive actions (onTap, onDelete),
/// this widget is a lightweight, presentational tile optimized for use in
/// dashboard recent-activity sections and other read-only contexts.
class ReadOnlyRecordTile extends StatelessWidget {
  final Record record;
  final NumberFormat? amountFormat;
  final EdgeInsetsGeometry padding;
  final double avatarRadius;
  final double iconSize;

  // A getter, not cached: DateFormat keeps the language it was created in.
  static DateFormat get _dateFormat => DateFormat('MMM dd');

  const ReadOnlyRecordTile({
    super.key,
    required this.record,
    this.amountFormat,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.smd,
    ),
    this.avatarRadius = 18,
    this.iconSize = 16,
  });

  String _formatAmount() {
    final localAmountFormat = amountFormat;
    if (localAmountFormat != null) {
      return localAmountFormat.format(record.amount);
    }
    final prefix = record.recordType == RecordType.expense ? '-' : '+';

    return '$prefix${CurrencyFormatter.format(record.amount.abs())}';
  }

  String _description() {
    if (record.description.isNotEmpty) return record.description;

    return record.recordType.displayName;
  }

  Widget _leadingIcon(Color amtColor) {
    return CircleAvatar(
      radius: avatarRadius,
      backgroundColor: amtColor.withAlpha(25),
      child: Icon(
        record.recordType == RecordType.expense
            ? PiconsRegular.trendDown
            : PiconsRegular.trendUp,
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
            style: AppTypography.bodyMedium.copyWith(color: colors.onSurface),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _dateFormat.format(record.date),
            style: AppTypography.bodySmall.copyWith(
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
      semanticsLabel: CurrencyFormatter.semanticsLabel(
        record.amount,
        isExpense: record.recordType == RecordType.expense,
      ),
      style: AppTypography.titleMedium.copyWith(color: amtColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = record.recordType == RecordType.expense;
    final palette = context.palette;
    final amtColor = isExpense ? palette.expense : palette.income;
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: padding,
      child: Row(
        children: [
          _leadingIcon(amtColor),
          const SizedBox(width: AppSpacing.smd),
          _titleAndDate(colors),
          _amountText(amtColor),
        ],
      ),
    );
  }
}
