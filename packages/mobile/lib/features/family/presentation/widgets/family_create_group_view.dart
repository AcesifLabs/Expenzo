import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/router/family_route.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/utils/amount_input.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';

import '../bloc/family_bloc.dart';
import '../bloc/family_event.dart';
import '../bloc/family_state.dart';
import '../helpers/family_form_validators.dart';
import 'family_bottom_button.dart';
import 'family_icon_header.dart';

/// Frame `FamilyCreateGroup`: shown on Settings → Family group when the
/// user is in no group. The group's Currency is the user's.
class FamilyCreateGroupView extends StatefulWidget {
  const FamilyCreateGroupView({super.key});

  @override
  State<FamilyCreateGroupView> createState() => _FamilyCreateGroupViewState();
}

class _FamilyCreateGroupViewState extends State<FamilyCreateGroupView> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _budget = TextEditingController();

  void _onCreated(BuildContext context, FamilyState _) {
    // The Invite screen makes the first code when it opens.
    context.pushReplacement(FamilyRoute.invite.location);
  }

  void _submit() {
    if (!(_form.currentState?.validate() ?? false)) return;
    context.read<FamilyBloc>().add(
      FamilyCreateRequested(
        name: _name.text.trim(),
        monthlyBudget: parseAmountInput(_budget.text),
      ),
    );
  }

  void _openJoin() => context.push(FamilyRoute.join.location);

  String? _validateName(String? value) => validateGroupName(value ?? '');

  String? _validateBudget(String? value) => validateMonthlyBudget(value ?? '');

  /// Name and budget fields, the Currency note and the join link.
  List<Widget> _buildFields(BuildContext context) {
    final createT = t.family.create;
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final currency = CurrencyFormatter.current.value;

    return [
      TextFormField(
        controller: _name,
        textCapitalization: TextCapitalization.words,
        inputFormatters: [
          LengthLimitingTextInputFormatter(AppConstants.groupNameMaxLength),
        ],
        decoration: InputDecoration(
          labelText: createT.nameLabel,
          hintText: createT.nameHint,
        ),
        validator: _validateName,
      ),
      const SizedBox(height: AppSpacing.md),
      TextFormField(
        controller: _budget,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: createT.budgetLabel,
          prefixText: currency.symbol,
        ),
        validator: _validateBudget,
      ),
      const SizedBox(height: AppSpacing.sm),
      Text(
        createT.currencyNote(code: currency.code),
        style: textTheme.bodySmall?.copyWith(color: palette.textSecondary),
      ),
      const SizedBox(height: AppSpacing.md),
      Center(
        child: TextButton(
          style: TextButton.styleFrom(
            minimumSize: const Size(0, AppSpacing.minTapTarget),
          ),
          onPressed: _openJoin,
          child: Text(createT.haveCode),
        ),
      ),
    ];
  }

  @override
  void dispose() {
    _name.dispose();
    _budget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final createT = t.family.create;

    return BlocListener<FamilyBloc, FamilyState>(
      listenWhen: (a, b) =>
          b.lastAction == FamilyAction.created && a.lastAction != b.lastAction,
      listener: _onCreated,
      child: Column(
        children: [
          Expanded(
            child: Form(
              key: _form,
              child: ListView(
                padding: AppSpacing.pagePadding,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  FamilyIconHeader(
                    icon: PiconsRegular.usersThree,
                    heading: createT.heading,
                    body: createT.body,
                  ),
                  ..._buildFields(context),
                ],
              ),
            ),
          ),
          BlocSelector<FamilyBloc, FamilyState, bool>(
            selector: (state) => state.busy,
            builder: (context, busy) => FamilyBottomButton(
              label: createT.submit,
              busy: busy,
              onPressed: _submit,
            ),
          ),
        ],
      ),
    );
  }
}
