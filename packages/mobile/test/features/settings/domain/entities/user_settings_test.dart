import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/constants/first_day_of_week.dart';
import 'package:expense_tracker/features/settings/domain/entities/notification_toggle.dart';
import 'package:expense_tracker/features/settings/domain/entities/user_settings.dart';

import '../../../../support/factories/user_settings_factory.dart';

void main() {
  final base = UserSettings(
    currencyCode: 'BDT',
    emailFetchLimit: 100,
    notificationsEnabled: true,
    theme: 'system',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  test('defaults: weekly summary off, the other three on', () {
    expect(base.budgetOverAlertsEnabled, isTrue);
    expect(base.budgetNearLimitAlertsEnabled, isTrue);
    expect(base.weeklySummaryEnabled, isFalse);
    expect(base.recurringRemindersEnabled, isTrue);
  });

  test('isEnabled follows each toggle while the master switch is on', () {
    expect(base.isEnabled(NotificationToggle.budgetOver), isTrue);
    expect(base.isEnabled(NotificationToggle.budgetNearLimit), isTrue);
    expect(base.isEnabled(NotificationToggle.weeklySummary), isFalse);
    expect(base.isEnabled(NotificationToggle.recurringReminders), isTrue);
  });

  test(
    'isEnabled is false for every toggle while the master switch is off',
    () {
      final off = makeUserSettings(
        notificationsEnabled: false,
        weeklySummaryEnabled: true,
      );

      for (final toggle in NotificationToggle.values) {
        expect(off.isEnabled(toggle), isFalse, reason: toggle.name);
      }
    },
  );

  test('withToggle changes only the matching field', () {
    expect(
      base.withToggle(NotificationToggle.budgetOver, false),
      base.copyWith(budgetOverAlertsEnabled: false),
    );
    expect(
      base.withToggle(NotificationToggle.budgetNearLimit, false),
      base.copyWith(budgetNearLimitAlertsEnabled: false),
    );
    expect(
      base.withToggle(NotificationToggle.weeklySummary, true),
      base.copyWith(weeklySummaryEnabled: true),
    );
    expect(
      base.withToggle(NotificationToggle.recurringReminders, false),
      base.copyWith(recurringRemindersEnabled: false),
    );
  });

  group('effectiveFirstDayOfWeek', () {
    test('while unset, follows the app language', () {
      expect(base.firstDayOfWeek, isNull);
      expect(base.effectiveFirstDayOfWeek('bn'), FirstDayOfWeek.saturday);
      expect(base.effectiveFirstDayOfWeek('en'), FirstDayOfWeek.monday);
    });

    test('a stored day wins over the language', () {
      final sunday = base.copyWith(firstDayOfWeek: FirstDayOfWeek.sunday);

      expect(sunday.effectiveFirstDayOfWeek('bn'), FirstDayOfWeek.sunday);
      expect(sunday.effectiveFirstDayOfWeek('en'), FirstDayOfWeek.sunday);
    });
  });
}
