import 'package:flutter/widgets.dart';
import 'package:picons/picons.dart';

/// Root screens hosted as tabs inside the app shell at `/`.
///
/// The selected tab lives in the `tab` query parameter so any screen can
/// navigate straight to a root screen with `context.go(tab.location)`.
enum AppRootTab {
  home,
  activity,
  budgets,
  reports;

  static const queryKey = 'tab';

  String get location => this == home ? '/' : '/?$queryKey=$name';

  /// The nav bar icon, also shown on the Home page settings screen.
  IconData get icon => switch (this) {
    home => PiconsRegular.house,
    activity => PiconsRegular.listDashes,
    budgets => PiconsRegular.wallet,
    reports => PiconsRegular.chartBar,
  };

  IconData get selectedIcon => switch (this) {
    home => PiconsFill.house,
    activity => PiconsFill.listDashes,
    budgets => PiconsFill.wallet,
    reports => PiconsFill.chartBar,
  };

  /// The tab named [name], or home for a missing or unknown name.
  static AppRootTab fromName(String? name) => values.asNameMap()[name] ?? home;

  static AppRootTab fromUri(Uri uri) => fromName(uri.queryParameters[queryKey]);
}
