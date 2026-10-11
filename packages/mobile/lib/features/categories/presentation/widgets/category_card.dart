import 'package:flutter/material.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';
import 'package:expense_tracker/shared/presentation/widgets/category_tile.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import '../../domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/helpers/category_display_name.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CategoryTile(colorHex: category.color, iconKey: category.emoji),
          const SizedBox(height: AppSpacing.sm),
          Text(
            category.displayName,
            style: textTheme.titleSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
