import 'package:flutter_test/flutter_test.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/router/app_root_tab.dart';

void main() {
  test('home is the bare root and the other tabs use the tab query', () {
    expect(AppRootTab.home.location, '/');
    expect(AppRootTab.activity.location, '/?tab=activity');
    expect(AppRootTab.budgets.location, '/?tab=budgets');
    expect(AppRootTab.reports.location, '/?tab=reports');
  });

  test('every tab survives a round trip through its location', () {
    for (final tab in AppRootTab.values) {
      expect(AppRootTab.fromUri(Uri.parse(tab.location)), tab);
    }
  });

  test('missing, empty or unknown tab values fall back to home', () {
    for (final location in ['/', '/?tab=', '/?tab=settings', '/?tab=HOME']) {
      expect(AppRootTab.fromUri(Uri.parse(location)), AppRootTab.home);
    }
  });

  test('other query parameters do not change the tab', () {
    expect(
      AppRootTab.fromUri(Uri.parse('/?from=push&tab=budgets')),
      AppRootTab.budgets,
    );
  });

  test('the old Scan tab link falls back to home (docs/adr/0006)', () {
    expect(AppRootTab.fromUri(Uri.parse('/?tab=scan')), AppRootTab.home);
  });

  test('tabs are in bottom-bar order', () {
    expect(AppRootTab.values, [
      AppRootTab.home,
      AppRootTab.activity,
      AppRootTab.budgets,
      AppRootTab.reports,
    ]);
  });

  test('fromName maps every tab name to its tab', () {
    for (final tab in AppRootTab.values) {
      expect(AppRootTab.fromName(tab.name), tab);
    }
  });

  test('fromName falls back to home for missing or unknown names', () {
    for (final name in [null, '', 'scan', 'HOME']) {
      expect(AppRootTab.fromName(name), AppRootTab.home);
    }
  });

  test('each tab has the nav bar icons', () {
    expect(AppRootTab.values.map((tab) => tab.icon), [
      PiconsRegular.house,
      PiconsRegular.listDashes,
      PiconsRegular.wallet,
      PiconsRegular.chartBar,
    ]);
    expect(AppRootTab.values.map((tab) => tab.selectedIcon), [
      PiconsFill.house,
      PiconsFill.listDashes,
      PiconsFill.wallet,
      PiconsFill.chartBar,
    ]);
  });
}
