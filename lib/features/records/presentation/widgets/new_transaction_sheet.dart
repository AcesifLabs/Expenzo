import 'package:expense_tracker/shared/presentation/widgets/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_state.dart';
import '../../../categories/presentation/bloc/category_event.dart';
import '../../domain/entities/record.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import '../bloc/record_bloc.dart';
import '../bloc/record_event.dart';

class NewTransactionSheet extends StatefulWidget {
  const NewTransactionSheet({super.key});

  @override
  State<NewTransactionSheet> createState() => _NewTransactionSheetState();
}

class _NewTransactionSheetState extends State<NewTransactionSheet> {
  late RecordType _type;
  final _amountText = ValueNotifier<String>('');
  final _noteCtrl = TextEditingController();
  int? _selectedCategoryId;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _type = RecordType.expense;
    _loadCategories();
  }

  @override
  void dispose() {
    _amountText.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _loadCategories() {
    context.read<CategoryBloc>().add(
      LoadCategories(type: _type, sortByUsage: true),
    );
  }

  void _showAllCategories(BuildContext context, List<Category> allCategories) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AllCategoriesPicker(
        categories: allCategories,
        selectedId: _selectedCategoryId,
        onSelect: (id) {
          setState(() => _selectedCategoryId = id);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _switchType(RecordType t) {
    setState(() {
      _type = t;
      _selectedCategoryId = null;
    });
    _loadCategories();
  }

  void _appendDigit(String d) {
    final current = _amountText.value;
    if (d == '.' && current.contains('.')) return;
    if (current == '0' && d != '.') {
      _amountText.value = d;
      return;
    }
    // Limit to 2 decimal places
    if (current.contains('.') && current.split('.')[1].length >= 2) return;
    // Limit total digits
    if (current.replaceAll('.', '').length >= 10) return;
    _amountText.value = current + d;
  }

  void _backspace() {
    if (_amountText.value.isNotEmpty) {
      _amountText.value = _amountText.value.substring(
        0,
        _amountText.value.length - 1,
      );
    }
  }

  double get _parsedAmount => double.tryParse(_amountText.value) ?? 0;

  void _submit() {
    final amount = _parsedAmount;
    if (amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter an amount')));
      return;
    }
    final now = DateTime.now().toUtc();
    final finalAmount = _type == RecordType.expense ? -amount : amount;

    final record = Record(
      amount: finalAmount,
      description: _noteCtrl.text.trim(),
      date: DateTime.now(),
      categoryId: _selectedCategoryId,
      source: ExpenseSource.manual,
      recordType: _type,
      createdAt: now,
      updatedAt: now,
    );

    context.read<RecordBloc>().add(AddRecordEvent(record));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.onSurface.withAlpha(50),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Toggle
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: _TypeToggle(type: _type, onSwitch: _switchType),
              ),
              // Amount display
              ValueListenableBuilder<String>(
                valueListenable: _amountText,
                builder: (_, val, _) {
                  final displayVal = val.isEmpty ? '0' : val;
                  final sign = _type == RecordType.expense ? '-' : '+';
                  final signColor = _type == RecordType.expense
                      ? const Color(0xFFFF3B30)
                      : const Color(0xFF34C759);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      '$sign$displayVal',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: signColor,
                        letterSpacing: -1,
                      ),
                    ),
                  );
                },
              ),
              // Numeric keypad
              _NumericKeypad(
                onDigit: _appendDigit,
                onBackspace: _backspace,
                color: colors,
              ),
              // Categories
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                ),
              ),
              _buildCategoryChips(colors),
              // Note
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
                child: TextField(
                  controller: _noteCtrl,
                  decoration: InputDecoration(
                    hintText: 'Add a note...',
                    hintStyle: TextStyle(color: colors.onSurface.withAlpha(80)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colors.onSurface.withAlpha(25),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colors.onSurface.withAlpha(25),
                      ),
                    ),
                    filled: true,
                    fillColor: colors.onSurface.withAlpha(8),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  style: TextStyle(fontSize: 15, color: colors.onSurface),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: _type == RecordType.expense
                          ? colors.error
                          : colors.primary,
                      foregroundColor: colors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Add ${_type.displayName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(ColorScheme colors) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (ctx, state) {
        if (state is CategoryLoaded) {
          _categories = state.categories;
        }
        final allCats = _categories;
        if (allCats.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'No categories available',
              style: TextStyle(color: colors.onSurface.withAlpha(80)),
            ),
          );
        }

        final displayCats = allCats.take(5).toList();
        if (_selectedCategoryId != null &&
            !displayCats.any((c) => c.id == _selectedCategoryId)) {
          final selected = allCats.firstWhere(
            (c) => c.id == _selectedCategoryId,
          );
          displayCats.removeLast();
          displayCats.insert(0, selected);
        }

        return Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              ...displayCats.map((cat) {
                final sel = _selectedCategoryId == cat.id;
                return _CategoryPickerItem(
                  category: cat,
                  isSelected: sel,
                  onTap: () => setState(() {
                    _selectedCategoryId = sel ? null : cat.id;
                  }),
                );
              }),
              // More button - hide if something selected
              if (_selectedCategoryId == null)
                _MoreButton(onTap: () => _showAllCategories(context, allCats)),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryPickerItem extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryPickerItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isLight = Theme.of(context).brightness == Brightness.light;

    final iconColor = isSelected
        ? colors.primary
        : colors.onSurface.withAlpha(150);

    final textColor = (isSelected && isLight) ? Colors.black : iconColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withAlpha(25)
              : colors.onSurface.withAlpha(10),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? colors.primary.withAlpha(50)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              AppIcons.getCategoryIcon(category.emoji),
              size: 20,
              color: iconColor,
            ),
            ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                child: isSelected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          category.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          maxLines: 1,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreButton extends StatelessWidget {
  final VoidCallback onTap;
  const _MoreButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        margin: const EdgeInsets.only(left: 4),
        decoration: BoxDecoration(
          color: colors.onSurface.withAlpha(10),
          shape: BoxShape.circle,
        ),
        child: Icon(
          PhosphorIcons.dotsThree(PhosphorIconsStyle.bold),
          size: 20,
          color: colors.onSurface.withAlpha(150),
        ),
      ),
    );
  }
}

class _AllCategoriesPicker extends StatelessWidget {
  final List<Category> categories;
  final int? selectedId;
  final ValueChanged<int> onSelect;

  const _AllCategoriesPicker({
    required this.categories,
    required this.selectedId,
    required this.onSelect,
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
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemBuilder: (context, index) {
                final cat = categories[index];
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
                              ? colors.primary.withAlpha(40)
                              : colors.onSurface.withAlpha(10),
                          shape: BoxShape.circle,
                          border: isSel
                              ? Border.all(color: colors.primary, width: 2)
                              : null,
                        ),
                        child: Icon(
                          AppIcons.getCategoryIcon(cat.emoji),
                          color: isSel ? colors.primary : colors.onSurface,
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

// ──────────────────────────────────
// Type Toggle
// ──────────────────────────────────
class _TypeToggle extends StatelessWidget {
  final RecordType type;
  final ValueChanged<RecordType> onSwitch;

  const _TypeToggle({required this.type, required this.onSwitch});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.onSurface.withAlpha(12),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onSwitch(RecordType.expense),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: type == RecordType.expense
                      ? const Color(0xFFFF3B30).withAlpha(25)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      PhosphorIcons.trendDown(PhosphorIconsStyle.fill),
                      size: 18,
                      color: type == RecordType.expense
                          ? const Color(0xFFFF3B30)
                          : colors.onSurface.withAlpha(100),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Expense',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: type == RecordType.expense
                            ? const Color(0xFFFF3B30)
                            : colors.onSurface.withAlpha(100),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onSwitch(RecordType.income),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: type == RecordType.income
                      ? const Color(0xFF34C759).withAlpha(25)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      PhosphorIcons.trendUp(PhosphorIconsStyle.fill),
                      size: 18,
                      color: type == RecordType.income
                          ? const Color(0xFF34C759)
                          : colors.onSurface.withAlpha(100),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Income',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: type == RecordType.income
                            ? const Color(0xFF34C759)
                            : colors.onSurface.withAlpha(100),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────
// Numeric Keypad
// ──────────────────────────────────
class _NumericKeypad extends StatelessWidget {
  final void Function(String) onDigit;
  final VoidCallback onBackspace;
  final ColorScheme color;

  const _NumericKeypad({
    required this.onDigit,
    required this.onBackspace,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final btnColor = color.onSurface.withAlpha(12);
    final txtColor = color.onSurface;

    Widget btn(String label, {VoidCallback? custom}) {
      return Expanded(
        child: GestureDetector(
          onTap: custom ?? () => onDigit(label),
          child: Container(
            height: 52,
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: btnColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: label == 'back'
                  ? Icon(
                      PhosphorIcons.backspace(PhosphorIconsStyle.light),
                      color: txtColor,
                      size: 22,
                    )
                  : Text(
                      label,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: txtColor,
                      ),
                    ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(children: [btn('1'), btn('2'), btn('3')]),
          Row(children: [btn('4'), btn('5'), btn('6')]),
          Row(children: [btn('7'), btn('8'), btn('9')]),
          Row(
            children: [
              btn('.'),
              btn('0'),
              btn('back', custom: onBackspace),
            ],
          ),
        ],
      ),
    );
  }
}
