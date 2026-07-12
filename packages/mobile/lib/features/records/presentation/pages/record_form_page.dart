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

const _inputRadius = BorderRadius.all(Radius.circular(12));
const _buttonRadius = BorderRadius.all(Radius.circular(14));

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
    context.read<CategoryBloc>().add(LoadCategories(type: _recordType));
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
    final amount = _amountController.text;
    if (amount.isEmpty) {
      _amountError = 'Please enter an amount';
      valid = false;
    } else if (double.tryParse(amount) == null) {
      _amountError = 'Please enter a valid number';
      valid = false;
    } else {
      _amountError = null;
    }

    final desc = _descriptionController.text;
    if (desc.isEmpty) {
      _descriptionError = 'Please enter a description';
      valid = false;
    } else {
      _descriptionError = null;
    }

    setState(() {});
    return valid;
  }

  void _onCategoryChanged(String? value) {
    setState(() => _selectedCategoryId = value);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
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
            datePickerTheme: DatePickerThemeData(
              backgroundColor: _bg,
              surfaceTintColor: Colors.transparent,
              headerBackgroundColor: _inputFill,
              headerForegroundColor: _textPrimary,
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return _onPrimary;
                }
                if (states.contains(WidgetState.disabled)) {
                  return _textSecondary.withAlpha(80);
                }
                return _textPrimary;
              }),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return _primary;
                return Colors.transparent;
              }),
              todayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return _onPrimary;
                return _primary;
              }),
              todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return _primary;
                return Colors.transparent;
              }),
              todayBorder: const BorderSide(color: _primary, width: 1),
              yearForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return _onPrimary;
                }
                if (states.contains(WidgetState.disabled)) {
                  return _textSecondary.withAlpha(80);
                }
                return _textPrimary;
              }),
              yearBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return _primary;
                return Colors.transparent;
              }),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              dayShape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              yearShape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: _primary),
            ),
            inputDecorationTheme: const InputDecorationTheme(
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
            ),
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: _primary,
              selectionColor: _inputFill,
              selectionHandleColor: _primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (!mounted) return;
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
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

  // -- Amount Field --
  Widget _buildAmountField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Amount',
            style: TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: _inputFill,
              borderRadius: _inputRadius,
              border: Border.all(
                color: _amountError != null
                    ? const Color(0xFFF48FB1)
                    : _amountFocused
                    ? _primary
                    : _inputStroke,
                width: _amountFocused ? 1.5 : 1,
              ),
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
                    onChanged: (_) {
                      if (_amountError != null) {
                        setState(() => _amountError = null);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_amountError != null) ...[
            const SizedBox(height: 6),
            Text(
              _amountError!,
              style: const TextStyle(
                fontFamily: 'Work Sans',
                fontSize: 12,
                color: Color(0xFFF48FB1),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // -- Description Field --
  Widget _buildDescriptionField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: _inputFill,
              borderRadius: _inputRadius,
              border: Border.all(
                color: _descriptionError != null
                    ? const Color(0xFFF48FB1)
                    : _descriptionFocused
                    ? _primary
                    : _inputStroke,
                width: _descriptionFocused ? 1.5 : 1,
              ),
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
              onChanged: (_) {
                if (_descriptionError != null) {
                  setState(() => _descriptionError = null);
                }
              },
            ),
          ),
          if (_descriptionError != null) ...[
            const SizedBox(height: 6),
            Text(
              _descriptionError!,
              style: const TextStyle(
                fontFamily: 'Work Sans',
                fontSize: 12,
                color: Color(0xFFF48FB1),
              ),
            ),
          ],
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
            const Text(
              'Category',
              style: TextStyle(
                fontFamily: 'Work Sans',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: _textSecondary,
              ),
            ),
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
          style: const TextStyle(color: Color(0xFFF48FB1)),
        ),
      ),
      CategoryLoaded(:final categories) => _buildCategorySelect(categories),
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category',
            style: TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _textSecondary,
            ),
          ),
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
                  Icon(
                    selected != null
                        ? AppIcons.getCategoryIcon(selected.emoji)
                        : PiconsRegular.coffee,
                    size: 18,
                    color: _primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selected?.name ?? 'Select category',
                      style: TextStyle(
                        fontFamily: 'Work Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                        color: selected != null ? _textPrimary : _textSecondary,
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

  void _showCategoryPicker(List<Category> categories) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _textSecondary.withAlpha(80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'Select Category',
                  style: TextStyle(
                    fontFamily: 'Work Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
              ),
              // Scrollable category list
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Category list
                      ...categories.map(
                        (cat) => _buildCategoryPickerItem(
                          icon: AppIcons.getCategoryIcon(cat.emoji),
                          name: cat.name,
                          isSelected: cat.id == _selectedCategoryId,
                          onTap: () {
                            _onCategoryChanged(cat.id);
                            Navigator.pop(ctx);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryPickerItem({
    required IconData icon,
    required String name,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: _primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontFamily: 'Work Sans',
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: _textPrimary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(PiconsRegular.check, size: 18, color: _primary),
          ],
        ),
      ),
    );
  }

  // -- Date Field --
  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Date',
            style: TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _selectDate,
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
              // Amount shimmer
              _buildFieldShimmer('Amount', 48),
              // Description shimmer
              _buildFieldShimmer('Description', 80),
              // Category shimmer
              _buildFieldShimmer('Category', 48),
              // Date shimmer
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
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _textSecondary,
            ),
          ),
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
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: _primary,
          selectionColor: _primary.withAlpha(80),
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
