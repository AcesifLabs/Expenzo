import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/di/injection_container.dart';
import '../../domain/entities/budget.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';

class BudgetFormPage extends StatefulWidget {
  final Budget? budget;

  const BudgetFormPage({super.key, this.budget});

  @override
  State<BudgetFormPage> createState() => _BudgetFormPageState();
}

class _BudgetFormPageState extends State<BudgetFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  String? _selectedCategoryId;
  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;
  bool _rolloverEnabled = false;

  bool get isEditing => widget.budget != null;

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      _amountController.text = widget.budget!.amount.toString();
      _selectedCategoryId = widget.budget!.categoryId;
      _selectedPeriod = widget.budget!.period;
      _rolloverEnabled = widget.budget!.rolloverEnabled;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<BudgetBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Budget' : 'Create Budget'),
        ),
        body: BlocConsumer<BudgetBloc, BudgetState>(
          listener: (context, state) {
            if (state is BudgetOperationSuccess) {
              Navigator.pop(context, true);
            } else if (state is BudgetError) {
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
                  // Amount
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Budget Amount',
                      prefixText: '৳',
                      border: OutlineInputBorder(),
                    ),
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

                  // Period
                  DropdownButtonFormField<BudgetPeriod>(
                    initialValue: _selectedPeriod,
                    decoration: const InputDecoration(
                      labelText: 'Period',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: BudgetPeriod.weekly,
                        child: Text('Weekly'),
                      ),
                      DropdownMenuItem(
                        value: BudgetPeriod.monthly,
                        child: Text('Monthly'),
                      ),
                      DropdownMenuItem(
                        value: BudgetPeriod.yearly,
                        child: Text('Yearly'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedPeriod = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Rollover toggle
                  SwitchListTile(
                    title: const Text('Enable Rollover'),
                    subtitle: const Text(
                      'Carry forward unspent amount to next period',
                    ),
                    value: _rolloverEnabled,
                    onChanged: (value) {
                      setState(() => _rolloverEnabled = value);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Submit button
                  ElevatedButton(
                    onPressed: state is BudgetLoading ? null : _submit,
                    child: Text(isEditing ? 'Update Budget' : 'Create Budget'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final budget = Budget(
        id: widget.budget?.id,
        categoryId: _selectedCategoryId,
        amount: double.parse(_amountController.text),
        period: _selectedPeriod,
        startDate: DateTime(DateTime.now().year, DateTime.now().month, 1),
        rolloverEnabled: _rolloverEnabled,
        rolloverAmount: widget.budget?.rolloverAmount ?? 0,
        isEnabled: true,
      );

      if (isEditing) {
        context.read<BudgetBloc>().add(UpdateBudgetEvent(budget));
      } else {
        context.read<BudgetBloc>().add(CreateBudgetEvent(budget));
      }
    }
  }
}
