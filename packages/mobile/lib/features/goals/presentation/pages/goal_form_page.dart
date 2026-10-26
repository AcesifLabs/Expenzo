import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:picons/picons.dart';

import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/amount_input.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_empty_state.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';

import '../../domain/entities/goal.dart';
import '../bloc/goal_form_bloc.dart';
import '../bloc/goal_form_event.dart';
import '../bloc/goal_form_state.dart';

class GoalFormPage extends StatefulWidget {
  final String? goalId;

  const GoalFormPage({super.key, this.goalId});

  @override
  State<GoalFormPage> createState() => _GoalFormPageState();
}

class _GoalFormPageState extends State<GoalFormPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _target = TextEditingController();
  final _saved = TextEditingController();
  final _monthly = TextEditingController();
  DateTime? _date;
  bool _filled = false;
  bool get _isCreate => widget.goalId == null;

  @override
  void initState() {
    super.initState();

    final state = context.read<GoalFormBloc>().state;
    final goal = state.goal;
    if (state.status == GoalFormStatus.ready && goal != null) _fill(goal);
  }

  void _fill(Goal goal) {
    _filled = true;
    _name.text = goal.name;
    _target.text = CurrencyFormatter.formatInput(goal.targetAmount);
    _saved.text = CurrencyFormatter.formatInput(goal.savedAmount);
    final monthly = goal.monthlyContribution;
    _monthly.text = monthly == null
        ? ''
        : CurrencyFormatter.formatInput(monthly);
    _date = goal.targetDate;
  }

  void _onState(BuildContext context, GoalFormState state) {
    final goal = state.goal;
    if (state.status == GoalFormStatus.ready && goal != null && !_filled) {
      setState(() => _fill(goal));
    }
    final messenger = ScaffoldMessenger.of(context);
    final formT = t.goals.form;
    final message = switch (state.status) {
      GoalFormStatus.saved => formT.savedMessage,
      GoalFormStatus.created => formT.createdMessage,
      GoalFormStatus.deleted => formT.deleted,
      GoalFormStatus.notFound => t.common.errors.notFound,
      _ => null,
    };
    if (message != null) {
      context.pop();
      messenger
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(message)));

      return;
    }
    final error = state.errorText;
    if (error != null) {
      messenger
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(error)));
    }
  }

  String? _validateName(String? value) =>
      (value ?? '').trim().isEmpty ? t.goals.errors.nameRequired : null;

  String? _validateTarget(String? value) {
    final amount = parseAmountInput(value ?? '');
    if ((value ?? '').trim().isNotEmpty && amount == null) {
      return t.goals.errors.amountTooLarge;
    }

    return amount == null || amount <= 0 ? t.goals.errors.targetPositive : null;
  }

  String? _validateOptional(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    final amount = parseAmountInput(text);

    return amount == null || amount > AppConstants.maxAmount
        ? t.goals.errors.amountTooLarge
        : null;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? tomorrow,
      firstDate: AppConstants.pickerFirstDate,
      lastDate: DateTime(now.year + 10, now.month, now.day),
    );

    if (picked != null && mounted) setState(() => _date = picked);
  }

  void _clearDate() => setState(() => _date = null);

  void _save(GoalFormState state) {
    if (!(_form.currentState?.validate() ?? false)) return;
    final monthlyText = _monthly.text.trim();
    final goal = (state.goal ?? const Goal(name: '', targetAmount: 0)).copyWith(
      name: _name.text.trim(),
      targetAmount: parseAmountInput(_target.text),
      savedAmount: _isCreate ? 0 : parseAmountInput(_saved.text) ?? 0,
      targetDate: _date,
      monthlyContribution: monthlyText.isEmpty
          ? null
          : parseAmountInput(monthlyText),
    );
    context.read<GoalFormBloc>().add(
      _isCreate ? GoalFormCreated(goal) : GoalFormSaved(goal),
    );
  }

  Future<void> _confirmDelete() async {
    final bloc = context.read<GoalFormBloc>();
    final formT = t.goals.form;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(formT.deleteTitle),
        content: Text(formT.deleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(t.common.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              t.common.delete,
              style: TextStyle(color: context.palette.expense),
            ),
          ),
        ],
      ),
    );
    if (confirmed ?? false) bloc.add(const GoalFormDeleted());
  }

  String? _suggestion() {
    final date = _date;
    final target = parseAmountInput(_target.text);
    if (date == null || target == null) return null;
    final saved = _isCreate ? 0.0 : parseAmountInput(_saved.text) ?? 0;
    final draft = Goal(
      name: '',
      targetAmount: target,
      savedAmount: saved,
      targetDate: date,
    );
    final months = draft.monthsLeft(DateTime.now()) ?? 0;
    if (months <= 0 || draft.remaining <= 0) return null;

    return t.goals.form.suggestMonthly(
      amount: CurrencyFormatter.format(draft.remaining / months),
    );
  }

  Widget _body(BuildContext context, GoalFormState state) {
    if (state.status == GoalFormStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == GoalFormStatus.failure && state.goal == null) {
      return AppEmptyState(
        icon: PiconsRegular.warningCircle,
        message: t.common.errors.storage,
        actionLabel: t.common.tryAgain,
        onAction: () => context.read<GoalFormBloc>().add(
          GoalFormLoaded(widget.goalId ?? ''),
        ),
      );
    }

    return Column(
      children: [
        Expanded(child: _fields(context)),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageGutter,
            AppSpacing.sm,
            AppSpacing.pageGutter,
            AppSpacing.md,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: double.infinity,
              minHeight: AppSpacing.xxl,
            ),
            child: ElevatedButton(
              onPressed: state.isBusy ? null : () => _save(state),
              child: state.status == GoalFormStatus.saving
                  ? const SizedBox.square(
                      dimension: AppSpacing.md,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(t.common.save),
            ),
          ),
        ),
      ],
    );
  }

  Widget _fields(BuildContext context) {
    final formT = t.goals.form;
    final textTheme = Theme.of(context).textTheme;
    final amountKeyboard = const TextInputType.numberWithOptions(decimal: true);
    final date = _date;

    return Form(
      key: _form,
      child: ListView(
        padding: AppSpacing.pagePadding,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: formT.name),
            validator: _validateName,
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            controller: _target,
            keyboardType: amountKeyboard,
            decoration: InputDecoration(labelText: formT.target),
            validator: _validateTarget,
          ),
          if (!_isCreate) ...[
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _saved,
              keyboardType: amountKeyboard,
              decoration: InputDecoration(labelText: formT.saved),
              validator: _validateOptional,
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(formT.targetDate, style: textTheme.bodyLarge),
            subtitle: Text(
              date == null ? formT.noDate : DateFormat.yMMMd().format(date),
            ),
            trailing: date == null
                ? null
                : TextButton(
                    onPressed: _clearDate,
                    child: Text(formT.clearDate),
                  ),
            onTap: () => unawaited(_pickDate()),
          ),
          const SizedBox(height: AppSpacing.sm),

          ListenableBuilder(
            listenable: Listenable.merge([_target, _saved]),
            builder: (context, _) => TextFormField(
              controller: _monthly,
              keyboardType: amountKeyboard,
              decoration: InputDecoration(
                labelText: formT.monthly,
                helperText: _suggestion(),
              ),
              validator: _validateOptional,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    _saved.dispose();
    _monthly.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formT = t.goals.form;

    return BlocConsumer<GoalFormBloc, GoalFormState>(
      listenWhen: (a, b) =>
          a.status != b.status ||
          (b.errorText != null && a.errorText != b.errorText),
      listener: _onState,
      builder: (context, state) => Scaffold(
        body: AppScaffold(
          title: _isCreate ? formT.createTitle : formT.title,
          leading: const AppBackButton(),
          actions: [
            if (!_isCreate && state.goal != null)
              IconButton(
                icon: Icon(PiconsRegular.trash, color: context.palette.expense),
                tooltip: t.common.delete,
                onPressed: state.isBusy
                    ? null
                    : () => unawaited(_confirmDelete()),
              ),
          ],
          child: _body(context, state),
        ),
      ),
    );
  }
}
