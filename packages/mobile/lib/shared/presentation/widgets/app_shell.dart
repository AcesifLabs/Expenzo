import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/router/app_root_tab.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:expense_tracker/features/records/presentation/pages/record_list_page.dart';
import 'package:expense_tracker/features/records/presentation/widgets/new_transaction_sheet.dart';
import 'package:expense_tracker/features/budgets/presentation/pages/budget_list_page.dart';
import 'package:expense_tracker/features/reports/presentation/pages/reports_screen.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'lazy_indexed_stack.dart';
import 'nav_bar_metrics.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  static List<String> get _labels => [
    t.shell.tabs.home,
    t.shell.tabs.activity,
    t.shell.tabs.budgets,
    t.shell.tabs.reports,
  ];

  DateTime? _lastFabPress;
  final ValueNotifier<int> _homeRefreshTick = ValueNotifier(0);
  final ValueNotifier<int> _reportsRefreshTick = ValueNotifier(0);

  IconData _navIcon(int i, {bool fill = false}) {
    if (fill) {
      switch (i) {
        case 0:
          return PiconsFill.house;
        case 1:
          return PiconsFill.listDashes;
        case 2:
          return PiconsFill.wallet;
        case 3:
          return PiconsFill.chartBar;
        default:
          return PiconsFill.circle;
      }
    }
    switch (i) {
      case 0:
        return PiconsRegular.house;
      case 1:
        return PiconsRegular.listDashes;
      case 2:
        return PiconsRegular.wallet;
      case 3:
        return PiconsRegular.chartBar;
      default:
        return PiconsRegular.circle;
    }
  }

  Widget _navIconTransition(Widget child, Animation<double> animation) {
    return ScaleTransition(scale: animation, child: child);
  }

  // The selected tab is driven by the `tab` query on `/` so other screens
  // can navigate straight to a root tab (see [AppRootTab]).
  int get _currentIndex =>
      AppRootTab.fromUri(GoRouterState.of(context).uri).index;

  Widget _buildBottomNav(ColorScheme colors, bool showFab) {
    const leftCount = 2;
    const rightCount = 2;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          NavBarMetrics.bottomMargin,
        ),
        child: Container(
          height: NavBarMetrics.height,
          decoration: BoxDecoration(
            color: colors.surface.withAlpha(240),
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(20),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: colors.onSurface.withAlpha(10), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.smd),
            child: Row(
              children: [
                ...List.generate(leftCount, (i) => _navItem(i, colors)),
                AnimatedContainer(
                  duration: AppSpacing.durationNormal,
                  curve: Curves.easeInOut,
                  width: showFab ? 48 : 0,
                ),
                ...List.generate(
                  rightCount,
                  (i) => _navItem(leftCount + i, colors),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(int i, ColorScheme colors) {
    final sel = _currentIndex == i;
    final mutedColor = colors.onSurface.withAlpha(120);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _switchToTab(i),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: AppSpacing.durationFast,
                transitionBuilder: _navIconTransition,
                child: Icon(
                  _navIcon(i, fill: sel),
                  key: ValueKey('nav_icon_${i}_$sel'),
                  color: sel ? colors.primary : mutedColor,
                  size: 24,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              // The bar keeps its height and FAB dock; at large text sizes
              // the label shrinks to fit.
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AnimatedDefaultTextStyle(
                    duration: AppSpacing.durationFast,
                    style: AppTypography.bodySmall.copyWith(
                      color: sel ? colors.primary : mutedColor,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                    ),
                    child: Text(_labels[i], maxLines: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _switchToTab(int index) {
    if (!mounted || _currentIndex == index) return;
    // Reports stays alive in the tab stack; refresh it each time it is shown.
    if (AppRootTab.values[index] == AppRootTab.reports) {
      _reportsRefreshTick.value++;
    }
    context.go(AppRootTab.values[index].location);
  }

  void _onFabPressed(BuildContext context) async {
    final now = DateTime.now();
    final lastPress = _lastFabPress;
    if (lastPress != null &&
        now.difference(lastPress) < const Duration(seconds: 1)) {
      return;
    }
    _lastFabPress = now;
    final saved = await showTransactionSheet(context);
    if (saved) {
      _homeRefreshTick.value++;
      _reportsRefreshTick.value++;
    }
  }

  @override
  void dispose() {
    _homeRefreshTick.dispose();
    _reportsRefreshTick.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    // One add button on every tab: it always adds a transaction.
    final showFab = !keyboardOpen;

    return Scaffold(
      extendBody: true,
      body: LazyIndexedStack(
        index: _currentIndex,
        children: [
          DashboardPage(
            onNavigateToTab: (tab) => _switchToTab(tab.index),
            refreshTick: _homeRefreshTick,
          ),
          const RecordListPage(),
          const BudgetListPage(),
          ReportsScreen(isTab: true, refreshTick: _reportsRefreshTick),
        ],
      ),
      floatingActionButton: showFab
          ? FloatingActionButton(
              heroTag: null,
              onPressed: () => _onFabPressed(context),
              tooltip: t.common.addTransaction,
              shape: const CircleBorder(),
              child: const Icon(PiconsRegular.plus, size: 28),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(colors, showFab),
    );
  }
}
