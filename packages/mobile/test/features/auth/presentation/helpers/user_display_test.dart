import 'package:flutter_test/flutter_test.dart';

import 'package:expense_tracker/features/auth/domain/entities/user.dart';
import 'package:expense_tracker/features/auth/presentation/helpers/user_display.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.en));

  group('userFirstName', () {
    test('takes the first word of a full name', () {
      expect(
        userFirstName(const User(uid: 'u', displayName: 'Sam Rahman')),
        'Sam',
      );
    });

    test('is null for a blank name', () {
      expect(userFirstName(const User(uid: 'u', displayName: '  ')), isNull);
      expect(userFirstName(const User(uid: 'u')), isNull);
    });
  });

  group('userInitial', () {
    test('comes from the name', () {
      expect(userInitial(const User(uid: 'u', displayName: 'sam')), 'S');
    });

    test('falls back to the email, then to ?', () {
      expect(userInitial(const User(uid: 'u', email: 'zed@x.com')), 'Z');
      expect(
        userInitial(const User(uid: 'u', displayName: ' ', email: '')),
        '?',
      );
    });

    test('keeps a Bangla first letter as one grapheme', () {
      expect(userInitial(const User(uid: 'u', displayName: 'ক্ষমা')), 'ক্ষ');
    });
  });

  group('userDisplayName', () {
    test('uses the trimmed name', () {
      expect(
        userDisplayName(const User(uid: 'u', displayName: ' Sam ')),
        'Sam',
      );
    });

    test("falls back to the email's local part", () {
      expect(userDisplayName(const User(uid: 'u', email: 'sam@x.com')), 'sam');
    });

    test('falls back to the generic label', () {
      expect(userDisplayName(const User(uid: 'u')), t.dashboard.userFallback);
    });
  });
}
