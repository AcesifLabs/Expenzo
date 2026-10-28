import 'package:flutter/widgets.dart';
import 'package:picons/picons.dart';

enum AppRootTab {
  home,
  activity,
  budgets,
  reports;

  static const queryKey = 'tab';

  String get location => this == home ? '/' : '/?$queryKey=$name';

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

  static AppRootTab fromName(String? name) => values.asNameMap()[name] ?? home;

  static AppRootTab fromUri(Uri uri) => fromName(uri.queryParameters[queryKey]);
}
