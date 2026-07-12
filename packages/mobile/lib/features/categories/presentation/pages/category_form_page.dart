import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';
import 'package:uuid/uuid.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';
import '../widgets/category_type_toggle.dart';
import '../widgets/icon_grid_picker.dart';
import '../widgets/color_picker_row.dart';

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
  final _nameController = TextEditingController();
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
      if (widget.category == null && widget.initialType != null) {
        _type = widget.initialType!;
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
    _nameController.text = category.name;
    _selectedIcon = category.emoji;
    _selectedColor = category.color;
    _type = category.type;
  }

  void _saveCategory() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a name')));
      return;
    }

    final now = DateTime.now().toUtc();
    final id = widget.category?.id ?? widget.categoryId ?? const Uuid().v4();
    final category = Category(
      id: id,
      name: name,
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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _DesignTokens.background,
        body: Center(
          child: CircularProgressIndicator(color: _DesignTokens.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _DesignTokens.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
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

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(
              PiconsRegular.x,
              size: 24,
              color: _DesignTokens.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _isEditing ? 'Edit Category' : 'Add New Category',
            style: const TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: _DesignTokens.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Name',
            style: TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _DesignTokens.mutedColor,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: _DesignTokens.inputFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _DesignTokens.inputBorder, width: 1),
            ),
            child: TextField(
              controller: _nameController,
              style: const TextStyle(
                fontFamily: 'Work Sans',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _DesignTokens.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'Groceries',
                hintStyle: TextStyle(color: _DesignTokens.mutedColor),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _saveCategory,
          style: ElevatedButton.styleFrom(
            backgroundColor: _DesignTokens.primary,
            foregroundColor: _DesignTokens.background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Save Category',
            style: TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _DesignTokens {
  _DesignTokens._();

  static const Color background = Color(0xFF141315);
  static const Color primary = Color(0xFFD1C4E9);
  static const Color textPrimary = Color(0xFFF5F7FA);
  static const Color mutedColor = Color(0xFF8E8E93);
  static const Color inputFill = Color(0xFF201F21);
  static const Color inputBorder = Color(0x208E8E93);
}
