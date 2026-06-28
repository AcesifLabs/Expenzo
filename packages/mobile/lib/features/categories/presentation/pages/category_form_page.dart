import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_icons.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import '../../domain/entities/category.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';

class CategoryFormPage extends StatefulWidget {
  final Category? category;
  final RecordType? initialType;

  const CategoryFormPage({super.key, this.category, this.initialType});

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  String _selectedEmoji = 'package';
  String _selectedColor = '#2196F3';
  late RecordType _type;

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

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _type = widget.category?.type ?? widget.initialType ?? RecordType.expense;
    if (_isEditing) {
      _selectedEmoji = widget.category!.emoji;
      _selectedColor = widget.category!.color;
    }
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Text('Icon', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _iconNames.map((name) {
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
                            : Theme.of(
                                context,
                              ).colorScheme.outline.withAlpha(40),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        AppIcons.getCategoryIcon(name),
                        size: 24,
                        color: isSelected ? accentColor : Colors.grey,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

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

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now().toUtc();

      final id = widget.category?.id ?? const Uuid().v4();
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
      Navigator.pop(context, category);
    }
  }
}
