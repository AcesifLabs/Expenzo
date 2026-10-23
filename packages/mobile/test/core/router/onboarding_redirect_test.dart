import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/router/app_routes.dart';
import 'package:expense_tracker/features/auth/domain/entities/user.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/settings/domain/entities/user_settings.dart';

void main() {
  UserSettings settings(bool? onboardingCompleted) => UserSettings(
    currencyCode: 'BDT',
    emailFetchLimit: 100,
    notificationsEnabled: true,
    theme: 'system',
    onboardingCompleted: onboardingCompleted,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  test('waits until settings are loaded', () {
    expect(onboardingRedirectFor(null, '/'), isNull);
  });

  test('sends a user who has not done onboarding there', () {
    expect(onboardingRedirectFor(settings(false), '/'), '/onboarding');
    expect(onboardingRedirectFor(settings(false), '/settings'), '/onboarding');
    expect(onboardingRedirectFor(settings(false), '/onboarding'), isNull);
  });

  test('a finished user may open onboarding again and is not redirected', () {
    expect(onboardingRedirectFor(settings(true), '/onboarding'), isNull);
    expect(onboardingRedirectFor(settings(true), '/'), isNull);
  });

  test('an unresolved flag never redirects', () {
    expect(onboardingRedirectFor(settings(null), '/'), isNull);
  });

  group('redirectFor', () {
    const conflict = AuthSyncConflictPending(User(uid: 'u1'));

    test('a pending sync conflict wins over onboarding', () {
      expect(redirectFor(conflict, settings(false), '/'), '/sync-conflict');
      expect(
        redirectFor(conflict, settings(false), '/onboarding'),
        '/sync-conflict',
      );
    });

    test('stays on /sync-conflict while onboarding is not done', () {
      expect(redirectFor(conflict, settings(false), '/sync-conflict'), isNull);
    });

    test('sends a user with no conflict to onboarding', () {
      expect(
        redirectFor(const Unauthenticated(), settings(false), '/'),
        '/onboarding',
      );
    });
  });
}
