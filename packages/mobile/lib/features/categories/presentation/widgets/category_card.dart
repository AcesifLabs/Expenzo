import 'package:flutter/material.dart';
import 'package:expense_tracker/core/utils/color_utils.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_icons.dart';
import '../../domain/entities/category.dart';

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
    final parsedColor = ColorUtils.fromHex(category.color);

    return AppCard(
      onTap: onTap,
      onLongPress: onLongPress,
      backgroundColor: const Color(0x00000000),
      borderColor: parsedColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppIcons.getCategoryIcon(category.emoji),
            size: 32,
            color: parsedColor,
          ),
          const SizedBox(height: 8),
          Text(
            category.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: parsedColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
