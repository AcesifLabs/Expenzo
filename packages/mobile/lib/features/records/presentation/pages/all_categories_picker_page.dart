import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/shared/presentation/widgets/app_icons.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_event.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_state.dart';
import 'package:expense_tracker/features/categories/presentation/widgets/delete_category_dialog.dart';
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Default categories cannot be deleted')),
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
      categoryName: category.name,
      transactionCount: transactionCount,
    );

    if (confirmed == true && mounted) {
      context.read<CategoryBloc>().add(DeleteCategoryEvent(id));
    }
  }

  void _onAddNew() {
    context.push('/categories/new', extra: {'initialType': widget.type});
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 24, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              PiconsRegular.x,
              size: 24,
              color: Color(0xFFF5F7FA),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Choose Category',
            style: TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFFF5F7FA),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1B1D),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(
              PiconsRegular.magnifyingGlass,
              size: 16,
              color: Color(0xFF8E8E93),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: _debounceAndSearch,
                style: const TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 14,
                  color: Color(0xFFF5F7FA),
                ),
                decoration: InputDecoration(
                  hintText: 'Search categories...',
                  hintStyle: const TextStyle(
                    fontFamily: 'Work Sans',
                    fontSize: 14,
                    color: Color(0xFF8E8E93),
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
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoading) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF8E8E93),
            ),
          );
        }

        if (state is CategoryError) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(
                fontFamily: 'Work Sans',
                fontSize: 14,
                color: Color(0xFF8E8E93),
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
          return const Center(
            child: Text(
              'No categories found',
              style: TextStyle(
                fontFamily: 'Work Sans',
                fontSize: 14,
                color: Color(0xFF8E8E93),
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
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          children: [
            if (expenseCategories.isNotEmpty) ...[
              _buildSectionHeader('EXPENSE'),
              ...expenseCategories.map((cat) => _buildCategoryRow(cat)),
            ],
            if (incomeCategories.isNotEmpty) ...[
              _buildSectionHeader('INCOME'),
              ...incomeCategories.map((cat) => _buildCategoryRow(cat)),
            ],
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Work Sans',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.05,
          color: Color(0xFF8E8E93),
        ),
      ),
    );
  }

  Widget _buildCategoryRow(Category category) {
    final isSelected = category.id == widget.selectedId;
    final iconColor = _getCategoryColor(category);

    return GestureDetector(
      onTap: () => _onCategoryTap(category),
      onLongPress: () => _onLongPressDelete(category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: const Color(0xFF1C1B1D),
        child: Row(
          children: [
            Icon(
              AppIcons.getCategoryIcon(category.emoji),
              size: 20,
              color: iconColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                category.name,
                style: const TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 14,
                  color: Color(0xFFF5F7FA),
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                PiconsRegular.checkCircle,
                size: 20,
                color: Color(0xFFD1C4E9),
              ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(Category category) {
    final colorHex = category.color;
    if (colorHex.isNotEmpty) {
      try {
        final hex = colorHex.replaceFirst('#', '');

        return Color(int.parse('0xFF$hex'));
      } catch (_) {
        // Fallback to default color
      }
    }

    return const Color(0xFF8E8E93);
  }

  Widget _buildAddCategoryButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: GestureDetector(
        onTap: _onAddNew,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1B1D),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF8E8E93).withAlpha(64)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PiconsRegular.plusCircle,
                size: 18,
                color: Color(0xFFD1C4E9),
              ),
              SizedBox(width: 8),
              Text(
                'Add New Category',
                style: TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFD1C4E9),
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
    const backgroundColor = Color(0xFF141315);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            _buildSearchBar(),
            Expanded(child: _buildCategoryList()),
            _buildAddCategoryButton(),
          ],
        ),
      ),
    );
  }
}
