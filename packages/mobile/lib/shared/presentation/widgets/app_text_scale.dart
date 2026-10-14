import 'package:flutter/widgets.dart';

import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/theme/scaled_text_scaler.dart';

/// Applies the Font size [factor] on top of the device text scale for
/// everything below it, capped at [AppConstants.maxTextScale].
///
/// Always wraps, also at factor 1.0, so a device scale above the cap is
/// capped too. Only text scales; icons and fixed sizes don't.
class AppTextScale extends StatelessWidget {
  final double factor;
  final Widget child;

  const AppTextScale({super.key, required this.factor, required this.child});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return MediaQuery(
      data: mediaQuery.copyWith(
        textScaler: ScaledTextScaler(
          mediaQuery.textScaler,
          factor,
        ).clamp(maxScaleFactor: AppConstants.maxTextScale),
      ),
      child: child,
    );
  }
}
