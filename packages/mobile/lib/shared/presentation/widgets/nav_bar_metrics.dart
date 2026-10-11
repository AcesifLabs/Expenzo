import 'package:flutter/widgets.dart';

/// Size of the floating bottom navigation bar in the app shell.
///
/// Tab pages draw behind it (the shell uses `extendBody`), so anything that
/// must stay visible at the bottom of a tab, like a floating button or the
/// end of a list, has to clear [clearance].
abstract final class NavBarMetrics {
  static const double height = 72;
  static const double bottomMargin = 16;

  /// Distance from the bottom of the screen to the top of the bar,
  /// including the system gesture area the bar sits above.
  static double clearance(BuildContext context) =>
      height + bottomMargin + MediaQuery.viewPaddingOf(context).bottom;
}
