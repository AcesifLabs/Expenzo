import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/domain/usecases/get_categories.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_icons.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_state.dart';
import '../../../categories/presentation/bloc/category_event.dart';
import '../../domain/entities/record.dart';
import '../../domain/usecases/add_record.dart';
import 'package:expense_tracker/features/budgets/domain/entities/budget.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:expense_tracker/features/recurring/domain/repositories/recurring_repository.dart';
import 'package:expense_tracker/features/receipt_scan/domain/entities/receipt_extraction.dart';
import 'package:expense_tracker/features/receipt_scan/presentation/helpers/category_name_matcher.dart';
import 'package:expense_tracker/features/receipt_scan/presentation/pages/receipt_scan_camera_page.dart';
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

  RecordType _type = RecordType.expense;
  final _amountText = ValueNotifier<String>('');
  final _noteCtrl = TextEditingController();
  String? _selectedCategoryId;
  String? _selectedBudgetId;
  List<Budget> _budgets = const [];
  var _budgetsLoading = true;
  var _labelError = false;
  var _categoryError = false;
  var _isSubmitting = false;
  var _selectedDate = DateTime.now();
  var _isRecurring = false;

  double get _parsedAmount => double.tryParse(_amountText.value) ?? 0;

  Color get _typeAccentColor => _type == RecordType.expense
      ? Theme.of(context).colorScheme.error
      : Theme.of(context).colorScheme.primary;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadBudgets();
    initTypewriter(_expensePlaceholders);
    _noteCtrl.addListener(_onNoteChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) startTypewriter();
    });
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

  Future<void> _loadBudgets() async {
    final result = await di.getIt<GetBudgets>()();
    if (!mounted) return;
    setState(() {
      _budgets = result
          .getOrElse(() => const <Budget>[])
          .where((b) => b.isEnabled)
          .toList();
      _budgetsLoading = false;
    });
  }

  Future<void> _showAllCategories(BuildContext context, RecordType type) async {
    final result = await context.push<Category>(
      '/categories/picker',
      extra: {'type': type, 'selectedId': _selectedCategoryId},
    );

    if (result != null && mounted) {
      setState(() {
        _selectedCategoryId = result.id;
        _categoryError = false;
      });
    }

    // Reload categories to restore bloc state after picker changed it
    if (mounted) {
      _loadCategories();
    }
  }

  Future<void> _showAllBudgets(BuildContext context) async {
    final picked = await context.push<String?>(
      '/budgets/picker',
      extra: {'selectedId': _selectedBudgetId},
    );
    if (!mounted || picked == null) return;

    setState(() {
      _selectedBudgetId = picked.isEmpty ? null : picked;
    });
    await _loadBudgets();
  }

  void _switchType(RecordType t) {
    stopTypewriter();
    setState(() {
      _type = t;
      _selectedCategoryId = null;
      _selectedBudgetId = null;
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

  bool _validateInput(double amount, String description) {
    var hasError = false;
    if (amount <= 0) {
      hasError = true;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(content: Text('Enter an amount')));
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
      budgetId: _type == RecordType.expense ? _selectedBudgetId : null,
      source: ExpenseSource.manual,
      recordType: _type,
      createdAt: now,
      updatedAt: now,
    );

    // Await insert so Home can refresh against committed data after pop(true).
    final result = await di.getIt<AddRecord>()(record);
    if (!mounted) return;

    final failed = result.fold((failure) {
      appLogger.error(
        'NewTransactionSheet: Failed to save record: ${failure.message}',
      );
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(failure.message)));

      return true;
    }, (_) => false);
    if (failed) return;

    if (_isRecurring) {
      final created = await _createRecurringTransaction(finalAmount);
      if (!created) {
        if (mounted) setState(() => _isSubmitting = false);

        return;
      }
    }

    if (mounted) Navigator.pop(context, true);
  }

  Future<bool> _createRecurringTransaction(double finalAmount) async {
    try {
      final repo = widget.recurringRepository;
      if (repo == null) {
        if (mounted) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
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
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
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

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.round().toString();
    }

    return amount
        .toStringAsFixed(2)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  Future<List<Category>> _loadExpenseCategoriesForScan() async {
    final result = await di.getIt<GetCategories>()(
      const GetCategoriesParams(type: RecordType.expense, sortByUsage: true),
    );

    return result.fold(
      (_) => const <Category>[],
      (categories) =>
          categories.where((c) => c.type == RecordType.expense).toList(),
    );
  }

  Future<void> _openReceiptScan() async {
    final expenseCategories = await _loadExpenseCategoriesForScan();
    if (!mounted) return;

    final extraction = await Navigator.of(context, rootNavigator: true)
        .push<ReceiptExtraction>(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => ReceiptScanCameraPage(
              expenseCategoryNames: expenseCategories
                  .map((c) => c.name)
                  .toList(),
            ),
          ),
        );
    if (extraction == null || !mounted) return;

    final matched = matchCategoryByName(
      extraction.categoryName,
      expenseCategories,
    );

    final extractedDate = extraction.date;
    final matchedCategoryId = matched?.id;

    pauseTypewriter();
    setState(() {
      _type = RecordType.expense;
      _labelError = false;
      _categoryError = false;
      _amountText.value = _formatAmount(extraction.amount);
      _noteCtrl.text = extraction.description;
      if (extractedDate != null) {
        _selectedDate = extractedDate;
      }
      if (matchedCategoryId != null) {
        _selectedCategoryId = matchedCategoryId;
      }
    });
    _loadCategories();
  }

  Widget _buildDragHandle(ColorScheme colors) {
    return _DragHandle(colors: colors);
  }

  Widget _buildTypeToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: TypeToggle(type: _type, onSwitch: _switchType),
    );
  }

  Widget _buildAmountDisplay(ColorScheme _) {
    return ValueListenableBuilder<String>(
      valueListenable: _amountText,
      builder: (_, val, _) {
        final displayVal = val.isEmpty ? '0' : val;
        final sign = _type == RecordType.expense ? '-' : '+';

        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
          child: Text(
            '$sign$displayVal',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: _typeAccentColor,
              letterSpacing: -1,
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoteField(ColorScheme colors) {
    final typeColor = _typeAccentColor;

    final borderColor = _labelError
        ? colors.error
        : colors.onSurface.withAlpha(12);
    final borderWidth = _labelError ? 1.5 : 1.0;

    final titleLabel = '${_type.displayName} title';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPickerFieldLabel(colors, titleLabel, error: _labelError),
                TextField(
                  controller: _noteCtrl,
                  cursorColor: _labelError ? colors.error : typeColor,
                  decoration: InputDecoration(
                    hintText: _getHintText(),
                    errorText: _labelError ? 'Description is required' : null,
                    hintStyle: TextStyle(color: colors.onSurface.withAlpha(80)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: borderColor,
                        width: borderWidth,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: borderColor,
                        width: borderWidth,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _labelError ? colors.error : typeColor,
                        width: 2.0,
                      ),
                    ),
                    filled: true,
                    fillColor: colors.surfaceContainerLow,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  style: TextStyle(fontSize: 15, color: colors.onSurface),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildPickerFieldLabel(colors, 'Scan'),
              Semantics(
                button: true,
                label: 'Scan receipt',
                child: Tooltip(
                  message: 'Scan receipt',
                  child: Material(
                    color: colors.secondary.withAlpha(32),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: _isSubmitting
                          ? null
                          : () {
                              unawaited(_openReceiptScan());
                            },
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(
                          PiconsRegular.receipt,
                          size: 22,
                          color: colors.secondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
            border: Border.all(color: colors.onSurface.withAlpha(12)),
            color: colors.surfaceContainerLow,
          ),
          child: Row(
            children: [
              Icon(
                PiconsLight.calendar,
                size: 20,
                color: colors.onSurface.withAlpha(120),
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
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
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
    final typePrimary = _typeAccentColor;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (ctx, child) {
        final ctxColorScheme = Theme.of(ctx).colorScheme;
        final ctxOnSurface = ctxColorScheme.onSurface;
        final isDark =
            Theme.of(context).colorScheme.brightness == Brightness.dark;

        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: typePrimary,
                    onPrimary: ctxOnSurface,
                    surface: AppColors.surfaceDark,
                    onSurface: ctxOnSurface,
                    onSurfaceVariant: ctxOnSurface.withAlpha(180),
                  )
                : null,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Widget _buildCategorySelector(ColorScheme colors) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (ctx, state) => _buildCategorySelectorContent(state, colors),
    );
  }

  Widget _buildBudgetSelector(ColorScheme colors) {
    if (_budgetsLoading) {
      return _buildBudgetSelectorLoading(colors);
    }

    final selectedBudget = _selectedBudgetId == null
        ? null
        : _budgets.cast<Budget?>().firstWhere(
            (b) => b?.id == _selectedBudgetId,
            orElse: () => null,
          );

    return _buildLabeledPickerSection(
      colors: colors,
      label: 'Budget',
      child: _PickerFieldButton(
        colors: colors,
        semanticsLabel: 'Select a budget',
        decoration: _buildPickerFieldDecoration(colors),
        onTap: () => unawaited(_showAllBudgets(context)),
        content: selectedBudget != null
            ? _buildBudgetSelectedRow(selectedBudget, colors)
            : _buildBudgetHint(colors),
      ),
    );
  }

  Widget _buildBudgetHint(ColorScheme colors) {
    final hintColor = colors.onSurface.withAlpha(120);

    return Row(
      children: [
        Icon(PiconsRegular.wallet, size: 20, color: hintColor),
        const SizedBox(width: 12),
        Text('Select a budget', style: TextStyle(color: hintColor)),
      ],
    );
  }

  Widget _buildBudgetSelectedRow(Budget budget, ColorScheme colors) {
    return Row(
      children: [
        Icon(
          PiconsRegular.wallet,
          size: 20,
          color: colors.onSurface.withAlpha(180),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            budget.name,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.onSurface),
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetSelectorLoading(ColorScheme colors) {
    return _buildLabeledPickerSection(
      colors: colors,
      label: 'Budget',
      child: SizedBox(
        height: 48,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.onSurface.withAlpha(80),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledPickerSection({
    required ColorScheme colors,
    required String label,
    required Widget child,
    bool labelError = false,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPickerFieldLabel(colors, label, error: labelError),
          child,
        ],
      ),
    );
  }

  Widget _buildPickerFieldLabel(
    ColorScheme colors,
    String label, {
    bool error = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: error ? colors.error : colors.onSurface.withAlpha(180),
        ),
      ),
    );
  }

  Widget _buildCategorySelectorContent(
    CategoryState state,
    ColorScheme colors,
  ) {
    final categories = state is CategoryLoaded
        ? state.categories
        : <Category>[];

    if (state is CategoryLoaded && state.type != null && state.type != _type) {
      return _buildCategorySelectorLoading(colors);
    }

    if (state is CategoryLoading) {
      return _buildCategorySelectorLoading(colors);
    }

    Category? selectedCategory;
    if (_selectedCategoryId != null) {
      selectedCategory = categories.cast<Category?>().firstWhere(
        (c) => c?.id == _selectedCategoryId,
        orElse: () => null,
      );
    }

    return _buildLabeledPickerSection(
      colors: colors,
      label: 'Category',
      labelError: _categoryError,
      child: _PickerFieldButton(
        colors: colors,
        semanticsLabel: 'Select a category',
        decoration: _buildPickerFieldDecoration(
          colors,
          hasError: _categoryError,
          errorText: _categoryError ? 'Select a category' : null,
        ),
        onTap: () => unawaited(_showAllCategories(context, _type)),
        content: selectedCategory != null
            ? _buildCategorySelectedRow(selectedCategory)
            : _buildCategoryHint(colors),
      ),
    );
  }

  InputDecoration _buildPickerFieldDecoration(
    ColorScheme colors, {
    bool hasError = false,
    String? errorText,
  }) {
    final idleBorderColor = hasError
        ? colors.error
        : colors.onSurface.withAlpha(12);
    final idleBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: idleBorderColor),
    );

    return InputDecoration(
      filled: true,
      fillColor: colors.surfaceContainerLow,
      border: idleBorder,
      enabledBorder: idleBorder,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: hasError ? colors.error : colors.primary,
          width: 2,
        ),
      ),
      errorText: errorText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildCategoryHint(ColorScheme colors) {
    final hintColor = colors.onSurface.withAlpha(120);

    return Row(
      children: [
        Icon(PiconsRegular.tag, size: 20, color: hintColor),
        const SizedBox(width: 12),
        Text('Select a category', style: TextStyle(color: hintColor)),
      ],
    );
  }

  Widget _buildCategorySelectedRow(Category category) {
    final color = _parseCategoryColor(category.color);

    return Row(
      children: [
        Icon(AppIcons.getCategoryIcon(category.emoji), size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(child: Text(category.name, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Color _parseCategoryColor(String colorHex) {
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

  Widget _buildCategorySelectorLoading(ColorScheme colors) {
    return _buildLabeledPickerSection(
      colors: colors,
      label: 'Category',
      labelError: _categoryError,
      child: SizedBox(
        height: 48,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.onSurface.withAlpha(80),
            ),
          ),
        ),
      ),
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
                _buildCategorySelector(colors),
                if (_type == RecordType.expense) _buildBudgetSelector(colors),
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
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
      child: Align(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PickerFieldButton extends StatelessWidget {
  final ColorScheme colors;
  final String semanticsLabel;
  final InputDecoration decoration;
  final VoidCallback onTap;
  final Widget content;

  const _PickerFieldButton({
    required this.colors,
    required this.semanticsLabel,
    required this.decoration,
    required this.onTap,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final trailingColor = colors.onSurface.withAlpha(120);

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: decoration,
            isEmpty: false,
            child: Row(
              children: [
                Expanded(child: content),
                Icon(PiconsRegular.caretRight, size: 20, color: trailingColor),
              ],
            ),
          ),
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
    final activeColor = type == RecordType.expense
        ? colors.error
        : colors.primary;

    return Material(
      color: Colors.transparent,
      child: MergeSemantics(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onChanged(!isRecurring),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Theme(
                  data: Theme.of(context).copyWith(
                    checkboxTheme: CheckboxThemeData(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: BorderSide(color: mutedIconColor, width: 1.5),
                      fillColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return activeColor;
                        }

                        return Colors.transparent;
                      }),
                      checkColor: WidgetStatePropertyAll(colors.onPrimary),
                    ),
                  ),
                  child: Checkbox(
                    value: isRecurring,
                    onChanged: (value) => onChanged(value ?? false),
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  'Recurring?',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: mutedIconColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
