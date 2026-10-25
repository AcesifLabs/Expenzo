import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_event.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_state.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/delete_category_dialog.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/category_tile.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_page_header.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/features/categories/presentation/helpers/category_display_name.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

/// Full-screen category picker matching the .pen design.
///
/// Returns the selected [Category] via [Navigator.pop] when a category
/// is tapped, or `null` if the user presses the close button.
class AllCategoriesPickerPage extends StatefulWidget {
  final RecordType type;
  final String? selectedId;

  const AllCategoriesPickerPage({
    super.key,
    required this.type,
    this.selectedId,
  });

  @override
  State<AllCategoriesPickerPage> createState() =>
      _AllCategoriesPickerPageState();
}

class _AllCategoriesPickerPageState extends State<AllCategoriesPickerPage> {
  AppPalette get _palette => context.palette;

  final _searchController = TextEditingController();
  Timer? _debounce;
  String _pendingQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(
      LoadCategories(type: widget.type, sortByUsage: true),
    );
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      context.read<CategoryBloc>().add(
        LoadCategories(type: widget.type, sortByUsage: true),
      );
    } else {
      context.read<CategoryBloc>().add(
        SearchCategoriesEvent(query: query, type: widget.type),
      );
    }
  }

  void _debounceAndSearch(String query) {
    _debounce?.cancel();
    _pendingQuery = query;
    _debounce = Timer(const Duration(milliseconds: 300), _runPendingSearch);
  }

  void _runPendingSearch() {
    _performSearch(_pendingQuery);
  }

  void _onCategoryTap(Category category) {
    Navigator.pop(context, category);
  }

  Future<void> _onLongPressDelete(Category category) async {
    if (category.isDefault) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(content: Text(t.categories.defaultCannotDelete)),
        );

      return;
    }

    final id = category.id;
    if (id == null) return;

    int transactionCount = 0;
    final repo = di.getIt<RecordRepository>();
    final result = await repo.getRecordCountByCategory(id);
    result.fold(
      (_) => transactionCount = 0,
      (count) => transactionCount = count,
    );

    if (!mounted) return;

    final confirmed = await DeleteCategoryDialog.show(
      context: context,
      categoryName: category.displayName,
      transactionCount: transactionCount,
    );

    if (confirmed == true && mounted) {
      context.read<CategoryBloc>().add(DeleteCategoryEvent(id));
    }
  }

  void _onAddNew() {
    context.push('/categories/new', extra: {'initialType': widget.type});
  }

  PreferredSizeWidget _buildTopBar() {
    return AppPageHeader(
      leading: AppBackButton(icon: PiconsRegular.x),
      title: t.records.picker.title,
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: _palette.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
        ),
        child: Row(
          children: [
            Icon(
              PiconsRegular.magnifyingGlass,
              size: 16,
              color: _palette.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              // The whole 48 dp row is the field's tap target.
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: AppSpacing.minTapTarget,
                ),
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  controller: _searchController,
                  onChanged: _debounceAndSearch,
                  style: AppTypography.bodyMedium.copyWith(
                    color: _palette.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: t.records.picker.search,
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: _palette.textSecondary,
                    ),
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading) {
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _palette.textSecondary,
            ),
          );
        }

        if (state is CategoryError) {
          return Center(
            child: Text(
              state.message,
              style: AppTypography.bodyMedium.copyWith(
                color: _palette.textSecondary,
              ),
            ),
          );
        }

        List<Category> categories;
        if (state is CategorySearchResults) {
          categories = state.results;
        } else if (state is CategoryLoaded) {
          categories = state.categories;
        } else {
          categories = [];
        }

        if (categories.isEmpty) {
          return Center(
            child: Text(
              t.records.picker.noneFound,
              style: AppTypography.bodyMedium.copyWith(
                color: _palette.textSecondary,
              ),
            ),
          );
        }

        final expenseCategories = categories
            .where((c) => c.type == RecordType.expense)
            .toList();
        final incomeCategories = categories
            .where((c) => c.type == RecordType.income)
            .toList();

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          children: [
            if (expenseCategories.isNotEmpty) ...[
              _buildSectionHeader(RecordType.expense.displayName.toUpperCase()),
              ...expenseCategories.map((cat) => _buildCategoryRow(cat)),
            ],
            if (incomeCategories.isNotEmpty) ...[
              _buildSectionHeader(RecordType.income.displayName.toUpperCase()),
              ...incomeCategories.map((cat) => _buildCategoryRow(cat)),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.sm),
      child: Text(
        title,
        style: AppTypography.labelMedium.copyWith(
          letterSpacing: 0.05,
          color: _palette.textSecondary,
        ),
      ),
    );
  }

  Widget _buildCategoryRow(Category category) {
    final isSelected = category.id == widget.selectedId;

    return GestureDetector(
      onTap: () => _onCategoryTap(category),
      onLongPress: () => _onLongPressDelete(category),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.smd,
        ),
        color: _palette.surface,
        child: Row(
          children: [
            CategoryTile(
              colorHex: category.color,
              iconKey: category.emoji,
              size: 32,
            ),
            const SizedBox(width: AppSpacing.smd),
            Expanded(
              child: Text(
                category.displayName,
                style: AppTypography.bodyMedium.copyWith(
                  color: _palette.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              Icon(PiconsRegular.checkCircle, size: 20, color: _palette.brand),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCategoryButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: GestureDetector(
        onTap: _onAddNew,
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSpacing.minTapTarget),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: _palette.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
            border: Border.all(color: _palette.textSecondary.withAlpha(64)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(PiconsRegular.plusCircle, size: 18, color: _palette.brand),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  t.records.picker.addCategory,
                  style: AppTypography.bodyMedium.copyWith(
                    color: _palette.brand,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _palette.bg,
      appBar: _buildTopBar(),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildCategoryList()),
            _buildAddCategoryButton(),
          ],
        ),
      ),
    );
  }
}
