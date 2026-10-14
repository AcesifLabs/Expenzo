import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/domain/usecases/get_categories.dart';
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
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/shared/presentation/widgets/category_tile.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/records/domain/usecases/update_record.dart';
import 'package:expense_tracker/features/records/domain/usecases/delete_record.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_bloc.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_event.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_state.dart';
import 'new_transaction/numeric_keypad.dart';
import 'new_transaction/type_toggle.dart';
import 'new_transaction/typewriter_animation_mixin.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/check_budget_alerts.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/features/categories/presentation/helpers/category_display_name.dart';
import 'package:expense_tracker/features/budgets/presentation/helpers/budget_display_name.dart';

/// Opens the transaction sheet to add a record, or to edit [record].
///
/// Returns true when something was saved or deleted.
Future<bool> showTransactionSheet(
  BuildContext context, {
  Record? record,
  String? budgetId,
  bool startWithReceiptScan = false,
}) async {
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: context.read<RecordBloc>()),
        BlocProvider.value(value: context.read<CategoryBloc>()),
      ],
      child: NewTransactionSheet(
        initialRecord: record,
        initialBudgetId: budgetId,
        startWithReceiptScan: startWithReceiptScan,
        recurringRepository: di.getIt<RecurringRepository>(),
      ),
    ),
  );
  // The sheet filters categories by type; restore the full list.
  if (context.mounted) {
    context.read<CategoryBloc>().add(const LoadCategories());
  }

  return saved == true;
}

/// The one Record editor (docs/adr/0004): adds a record, or edits
/// [initialRecord] when given. Pops `true` after a save or delete.
class NewTransactionSheet extends StatefulWidget {
  final RecurringRepository? recurringRepository;

  /// The record to edit; null to add a new one.
  final Record? initialRecord;

  /// Preselects a budget when adding from a budget's page.
  final String? initialBudgetId;

  /// Opens the receipt camera as soon as the sheet appears (Home banner).
  /// Ignored when editing.
  final bool startWithReceiptScan;

  const NewTransactionSheet({
    super.key,
    this.recurringRepository,
    this.initialRecord,
    this.initialBudgetId,
    this.startWithReceiptScan = false,
  });

  @override
  State<NewTransactionSheet> createState() => _NewTransactionSheetState();
}

class _NewTransactionSheetState extends State<NewTransactionSheet>
    with TickerProviderStateMixin, TypewriterAnimationMixin {
  static List<String> get _expensePlaceholders =>
      t.records.sheet.placeholders.expense;

  static List<String> get _incomePlaceholders =>
      t.records.sheet.placeholders.income;

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
  Animation<double>? _routeAnimation;
  AnimationStatusListener? _routeSettledListener;

  double get _parsedAmount => double.tryParse(_amountText.value) ?? 0;

  bool get _isEditing => widget.initialRecord != null;

  Color get _typeAccentColor => _type == RecordType.expense
      ? context.palette.expense
      : context.palette.income;

  @override
  void initState() {
    super.initState();
    _prefillFrom(widget.initialRecord);
    _selectedBudgetId ??= widget.initialBudgetId;
    _loadCategories();
    _loadBudgets();
    initTypewriter(
      _type == RecordType.expense ? _expensePlaceholders : _incomePlaceholders,
    );
    _noteCtrl.addListener(_onNoteChanged);
    // A prefilled name needs no example names cycling behind it.
    if (_isEditing) {
      pauseTypewriter();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        startTypewriter();
        if (widget.startWithReceiptScan) _openReceiptScanWhenSettled();
      });
    }
  }

  void _prefillFrom(Record? record) {
    if (record == null) return;
    _type = record.recordType;
    _amountText.value = CurrencyFormatter.formatInput(record.amount.abs());
    _noteCtrl.text = record.description;
    _selectedCategoryId = record.categoryId;
    _selectedBudgetId = record.budgetId;
    _selectedDate = record.date;
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
          .getOrElse(() => <Budget>[])
          .where((b) => b.isEnabled)
          .toList();
      _budgetsLoading = false;
    });
  }

  void _showAllCategories(BuildContext context, RecordType type) async {
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

    if (mounted) {
      _loadCategories();
    }
  }

  Future<void> _showAllBudgets() async {
    final picked = await context.push<String>(
      '/budgets/picker',
      extra: {'selectedId': _selectedBudgetId},
    );
    if (!mounted) return;

    // An empty id means "No budget"; null means closed without choosing.
    if (picked != null) {
      setState(() => _selectedBudgetId = picked.isEmpty ? null : picked);
    }
    await _loadBudgets();
  }

  void _switchType(RecordType type) {
    stopTypewriter();
    setState(() {
      _type = type;
      _selectedCategoryId = null;
      _selectedBudgetId = null;
      _labelError = false;
      _categoryError = false;
    });
    _loadCategories();
    initTypewriter(
      type == RecordType.expense ? _expensePlaceholders : _incomePlaceholders,
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
    // Decimal places is display-only (SAAP-65); stored amounts keep cents.
    final digits = CurrencyFormatter.current.value.decimalDigits;
    if (d == '.' && (digits == 0 || current.contains('.'))) return;

    if (current == '0' && d != '.') {
      _amountText.value = d;

      return;
    }

    final dotIndex = current.indexOf('.');
    if (dotIndex != -1 && current.substring(dotIndex + 1).length >= digits) {
      return;
    }

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
        ..showSnackBar(SnackBar(content: Text(t.records.sheet.enterAmount)));
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
    final budgetId = _type == RecordType.expense ? _selectedBudgetId : null;
    final original = widget.initialRecord;

    // Editing keeps what this sheet doesn't show (id, source, createdAt).
    // copyWith clears a field passed as null, so "no budget" (or switching
    // to income) saves budgetId as null.
    final record = original != null
        ? original.copyWith(
            amount: finalAmount,
            description: description,
            date: _selectedDate,
            categoryId: _selectedCategoryId,
            budgetId: budgetId,
            recordType: _type,
            updatedAt: now,
          )
        : Record(
            amount: finalAmount,
            description: description,
            date: _selectedDate,
            categoryId: _selectedCategoryId,
            budgetId: budgetId,
            source: ExpenseSource.manual,
            recordType: _type,
            createdAt: now,
            updatedAt: now,
          );

    // Await the write so lists refresh against committed data after pop.
    final result = original != null
        ? await di.getIt<UpdateRecord>()(record)
        : await di.getIt<AddRecord>()(record);
    if (!mounted) return;

    final failed = result.fold((failure) {
      appLogger.error(
        'NewTransactionSheet: Failed to save record: ${failure.message}',
      );
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(failureText(failure))));

      return true;
    }, (_) => false);
    if (failed) return;

    // The record is already saved, so close even if the repeat fails: staying
    // open would invite a second tap and a duplicate record.
    if (_isRecurring && !_isEditing) {
      await _createRecurringTransaction(finalAmount);
    }

    _closeAfterChange();
  }

  void _closeAfterChange() {
    if (!mounted) return;
    // A loaded list already follows the records stream; reloading would
    // throw away the Activity search, filters and scroll position.
    final records = context.read<RecordBloc>();
    if (records.state is! RecordLoaded) records.add(const LoadRecords());
    if (di.getIt.isRegistered<CheckBudgetAlerts>()) {
      unawaited(di.getIt<CheckBudgetAlerts>()());
    }
    Navigator.pop(context, true);
  }

  Future<void> _confirmDelete() async {
    final record = widget.initialRecord;
    final id = record?.id;
    if (record == null || id == null) return;
    final sheetT = t.records.sheet;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          record.recordType == RecordType.expense
              ? sheetT.deleteExpenseTitle
              : sheetT.deleteIncomeTitle,
        ),
        content: Text(sheetT.cannotUndo),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(t.common.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(t.common.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSubmitting = true);
    final result = await di.getIt<DeleteRecord>()(id);
    if (!mounted) return;
    result.fold((failure) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(failureText(failure))));
    }, (_) => _closeAfterChange());
  }

  Future<bool> _createRecurringTransaction(double finalAmount) async {
    try {
      final repo = widget.recurringRepository;
      if (repo == null) {
        if (mounted) {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(content: Text(t.records.sheet.repeatFailed)),
            );
        }

        return false;
      }

      final result = await repo.createRecurring(
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

      // A failure comes back as a value, not an exception.
      return result.fold((failure) {
        throw StateError(failure.message);
      }, (_) => true);
    } catch (e, s) {
      debugPrint('Error: $e\n$s');
      debugPrint(
        'NewTransactionSheet: Failed to create recurring transaction: $e',
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(t.records.sheet.repeatFailed),
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

    final sheetT = t.records.sheet;

    return _type == RecordType.expense
        ? sheetT.nameHintExpense
        : sheetT.nameHintIncome;
  }

  Future<List<Category>> _loadExpenseCategoriesForScan() async {
    final result = await di.getIt<GetCategories>()(
      const GetCategoriesParams(type: RecordType.expense, sortByUsage: true),
    );

    return result.fold(
      (_) => <Category>[],
      (categories) =>
          categories.where((c) => c.type == RecordType.expense).toList(),
    );
  }

  /// Opens the camera once the sheet has finished sliding in, so the two
  /// route transitions do not overlap.
  void _openReceiptScanWhenSettled() {
    final animation = ModalRoute.of(context)?.animation;
    if (animation == null || animation.isCompleted) {
      unawaited(_openReceiptScan());

      return;
    }

    void listener(AnimationStatus status) {
      if (status != AnimationStatus.completed) return;
      _removeRouteSettledListener();
      if (mounted) unawaited(_openReceiptScan());
    }

    _routeAnimation = animation;
    _routeSettledListener = listener;
    animation.addStatusListener(listener);
  }

  void _removeRouteSettledListener() {
    final listener = _routeSettledListener;
    if (listener != null) _routeAnimation?.removeStatusListener(listener);
    _routeAnimation = null;
    _routeSettledListener = null;
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
      _amountText.value = CurrencyFormatter.formatInput(extraction.amount);
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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.smd,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: TypeToggle(type: _type, onSwitch: _switchType),
    );
  }

  Widget _buildAmountDisplay(ColorScheme _) {
    return ValueListenableBuilder<String>(
      valueListenable: _amountText,
      builder: (_, val, _) {
        // No sign on the empty "0": "-0" reads as a value.
        final isEmpty = val.isEmpty;
        final sign = _type == RecordType.expense ? '-' : '+';
        final symbol = CurrencyFormatter.current.value.symbol;
        // The stored text keeps '.'; only the shown mark follows the setting.
        final shown = val.replaceAll('.', CurrencyFormatter.decimalSeparator);

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            0,
            AppSpacing.sm,
            0,
            AppSpacing.xs,
          ),
          child: Text(
            isEmpty ? '${symbol}0' : '$sign$symbol$shown',
            style: AppTypography.headlineLarge.copyWith(
              color: isEmpty
                  ? Theme.of(context).colorScheme.onSurface.withAlpha(90)
                  : _typeAccentColor,
              letterSpacing: -1,
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoteField(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.smd,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildNoteInput(colors),
              const SizedBox(width: AppSpacing.sm),
              _buildScanReceiptButton(colors),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoteInput(ColorScheme colors) {
    final typeColor = _typeAccentColor;

    final borderColor = _labelError
        ? colors.error
        : colors.onSurface.withAlpha(12);
    final borderWidth = _labelError ? 1.5 : 1.0;

    return Expanded(
      child: TextField(
        controller: _noteCtrl,
        cursorColor: _labelError ? colors.error : typeColor,
        decoration: InputDecoration(
          hintText: _getHintText(),
          errorText: _labelError ? t.records.sheet.nameRequired : null,
          hintStyle: TextStyle(color: colors.onSurface.withAlpha(80)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
            borderSide: BorderSide(color: borderColor, width: borderWidth),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
            borderSide: BorderSide(color: borderColor, width: borderWidth),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
            borderSide: BorderSide(
              color: _labelError ? colors.error : typeColor,
              width: 2.0,
            ),
          ),
          filled: true,
          fillColor: colors.surfaceContainerLow,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
        ),
        style: AppTypography.bodyLarge.copyWith(color: colors.onSurface),
      ),
    );
  }

  Widget _buildScanReceiptButton(ColorScheme colors) {
    return Tooltip(
      message: t.records.sheet.scanReceipt,
      child: Material(
        color: colors.primary.withAlpha(32),
        borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
        child: InkWell(
          onTap: _isSubmitting
              ? null
              : () {
                  unawaited(_openReceiptScan());
                },
          borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(PiconsRegular.receipt, size: 22, color: colors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(ColorScheme colors, DateFormat dateFmt) {
    return Expanded(
      child: InkWell(
        onTap: () => _pickDate(context),
        borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppSpacing.minTapTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.smd,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
            border: Border.all(color: colors.onSurface.withAlpha(12)),
            color: colors.surfaceContainerLow,
          ),
          child: Row(
            children: [
              Icon(
                PiconsRegular.calendar,
                size: 20,
                color: colors.onSurface.withAlpha(120),
              ),
              const SizedBox(width: AppSpacing.smd),
              Flexible(
                child: Text(
                  dateFmt.format(_selectedDate),
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.onSurface,
                  ),
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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.smd,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          _buildDatePicker(colors, dateFmt),
          // Repeating is set up when adding; editing changes one record.
          if (!_isEditing) ...[
            const SizedBox(width: AppSpacing.smd),
            Flexible(
              child: _RecurringCheckbox(
                isRecurring: _isRecurring,
                type: _type,
                colors: colors,
                mutedIconColor: mutedIconColor,
                onChanged: (v) => setState(() => _isRecurring = v),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: AppConstants.pickerFirstDate,
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Widget _buildAllCategoriesButton(ColorScheme colors) {
    return _ShowAllButton(
      colors: colors,
      label: t.records.sheet.showAllCategories,
      onTap: () => _showAllCategories(context, _type),
    );
  }

  Widget _buildAllBudgetsButton(ColorScheme colors) {
    return _ShowAllButton(
      colors: colors,
      label: t.records.sheet.showAllBudgets,
      onTap: _budgetsLoading ? null : () => unawaited(_showAllBudgets()),
    );
  }

  Widget _buildCategorySelector(ColorScheme colors) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (ctx, state) => _buildCategorySelectorContent(state, colors),
    );
  }

  Widget _buildBudgetSelector(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.smd,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildBudgetDropdown(colors)),
          const SizedBox(width: AppSpacing.sm),
          _buildAllBudgetsButton(colors),
        ],
      ),
    );
  }

  Widget _buildBudgetDropdown(ColorScheme colors) {
    final noneOrEmpty = _budgetsLoading || _budgets.isEmpty;
    final selectedId = _selectedBudgetId;
    final isListed = _budgets.any((b) => b.id == selectedId);
    // An edited record can point at a budget that is still loading, or that
    // has since been disabled. Keep the link (it is saved unchanged) but only
    // hand the dropdown a value it has an item for.
    final showInactiveLink =
        selectedId != null && !isListed && !_budgetsLoading;
    final sheetT = t.records.sheet;

    return InputDecorator(
      decoration: _buildBudgetFieldDecoration(colors),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: isListed || showInactiveLink ? selectedId : null,
          hint: _buildBudgetHint(colors),
          isExpanded: true,
          icon: Icon(
            PiconsRegular.caretDown,
            color: colors.onSurface.withAlpha(120),
          ),
          dropdownColor: colors.surfaceContainerLow,
          isDense: true,
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(sheetT.noBudget, overflow: TextOverflow.ellipsis),
            ),
            for (final budget in _budgets)
              DropdownMenuItem<String?>(
                value: budget.id,
                child: Text(
                  sheetT.budgetOption(
                    name: budgetDisplayName(budget.name),
                    period: budget.period.displayName,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (showInactiveLink)
              DropdownMenuItem<String?>(
                value: selectedId,
                child: Text(
                  sheetT.previousBudget,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: noneOrEmpty && !showInactiveLink
              ? null
              : _onBudgetSelected,
        ),
      ),
    );
  }

  InputDecoration _buildBudgetFieldDecoration(ColorScheme colors) {
    final idleBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
      borderSide: BorderSide(color: colors.onSurface.withAlpha(12)),
    );

    return InputDecoration(
      filled: true,
      fillColor: colors.surfaceContainerLow,
      border: idleBorder,
      enabledBorder: idleBorder,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.smd,
      ),
    );
  }

  void _onBudgetSelected(String? budgetId) {
    setState(() => _selectedBudgetId = budgetId);
  }

  Widget _buildBudgetHint(ColorScheme colors) {
    final hintColor = colors.onSurface.withAlpha(120);
    final sheetT = t.records.sheet;
    final text = _budgetsLoading ? sheetT.loadingBudgets : sheetT.noBudget;

    return Text(text, style: TextStyle(color: hintColor));
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

    if (state is CategoryLoading || categories.isEmpty) {
      if (state is CategoryLoading) {
        return _buildCategorySelectorLoading(colors);
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          0,
        ),
        child: Text(
          t.records.sheet.noCategories,
          style: TextStyle(color: colors.onSurface.withAlpha(80)),
        ),
      );
    }

    Category? selectedCategory;
    if (_selectedCategoryId != null) {
      selectedCategory = categories.cast<Category?>().firstWhere(
        (c) => c?.id == _selectedCategoryId,
        orElse: () => null,
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.smd,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: InputDecorator(
              decoration: _buildCategoryFieldDecoration(colors),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Category>(
                  value: selectedCategory,
                  hint: _buildCategoryHint(colors),
                  isExpanded: true,
                  icon: Icon(
                    PiconsRegular.caretDown,
                    color: colors.onSurface.withAlpha(120),
                  ),
                  dropdownColor: colors.surfaceContainerLow,
                  isDense: true,
                  items: categories.map(_buildCategoryDropdownItem).toList(),
                  onChanged: _onCategorySelected,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildAllCategoriesButton(colors),
        ],
      ),
    );
  }

  InputDecoration _buildCategoryFieldDecoration(ColorScheme colors) {
    final idleBorderColor = _categoryError
        ? colors.error
        : colors.onSurface.withAlpha(12);
    final idleBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
      borderSide: BorderSide(color: idleBorderColor),
    );

    return InputDecoration(
      filled: true,
      fillColor: colors.surfaceContainerLow,
      border: idleBorder,
      enabledBorder: idleBorder,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
        borderSide: BorderSide(
          color: _categoryError ? colors.error : colors.primary,
          width: 2,
        ),
      ),
      errorText: _categoryError ? t.records.sheet.selectCategory : null,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.smd,
      ),
    );
  }

  DropdownMenuItem<Category> _buildCategoryDropdownItem(Category cat) {
    return DropdownMenuItem<Category>(
      value: cat,
      child: _buildCategoryDropdownRow(cat),
    );
  }

  void _onCategorySelected(Category? cat) {
    if (cat != null) {
      setState(() {
        _selectedCategoryId = cat.id;
        _categoryError = false;
      });
    }
  }

  Widget _buildCategoryHint(ColorScheme colors) {
    final hintColor = colors.onSurface.withAlpha(120);

    return Row(
      children: [
        Icon(PiconsRegular.tag, size: 20, color: hintColor),
        const SizedBox(width: AppSpacing.smd),
        Flexible(
          child: Text(
            t.records.sheet.selectCategory,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: hintColor),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdownRow(Category category) {
    return Row(
      children: [
        CategoryTile(
          colorHex: category.color,
          iconKey: category.emoji,
          size: 28,
        ),
        const SizedBox(width: AppSpacing.smd),
        Expanded(
          child: Text(category.displayName, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildCategorySelectorLoading(ColorScheme colors) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
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

  String _submitLabel() {
    if (_isEditing) return t.common.save;

    return _type == RecordType.expense
        ? t.common.addExpense
        : t.records.sheet.addIncome;
  }

  Widget _buildSubmitButton(ColorScheme colors) {
    final sheetT = t.records.sheet;

    return Column(
      children: [
        _SubmitButton(
          isSubmitting: _isSubmitting,
          label: _submitLabel(),
          onSubmit: _submit,
        ),
        if (_isEditing)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: colors.error),
              onPressed: _isSubmitting
                  ? null
                  : () => unawaited(_confirmDelete()),
              icon: const Icon(PiconsRegular.trash, size: 18),
              label: Text(
                _type == RecordType.expense
                    ? sheetT.deleteExpense
                    : sheetT.deleteIncome,
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _removeRouteSettledListener();
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
      // Keyboard dismissal and the type swipe both have explicit controls.
      excludeFromSemantics: true,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusCard),
            ),
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
      padding: const EdgeInsets.only(
        top: AppSpacing.smd,
        bottom: AppSpacing.xs,
      ),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: colors.onSurface.withAlpha(50),
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isSubmitting;
  final String label;
  final Future<void> Function() onSubmit;

  const _SubmitButton({
    required this.isSubmitting,
    required this.label,
    required this.onSubmit,
  });

  // Styled by the app's ElevatedButton theme: the brand mint fill.
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, AppSpacing.sm, 0, AppSpacing.md),
      child: Align(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          // A minimum, not a fixed height: the label may wrap at large text
          // sizes.
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: double.infinity,
              minHeight: 52,
            ),
            child: ElevatedButton(
              onPressed: isSubmitting ? null : () => unawaited(onSubmit()),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShowAllButton extends StatelessWidget {
  final ColorScheme colors;
  final String label;
  final VoidCallback? onTap;

  const _ShowAllButton({
    required this.colors,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
                border: Border.all(color: colors.onSurface.withAlpha(12)),
              ),
              alignment: Alignment.center,
              child: Icon(
                PiconsRegular.dotsThreeVertical,
                size: 22,
                color: colors.onSurface.withAlpha(150),
              ),
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
          borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
          onTap: () => onChanged(!isRecurring),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Theme(
                  data: Theme.of(context).copyWith(
                    checkboxTheme: CheckboxThemeData(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusPill,
                        ),
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
                const SizedBox(width: AppSpacing.xs),
                // Wraps beside the date picker at large text sizes.
                Flexible(
                  child: Text(
                    t.records.sheet.repeatMonthly,
                    style: AppTypography.bodyMedium.copyWith(
                      color: mutedIconColor,
                    ),
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
