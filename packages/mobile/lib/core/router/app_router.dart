import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';

/// Wires the route tree and the auth redirect into a single [GoRouter].
///
/// Route definitions live in [buildAppRoutes]; the redirect lives in
/// [authRedirect] — see `app_routes.dart`.
class AppRouter {
  final GoRouter config;

  AppRouter({required GlobalKey<NavigatorState> navigatorKey})
    : config = GoRouter(
        navigatorKey: navigatorKey,
        initialLocation: '/',
        routes: buildAppRoutes(),
        redirect: authRedirect,
      );
}
