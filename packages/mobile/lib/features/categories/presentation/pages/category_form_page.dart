import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_icons.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';

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
  static const List<String> _iconNames = [
    'package',
    'shoppingCart',
    'forkKnife',
    'car',
    'house',
    'heartbeat',
    'gameController',
    'deviceMobile',
    'airplane',
    'graduationCap',
    'currencyDollar',
    'gift',
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedEmoji = 'package';
  String _selectedColor = '#2196F3';
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
    _selectedEmoji = category.emoji;
    _selectedColor = category.color;
    _type = category.type;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a name';
    }

    return null;
  }

  Widget _buildIconSelector(Color accentColor) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _iconNames.map((name) {
        return _buildIconItem(name, accentColor);
      }).toList(),
    );
  }

  Widget _buildIconItem(String name, Color accentColor) {
    final isSelected = name == _selectedEmoji;

    return GestureDetector(
      onTap: () => setState(() => _selectedEmoji = name),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? accentColor
                : Theme.of(context).colorScheme.outline.withAlpha(40),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(
            AppIcons.getCategoryIcon(name),
            size: 24,
            color: isSelected
                ? accentColor
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  void _saveCategory() {
    final currentState = _formKey.currentState;
    if (currentState == null || !currentState.validate()) return;

    final now = DateTime.now().toUtc();
    final id = widget.category?.id ?? widget.categoryId ?? const Uuid().v4();
    final category = Category(
      id: id,
      name: _nameController.text,
      emoji: _selectedEmoji,
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
    final colors = Theme.of(context).colorScheme;
    final isExpense = _type == RecordType.expense;
    final accentColor = isExpense ? colors.error : colors.primary;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            _isEditing ? 'Edit Category' : 'New ${_type.displayName} Category',
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Category' : 'New ${_type.displayName} Category',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'Enter category name',
              ),
              validator: _validateName,
            ),
            const SizedBox(height: 24),
            const Text('Icon', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            _buildIconSelector(accentColor),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: colors.onError,
              ),
              onPressed: _saveCategory,
              child: Text(_isEditing ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }
}
