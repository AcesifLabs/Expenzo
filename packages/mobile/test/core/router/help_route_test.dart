import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/router/help_route.dart';
import 'package:expense_tracker/core/router/settings_route.dart';

void main() {
  test('each route sits under /settings/help', () {
    expect(SettingsRoute.help.location, '/settings/help');
    expect(HelpRoute.faq.location, '/settings/help/faq');
    for (final route in HelpRoute.values) {
      expect(route.location, '/settings/help/${route.path}');
    }
  });

  test('no two routes share a path', () {
    final paths = HelpRoute.values.map((route) => route.path);

    expect(paths.toSet(), hasLength(HelpRoute.values.length));
  });
}
