import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/router/app_root_tab.dart';
import 'package:expense_tracker/core/router/cold_start_location.dart';

void main() {
  String? locationFor(String current, AppRootTab homeTab) =>
      coldStartLocation(current: Uri.parse(current), homeTab: homeTab);

  test('home as the home tab stays put', () {
    expect(locationFor('/', AppRootTab.home), isNull);
  });

  test('a bare root opens the chosen tab', () {
    expect(locationFor('/', AppRootTab.activity), '/?tab=activity');
    expect(locationFor('/', AppRootTab.budgets), '/?tab=budgets');
    expect(locationFor('/', AppRootTab.reports), '/?tab=reports');
  });

  test('a link to a tab wins', () {
    expect(locationFor('/?tab=activity', AppRootTab.budgets), isNull);
  });

  test('other screens win, including onboarding', () {
    expect(locationFor('/settings', AppRootTab.budgets), isNull);
    expect(locationFor('/onboarding', AppRootTab.budgets), isNull);
  });

  test('an unrelated query on the root still opens the chosen tab', () {
    expect(locationFor('/?from=push', AppRootTab.reports), '/?tab=reports');
  });

  test('no location yet stays put', () {
    expect(
      coldStartLocation(current: Uri(), homeTab: AppRootTab.budgets),
      isNull,
    );
  });
}
