import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/router/refresh_on_auth_change.dart';
import 'package:expense_tracker/features/auth/domain/entities/user.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';

class _MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  testWidgets('does not create the auth bloc before start-up finishes', (
    tester,
  ) async {
    // Mirrors ExpenzoApp before DI is ready: creating AuthBloc throws.
    var created = false;
    await tester.pumpWidget(
      BlocProvider<AuthBloc>(
        create: (_) {
          created = true;
          throw StateError('AuthBloc is not registered inside GetIt.');
        },
        child: RefreshOnAuthChange(
          enabled: false,
          onAuthChanged: () {},
          child: const SizedBox(),
        ),
      ),
    );

    expect(created, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('refreshes when a sync conflict starts or ends, once enabled', (
    tester,
  ) async {
    final authBloc = _MockAuthBloc();
    final states = StreamController<AuthState>.broadcast();
    addTearDown(states.close);
    when(() => authBloc.stream).thenAnswer((_) => states.stream);
    when(() => authBloc.state).thenReturn(const AuthInitial());
    when(() => authBloc.close()).thenAnswer((_) async {});
    var refreshes = 0;
    const user = User(uid: 'u1');

    Widget app({required bool enabled}) => BlocProvider<AuthBloc>.value(
      value: authBloc,
      child: RefreshOnAuthChange(
        enabled: enabled,
        onAuthChanged: () => refreshes++,
        child: const SizedBox(),
      ),
    );

    await tester.pumpWidget(app(enabled: false));
    states.add(const AuthSyncConflictPending(user));
    await tester.pump();
    expect(refreshes, 0);

    await tester.pumpWidget(app(enabled: true));
    // Plain sign-in leaves navigation to LoginPage.
    states.add(const Authenticated(user));
    await tester.pump();
    expect(refreshes, 0);

    states.add(const AuthSyncConflictPending(user));
    await tester.pump();
    expect(refreshes, 1);

    // Resolving goes through loading first; that alone ends nothing.
    states.add(const AuthLoading());
    await tester.pump();
    expect(refreshes, 1);

    states.add(const Authenticated(user));
    await tester.pump();
    expect(refreshes, 2);
  });
}
