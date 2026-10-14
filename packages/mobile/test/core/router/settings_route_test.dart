import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/router/settings_route.dart';

void main() {
  test('each route sits under /settings', () {
    expect(SettingsRoute.rootLocation, '/settings');
    expect(SettingsRoute.homePage.location, '/settings/home-page');
    expect(SettingsRoute.numberFormat.location, '/settings/number-format');
    for (final route in SettingsRoute.values) {
      expect(route.location, '/settings/${route.path}');
    }
  });

  test('no two routes share a path', () {
    final paths = SettingsRoute.values.map((route) => route.path);

    expect(paths.toSet(), hasLength(SettingsRoute.values.length));
  });
}
