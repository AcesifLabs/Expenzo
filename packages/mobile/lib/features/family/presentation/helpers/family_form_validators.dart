import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/utils/amount_input.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

/// Invite Code characters: A–Z and 2–9 without I, L, O (the backend's
/// `INVITE_CODE_ALPHABET`).
final _inviteCode = RegExp(r'^[A-HJKMNP-Z2-9]{6}$');

String? validateGroupName(String value) {
  final name = value.trim();

  return name.isEmpty || name.length > AppConstants.groupNameMaxLength
      ? t.family.create.nameRequired
      : null;
}

/// Optional: empty is fine; otherwise an amount above zero.
String? validateMonthlyBudget(String value) {
  if (value.trim().isEmpty) return null;
  final amount = parseAmountInput(value);

  return amount == null || amount <= 0 ? t.family.create.budgetInvalid : null;
}

/// What a user types becomes a code: no spaces, upper case.
String normalizeInviteCode(String raw) =>
    raw.replaceAll(RegExp(r'\s'), '').toUpperCase();

bool isValidInviteCode(String code) => _inviteCode.hasMatch(code);
