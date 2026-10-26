import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/router/app_routes.dart';
import 'package:expense_tracker/features/auth/domain/entities/user.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';

void main() {
  const user = User(uid: 'u1');

  test('waits while auth is still loading', () {
    expect(authRedirectFor(const AuthLoading(), '/sync-conflict'), isNull);
  });

  test('sends a pending conflict to the conflict page', () {
    expect(
      authRedirectFor(const AuthSyncConflictPending(user), '/'),
      '/sync-conflict',
    );
    expect(
      authRedirectFor(const AuthSyncConflictPending(user), '/sync-conflict'),
      isNull,
    );
  });

  test('leaves the conflict page once the conflict is resolved', () {
    expect(authRedirectFor(const Authenticated(user), '/sync-conflict'), '/');
    expect(authRedirectFor(const Unauthenticated(), '/sync-conflict'), '/');
  });

  test('sign-in is left to the login page, not redirected', () {
    expect(authRedirectFor(const Authenticated(user), '/login'), isNull);
    expect(authRedirectFor(const Unauthenticated(), '/login'), isNull);
  });

  test('keeps signed-out users out of Family group screens', () {
    for (final location in ['/settings/family', '/settings/family/members']) {
      expect(authRedirectFor(const Unauthenticated(), location), '/settings');
      expect(authRedirectFor(const Authenticated(user), location), isNull);
    }
    expect(authRedirectFor(const AuthInitial(), '/settings/family'), isNull);
  });
}
