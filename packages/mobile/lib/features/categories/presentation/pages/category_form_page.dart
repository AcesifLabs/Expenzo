import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';
import 'package:uuid/uuid.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_page_header.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../widgets/category_type_toggle.dart';
import '../widgets/icon_grid_picker.dart';
import '../widgets/color_picker_row.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/features/categories/presentation/helpers/category_display_name.dart';

class CategoryFormPage extends StatefulWidget {
  final Category? category;
  final RecordType? initialType;
  final String? categoryId;

  const CategoryFormPage({
    super.key,
    this.category,
    this.initialType,
    this.categoryId,
  });

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  AppPalette get _palette => context.palette;
  final _nameController = TextEditingController();

  /// The category being edited, as stored.
  Category? _original;
  String _selectedIcon = 'shoppingCart';
  String _selectedColor = '#D1C4E9';
  RecordType _type = RecordType.expense;
  var _isLoading = false;

  bool get _isEditing => widget.category != null || widget.categoryId != null;

  @override
  void initState() {
    super.initState();
    final categoryId = widget.categoryId;
    if (categoryId != null) {
      _isLoading = true;
      _loadCategory(categoryId);
    } else {
      _initFromCategory(widget.category);
      final initialType = widget.initialType;
      if (widget.category == null && initialType != null) {
        _type = initialType;
      }
    }
  }

  Future<void> _loadCategory(String id) async {
    final repo = di.getIt<CategoryRepository>();
    final result = await repo.getCategoryById(id);
    if (!mounted) return;
    result.fold(
      (failure) {
        debugPrint(
          'CategoryFormPage: Failed to load category: ${failure.message}',
        );
        setState(() => _isLoading = false);
      },
      (category) {
        if (!mounted) return;
        setState(() {
          _initFromCategory(category);
          _isLoading = false;
        });
      },
    );
  }

  void _initFromCategory(Category? category) {
    if (category == null) return;
    _original = category;
    _nameController.text = category.displayName;
    _selectedIcon = category.emoji;
    _selectedColor = category.color;
    _type = category.type;
  }

  void _saveCategory() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(t.categories.form.nameRequired)));

      return;
    }

    final now = DateTime.now().toUtc();
    final id = widget.category?.id ?? widget.categoryId ?? const Uuid().v4();
    final existing = _original ?? widget.category;
    // An untouched default shows its translated name; saving it unchanged
    // must keep the English seed name so it stays translatable.
    final storedName = existing != null && name == existing.displayName
        ? existing.name
        : name;
    final category = Category(
      id: id,
      name: storedName,
      isDefault: existing?.isDefault ?? false,
      emoji: _selectedIcon,
      color: _selectedColor,
      type: _type,
      createdAt: widget.category?.createdAt ?? now,
      updatedAt: now,
    );

    if (_isEditing) {
      context.read<CategoryBloc>().add(UpdateCategoryEvent(category));
    } else {
      context.read<CategoryBloc>().add(CreateCategoryEvent(category));
    }
    context.pop(category);
  }

  PreferredSizeWidget _buildTopBar() {
    return AppPageHeader(
      leading: const AppBackButton(icon: PiconsRegular.x),
      title: _isEditing ? t.categories.form.edit : t.categories.form.add,
    );
  }

  Widget _buildNameField() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.smd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.categories.form.name,
            style: AppTypography.bodySmall.copyWith(
              color: _palette.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: _palette.inputFill,
              borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
              border: Border.all(color: _palette.inputStroke, width: 1),
            ),
            child: TextField(
              controller: _nameController,
              style: AppTypography.bodyLarge.copyWith(
                color: _palette.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: t.categories.form.nameHint,
                hintStyle: TextStyle(color: _palette.textSecondary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _saveCategory,
          style: ElevatedButton.styleFrom(
            backgroundColor: _palette.brandFill,
            foregroundColor: _palette.onBrandFill,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
            ),
            elevation: 0,
          ),
          child: Text(t.common.save, style: AppTypography.titleMedium),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _palette.bg,
        body: Center(child: CircularProgressIndicator(color: _palette.brand)),
      );
    }

    return Scaffold(
      backgroundColor: _palette.bg,
      appBar: _buildTopBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CategoryTypeToggle(
                      type: _type,
                      onSwitch: (t) => setState(() => _type = t),
                    ),
                    _buildNameField(),
                    IconGridPicker(
                      selectedIcon: _selectedIcon,
                      onIconSelected: (icon) =>
                          setState(() => _selectedIcon = icon),
                    ),
                    ColorPickerRow(
                      selectedColor: _selectedColor,
                      onColorSelected: (color) =>
                          setState(() => _selectedColor = color),
                    ),
                  ],
                ),
              ),
            ),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }
}
