import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_icons.dart';
import '../../../../shared/presentation/widgets/shimmer_box.dart';
import '../../../categories/presentation/bloc/category_bloc.dart';
import '../../../categories/presentation/bloc/category_event.dart';
import '../../../categories/presentation/bloc/category_state.dart';
import '../../domain/entities/expense.dart';
import "package:expense_tracker/core/constants/source_types.dart";
import '../bloc/expense_bloc.dart';
import '../bloc/expense_event.dart';

class ExpenseFormPage extends StatefulWidget {
  final Expense? expense;

  const ExpenseFormPage({super.key, this.expense});

  @override
  State<ExpenseFormPage> createState() => _ExpenseFormPageState();
}

class _ExpenseFormPageState extends State<ExpenseFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  int? _selectedCategoryId;
  bool _showNegativeWarning = false;

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.expense?.amount.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.expense?.description ?? '',
    );
    _selectedDate = widget.expense?.date ?? DateTime.now();
    _selectedCategoryId = widget.expense?.categoryId;

    _amountController.addListener(_checkNegativeAmount);

    // Load categories for the dropdown
    context.read<CategoryBloc>().add(const LoadCategories());
  }

  @override
  void dispose() {
    _amountController.removeListener(_checkNegativeAmount);
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _checkNegativeAmount() {
    final amount = double.tryParse(_amountController.text);
    if (amount != null && amount < 0 && !_showNegativeWarning) {
      setState(() => _showNegativeWarning = true);
    } else if ((amount == null || amount >= 0) && _showNegativeWarning) {
      setState(() => _showNegativeWarning = false);
    }
  }

  // Memoized formatter — created once per instance instead of per build
  static final _dateFormat = DateFormat('MMM dd, yyyy');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Expense' : 'New Expense')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '৳ ',
                hintText: '0.00',
                suffixIcon: _showNegativeWarning
                    ? Icon(
                        PhosphorIcons.warning(PhosphorIconsStyle.regular),
                        color: AppColors.warning,
                      )
                    : null,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d{0,2}')),
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
            if (_showNegativeWarning)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIcons.warning(PhosphorIconsStyle.regular),
                      color: AppColors.warning,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Negative amount - this is a refund or income',
                      style: TextStyle(color: AppColors.warning, fontSize: 12),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'What was this expense for?',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, state) {
                if (state is CategoryLoading || state is CategoryInitial) {
                  return ShimmerBox.rectangle(
                    width: double.infinity,
                    height: 56,
                    borderRadius: 12,
                  );
                }
                if (state is CategoryError) {
                  return Text('Error: ${state.message}');
                }
                if (state is CategoryLoaded) {
                  return DropdownButtonFormField<int>(
                    initialValue: _selectedCategoryId,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text('No Category'),
                      ),
                      ...state.categories.map((cat) {
                        return DropdownMenuItem<int>(
                          value: cat.id,
                          child: Row(
                            children: [
                              Icon(
                                AppIcons.getCategoryIcon(cat.emoji),
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(cat.name),
                            ],
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedCategoryId = value);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(_dateFormat.format(_selectedDate)),
              trailing: Icon(
                PhosphorIcons.calendar(PhosphorIconsStyle.regular),
              ),
              onTap: _selectDate,
            ),
            const Divider(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveExpense,
              child: Text(_isEditing ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveExpense() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now().toUtc();
      final expense = Expense(
        id: widget.expense?.id,
        amount: double.parse(_amountController.text),
        description: _descriptionController.text,
        date: _selectedDate,
        categoryId: _selectedCategoryId,
        source: ExpenseSource.manual,
        createdAt: widget.expense?.createdAt ?? now,
        updatedAt: now,
      );

      if (_isEditing) {
        context.read<ExpenseBloc>().add(UpdateExpenseEvent(expense));
      } else {
        context.read<ExpenseBloc>().add(AddExpenseEvent(expense));
      }
      Navigator.pop(context);
    }
  }
}
