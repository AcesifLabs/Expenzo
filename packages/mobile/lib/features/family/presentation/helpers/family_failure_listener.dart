import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/router/settings_route.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/family_bloc.dart';
import '../bloc/family_event.dart';
import '../bloc/family_state.dart';

/// For every Family page's `BlocListener`: a new failure, or the group
/// going away.
bool familyStateNeedsListener(FamilyState previous, FamilyState current) =>
    (current.failure != null && current.failure != previous.failure) ||
    (current.lastAction == FamilyAction.removedFromGroup &&
        previous.lastAction != FamilyAction.removedFromGroup);

/// Shows a failure, or leaves for Settings when signed out or no longer in
/// the group.
void handleFamilyState(BuildContext context, FamilyState state) {
  final messenger = ScaffoldMessenger.of(context)..clearSnackBars();
  final router = GoRouter.of(context);
  if (state.lastAction == FamilyAction.removedFromGroup) {
    messenger.showSnackBar(SnackBar(content: Text(t.family.errors.notInGroup)));
    router.go(SettingsRoute.rootLocation);

    return;
  }
  final failure = state.failure;
  if (failure == null) return;
  context.read<FamilyBloc>().add(const FamilyFailureCleared());
  if (failure is AuthFailure) {
    messenger.showSnackBar(
      SnackBar(content: Text(t.family.errors.signInRequired)),
    );
    router.go(SettingsRoute.rootLocation);

    return;
  }
  messenger.showSnackBar(
    SnackBar(
      content: Text(failureText(failure)),
      action: failure.errorCode == FailureCodes.currencyMismatch
          ? SnackBarAction(
              label: t.settings.currency,
              onPressed: () => router.go(SettingsRoute.currency.location),
            )
          : null,
    ),
  );
}
