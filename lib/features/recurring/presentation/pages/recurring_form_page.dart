import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../categories/presentation/bloc/category_bloc.dart';
import '../../../categories/presentation/bloc/category_event.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../bloc/recurring_bloc.dart';
import '../bloc/recurring_event.dart';
import '../bloc/recurring_state.dart';

class RecurringFormPage extends StatefulWidget {
  final RecurringTransaction? recurring;

  const RecurringFormPage({super.key, this.recurring});

  @override
  State<RecurringFormPage> createState() => _RecurringFormPageState();
}

class _RecurringFormPageState extends State<RecurringFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late DateTime _startDate;
  DateTime? _endDate;
  RecurringFrequency _frequency = RecurringFrequency.monthly;
  bool _autoCreateExpense = true;
  int? _dayOfMonth;
  bool _isActive = true;

  bool get _isEditing => widget.recurring != null;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.recurring?.amount.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.recurring?.description ?? '',
    );
    _startDate = widget.recurring?.startDate ?? DateTime.now();
    _endDate = widget.recurring?.endDate;
    _frequency = widget.recurring?.frequency ?? RecurringFrequency.monthly;
    _autoCreateExpense = widget.recurring?.autoCreateExpense ?? true;
    _dayOfMonth = widget.recurring?.dayOfMonth;
    _isActive = widget.recurring?.isActive ?? true;

    context.read<CategoryBloc>().add(const LoadCategories());
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Recurring' : 'New Recurring'),
      ),
      body: BlocConsumer<RecurringBloc, RecurringState>(
        listener: (context, state) {
          if (state is RecurringOperationSuccess) {
            Navigator.pop(context, true);
          } else if (state is RecurringError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
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
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^-?\d*\.?\d{0,2}'),
                    ),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'What is this recurring expense for?',
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<RecurringFrequency>(
                  initialValue: _frequency,
                  decoration: const InputDecoration(labelText: 'Frequency'),
                  items: const [
                    DropdownMenuItem(
                      value: RecurringFrequency.daily,
                      child: Text('Daily'),
                    ),
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
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _frequency = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Start Date'),
                  subtitle: Text(dateFormat.format(_startDate)),
                  trailing: Icon(
                    PhosphorIcons.calendar(PhosphorIconsStyle.regular),
                  ),
                  onTap: _selectStartDate,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('End Date (Optional)'),
                  subtitle: Text(
                    _endDate != null
                        ? dateFormat.format(_endDate!)
                        : 'No end date',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_endDate != null)
                        IconButton(
                          icon: Icon(
                            PhosphorIcons.x(PhosphorIconsStyle.regular),
                          ),
                          onPressed: () => setState(() => _endDate = null),
                        ),
                      Icon(PhosphorIcons.calendar(PhosphorIconsStyle.regular)),
                    ],
                  ),
                  onTap: _selectEndDate,
                ),
                const Divider(),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Auto-create expenses'),
                  subtitle: const Text(
                    'Automatically create expenses when due',
                  ),
                  value: _autoCreateExpense,
                  onChanged: (value) {
                    setState(() => _autoCreateExpense = value);
                  },
                ),
                SwitchListTile(
                  title: const Text('Active'),
                  subtitle: const Text('Process this recurring transaction'),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() => _isActive = value);
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: state is RecurringLoading ? null : _submit,
                  child: Text(_isEditing ? 'Update' : 'Create'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
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
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final recurring = RecurringTransaction(
        id: widget.recurring?.id,
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
  }
}
