import 'package:flutter/material.dart';
import 'package:picons/picons.dart';

/// A reusable delete-confirmation dialog for categories, matching the
/// `DeleteCategoryDialog` spec in `expenzo.pen`.
///
/// Shows a warning icon, category name, optional transaction count,
/// and Cancel / Delete buttons.
class DeleteCategoryDialog extends StatelessWidget {
  /// Convenience method to show the dialog via [showDialog].
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
      return 'Are you sure you want to delete "$categoryName"? '
          '$transactionCount transactions using this category will be uncategorized.';
    }

    return 'Are you sure you want to delete "$categoryName"?';
  }

  Widget _buildButtonRow() {
    const errorColor = Color(0xFFF48FB1);
    const textPrimary = Color(0xFFF5F7FA);
    const cancelBg = Color(0xFF2B292C);

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
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontFamily: 'Work Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: errorColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    fontFamily: 'Work Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF141315),
                  ),
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
    const surfaceColor = Color(0xFF1C1B1D);
    const errorColor = Color(0xFFF48FB1);
    const textPrimary = Color(0xFFF5F7FA);
    const textSecondary = Color(0xFF8E8E93);

    return Dialog(
      backgroundColor: const Color(0xFF141315),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 312,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              PiconsRegular.warningCircle,
              size: 48,
              color: errorColor,
            ),
            const SizedBox(height: 16),
            const Text(
              'Delete Category?',
              style: TextStyle(
                fontFamily: 'Work Sans',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _buildDescription(),
              style: const TextStyle(
                fontFamily: 'Work Sans',
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildButtonRow(),
          ],
        ),
      ),
    );
  }
}
