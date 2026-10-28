import 'package:flutter/material.dart';

import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/category_tile.dart';

import '../../domain/entities/category.dart';
import '../helpers/category_display_name.dart';

class CategorySettingsRow extends StatelessWidget {
  final Category category;
  final int? recordCount;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const CategorySettingsRow({
    super.key,
    required this.category,
    required this.recordCount,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final count = recordCount;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSpacing.minTapTarget),
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        leading: CategoryTile(
          colorHex: category.color,
          iconKey: category.emoji,
        ),
        title: Text(
          category.displayName,
          style: textTheme.bodyMedium?.copyWith(color: palette.textPrimary),
        ),

        trailing: count == null
            ? null
            : ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width / 3,
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerEnd,
                  child: Text(
                    t.categories.settings.recordCount(n: count),
                    maxLines: 1,
                    style: textTheme.bodySmall?.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
