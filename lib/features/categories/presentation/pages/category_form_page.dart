import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/category.dart';
import '../bloc/category_bloc.dart';
import '../bloc/category_event.dart';

class CategoryFormPage extends StatefulWidget {
  final Category? category;

  const CategoryFormPage({super.key, this.category});

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  String _selectedEmoji = '📦';
  String _selectedColor = '#2196F3';

  static const List<String> _emojis = [
    '📦',
    '🛒',
    '🍔',
    '🚗',
    '🏠',
    '💊',
    '🎮',
    '📱',
    '✈️',
    '🎓',
    '💰',
    '🎁',
  ];

  static const List<String> _colors = [
    '#E53935',
    '#D81B60',
    '#8E24AA',
    '#5E35B1',
    '#3949AB',
    '#1E88E5',
    '#00ACC1',
    '#00897B',
    '#43A047',
    '#7CB342',
    '#FDD835',
    '#FFB300',
  ];

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Category' : 'New Category'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
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
            const Text('Emoji', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emojis.map((emoji) {
                final isSelected = emoji == _selectedEmoji;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = emoji),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.grey,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text('Color', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colors.map((color) {
                final isSelected = color == _selectedColor;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: isSelected ? 3 : 0,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: isSelected
                        ? const Icon(LucideIcons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
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
      final category = Category(
        id: widget.category?.id,
        name: _nameController.text,
        emoji: _selectedEmoji,
        color: _selectedColor,
        createdAt: widget.category?.createdAt ?? now,
        updatedAt: now,
      );

      if (_isEditing) {
        context.read<CategoryBloc>().add(UpdateCategoryEvent(category));
      } else {
        context.read<CategoryBloc>().add(CreateCategoryEvent(category));
      }
      Navigator.pop(context);
    }
  }
}
