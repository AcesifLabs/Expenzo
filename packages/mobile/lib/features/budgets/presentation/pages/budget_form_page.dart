import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';

class BudgetFormPage extends StatefulWidget {
  final Budget? budget;
  final String? budgetId;

  const BudgetFormPage({super.key, this.budget, this.budgetId});

  @override
  State<BudgetFormPage> createState() => _BudgetFormPageState();
}

class _BudgetFormPageState extends State<BudgetFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  String? _selectedCategoryId;
  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;
  bool _rolloverEnabled = false;
  var _isLoading = false;

  bool get isEditing => widget.budget != null || widget.budgetId != null;

  @override
  void initState() {
    super.initState();
    final budgetId = widget.budgetId;
    if (budgetId != null) {
      _isLoading = true;
      _loadBudget(budgetId);
    } else {
      _initFromBudget(widget.budget);
    }
  }

  Future<void> _loadBudget(String id) async {
    final repo = di.getIt<BudgetRepository>();
    final result = await repo.getBudgetById(id);
    if (!mounted) return;
    result.fold(
      (failure) => debugPrint(
        'BudgetFormPage: Failed to load budget: ${failure.message}',
      ),
      (budget) {
        if (!mounted) return;
        setState(() {
          _initFromBudget(budget);
          _isLoading = false;
        });
      },
    );
  }

  void _initFromBudget(Budget? budget) {
    if (budget != null) {
      _amountController.text = budget.amount.toString();
      _selectedCategoryId = budget.categoryId;
      _selectedPeriod = budget.period;
      _rolloverEnabled = budget.rolloverEnabled;
    }
  }

  void _onBudgetOperation(BuildContext context, BudgetState state) {
    switch (state) {
      case BudgetOperationSuccess():
        context.pop(true);
      case BudgetError(:final message):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      default:
        break;
    }
  }

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty) return 'Please enter an amount';
    if (double.tryParse(value) == null) return 'Please enter a valid number';

    return null;
  }

  void _onPeriodChanged(BudgetPeriod? value) {
    if (value != null) {
      setState(() => _selectedPeriod = value);
    }
  }

  void _onRolloverChanged(bool value) {
    setState(() => _rolloverEnabled = value);
  }

  void _submit() {
    final key = _formKey.currentState;
    if (key == null || !key.validate()) return;

    final budget = Budget(
      id: widget.budget?.id ?? widget.budgetId,
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

  Widget _buildFormFields(BudgetState state) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAmountField(),
          const SizedBox(height: 16),
          _buildPeriodField(),
          const SizedBox(height: 16),
          _buildRolloverField(),
          const SizedBox(height: 24),
          _buildSubmitButton(state),
        ],
      ),
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: 'Budget Amount',
        prefixText: '৳',
        border: OutlineInputBorder(),
      ),
      validator: _validateAmount,
    );
  }

  Widget _buildPeriodField() {
    return DropdownButtonFormField<BudgetPeriod>(
      initialValue: _selectedPeriod,
      decoration: const InputDecoration(
        labelText: 'Period',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: BudgetPeriod.weekly, child: Text('Weekly')),
        DropdownMenuItem(value: BudgetPeriod.monthly, child: Text('Monthly')),
        DropdownMenuItem(value: BudgetPeriod.yearly, child: Text('Yearly')),
      ],
      onChanged: _onPeriodChanged,
    );
  }

  Widget _buildRolloverField() {
    return SwitchListTile(
      title: const Text('Enable Rollover'),
      subtitle: const Text('Carry forward unspent amount to next period'),
      value: _rolloverEnabled,
      onChanged: _onRolloverChanged,
    );
  }

  Widget _buildSubmitButton(BudgetState state) {
    return ElevatedButton(
      onPressed: state is BudgetLoading ? null : _submit,
      child: Text(isEditing ? 'Update Budget' : 'Create Budget'),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Budget' : 'Create Budget'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Budget' : 'Create Budget')),
      body: BlocConsumer<BudgetBloc, BudgetState>(
        listener: _onBudgetOperation,
        builder: (context, state) => _buildFormFields(state),
      ),
    );
  }
}
