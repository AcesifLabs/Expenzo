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
  var _selectedDate = DateTime.now();
  String? _selectedCategoryId;
  var _recordType = RecordType.expense;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    final recordId = widget.recordId;
    if (recordId != null) {
      _isLoading = true;
      _loadRecord(recordId);
    } else {
      _initFromRecord(widget.record);
    }
    context.read<CategoryBloc>().add(LoadCategories(type: _recordType));
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

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) return 'Please enter an amount';
    if (double.tryParse(value) == null) return 'Please enter a valid number';

    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a description';

    return null;
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
    );
    if (!mounted) return;
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveRecord() {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

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

  Widget _buildCategoryField(BuildContext _, CategoryState state) {
    return switch (state) {
      CategoryInitial() || CategoryLoading() => ShimmerBox.rectangle(
        width: double.infinity,
        height: 56,
        borderRadius: 12,
      ),
      CategoryError(:final message) => Text('Error: $message'),
      CategoryLoaded(:final categories) =>
        categories.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('No categories available. Create one first.'),
              )
            : _buildCategoryDropdown(categories),
    };
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: const InputDecoration(
        labelText: 'Amount',
        prefixText: '৳ ',
        hintText: '0.00',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      validator: _validateAmount,
    );
  }

  Widget _buildCategoryDropdown(List<Category> categories) {
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

    return DropdownButtonFormField<String>(
      initialValue: _selectedCategoryId,
      decoration: const InputDecoration(labelText: 'Category'),
      items: [
        const DropdownMenuItem<String>(value: null, child: Text('No Category')),
        ...unique.map(
          (cat) => DropdownMenuItem<String>(
            value: cat.id ?? '',
            child: Row(
              children: [
                Icon(AppIcons.getCategoryIcon(cat.emoji), size: 18),
                const SizedBox(width: 8),
                Text(cat.name),
              ],
            ),
          ),
        ),
      ],
      onChanged: _onCategoryChanged,
      key: ValueKey('category_dropdown_$_recordType'),
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Description',
        hintText: 'What was this ${_recordType.displayName.toLowerCase()} for?',
      ),
      maxLines: 3,
      validator: _validateDescription,
    );
  }

  Widget _buildDatePicker() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Date'),
      subtitle: Text(_dateFormat.format(_selectedDate)),
      trailing: Icon(PiconsRegular.calendar),
      onTap: () => _selectDate(),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: _saveRecord,
      child: Text(_isEditing ? 'Update' : 'Create'),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditing
        ? 'Edit ${_recordType.displayName}'
        : 'New ${_recordType.displayName}';

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildAmountField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 16),
            BlocBuilder<CategoryBloc, CategoryState>(
              builder: _buildCategoryField,
            ),
            const SizedBox(height: 16),
            _buildDatePicker(),
            const Divider(),
            const SizedBox(height: 16),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }
}
