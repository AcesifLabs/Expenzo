import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_state.dart';
import '../../../categories/presentation/bloc/category_event.dart';
import '../../domain/entities/record.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:expense_tracker/features/recurring/domain/repositories/recurring_repository.dart';
import '../bloc/record_bloc.dart';
import '../bloc/record_event.dart';
import 'new_transaction/all_categories_picker.dart';
import 'new_transaction/category_picker_item.dart';
import 'new_transaction/numeric_keypad.dart';
import 'new_transaction/type_toggle.dart';
import 'new_transaction/typewriter_animation_mixin.dart';

class NewTransactionSheet extends StatefulWidget {
  final RecurringRepository? recurringRepository;

  const NewTransactionSheet({super.key, this.recurringRepository});

  @override
  State<NewTransactionSheet> createState() => _NewTransactionSheetState();
}

class _NewTransactionSheetState extends State<NewTransactionSheet>
    with TickerProviderStateMixin, TypewriterAnimationMixin {
  static const _expensePlaceholders = [
    'Groceries',
    'Uber to office',
    'Lunch with colleague',
    'Netflix subscription',
    'Electricity bill',
    'Gas station',
  ];

  static const _incomePlaceholders = [
    'Salary',
    'Freelance payment',
    'Side hustle',
    'Refund',
    'Bonus',
    'Investment dividend',
  ];

  // ignore: avoid-late-keyword
  late final AnimationController _glowController;
  // ignore: avoid-late-keyword
  late final CurvedAnimation _glowCurve;

  RecordType _type = RecordType.expense;
  final _amountText = ValueNotifier<String>('');
  final _noteCtrl = TextEditingController();
  String? _selectedCategoryId;
  List<Category> _categories = [];
  var _hasManuallyDeselected = false;
  var _labelError = false;
  var _categoryError = false;
  var _isSubmitting = false;
  var _selectedDate = DateTime.now();
  var _isRecurring = false;

  double get _parsedAmount => double.tryParse(_amountText.value) ?? 0;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    initTypewriter(_expensePlaceholders);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _glowCurve = CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeIn,
      reverseCurve: Curves.easeOut,
    );
    _glowController.addStatusListener(_onGlowStatus);
    _noteCtrl.addListener(_onNoteChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) startTypewriter();
    });
  }

  void _onGlowStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _glowController.reverse();
    } else if (status == AnimationStatus.dismissed) {
      setState(() {
        _labelError = false;
        _categoryError = false;
      });
    }
  }

  void _onNoteChanged() {
    if (_labelError && _noteCtrl.text.trim().isNotEmpty) {
      setState(() => _labelError = false);
    }
    if (_noteCtrl.text.isNotEmpty && !isTypewriterPaused) {
      pauseTypewriter();
    } else if (_noteCtrl.text.isEmpty && isTypewriterPaused) {
      resumeTypewriter();
    }
  }

  void _loadCategories() {
    context.read<CategoryBloc>().add(
      LoadCategories(type: _type, sortByUsage: true),
    );
  }

  void _showAllCategories(
    BuildContext context,
    List<Category> allCategories,
    RecordType type,
  ) {
    final colors = Theme.of(context).colorScheme;
    final accentColor = type == RecordType.expense
        ? colors.error
        : colors.primary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0x00000000),
      builder: (ctx) => AllCategoriesPicker(
        categories: allCategories,
        selectedId: _selectedCategoryId,
        type: type,
        accentColor: accentColor,
        onAddNew: _onAddNew(ctx, type),
        onSelect: _onCategorySelect(ctx),
      ),
    );
  }

  VoidCallback _onAddNew(BuildContext ctx, RecordType type) {
    return () {
      final categoryBloc = context.read<CategoryBloc>();
      Navigator.pop(ctx);
      _addNewCategory(context, type, categoryBloc);
    };
  }

  void Function(String) _onCategorySelect(BuildContext ctx) {
    return (id) {
      setState(() {
        _selectedCategoryId = id;
        _categoryError = false;
      });
      Navigator.pop(ctx);
    };
  }

  Future<void> _addNewCategory(
    BuildContext context,
    RecordType type,
    CategoryBloc categoryBloc,
  ) async {
    final created = await context.push<Category>(
      '/categories/new',
      extra: {'initialType': type, 'categoryBloc': categoryBloc},
    );
    if (created != null && context.mounted) {
      setState(() {
        _selectedCategoryId = created.id;
        _categories = [created, ..._categories];
      });
    }
  }

  void _selectDefaultCategory(List<Category> categories) {
    if (_selectedCategoryId != null ||
        _hasManuallyDeselected ||
        categories.isEmpty) {
      return;
    }

    final targetId = _findDefaultCategoryId(categories);
    if (targetId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _selectedCategoryId == null) {
          setState(() => _selectedCategoryId = targetId);
        }
      });
    }
  }

  String? _findDefaultCategoryId(List<Category> categories) {
    for (final c in categories) {
      if (c.name == 'General' && c.isDefault) return c.id;
    }

    return categories.first.id;
  }

  void _switchType(RecordType t) {
    _glowController.reset();
    stopTypewriter();
    setState(() {
      _type = t;
      _selectedCategoryId = null;
      _categories = [];
      _hasManuallyDeselected = false;
      _labelError = false;
      _categoryError = false;
    });
    _loadCategories();
    initTypewriter(
      t == RecordType.expense ? _expensePlaceholders : _incomePlaceholders,
    );
    if (!isTypewriterPaused) startTypewriter();
  }

  void _onHorizontalSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity;
    if (velocity == null || velocity.abs() < 100) return;

    final targetType = velocity > 0 ? RecordType.expense : RecordType.income;
    if (targetType != _type) _switchType(targetType);
  }

  void _appendDigit(String d) {
    final current = _amountText.value;
    if (d == '.' && current.contains('.')) return;

    if (current == '0' && d != '.') {
      _amountText.value = d;

      return;
    }

    final dotIndex = current.indexOf('.');
    if (dotIndex != -1 && current.substring(dotIndex + 1).length >= 2) return;

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

  Color _resolveGlowBorderColor(
    bool hasError,
    ColorScheme colors, {
    Color? fallback,
  }) {
    if (!hasError) return fallback ?? Colors.transparent;

    if (_glowController.isAnimating) {
      final lerped = Color.lerp(
        colors.error.withAlpha(80),
        colors.error,
        _glowCurve.value,
      );

      return lerped ?? colors.error;
    }

    return colors.error.withAlpha(150);
  }

  void _triggerValidationGlow() {
    _glowController.forward(from: 0.0);
  }

  bool _validateInput(double amount, String description) {
    var hasError = false;
    if (amount <= 0) {
      hasError = true;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter an amount')));
    }
    if (description.isEmpty) hasError = true;
    if (_selectedCategoryId == null) hasError = true;

    return hasError;
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final amount = _parsedAmount;
    final description = _noteCtrl.text.trim();

    if (_validateInput(amount, description)) {
      setState(() {
        _labelError = description.isEmpty;
        _categoryError = _selectedCategoryId == null;
      });
      if (_labelError || _categoryError) _triggerValidationGlow();

      return;
    }

    setState(() => _isSubmitting = true);

    final now = DateTime.now().toUtc();
    final finalAmount = _type == RecordType.expense ? -amount : amount;

    final record = Record(
      amount: finalAmount,
      description: description,
      date: _selectedDate,
      categoryId: _selectedCategoryId,
      source: ExpenseSource.manual,
      recordType: _type,
      createdAt: now,
      updatedAt: now,
    );

    context.read<RecordBloc>().add(AddRecordEvent(record));

    if (_isRecurring) {
      final created = await _createRecurringTransaction(finalAmount);
      if (!created) {
        if (mounted) setState(() => _isSubmitting = false);

        return;
      }
    }

    if (mounted) Navigator.pop(context);
  }

  Future<bool> _createRecurringTransaction(double finalAmount) async {
    try {
      final repo = widget.recurringRepository;
      if (repo == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recurring transactions are not ready yet.'),
            ),
          );
        }

        return false;
      }

      await repo.createRecurring(
        RecurringTransaction(
          description: _noteCtrl.text.trim(),
          amount: finalAmount,
          categoryId: _selectedCategoryId,
          frequency: RecurringFrequency.monthly,
          startDate: _selectedDate,
          endDate: null,
          nextOccurrence: _nextOccurrenceAfter(_selectedDate),
          isActive: true,
          autoCreateExpense: true,
          dayOfMonth: _selectedDate.day,
        ),
      );

      return true;
    } catch (e, s) {
      debugPrint('Error: $e\n$s');
      debugPrint(
        'NewTransactionSheet: Failed to create recurring transaction: $e',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Recurring transaction could not be saved. You can set it up later from the Recurring tab.',
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }

      return false;
    }
  }

  DateTime _nextOccurrenceAfter(DateTime date) =>
      DateTime(date.year, date.month + 1, date.day);

  String _getHintText() {
    if (!isTypewriterPaused && typewriterDisplayText.isNotEmpty) {
      return typewriterDisplayText;
    }

    return _type == RecordType.expense ? 'Name of expense' : 'Name of income';
  }

  Widget _buildDragHandle(ColorScheme colors) {
    return _DragHandle(colors: colors);
  }

  Widget _buildTypeToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: TypeToggle(type: _type, onSwitch: _switchType),
    );
  }

  Widget _buildAmountDisplay(ColorScheme _) {
    return ValueListenableBuilder<String>(
      valueListenable: _amountText,
      builder: (_, val, _) {
        final displayVal = val.isEmpty ? '0' : val;
        final sign = _type == RecordType.expense ? '-' : '+';
        final signColor = _type == RecordType.expense
            ? AppColors.expense
            : AppColors.success;

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
    );
  }

  Widget _buildNoteField(ColorScheme colors) {
    final typeColor = _type == RecordType.expense
        ? colors.error
        : colors.primary;

    return AnimatedBuilder(
      animation: _glowCurve,
      builder: (context, _) {
        final borderColor = _resolveGlowBorderColor(
          _labelError,
          colors,
          fallback: colors.onSurface.withAlpha(25),
        );
        final borderWidth = _labelError ? 2.0 : 1.0;

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
          child: TextField(
            controller: _noteCtrl,
            decoration: InputDecoration(
              hintText: _getHintText(),
              hintStyle: TextStyle(color: colors.onSurface.withAlpha(80)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor, width: borderWidth),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor, width: borderWidth),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _labelError ? borderColor : typeColor,
                  width: 2.0,
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
        );
      },
    );
  }

  Widget _buildDatePicker(ColorScheme colors, DateFormat dateFmt) {
    return Expanded(
      child: InkWell(
        onTap: () => _pickDate(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.onSurface.withAlpha(30)),
            color: colors.onSurface.withAlpha(6),
          ),
          child: Row(
            children: [
              Icon(
                PiconsLight.calendar,
                size: 20,
                color: colors.onSurface.withAlpha(180),
              ),
              const SizedBox(width: 10),
              Text(
                dateFmt.format(_selectedDate),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colors.onSurface,
                ),
              ),
              const Spacer(),
              Icon(
                PiconsLight.caretDown,
                size: 14,
                color: colors.onSurface.withAlpha(100),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateAndRecurringRow(ColorScheme colors) {
    final dateFmt = DateFormat('MMM dd, yyyy');
    final mutedIconColor = colors.onSurface.withAlpha(120);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
      child: Row(
        children: [
          _buildDatePicker(colors, dateFmt),
          const SizedBox(width: 12),
          _RecurringCheckbox(
            isRecurring: _isRecurring,
            type: _type,
            colors: colors,
            mutedIconColor: mutedIconColor,
            onChanged: (v) => setState(() => _isRecurring = v),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final typePrimary = _type == RecordType.expense
        ? AppColors.expense
        : AppColors.secondary;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
              Theme.of(context).colorScheme.brightness == Brightness.dark
              ? ColorScheme.dark(
                  primary: typePrimary,
                  onPrimary: Theme.of(ctx).colorScheme.onSurface,
                  surface: AppColors.surfaceDark,
                  onSurface: Theme.of(ctx).colorScheme.onSurface,
                  onSurfaceVariant: Theme.of(
                    ctx,
                  ).colorScheme.onSurface.withAlpha(180),
                )
              : null,
        ),
        child: child ?? const SizedBox.shrink(),
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Widget _buildAllCategoriesButton(List<Category> allCats, ColorScheme colors) {
    return _AllCategoriesButton(
      allCats: allCats,
      colors: colors,
      onTap: () => _showAllCategories(context, allCats, _type),
    );
  }

  List<Category> _buildDisplayCategories(List<Category> allCats) {
    final displayCats = allCats.take(4).toList();
    if (_selectedCategoryId != null &&
        !displayCats.any((c) => c.id == _selectedCategoryId)) {
      Category? selected;
      for (final c in allCats) {
        if (c.id == _selectedCategoryId) {
          selected = c;
          break;
        }
      }
      if (selected != null) {
        displayCats.removeLast();
        displayCats.insert(0, selected);
      }
    }

    return displayCats;
  }

  void _onCategoryChipTap(Category cat) {
    setState(() {
      _selectedCategoryId = cat.id;
      _categoryError = false;
    });
  }

  Widget _buildCategoryChip(Category cat, ColorScheme colors) {
    return CategoryPickerItem(
      category: cat,
      isSelected: cat.id == _selectedCategoryId,
      errorBorderColor: _resolveGlowBorderColor(
        _categoryError,
        colors,
        fallback: Colors.transparent,
      ),
      selectedColor: _type == RecordType.expense
          ? colors.error
          : colors.primary,
      onTap: () => _onCategoryChipTap(cat),
    );
  }

  Widget _buildCategoryLoadingSpinner(ColorScheme colors) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: Alignment.center,
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: colors.onSurface.withAlpha(80),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(ColorScheme colors) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (ctx, state) {
        if (state is CategoryLoaded) {
          if (state.type != null && state.type != _type) {
            return _buildCategoryLoadingSpinner(colors);
          }
          _categories = state.categories;
          _selectDefaultCategory(state.categories);
        }

        final allCats = _categories;
        if (state is CategoryLoading || allCats.isEmpty) {
          if (state is CategoryLoading) {
            return _buildCategoryLoadingSpinner(colors);
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'No categories available',
              style: TextStyle(color: colors.onSurface.withAlpha(80)),
            ),
          );
        }

        final displayCats = _buildDisplayCategories(allCats);

        return AnimatedBuilder(
          animation: _glowCurve,
          builder: (context, _) => Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                ...displayCats.map((cat) => _buildCategoryChip(cat, colors)),
                _buildAllCategoriesButton(allCats, colors),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton(ColorScheme colors) {
    return _SubmitButton(
      isSubmitting: _isSubmitting,
      type: _type,
      colors: colors,
      onSubmit: _submit,
    );
  }

  @override
  void dispose() {
    _noteCtrl.removeListener(_onNoteChanged);
    _glowController.dispose();
    _amountText.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      onHorizontalDragEnd: _onHorizontalSwipe,
      behavior: HitTestBehavior.translucent,
      child: Padding(
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
                _buildDragHandle(colors),
                _buildTypeToggle(),
                _buildAmountDisplay(colors),
                NumericKeypad(
                  onDigit: _appendDigit,
                  onBackspace: _backspace,
                  color: colors,
                ),
                _buildNoteField(colors),
                _buildCategoryChips(colors),
                _buildDateAndRecurringRow(colors),
                _buildSubmitButton(colors),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  final ColorScheme colors;

  const _DragHandle({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: colors.onSurface.withAlpha(50),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isSubmitting;
  final RecordType type;
  final ColorScheme colors;
  final Future<void> Function() onSubmit;

  const _SubmitButton({
    required this.isSubmitting,
    required this.type,
    required this.colors,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton(
          onPressed: isSubmitting ? null : () => unawaited(onSubmit()),
          style: FilledButton.styleFrom(
            backgroundColor: type == RecordType.expense
                ? colors.error
                : colors.primary,
            foregroundColor: colors.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            'Add ${type.displayName}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _AllCategoriesButton extends StatelessWidget {
  final List<Category> allCats;
  final ColorScheme colors;
  final VoidCallback onTap;

  const _AllCategoriesButton({
    required this.allCats,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
          PiconsBold.gridFour,
          size: 20,
          color: colors.onSurface.withAlpha(150),
        ),
      ),
    );
  }
}

class _RecurringCheckbox extends StatelessWidget {
  final bool isRecurring;
  final RecordType type;
  final ColorScheme colors;
  final Color mutedIconColor;
  final ValueChanged<bool> onChanged;

  const _RecurringCheckbox({
    required this.isRecurring,
    required this.type,
    required this.colors,
    required this.mutedIconColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: isRecurring,
            onChanged: (v) => onChanged(v ?? false),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            activeColor: type == RecordType.expense
                ? colors.error
                : colors.primary,
            side: BorderSide(color: mutedIconColor, width: 1.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Recurring?',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: colors.onSurface.withAlpha(200),
          ),
        ),
        const SizedBox(width: 4),
        Tooltip(
          message: 'Check this if your expense or income repeats every month',
          preferBelow: false,
          triggerMode: TooltipTriggerMode.tap,
          child: Icon(PiconsLight.info, size: 14, color: mutedIconColor),
        ),
      ],
    );
  }
}
