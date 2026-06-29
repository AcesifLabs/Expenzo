import 'package:picons/picons.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_empty_state.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../bloc/category_state.dart';
import '../widgets/category_card.dart';

class CategoryListPage extends StatelessWidget {
  const CategoryListPage({super.key});

  void _refreshCategories(BuildContext context) {
    context.read<CategoryBloc>().add(const LoadCategories());
  }

  Widget _buildCategoryGrid(CategoryLoaded state) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.78,
      ),
      itemCount: state.categories.length,
      itemBuilder: (context, index) {
        final category = state.categories[index];

        return CategoryCard(
          category: category,
          onTap: () => _navigateToForm(context, category),
          onLongPress: () => _showDeleteDialog(context, category),
        );
      },
    );
  }

  void _navigateToForm(BuildContext context, Category? category) {
    if (category?.id != null) {
      context.push(
        '/categories/${category!.id}/edit',
        extra: {'category': category},
      );
    } else {
      context.push('/categories/new');
    }
  }

  void _showDeleteDialog(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _onDeleteConfirm(dialogContext, context, category),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _onDeleteConfirm(
    BuildContext dialogContext,
    BuildContext context,
    Category category,
  ) {
    Navigator.pop(dialogContext);
    final id = category.id;
    if (id != null) {
      context.read<CategoryBloc>().add(DeleteCategoryEvent(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Categories',
      onRefresh: () async => _refreshCategories(context),
      child: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          return switch (state) {
            CategoryLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            CategoryError(:final message) => Center(child: Text(message)),
            CategoryLoaded(:final categories) =>
              categories.isEmpty
                  ? AppEmptyState(
                      icon: PiconsRegular.tag,
                      message: 'No categories created',
                    )
                  : _buildCategoryGrid(state),
            _ => const SizedBox.shrink(),
          };
        },
      ),
    );
  }
}
