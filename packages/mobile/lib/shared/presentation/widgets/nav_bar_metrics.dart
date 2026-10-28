import 'package:flutter/widgets.dart';

abstract final class NavBarMetrics {
  static const double height = 72;
  static const double bottomMargin = 16;

  static double clearance(BuildContext context) =>
      height + bottomMargin + MediaQuery.viewPaddingOf(context).bottom;
}
