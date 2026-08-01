import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';
import 'package:expense_tracker/shared/presentation/widgets/shimmer_box.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';
import '../constants/budget_ui_tokens.dart';

class BudgetFormPage extends StatefulWidget {
  final Budget? budget;
  final String? budgetId;

  const BudgetFormPage({super.key, this.budget, this.budgetId});

  @override
  State<BudgetFormPage> createState() => _BudgetFormPageState();
}

class _BudgetFormPageState extends State<BudgetFormPage> {
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  final _amountFocus = FocusNode();

  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;
  bool _rolloverEnabled = false;
  var _isLoading = false;
  var _amountFocused = false;
  String? _amountError;
  String? _nameError;
  String _currencySymbol = CurrencyFormatter.getFormatter(
    decimalDigits: 0,
  ).currencySymbol;

  bool get isEditing => widget.budget != null || widget.budgetId != null;

  Color get _amountBorderColor {
    if (_amountError != null) return BudgetUiTokens.error;
    if (_amountFocused) return BudgetUiTokens.primary;

    return BudgetUiTokens.inputStroke;
  }

  @override
  void initState() {
    super.initState();
    _amountFocus.addListener(_onAmountFocusChange);
    _loadCurrencySymbol();
    final budgetId = widget.budgetId;
    if (budgetId != null) {
      _isLoading = true;
      _loadBudget(budgetId);
    } else {
      _initFromBudget(widget.budget);
    }
  }

  Future<void> _loadCurrencySymbol() async {
    final getSettings = di.getIt<GetSettings>();
    final result = await getSettings(NoParams());
    if (!mounted) return;
    // On failure, keep the default currency symbol.
    final settings = result.fold((_) => null, (settings) => settings);
    if (settings != null) {
      setState(() => _currencySymbol = settings.currencySymbol);
    }
  }

  void _onAmountFocusChange() {
    setState(() => _amountFocused = _amountFocus.hasFocus);
  }

  Future<void> _loadBudget(String id) async {
    final repo = di.getIt<BudgetRepository>();
    final result = await repo.getBudgetById(id);
    if (!mounted) return;
    result.fold(
      (failure) => appLogger.error(
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
      _nameController.text = budget.name;
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

  bool _validate() {
    var valid = true;
    String? amountError;
    String? nameError;

    final amount = _amountController.text;
    if (amount.isEmpty) {
      amountError = 'Please enter an amount';
      valid = false;
    } else if (double.tryParse(amount) == null) {
      amountError = 'Please enter a valid number';
      valid = false;
    }

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      nameError = 'Please enter a name';
      valid = false;
    }

    setState(() {
      _amountError = amountError;
      _nameError = nameError;
    });

    return valid;
  }

  void _onAmountChanged(String _) {
    if (_amountError != null) {
      setState(() => _amountError = null);
    }
  }

  void _onNameChanged(String _) {
    if (_nameError != null) {
      setState(() => _nameError = null);
    }
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
    if (!_validate()) return;

    final budget = Budget(
      id: widget.budget?.id ?? widget.budgetId,
      name: _nameController.text.trim(),
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
              color: BudgetUiTokens.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Work Sans',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: BudgetUiTokens.textPrimary,
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
        color: BudgetUiTokens.textSecondary,
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
          color: BudgetUiTokens.error,
        ),
      ),
    );
  }

  // -- Amount Field --
  Widget _buildAmountField() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Budget Amount'),
          const SizedBox(height: 6),
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: BudgetUiTokens.inputFill,
              borderRadius: BudgetUiTokens.inputRadius,
              border: Border.all(
                color: _amountBorderColor,
                width: _amountFocused || _amountError != null ? 1.5 : 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text(
                  _currencySymbol,
                  style: const TextStyle(
                    fontFamily: 'Work Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: BudgetUiTokens.textSecondary,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextFormField(
                    controller: _amountController,
                    focusNode: _amountFocus,
                    cursorColor: BudgetUiTokens.primary,
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
                      color: BudgetUiTokens.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      hintText: '0.00',
                      hintStyle: TextStyle(color: BudgetUiTokens.textSecondary),
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

  // -- Name Field --
  Widget _buildNameField() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Budget Name'),
          const SizedBox(height: 6),
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: BudgetUiTokens.inputFill,
              borderRadius: BudgetUiTokens.inputRadius,
              border: Border.all(
                color: _nameError != null
                    ? BudgetUiTokens.error
                    : BudgetUiTokens.inputStroke,
                width: _nameError != null ? 1.5 : 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: TextFormField(
              controller: _nameController,
              cursorColor: BudgetUiTokens.primary,
              style: const TextStyle(
                fontFamily: 'Work Sans',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: BudgetUiTokens.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'e.g. Food & Drinks',
                hintStyle: TextStyle(color: BudgetUiTokens.textSecondary),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onChanged: _onNameChanged,
            ),
          ),
          if (_nameError case final error?) _buildErrorText(error),
        ],
      ),
    );
  }

  // -- Period Field --
  Widget _buildPeriodField() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel('Period'),
          const SizedBox(height: 6),
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: BudgetUiTokens.inputFill,
              borderRadius: BudgetUiTokens.inputRadius,
              border: Border.all(color: BudgetUiTokens.inputStroke, width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: DropdownButtonFormField<BudgetPeriod>(
              initialValue: _selectedPeriod,
              icon: const Icon(
                PiconsRegular.caretDown,
                size: 16,
                color: BudgetUiTokens.textSecondary,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(
                    PiconsRegular.calendar,
                    size: 18,
                    color: BudgetUiTokens.primary,
                  ),
                ),
                prefixIconConstraints: BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
              ),
              dropdownColor: BudgetUiTokens.inputFill,
              style: const TextStyle(
                fontFamily: 'Work Sans',
                fontSize: 15,
                fontWeight: FontWeight.normal,
                color: BudgetUiTokens.textPrimary,
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
              onChanged: _onPeriodChanged,
            ),
          ),
        ],
      ),
    );
  }

  // -- Rollover Row --
  Widget _buildRolloverRow() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: BudgetUiTokens.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              PiconsRegular.arrowsClockwise,
              color: BudgetUiTokens.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Enable Rollover',
                    style: TextStyle(
                      fontFamily: 'Work Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: BudgetUiTokens.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Carry forward unspent amount',
                    style: TextStyle(
                      fontFamily: 'Work Sans',
                      fontSize: 12,
                      color: BudgetUiTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _rolloverEnabled,
              onChanged: _onRolloverChanged,
              activeThumbColor: BudgetUiTokens.primary,
              activeTrackColor: BudgetUiTokens.primary.withAlpha(0x40),
              inactiveThumbColor: BudgetUiTokens.toggleKnob,
              inactiveTrackColor: BudgetUiTokens.toggleTrack,
            ),
          ],
        ),
      ),
    );
  }

  // -- Submit Button --
  Widget _buildSubmitButton(BudgetState state) {
    final label = isEditing ? 'Update Budget' : 'Create Budget';
    final isLoading = state is BudgetLoading;

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: GestureDetector(
        onTap: isLoading ? null : _submit,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: isLoading
                ? BudgetUiTokens.primary.withAlpha(0x80)
                : BudgetUiTokens.primary,
            borderRadius: BudgetUiTokens.buttonRadius,
          ),
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: BudgetUiTokens.onPrimary,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Work Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: BudgetUiTokens.onPrimary,
                  ),
                ),
        ),
      ),
    );
  }

  // -- Form --
  Widget _buildForm(BudgetState state) {
    final title = isEditing ? 'Edit Budget' : 'Create Budget';

    return Scaffold(
      backgroundColor: BudgetUiTokens.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(title),
              _buildAmountField(),
              _buildNameField(),
              _buildPeriodField(),
              _buildRolloverRow(),
              _buildSubmitButton(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldShimmer(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
          const SizedBox(height: 6),
          ShimmerBox.rectangle(
            width: double.infinity,
            height: 52,
            borderRadius: 12,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = isEditing ? 'Edit Budget' : 'Create Budget';

    if (_isLoading) {
      return Scaffold(
        backgroundColor: BudgetUiTokens.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(title),
                _buildFieldShimmer('Budget Amount'),
                _buildFieldShimmer('Budget Name'),
                _buildFieldShimmer('Period'),
              ],
            ),
          ),
        ),
      );
    }

    return BlocConsumer<BudgetBloc, BudgetState>(
      listener: _onBudgetOperation,
      builder: (context, state) => _buildForm(state),
    );
  }
}
