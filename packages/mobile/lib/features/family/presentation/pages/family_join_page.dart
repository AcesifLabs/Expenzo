import 'package:expense_tracker/core/router/settings_route.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';
import 'package:expense_tracker/shared/presentation/widgets/offline_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';

import '../bloc/family_bloc.dart';
import '../bloc/family_event.dart';
import '../bloc/family_state.dart';
import '../helpers/family_failure_listener.dart';
import '../helpers/family_form_validators.dart';
import '../widgets/family_bottom_button.dart';
import '../widgets/family_icon_header.dart';

class FamilyJoinPage extends StatefulWidget {
  const FamilyJoinPage({super.key});

  @override
  State<FamilyJoinPage> createState() => _FamilyJoinPageState();
}

class _FamilyJoinPageState extends State<FamilyJoinPage> {
  final _code = TextEditingController();
  var _codeIsValid = false;

  void _submit() =>
      context.read<FamilyBloc>().add(FamilyJoinRequested(_code.text));

  void _onCodeChanged(String code) =>
      setState(() => _codeIsValid = isValidInviteCode(code));

  void _onJoined(BuildContext context, FamilyState state) {
    final messenger = ScaffoldMessenger.of(context)..clearSnackBars();
    final router = GoRouter.of(context);
    final joinT = t.family.join;
    router.go(SettingsRoute.family.location);
    if (state.lastAction == FamilyAction.joinedSyncOff) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(joinT.syncOff),
          action: SnackBarAction(
            label: t.settings.sync.title,
            onPressed: () => router.push(SettingsRoute.sync.location),
          ),
        ),
      );

      return;
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(joinT.joined(name: state.myGroup?.group.name ?? '')),
      ),
    );
  }

  bool _justJoined(FamilyState previous, FamilyState current) {
    const joined = {FamilyAction.joined, FamilyAction.joinedSyncOff};

    return joined.contains(current.lastAction) &&
        previous.lastAction != current.lastAction;
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final joinT = t.family.join;
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;

    return MultiBlocListener(
      listeners: [
        BlocListener<FamilyBloc, FamilyState>(
          listenWhen: familyStateNeedsListener,
          listener: handleFamilyState,
        ),
        BlocListener<FamilyBloc, FamilyState>(
          listenWhen: _justJoined,
          listener: _onJoined,
        ),
      ],
      child: Scaffold(
        body: AppScaffold(
          title: joinT.title,
          leading: const AppBackButton(),
          child: OfflineGate(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: AppSpacing.pagePadding,
                    children: [
                      FamilyIconHeader(
                        icon: PiconsRegular.ticket,
                        heading: joinT.title,
                        body: joinT.body,
                      ),
                      TextField(
                        controller: _code,
                        autofocus: true,
                        maxLength: 6,
                        textCapitalization: TextCapitalization.characters,
                        textAlign: TextAlign.center,
                        style: textTheme.headlineMedium?.copyWith(
                          fontFeatures: AppTypography.tabularFigures,
                          letterSpacing: AppSpacing.xs,
                        ),
                        inputFormatters: [_InviteCodeFormatter()],
                        decoration: InputDecoration(
                          labelText: joinT.codeLabel,
                          errorText: _code.text.length == 6 && !_codeIsValid
                              ? joinT.codeInvalid
                              : null,
                        ),
                        onChanged: _onCodeChanged,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        joinT.currencyNote(
                          code: CurrencyFormatter.current.value.code,
                        ),
                        style: textTheme.bodySmall?.copyWith(
                          color: palette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                BlocSelector<FamilyBloc, FamilyState, bool>(
                  selector: (state) => state.busy,
                  builder: (context, busy) => FamilyBottomButton(
                    label: joinT.submit,
                    busy: busy,
                    onPressed: _codeIsValid ? _submit : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InviteCodeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = normalizeInviteCode(newValue.text);

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
