import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_icons.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/core/constants/record_type.dart';

class AllCategoriesPicker extends StatelessWidget {
  final List<Category> categories;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final RecordType type;
  final VoidCallback? onAddNew;
  final Color accentColor;

  const AllCategoriesPicker({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelect,
    required this.type,
    this.onAddNew,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: colors.onSurface.withAlpha(50),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Select Category',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Flexible(
            child: GridView.builder(
              shrinkWrap: true,
              itemCount: categories.length + 1,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                // First item is the "Add New" tile
                if (index == 0) {
                  return GestureDetector(
                    onTap: onAddNew,
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: colors.onSurface.withAlpha(10),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.onSurface.withAlpha(40),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            PhosphorIcons.plus(PhosphorIconsStyle.regular),
                            color: colors.onSurface.withAlpha(150),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add New',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.onSurface.withAlpha(150),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // Regular category tiles (shifted by 1)
                final cat = categories[index - 1];
                final isSel = cat.id == selectedId;
                return GestureDetector(
                  onTap: () => onSelect(cat.id!),
                  child: Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: isSel
                              ? accentColor.withAlpha(40)
                              : colors.onSurface.withAlpha(10),
                          shape: BoxShape.circle,
                          border: isSel
                              ? Border.all(color: accentColor, width: 2)
                              : null,
                        ),
                        child: Icon(
                          AppIcons.getCategoryIcon(cat.emoji),
                          color: isSel ? accentColor : colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat.name,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSel
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
