import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class NavigationHistory extends NavigatorObserver {
  final List<Route<dynamic>> _routes = [];
  GoRouter? _router;

  bool get canGoBack => _routes.length > 1;

  List<String?> get locations => _routes.map(_locationOf).toList();

  void bindRouter(GoRouter router) => _router = router;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PageRoute) _routes.add(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.remove(route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.remove(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final index = oldRoute == null ? -1 : _routes.indexOf(oldRoute);
    final replacement = newRoute is PageRoute ? newRoute : null;

    if (index == -1) {
      if (replacement != null) _routes.add(replacement);

      return;
    }

    if (replacement != null) {
      _routes[index] = replacement;
    } else {
      _routes.removeAt(index);
    }
  }

  String? _locationOf(Route<dynamic> route) {
    final matchList = _router?.routerDelegate.currentConfiguration;
    final settings = route.settings;
    if (matchList == null || settings is! Page<Object?>) return null;

    final baseMatches = matchList.matches
        .where((match) => match is! ImperativeRouteMatch)
        .toList();

    for (final match in matchList.matches) {
      if (match.pageKey != settings.key) continue;
      if (match is ImperativeRouteMatch) return match.matches.uri.toString();

      if (identical(match, baseMatches.lastOrNull)) {
        return matchList.uri.toString();
      }

      return match.matchedLocation;
    }

    return null;
  }
}
