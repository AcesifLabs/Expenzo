import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/router/app_routes.dart';
import 'package:expense_tracker/core/router/refresh_on_auth_change.dart';
import 'package:expense_tracker/features/auth/domain/entities/user.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import '../../support/pump_localized.dart';

class _MockAuthBloc extends Mock implements AuthBloc {}

/// Runs the real redirect and refresh wiring end to end, so timing between
/// auth changes and navigation is covered, not just the redirect decision.
void main() {
  testWidgets('a sync conflict opens its page and leaves it once resolved', (
    tester,
  ) async {
    const user = User(uid: 'u1');
    final authBloc = _MockAuthBloc();
    final states = StreamController<AuthState>.broadcast();
    addTearDown(states.close);
    AuthState current = const Unauthenticated();
    when(() => authBloc.state).thenAnswer((_) => current);
    when(() => authBloc.stream).thenAnswer((_) => states.stream);
    when(() => authBloc.close()).thenAnswer((_) async {});

    final router = GoRouter(
      initialLocation: '/',
      redirect: authRedirect,
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Text('home')),
        GoRoute(
          path: '/sync-conflict',
          builder: (_, _) => const Text('conflict'),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        child: RefreshOnAuthChange(
          enabled: true,
          onAuthChanged: router.refresh,
          child: translated(MaterialApp.router(routerConfig: router)),
        ),
      ),
    );
    expect(find.text('home'), findsOneWidget);

    Future<void> emit(AuthState state) async {
      current = state;
      states.add(state);
      await tester.pumpAndSettle();
    }

    await emit(const AuthSyncConflictPending(user));
    expect(find.text('conflict'), findsOneWidget);

    // SyncConflictPage re-checks auth once the user picks an option.
    await emit(const AuthLoading());
    expect(find.text('conflict'), findsOneWidget);

    await emit(const Authenticated(user));
    expect(find.text('home'), findsOneWidget);
    expect(find.text('conflict'), findsNothing);
  });
}
