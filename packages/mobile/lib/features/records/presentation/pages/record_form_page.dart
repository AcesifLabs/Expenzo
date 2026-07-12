import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_icons.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/records/domain/repositories/record_repository.dart';
import '../../../../shared/presentation/widgets/shimmer_box.dart';
import '../../../categories/presentation/bloc/category_bloc.dart';
import '../../../categories/presentation/bloc/category_event.dart';
import '../../../categories/presentation/bloc/category_state.dart';
import '../../../categories/domain/entities/category.dart';
import "package:expense_tracker/core/constants/source_types.dart";
import '../bloc/record_bloc.dart';
import '../bloc/record_event.dart';

// -- Design tokens from expenzo.pen --
const _bg = Color(0xFF141315);
const _inputFill = Color(0xFF201F21);
const _inputStroke = Color(0x208E8E93); // #8E8E93 at 12% opacity
const _primary = Color(0xFFD1C4E9);
const _textPrimary = Color(0xFFF5F7FA);
const _textSecondary = Color(0xFF8E8E93);
const _onPrimary = Color(0xFF141315);
const _errorColor = Color(0xFFF48FB1);

const _inputRadius = BorderRadius.all(Radius.circular(12));
const _buttonRadius = BorderRadius.all(Radius.circular(14));
const _cellShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(8)),
);

class RecordFormPage extends StatefulWidget {
  final Record? record;
  final RecordType? initialType;
  final String? recordId;

  const RecordFormPage({
    super.key,
    this.record,
    this.initialType,
    this.recordId,
  });

  @override
  State<RecordFormPage> createState() => _RecordFormPageState();
}

class _RecordFormPageState extends State<RecordFormPage> {
  static final _dateFormat = DateFormat('MMM dd, yyyy');
  bool get _isEditing => widget.record != null || widget.recordId != null;
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  var _selectedDate = DateTime.now();
  String? _selectedCategoryId;
  var _recordType = RecordType.expense;
  var _isLoading = false;
  String? _amountError;
  String? _descriptionError;
  var _amountFocused = false;
  var _descriptionFocused = false;

  @override
  void initState() {
    super.initState();
    _amountFocus.addListener(_onAmountFocusChange);
    _descriptionFocus.addListener(_onDescriptionFocusChange);
    final recordId = widget.recordId;
    if (recordId != null) {
      _isLoading = true;
      _loadRecord(recordId);
    } else {
      _initFromRecord(widget.record);
    }
    context.read<CategoryBloc>().add(const LoadCategories());
  }

  void _onAmountFocusChange() {
    setState(() => _amountFocused = _amountFocus.hasFocus);
  }

  void _onDescriptionFocusChange() {
    setState(() => _descriptionFocused = _descriptionFocus.hasFocus);
  }

  Future<void> _loadRecord(String id) async {
    final repo = di.getIt<RecordRepository>();
    final result = await repo.getRecordById(id);
    if (!mounted) return;
    result.fold(
      (failure) => debugPrint(
        'RecordFormPage: Failed to load record: ${failure.message}',
      ),
      (record) {
        if (!mounted) return;
        setState(() {
          _initFromRecord(record);
          _isLoading = false;
        });
      },
    );
  }

  void _initFromRecord(Record? record) {
    _amountController.text = record != null
        ? record.amount.abs().toString()
        : '';
    _descriptionController.text = record?.description ?? '';
    _selectedDate = record?.date ?? DateTime.now();
    _selectedCategoryId = record?.categoryId;
    _recordType =
        record?.recordType ?? widget.initialType ?? RecordType.expense;
  }

  bool _validate() {
    var valid = true;
    String? newAmountError;
    String? newDescriptionError;

    final amount = _amountController.text;
    if (amount.isEmpty) {
      newAmountError = 'Please enter an amount';
      valid = false;
    } else if (double.tryParse(amount) == null) {
      newAmountError = 'Please enter a valid number';
      valid = false;
    }

    final desc = _descriptionController.text;
    if (desc.isEmpty) {
      newDescriptionError = 'Please enter a description';
      valid = false;
    }

    setState(() {
      _amountError = newAmountError;
      _descriptionError = newDescriptionError;
    });

    return valid;
  }

  void _onCategoryChanged(String? value) {
    setState(() => _selectedCategoryId = value);
  }

  void _onAmountChanged(String _) {
    if (_amountError != null) {
      setState(() => _amountError = null);
    }
  }

  void _onDescriptionChanged(String _) {
    if (_descriptionError != null) {
      setState(() => _descriptionError = null);
    }
  }

  void _handleSelectDate() {
    _selectDate();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: _buildDatePickerTheme,
    );
    if (!mounted) return;
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Widget _buildDatePickerTheme(BuildContext context, Widget? child) {
    final isSelected = WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.selected)) {
        return _onPrimary;
      }
      if (states.contains(WidgetState.disabled)) {
        return _textSecondary.withAlpha(80);
      }

      return _textPrimary;
    });

    final selectedBg = WidgetStateProperty.resolveWith<Color?>((states) {
      if (states.contains(WidgetState.selected)) {
        return _primary;
      }

      return Colors.transparent;
    });

    final cellShape = WidgetStateProperty.all<OutlinedBorder>(_cellShape);

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.dark(
          surface: _bg,
          onSurface: _textPrimary,
          primary: _primary,
          onPrimary: _onPrimary,
          secondary: _primary,
          onSecondary: _onPrimary,
          outline: _textSecondary,
          surfaceContainerHighest: _inputFill,
          surfaceContainerHigh: _inputFill,
          surfaceContainerLow: _inputFill,
        ),
        dialogTheme: const DialogThemeData(backgroundColor: _bg),
        datePickerTheme: _buildDatePickerData(
          isSelected,
          selectedBg,
          cellShape,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: _primary),
        ),
        inputDecorationTheme: _buildInputDecorationTheme(),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: _primary,
          selectionColor: _inputFill,
          selectionHandleColor: _primary,
        ),
      ),
      child: child ?? const SizedBox.shrink(),
    );
  }

  DatePickerThemeData _buildDatePickerData(
    WidgetStateProperty<Color?> isSelected,
    WidgetStateProperty<Color?> selectedBg,
    WidgetStateProperty<OutlinedBorder> cellShape,
  ) {
    return DatePickerThemeData(
      backgroundColor: _bg,
      surfaceTintColor: Colors.transparent,
      headerBackgroundColor: _inputFill,
      headerForegroundColor: _textPrimary,
      dayForegroundColor: isSelected,
      dayBackgroundColor: selectedBg,
      todayForegroundColor: isSelected,
      todayBackgroundColor: selectedBg,
      todayBorder: const BorderSide(color: _primary, width: 1),
      yearForegroundColor: isSelected,
      yearBackgroundColor: selectedBg,
      weekdayStyle: const TextStyle(
        fontFamily: 'Work Sans',
        color: _textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      dayStyle: const TextStyle(
        fontFamily: 'Work Sans',
        color: _textPrimary,
        fontSize: 14,
      ),
      yearStyle: const TextStyle(
        fontFamily: 'Work Sans',
        color: _textPrimary,
        fontSize: 14,
      ),
      headerHeadlineStyle: const TextStyle(
        fontFamily: 'Work Sans',
        color: _textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headerHelpStyle: const TextStyle(
        fontFamily: 'Work Sans',
        color: _textSecondary,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      dayShape: cellShape,
      yearShape: cellShape,
    );
  }

  InputDecorationTheme _buildInputDecorationTheme() {
    return const InputDecorationTheme(
      filled: true,
      fillColor: _inputFill,
      hintStyle: TextStyle(color: _textSecondary),
      labelStyle: TextStyle(color: _textSecondary),
      prefixStyle: TextStyle(color: _textPrimary),
      suffixStyle: TextStyle(color: _textPrimary),
      enabledBorder: OutlineInputBorder(
        borderRadius: _inputRadius,
        borderSide: BorderSide(color: _inputStroke, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: _inputRadius,
        borderSide: BorderSide(color: _primary, width: 1.5),
      ),
      border: OutlineInputBorder(
        borderRadius: _inputRadius,
        borderSide: BorderSide(color: _inputStroke, width: 1),
      ),
    );
  }

  void _saveRecord() {
    if (!_validate()) return;

    final now = DateTime.now().toUtc();
    final rawAmount = double.parse(_amountController.text).abs();
    final finalAmount = _recordType == RecordType.expense
        ? -rawAmount
        : rawAmount;

    final record = Record(
      id: widget.record?.id ?? widget.recordId,
      amount: finalAmount,
      description: _descriptionController.text,
      date: _selectedDate,
      categoryId: _selectedCategoryId,
      source: ExpenseSource.manual,
      recordType: _recordType,
      createdAt: widget.record?.createdAt ?? now,
      updatedAt: now,
    );

    if (_isEditing) {
      context.read<RecordBloc>().add(UpdateRecordEvent(record));
    } else {
      context.read<RecordBloc>().add(AddRecordEvent(record));
    }
    if (mounted) context.pop();
  }

  // -- Helpers --

  Color _amountBorderColor() {
    if (_amountError != null) return _errorColor;
    if (_amountFocused) return _primary;

    return _inputStroke;
  }

  Color _descriptionBorderColor() {
    if (_descriptionError != null) return _errorColor;
    if (_descriptionFocused) return _primary;

    return _inputStroke;
  }

  double _focusedWidth(bool focused) => focused ? 1.5 : 1;

  // -- TopBar --
  Widget _buildTopBar(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(
              PiconsRegular.caretLeft,
              size: 24,
              color: _textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // -- Field label --
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Work Sans',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: _textSecondary,
      ),
    );
  }

  // -- Error text --
  Widget _buildErrorText(String error) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        error,
        style: const TextStyle(
          fontFamily: 'Work Sans',
          fontSize: 12,
          color: _errorColor,
        ),
      ),
    );
  }

  // -- Amount Field --
  Widget _buildAmountField() {
    final borderColor = _amountBorderColor();
    final borderWidth = _focusedWidth(_amountFocused);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Amount'),
          const SizedBox(height: 6),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: _inputFill,
              borderRadius: _inputRadius,
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const Text(
                  '\$',
                  style: TextStyle(
                    fontFamily: 'Work Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _textSecondary,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    focusNode: _amountFocus,
                    cursorColor: _primary,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    style: const TextStyle(
                      fontFamily: 'Work Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _textPrimary,
                    ),
                    decoration: const InputDecoration(
                      hintText: '0.00',
                      hintStyle: TextStyle(color: _textSecondary),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    onChanged: _onAmountChanged,
                  ),
                ),
              ],
            ),
          ),
          if (_amountError case final error?) _buildErrorText(error),
        ],
      ),
    );
  }

  // -- Description Field --
  Widget _buildDescriptionField() {
    final borderColor = _descriptionBorderColor();
    final borderWidth = _focusedWidth(_descriptionFocused);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Description'),
          const SizedBox(height: 6),
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: _inputFill,
              borderRadius: _inputRadius,
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: TextField(
              controller: _descriptionController,
              focusNode: _descriptionFocus,
              cursorColor: _primary,
              maxLines: 3,
              style: const TextStyle(
                fontFamily: 'Work Sans',
                fontSize: 15,
                fontWeight: FontWeight.normal,
                color: _textPrimary,
              ),
              decoration: InputDecoration(
                hintText:
                    'What was this ${_recordType.displayName.toLowerCase()} for?',
                hintStyle: const TextStyle(color: _textSecondary),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onChanged: _onDescriptionChanged,
            ),
          ),
          if (_descriptionError case final error?) _buildErrorText(error),
        ],
      ),
    );
  }

  // -- Category Field --
  Widget _buildCategoryField(BuildContext _, CategoryState state) {
    return switch (state) {
      CategoryInitial() || CategoryLoading() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Category'),
            const SizedBox(height: 6),
            ShimmerBox.rectangle(
              width: double.infinity,
              height: 48,
              borderRadius: 12,
            ),
          ],
        ),
      ),
      CategoryError(:final message) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Error: $message',
          style: const TextStyle(color: _errorColor),
        ),
      ),
      CategoryLoaded(:final categories) => _buildCategorySelect(categories),
      CategorySearchResults(:final results) => _buildCategorySelect(results),
    };
  }

  Widget _buildCategorySelect(List<Category> categories) {
    // Deduplicate by id to prevent DropdownButton assertion crash
    final seen = <String>{};
    final unique = categories
        .where((c) => c.id != null && seen.add(c.id ?? ''))
        .toList();

    // If _selectedCategoryId was a duplicate, reset to avoid mismatch
    if (_selectedCategoryId != null &&
        unique.every((c) => c.id != _selectedCategoryId)) {
      _selectedCategoryId = null;
    }

    // Find selected category for display
    final selected = _selectedCategoryId != null
        ? unique.where((c) => c.id == _selectedCategoryId).firstOrNull
        : null;
    final selectedIcon = selected != null
        ? AppIcons.getCategoryIcon(selected.emoji)
        : PiconsRegular.coffee;
    final selectedName = selected?.name ?? 'Select category';
    final selectedColor = selected != null ? _textPrimary : _textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Category'),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => _showCategoryPicker(unique),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: _inputFill,
                borderRadius: _inputRadius,
                border: Border.all(color: _inputStroke, width: 1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(selectedIcon, size: 18, color: _primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedName,
                      style: TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: selectedColor,
                      ),
                    ),
                  ),
                  const Icon(
                    PiconsRegular.caretDown,
                    size: 16,
                    color: _textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCategoryPicker(List<Category> categories) async {
    final result = await context.push<Category>(
      '/categories/picker',
      extra: {'type': _recordType, 'selectedId': _selectedCategoryId},
    );

    if (result != null && mounted) {
      _onCategoryChanged(result.id);
    }

    // Reload all categories to restore bloc state after picker changed it
    if (mounted) {
      context.read<CategoryBloc>().add(const LoadCategories());
    }
  }

  // -- Date Field --
  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Date'),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _handleSelectDate,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: _inputFill,
                borderRadius: _inputRadius,
                border: Border.all(color: _inputStroke, width: 1),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(PiconsRegular.calendar, size: 18, color: _primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _dateFormat.format(_selectedDate),
                      style: const TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: _textPrimary,
                      ),
                    ),
                  ),
                  const Icon(
                    PiconsRegular.caretDown,
                    size: 16,
                    color: _textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -- Save Button --
  Widget _buildSubmitButton() {
    final label = _isEditing
        ? 'Update ${_recordType.displayName}'
        : 'Create ${_recordType.displayName}';

    return GestureDetector(
      onTap: _saveRecord,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(color: _primary, borderRadius: _buttonRadius),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Work Sans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _onPrimary,
          ),
        ),
      ),
    );
  }

  // -- Loading state --
  Widget _buildLoadingState(String title) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(title),
              _buildFieldShimmer('Amount', 48),
              _buildFieldShimmer('Description', 80),
              _buildFieldShimmer('Category', 48),
              _buildFieldShimmer('Date', 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldShimmer(String label, double height) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
          const SizedBox(height: 6),
          ShimmerBox.rectangle(
            width: double.infinity,
            height: height,
            borderRadius: 12,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _amountFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing
        ? 'Edit ${_recordType.displayName}'
        : 'New ${_recordType.displayName}';

    if (_isLoading) {
      return _buildLoadingState(title);
    }

    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: _primary,
          selectionColor: _inputFill,
          selectionHandleColor: _primary,
        ),
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(title),
                  _buildAmountField(),
                  _buildDescriptionField(),
                  BlocBuilder<CategoryBloc, CategoryState>(
                    builder: _buildCategoryField,
                  ),
                  _buildDatePicker(),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
