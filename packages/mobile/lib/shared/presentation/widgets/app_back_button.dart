import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/router/app_root_tab.dart';
import 'package:expense_tracker/core/router/navigation_history.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class AppBackButton extends StatelessWidget {
  final String? overrideRoute;
  final Color? color;
  final double size;

  final IconData icon;

  const AppBackButton({
    super.key,
    this.overrideRoute,
    this.color,
    this.size = 24,
    this.icon = PiconsRegular.caretLeft,
  });

  void _onPressed(BuildContext context) {
    final override = overrideRoute;
    if (override != null) {
      context.go(override);

      return;
    }

    final navigator = Navigator.of(context);
    if (_historyCanGoBack() || navigator.canPop()) {
      navigator.maybePop();
    } else {
      context.go(AppRootTab.home.location);
    }
  }

  bool _historyCanGoBack() =>
      di.getIt.isRegistered<NavigationHistory>() &&
      di.getIt<NavigationHistory>().canGoBack;

  void _onSystemPop(BuildContext context, bool didPop) {
    final override = overrideRoute;
    if (!didPop && override != null) context.go(override);
  }

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      onPressed: () => _onPressed(context),
      tooltip: icon == PiconsRegular.x ? t.common.close : t.common.back,
      icon: Icon(icon, size: size),
      color: color ?? Theme.of(context).colorScheme.onSurface,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: AppSpacing.minTapTarget,
        minHeight: AppSpacing.minTapTarget,
      ),
      style: IconButton.styleFrom(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );

    if (overrideRoute == null) return button;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => _onSystemPop(context, didPop),
      child: button,
    );
  }
}
