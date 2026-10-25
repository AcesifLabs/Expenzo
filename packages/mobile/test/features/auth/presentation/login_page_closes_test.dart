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
import 'package:expense_tracker/features/auth/presentation/pages/login_page.dart';
import '../../../support/connectivity_test_support.dart';
import '../../../support/pump_localized.dart';

class _MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  testWidgets('after signing in from Settings, the user is back on Settings', (
    tester,
  ) async {
    final authBloc = _MockAuthBloc();
    final states = StreamController<AuthState>.broadcast();
    addTearDown(states.close);
    AuthState current = const Unauthenticated();
    when(() => authBloc.state).thenAnswer((_) => current);
    when(() => authBloc.stream).thenAnswer((_) => states.stream);
    when(() => authBloc.close()).thenAnswer((_) async {});

    registerTestConnectivity();

    final router = GoRouter(
      initialLocation: '/',
      redirect: authRedirect,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => TextButton(
            onPressed: () => context.push('/settings'),
            child: const Text('home'),
          ),
          routes: [
            GoRoute(
              path: 'settings',
              builder: (context, _) => TextButton(
                onPressed: () => context.push('/login'),
                child: const Text('settings'),
              ),
            ),
            GoRoute(path: 'login', builder: (_, _) => const LoginPage()),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      BlocProvider<AuthBloc>.value(
        value: authBloc,
        // Wired as in ExpenzoApp.
        child: RefreshOnAuthChange(
          enabled: true,
          onAuthChanged: router.refresh,
          child: translated(MaterialApp.router(routerConfig: router)),
        ),
      ),
    );
    await tester.tap(find.text('home'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('settings'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginPage), findsOneWidget);

    current = const Authenticated(User(uid: 'u1', displayName: 'Sam'));
    states.add(current);
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsNothing);
    expect(find.text('settings'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
