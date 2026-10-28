import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_page_header.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import '../../../categories/presentation/bloc/category_bloc.dart';
import '../../../categories/presentation/bloc/category_event.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../../domain/repositories/recurring_repository.dart';
import '../bloc/recurring_bloc.dart';
import '../bloc/recurring_event.dart';
import '../bloc/recurring_state.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_error_state.dart';

class RecurringFormPage extends StatefulWidget {
  final RecurringTransaction? recurring;
  final String? recurringId;

  final RecurringFrequency defaultFrequency;

  const RecurringFormPage({
    super.key,
    this.recurring,
    this.recurringId,
    this.defaultFrequency = RecurringFrequency.monthly,
  });

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

  String? _loadError;
  String? _categoryId;

  RecurringTransaction? _original;

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

  void _retryLoad(String id) {
    setState(() {
      _loadError = null;
      _isLoading = true;
    });
    unawaited(_loadRecurring(id));
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
          appLogger.warning(
            'RecurringFormPage: Failed to load recurring: ${failure.message}',
          );
          setState(() {
            _isLoading = false;
            _loadError = failureText(failure);
          });
        },
        (recurring) {
          setState(() {
            _initFromRecurring(recurring);
            _isLoading = false;
          });
        },
      );
    } catch (e, s) {
      appLogger.error('RecurringFormPage: Failed to load recurring', e, s);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = t.common.errors.generic;
        });
      }
    }
  }

  void _initFromRecurring(RecurringTransaction? recurring) {
    _original = recurring;
    if (recurring == null) {
      _amountController.text = '';
      _descriptionController.text = '';
      _startDate = DateTime.now();
      _endDate = null;
      _frequency = widget.defaultFrequency;
      _autoCreateExpense = true;
      _dayOfMonth = null;
      _isActive = true;

      return;
    }
    _amountController.text = CurrencyFormatter.formatInput(recurring.amount);
    _descriptionController.text = recurring.description;
    _startDate = recurring.startDate;
    _endDate = recurring.endDate;
    _frequency = recurring.frequency;
    _autoCreateExpense = recurring.autoCreateExpense;
    _dayOfMonth = recurring.dayOfMonth;
    _isActive = recurring.isActive;
    _categoryId = recurring.categoryId;
  }

  void _onRecurringListener(BuildContext context, RecurringState state) {
    switch (state) {
      case RecurringOperationSuccess():
        context.pop(true);
      case RecurringError(:final message):
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(message)));
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

  int? _dayOfMonthFor(RecurringFrequency frequency) => switch (frequency) {
    RecurringFrequency.monthly || RecurringFrequency.yearly => _startDate.day,
    RecurringFrequency.daily || RecurringFrequency.weekly => _dayOfMonth,
  };

  void _submit() {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    final recurring = RecurringTransaction(
      id: widget.recurring?.id ?? widget.recurringId,
      description: _descriptionController.text,
      amount: double.parse(_amountController.text),
      categoryId: _categoryId,
      frequency: _frequency,
      startDate: _startDate,
      endDate: _endDate,
      nextOccurrence: _original?.nextOccurrence ?? _startDate,
      isActive: _isActive,
      autoCreateExpense: _autoCreateExpense,
      dayOfMonth: _dayOfMonthFor(_frequency),
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
      firstDate: AppConstants.pickerFirstDate,
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
      firstDate: AppConstants.pickerFirstDate,
      lastDate: DateTime(2100),
    );
    if (!mounted) return;
    if (picked != null) setState(() => _endDate = picked);
  }

  String? _validateAmount(String? value) {
    final form = t.recurring.form;
    if (value == null || value.isEmpty) return form.amountRequired;
    if (double.tryParse(value) == null) return form.amountInvalid;

    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) return t.recurring.form.nameRequired;

    return null;
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: InputDecoration(
        labelText: t.recurring.form.amount,
        prefixText: '${CurrencyFormatter.current.value.symbol.trim()} ',
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
    final form = t.recurring.form;

    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: form.name,
        hintText: form.nameHint,
      ),
      maxLines: 2,
      validator: _validateDescription,
    );
  }

  Widget _buildFrequencyDropdown() {
    return DropdownButtonFormField<RecurringFrequency>(
      initialValue: _frequency,
      isExpanded: true,
      decoration: InputDecoration(labelText: t.recurring.form.frequency),
      items: [
        for (final frequency in RecurringFrequency.values)
          DropdownMenuItem(
            value: frequency,
            child: Text(frequency.displayName),
          ),
      ],
      onChanged: _onFrequencyChanged,
    );
  }

  Widget _buildStartDateTile(DateFormat dateFormat) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(t.recurring.form.startDate),
      subtitle: Text(dateFormat.format(_startDate)),
      trailing: const Icon(PiconsRegular.calendar),
      onTap: () => unawaited(_selectStartDate()),
    );
  }

  Widget _buildEndDateTile(DateFormat dateFormat) {
    final form = t.recurring.form;
    final endDate = _endDate;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(form.endDate),
      subtitle: Text(
        endDate != null ? dateFormat.format(endDate) : form.noEndDate,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (endDate != null)
            IconButton(
              icon: const Icon(PiconsRegular.x),
              tooltip: form.clearEndDate,
              onPressed: _clearEndDate,
            ),
          const Icon(PiconsRegular.calendar),
        ],
      ),
      onTap: () => unawaited(_selectEndDate()),
    );
  }

  Widget _buildAutoCreateSwitch() {
    final form = t.recurring.form;

    return SwitchListTile(
      title: Text(form.autoCreate),
      subtitle: Text(form.autoCreateDetail),
      value: _autoCreateExpense,
      onChanged: _onAutoCreateChanged,
    );
  }

  Widget _buildActiveSwitch() {
    final form = t.recurring.form;

    return SwitchListTile(
      title: Text(form.active),
      subtitle: Text(form.activeDetail),
      value: _isActive,
      onChanged: _onIsActiveChanged,
    );
  }

  Widget _buildSubmitButton(RecurringState state) {
    return ElevatedButton(
      onPressed: state is RecurringLoading ? null : _submit,
      child: Text(_isEditing ? t.common.save : t.common.add),
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
    final form = t.recurring.form;
    final dateFormat = DateFormat('MMM dd, yyyy');

    if (_isLoading) {
      return Scaffold(
        appBar: AppPageHeader(
          leading: const AppBackButton(),
          title: _isEditing ? form.edit : form.create,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final loadError = _loadError;
    final recurringId = widget.recurringId;
    if (loadError != null && recurringId != null) {
      return Scaffold(
        appBar: AppPageHeader(leading: const AppBackButton(), title: form.edit),
        body: AppErrorState(
          message: loadError,
          onRetry: () => _retryLoad(recurringId),
        ),
      );
    }

    return Scaffold(
      appBar: AppPageHeader(
        leading: const AppBackButton(),
        title: _isEditing ? form.edit : form.create,
      ),
      body: BlocConsumer<RecurringBloc, RecurringState>(
        listener: _onRecurringListener,
        builder: (context, state) => Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _buildAmountField(),
              const SizedBox(height: AppSpacing.md),
              _buildDescriptionField(),
              const SizedBox(height: AppSpacing.md),
              _buildFrequencyDropdown(),
              const SizedBox(height: AppSpacing.md),
              _buildStartDateTile(dateFormat),
              _buildEndDateTile(dateFormat),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              _buildAutoCreateSwitch(),
              _buildActiveSwitch(),
              const SizedBox(height: AppSpacing.lg),
              _buildSubmitButton(state),
            ],
          ),
        ),
      ),
    );
  }
}
