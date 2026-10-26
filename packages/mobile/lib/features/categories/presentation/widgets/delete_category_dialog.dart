import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class DeleteCategoryDialog extends StatelessWidget {
  static Future<bool?> show({
    required BuildContext context,
    required String categoryName,
    required int transactionCount,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => DeleteCategoryDialog(
        categoryName: categoryName,
        transactionCount: transactionCount,
        onCancel: () => Navigator.pop(context, false),
        onDelete: () => Navigator.pop(context, true),
      ),
    );
  }

  final String categoryName;
  final int transactionCount;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  const DeleteCategoryDialog({
    super.key,
    required this.categoryName,
    required this.transactionCount,
    required this.onCancel,
    required this.onDelete,
  });

  String _buildDescription() {
    if (transactionCount > 0) {
      return t.categories.delete.withRecords(
        n: transactionCount,
        name: categoryName,
      );
    }

    return t.categories.delete.confirm(name: categoryName);
  }

  Widget _buildButtonRow(AppPalette palette) {
    final errorColor = palette.error;
    final textPrimary = palette.textPrimary;
    final cancelBg = palette.surfaceHigh;

    return SizedBox(
      height: 48,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onCancel,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: cancelBg,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
                ),
                alignment: Alignment.center,
                child: Text(
                  t.common.cancel,
                  style: AppTypography.titleMedium.copyWith(color: textPrimary),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.smd),
          Expanded(
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: errorColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
                ),
                alignment: Alignment.center,
                child: Text(
                  t.common.delete,
                  style: AppTypography.titleMedium.copyWith(color: palette.bg),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final surfaceColor = palette.surface;
    final errorColor = palette.error;
    final textPrimary = palette.textPrimary;
    final textSecondary = palette.textSecondary;

    return Dialog(
      backgroundColor: palette.bg,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Container(
        width: 312,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PiconsRegular.warningCircle, size: 48, color: errorColor),
            const SizedBox(height: AppSpacing.md),
            Text(
              t.categories.delete.title,
              style: AppTypography.headlineSmall.copyWith(color: textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _buildDescription(),
              style: AppTypography.bodyMedium.copyWith(color: textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildButtonRow(palette),
          ],
        ),
      ),
    );
  }
}
