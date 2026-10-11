import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;

import 'app_routes.dart';
import 'navigation_history.dart';

/// Wires the route tree and the auth redirect into a single [GoRouter].
///
/// Route definitions live in [buildAppRoutes]; the redirect lives in
/// [authRedirect] — see `app_routes.dart`.
class AppRouter {
  final GoRouter config;
  final NavigationHistory history;

  AppRouter._(this.config, this.history);

  factory AppRouter({required GlobalKey<NavigatorState> navigatorKey}) {
    final history = NavigationHistory();
    final config = GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: '/',
      routes: buildAppRoutes(),
      redirect: authRedirect,
      observers: [history],
    );
    history.bindRouter(config);
    _registerHistory(history);

    return AppRouter._(config, history);
  }

  // The app root can be remounted, so replace any previous instance.
  static void _registerHistory(NavigationHistory history) {
    if (di.getIt.isRegistered<NavigationHistory>()) {
      di.getIt.unregister<NavigationHistory>();
    }
    di.getIt.registerSingleton<NavigationHistory>(history);
  }
}
