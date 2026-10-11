import 'dart:async';

import 'package:flutter/material.dart';
import 'package:expense_tracker/shared/services/notification_permission.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/shared/presentation/widgets/shimmer_box.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_page_header.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class BudgetFormPage extends StatefulWidget {
  final Budget? budget;
  final String? budgetId;

  const BudgetFormPage({super.key, this.budget, this.budgetId});

  @override
  State<BudgetFormPage> createState() => _BudgetFormPageState();
}

const _inputRadius = BorderRadius.all(
  Radius.circular(AppSpacing.radiusControl),
);
const _buttonRadius = BorderRadius.all(
  Radius.circular(AppSpacing.radiusControl),
);

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

  bool get isEditing => widget.budget != null || widget.budgetId != null;

  AppPalette get _palette => context.palette;

  Color get _amountBorderColor {
    if (_amountError != null) return _palette.error;
    if (_amountFocused) return _palette.brand;

    return _palette.inputStroke;
  }

  @override
  void initState() {
    super.initState();
    _amountFocus.addListener(_onAmountFocusChange);
    final budgetId = widget.budgetId;
    if (budgetId != null) {
      _isLoading = true;
      _loadBudget(budgetId);
    } else {
      _initFromBudget(widget.budget);
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
      _amountController.text = CurrencyFormatter.formatInput(budget.amount);
      _nameController.text = budget.name;
      _selectedPeriod = budget.period;
      _rolloverEnabled = budget.rolloverEnabled;
    }
  }

  void _onBudgetOperation(BuildContext context, BudgetState state) {
    switch (state) {
      case BudgetOperationSuccess():
        if (!isEditing) unawaited(requestBudgetAlertPermissionIfNeeded());
        context.pop(true);
      case BudgetError(:final message):
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(message)));
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
      amountError = t.budgets.form.amountRequired;
      valid = false;
    } else if (double.tryParse(amount) == null) {
      amountError = t.budgets.form.amountInvalid;
      valid = false;
    }

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      nameError = t.budgets.form.nameRequired;
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
  PreferredSizeWidget _buildTopBar(String title) {
    return AppPageHeader(leading: const AppBackButton(), title: title);
  }

  // -- Field label --
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: AppTypography.bodySmall.copyWith(color: _palette.textSecondary),
    );
  }

  // -- Error text --
  Widget _buildErrorText(String error) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Text(
        error,
        style: AppTypography.bodySmall.copyWith(color: _palette.error),
      ),
    );
  }

  // -- Amount Field --
  Widget _buildAmountField() {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.smd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(t.budgets.form.amount),
          const SizedBox(height: AppSpacing.sm),
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: _palette.inputFill,
              borderRadius: _inputRadius,
              border: Border.all(
                color: _amountBorderColor,
                width: _amountFocused || _amountError != null ? 1.5 : 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Text(
                  CurrencyFormatter.current.value.symbol.trim(),
                  style: AppTypography.bodyLarge.copyWith(
                    color: _palette.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextFormField(
                    controller: _amountController,
                    focusNode: _amountFocus,
                    cursorColor: _palette.brand,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                    style: AppTypography.bodyLarge.copyWith(
                      color: _palette.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: TextStyle(color: _palette.textSecondary),
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
      padding: const EdgeInsets.only(top: AppSpacing.smd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(t.budgets.form.name),
          const SizedBox(height: AppSpacing.sm),
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: _palette.inputFill,
              borderRadius: _inputRadius,
              border: Border.all(
                color: _nameError != null
                    ? _palette.error
                    : _palette.inputStroke,
                width: _nameError != null ? 1.5 : 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            alignment: Alignment.centerLeft,
            child: TextFormField(
              controller: _nameController,
              cursorColor: _palette.brand,
              style: AppTypography.bodyLarge.copyWith(
                color: _palette.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: t.budgets.form.nameHint,
                hintStyle: TextStyle(color: _palette.textSecondary),
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
      padding: const EdgeInsets.only(top: AppSpacing.smd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(t.budgets.form.period),
          const SizedBox(height: AppSpacing.sm),
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: _palette.inputFill,
              borderRadius: _inputRadius,
              border: Border.all(color: _palette.inputStroke, width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            alignment: Alignment.centerLeft,
            child: DropdownButtonFormField<BudgetPeriod>(
              initialValue: _selectedPeriod,
              icon: Icon(
                PiconsRegular.caretDown,
                size: 16,
                color: _palette.textSecondary,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: Icon(
                    PiconsRegular.calendar,
                    size: 18,
                    color: _palette.brand,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),
              ),
              dropdownColor: _palette.inputFill,
              style: AppTypography.bodyLarge.copyWith(
                color: _palette.textPrimary,
              ),
              items: [
                for (final period in BudgetPeriod.values)
                  DropdownMenuItem(
                    value: period,
                    child: Text(period.displayName),
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
      padding: const EdgeInsets.only(top: AppSpacing.smd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.smd,
        ),
        decoration: BoxDecoration(
          color: _palette.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
        ),
        child: Row(
          children: [
            Icon(PiconsRegular.arrowsClockwise, color: _palette.brand),
            const SizedBox(width: AppSpacing.smd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.budgets.form.rollover,
                    style: AppTypography.bodyMedium.copyWith(
                      color: _palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    t.budgets.form.rolloverDetail,
                    style: AppTypography.bodySmall.copyWith(
                      color: _palette.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _rolloverEnabled,
              onChanged: _onRolloverChanged,
              activeThumbColor: _palette.brand,
              activeTrackColor: _palette.brand.withAlpha(0x40),
              inactiveThumbColor: _palette.toggleKnob,
              inactiveTrackColor: _palette.toggleTrack,
            ),
          ],
        ),
      ),
    );
  }

  // -- Submit Button --
  Widget _buildSubmitButton(BudgetState state) {
    final label = isEditing ? t.common.save : t.budgets.form.add;
    final isLoading = state is BudgetLoading;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg),
      child: GestureDetector(
        onTap: isLoading ? null : _submit,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            color: isLoading
                ? _palette.brandFill.withAlpha(0x80)
                : _palette.brandFill,
            borderRadius: _buttonRadius,
          ),
          alignment: Alignment.center,
          child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: _palette.onBrandFill,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  label,
                  style: AppTypography.titleMedium.copyWith(
                    color: _palette.onBrandFill,
                  ),
                ),
        ),
      ),
    );
  }

  // -- Form --
  Widget _buildForm(BudgetState state) {
    final title = isEditing ? t.budgets.form.edit : t.budgets.form.add;

    return Scaffold(
      backgroundColor: _palette.bg,
      appBar: _buildTopBar(title),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
      padding: const EdgeInsets.only(top: AppSpacing.smd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLabel(label),
          const SizedBox(height: AppSpacing.sm),
          ShimmerBox.rectangle(
            width: double.infinity,
            height: 52,
            borderRadius: AppSpacing.radiusControl,
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
    final title = isEditing ? t.budgets.form.edit : t.budgets.form.add;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: _palette.bg,
        appBar: _buildTopBar(title),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldShimmer(t.budgets.form.amount),
                _buildFieldShimmer(t.budgets.form.name),
                _buildFieldShimmer(t.budgets.form.period),
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
