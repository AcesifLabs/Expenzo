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
    context.read<CategoryBloc>().add(LoadCategories(type: _type));
    final state = context.read<CategoryBloc>().state;
    if (state is CategoryLoaded) {
      _categories = state.categories;
    }
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
              // Submit button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1C1C1E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Add ${_type.displayName}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
    // Listen to category bloc for updates
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (ctx, state) {
        if (state is CategoryLoaded) {
          _categories = state.categories;
        }
        final cats = _categories;
        if (cats.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'No categories available',
              style: TextStyle(color: colors.onSurface.withAlpha(80)),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: cats.map((cat) {
              final sel = _selectedCategoryId == cat.id;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedCategoryId = sel ? null : cat.id;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: sel
                        ? const Color(0xFF1C1C1E)
                        : colors.onSurface.withAlpha(12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel
                          ? const Color(0xFF1C1C1E)
                          : colors.onSurface.withAlpha(20),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    cat.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                      color: sel ? Colors.white : colors.onSurface,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
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
