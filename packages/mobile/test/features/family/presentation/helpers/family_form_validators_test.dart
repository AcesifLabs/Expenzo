import 'package:expense_tracker/features/family/presentation/helpers/family_form_validators.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validateGroupName', () {
    test('rejects empty, blank and over-long names', () {
      for (final name in ['', '   ', 'x' * 61]) {
        expect(validateGroupName(name), t.family.create.nameRequired);
      }
    });

    test('accepts a name up to 60 characters', () {
      expect(validateGroupName('Rahman Family'), isNull);
      expect(validateGroupName('x' * 60), isNull);
    });
  });

  group('validateMonthlyBudget', () {
    test('is optional', () => expect(validateMonthlyBudget(''), isNull));

    test('rejects zero, negative, too large and text', () {
      for (final value in ['0', '-5', '99999999999', 'abc']) {
        expect(validateMonthlyBudget(value), t.family.create.budgetInvalid);
      }
    });

    test('accepts an amount, Bangla digits included', () {
      expect(validateMonthlyBudget('50000'), isNull);
      expect(validateMonthlyBudget('৫০০'), isNull);
    });
  });

  test('normalizeInviteCode trims, uppercases and removes inner spaces', () {
    expect(normalizeInviteCode(' rf4 xk2 '), 'RF4XK2');
  });

  group('isValidInviteCode', () {
    test('accepts the invite alphabet', () {
      expect(isValidInviteCode('RF4XK2'), isTrue);
      expect(isValidInviteCode('ABCH29'), isTrue);
    });

    test('rejects the wrong length and lookalikes', () {
      for (final code in [
        'RF4XK',
        'RF4XK22',
        'RF4XKI',
        'RF4XKL',
        'RF4XKO',
        'RF4XK0',
        'RF4XK1',
      ]) {
        expect(isValidInviteCode(code), isFalse, reason: code);
      }
    });
  });
}
