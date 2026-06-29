import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import '../../../categories/presentation/bloc/category_bloc.dart';
import '../../../categories/presentation/bloc/category_event.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../../domain/repositories/recurring_repository.dart';
import '../bloc/recurring_bloc.dart';
import '../bloc/recurring_event.dart';
import '../bloc/recurring_state.dart';

class RecurringFormPage extends StatefulWidget {
  final RecurringTransaction? recurring;
  final String? recurringId;

  const RecurringFormPage({super.key, this.recurring, this.recurringId});

  @override
  State<RecurringFormPage> createState() => _RecurringFormPageState();
}

class _RecurringFormPageState extends State<RecurringFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  var _startDate = DateTime.now();
  DateTime? _endDate;
  var _frequency = RecurringFrequency.monthly;
  var _autoCreateExpense = true;
  int? _dayOfMonth;
  var _isActive = true;
  var _isLoading = false;

  bool get _isEditing => widget.recurring != null || widget.recurringId != null;

  @override
  void initState() {
    super.initState();
    final recurringId = widget.recurringId;
    if (recurringId != null) {
      _isLoading = true;
      _loadRecurring(recurringId);
    } else {
      _initFromRecurring(widget.recurring);
    }
    context.read<CategoryBloc>().add(const LoadCategories());
  }

  Future<void> _loadRecurring(String id) async {
    try {
      await di.featureDependenciesReady;
      if (!mounted) return;
      final repo = di.getIt<RecurringRepository>();
      final result = await repo.getRecurringById(id);
      if (!mounted) return;
      result.fold(
        (failure) {
          debugPrint(
            'RecurringFormPage: Failed to load recurring: ${failure.message}',
          );
          setState(() => _isLoading = false);
        },
        (recurring) {
          setState(() {
            _initFromRecurring(recurring);
            _isLoading = false;
          });
        },
      );
    } catch (e, s) {
      debugPrint('Error: $e\n$s');
      debugPrint('RecurringFormPage: Failed to load recurring: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _initFromRecurring(RecurringTransaction? recurring) {
    if (recurring == null) {
      _amountController.text = '';
      _descriptionController.text = '';
      _startDate = DateTime.now();
      _endDate = null;
      _frequency = RecurringFrequency.monthly;
      _autoCreateExpense = true;
      _dayOfMonth = null;
      _isActive = true;

      return;
    }
    _amountController.text = recurring.amount.toString();
    _descriptionController.text = recurring.description;
    _startDate = recurring.startDate;
    _endDate = recurring.endDate;
    _frequency = recurring.frequency;
    _autoCreateExpense = recurring.autoCreateExpense;
    _dayOfMonth = recurring.dayOfMonth;
    _isActive = recurring.isActive;
  }

  void _onRecurringListener(BuildContext context, RecurringState state) {
    switch (state) {
      case RecurringOperationSuccess():
        context.pop(true);
      case RecurringError(:final message):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      default:
        break;
    }
  }

  void _onFrequencyChanged(RecurringFrequency? value) {
    if (value != null) setState(() => _frequency = value);
  }

  void _clearEndDate() {
    setState(() => _endDate = null);
  }

  void _onAutoCreateChanged(bool value) {
    setState(() => _autoCreateExpense = value);
  }

  void _onIsActiveChanged(bool value) {
    setState(() => _isActive = value);
  }

  void _submit() {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    final recurring = RecurringTransaction(
      id: widget.recurring?.id ?? widget.recurringId,
      description: _descriptionController.text,
      amount: double.parse(_amountController.text),
      categoryId: widget.recurring?.categoryId,
      frequency: _frequency,
      startDate: _startDate,
      endDate: _endDate,
      nextOccurrence: widget.recurring?.nextOccurrence ?? _startDate,
      isActive: _isActive,
      autoCreateExpense: _autoCreateExpense,
      dayOfMonth: _dayOfMonth,
    );

    if (_isEditing) {
      context.read<RecurringBloc>().add(UpdateRecurring(recurring));
    } else {
      context.read<RecurringBloc>().add(CreateRecurring(recurring));
    }
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (!mounted) return;
    if (picked != null && picked != _startDate) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (!mounted) return;
    if (picked != null) setState(() => _endDate = picked);
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

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: const InputDecoration(
        labelText: 'Amount',
        prefixText: '\$ ',
        hintText: '0.00',
      ),
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
        signed: true,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d{0,2}')),
      ],
      validator: _validateAmount,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description',
        hintText: 'What is this recurring expense for?',
      ),
      maxLines: 2,
      validator: _validateDescription,
    );
  }

  Widget _buildFrequencyDropdown() {
    return DropdownButtonFormField<RecurringFrequency>(
      initialValue: _frequency,
      decoration: const InputDecoration(labelText: 'Frequency'),
      items: const [
        DropdownMenuItem(value: RecurringFrequency.daily, child: Text('Daily')),
        DropdownMenuItem(
          value: RecurringFrequency.weekly,
          child: Text('Weekly'),
        ),
        DropdownMenuItem(
          value: RecurringFrequency.monthly,
          child: Text('Monthly'),
        ),
        DropdownMenuItem(
          value: RecurringFrequency.yearly,
          child: Text('Yearly'),
        ),
      ],
      onChanged: _onFrequencyChanged,
    );
  }

  Widget _buildStartDateTile(DateFormat dateFormat) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Start Date'),
      subtitle: Text(dateFormat.format(_startDate)),
      trailing: Icon(PiconsRegular.calendar),
      onTap: () => unawaited(_selectStartDate()),
    );
  }

  Widget _buildEndDateTile(DateFormat dateFormat) {
    final endDate = _endDate;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('End Date (Optional)'),
      subtitle: Text(
        endDate != null ? dateFormat.format(endDate) : 'No end date',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (endDate != null)
            IconButton(icon: Icon(PiconsRegular.x), onPressed: _clearEndDate),
          Icon(PiconsRegular.calendar),
        ],
      ),
      onTap: () => unawaited(_selectEndDate()),
    );
  }

  Widget _buildAutoCreateSwitch() {
    return SwitchListTile(
      title: const Text('Auto-create expenses'),
      subtitle: const Text('Automatically create expenses when due'),
      value: _autoCreateExpense,
      onChanged: _onAutoCreateChanged,
    );
  }

  Widget _buildActiveSwitch() {
    return SwitchListTile(
      title: const Text('Active'),
      subtitle: const Text('Process this recurring transaction'),
      value: _isActive,
      onChanged: _onIsActiveChanged,
    );
  }

  Widget _buildSubmitButton(RecurringState state) {
    return ElevatedButton(
      onPressed: state is RecurringLoading ? null : _submit,
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
    final dateFormat = DateFormat('MMM dd, yyyy');

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Recurring' : 'New Recurring'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Recurring' : 'New Recurring'),
      ),
      body: BlocConsumer<RecurringBloc, RecurringState>(
        listener: _onRecurringListener,
        builder: (context, state) => Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildAmountField(),
              const SizedBox(height: 16),
              _buildDescriptionField(),
              const SizedBox(height: 16),
              _buildFrequencyDropdown(),
              const SizedBox(height: 16),
              _buildStartDateTile(dateFormat),
              _buildEndDateTile(dateFormat),
              const Divider(),
              const SizedBox(height: 8),
              _buildAutoCreateSwitch(),
              _buildActiveSwitch(),
              const SizedBox(height: 24),
              _buildSubmitButton(state),
            ],
          ),
        ),
      ),
    );
  }
}
