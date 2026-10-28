import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/router/app_root_tab.dart';
import 'package:expense_tracker/core/router/app_router.dart';
import 'package:expense_tracker/core/router/navigation_history.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import '../../support/pump_localized.dart';

class _RootPage extends StatelessWidget {
  const _RootPage();

  @override
  Widget build(BuildContext context) {
    final tab = AppRootTab.fromUri(GoRouterState.of(context).uri);

    return Scaffold(body: Text('root:${tab.name}'));
  }
}

class _NestedPage extends StatelessWidget {
  final String label;
  final String? overrideRoute;

  const _NestedPage(this.label, {this.overrideRoute});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppBackButton(overrideRoute: overrideRoute),
          Text(label),
        ],
      ),
    );
  }
}

void main() {
  late NavigationHistory history;
  late GoRouter router;

  setUp(() {
    history = NavigationHistory();
    router = GoRouter(
      initialLocation: '/',
      observers: [history],
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const _RootPage(),
          routes: [
            GoRoute(path: 'a', builder: (_, _) => const _NestedPage('a')),
            GoRoute(
              path: 'b/:id',
              builder: (_, state) =>
                  _NestedPage('b:${state.pathParameters['id']}'),
            ),
            GoRoute(
              path: 'to-budgets',
              builder: (_, _) => _NestedPage(
                'to-budgets',
                overrideRoute: AppRootTab.budgets.location,
              ),
            ),
          ],
        ),
        GoRoute(path: '/solo', builder: (_, _) => const _NestedPage('solo')),
      ],
    );
    history.bindRouter(router);
    if (di.getIt.isRegistered<NavigationHistory>()) {
      di.getIt.unregister<NavigationHistory>();
    }
    di.getIt.registerSingleton<NavigationHistory>(history);
  });

  tearDown(() {
    if (di.getIt.isRegistered<NavigationHistory>()) {
      di.getIt.unregister<NavigationHistory>();
    }
    router.dispose();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      translated(MaterialApp.router(routerConfig: router)),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapBack(WidgetTester tester) async {
    await tester.tap(find.byType(AppBackButton));
    await tester.pumpAndSettle();
  }

  testWidgets('records concrete locations for pushed pages', (tester) async {
    await pumpApp(tester);

    router.go(AppRootTab.activity.location);
    await tester.pumpAndSettle();
    router.push('/a');
    await tester.pumpAndSettle();
    router.push('/b/42');
    await tester.pumpAndSettle();

    expect(history.locations, ['/?tab=activity', '/a', '/b/42']);
    expect(history.canGoBack, isTrue);
  });

  testWidgets('pops back through history one page at a time', (tester) async {
    await pumpApp(tester);
    router.push('/a');
    await tester.pumpAndSettle();
    router.push('/b/7');
    await tester.pumpAndSettle();

    await tapBack(tester);
    expect(find.text('a'), findsOneWidget);
    expect(history.locations, ['/', '/a']);

    await tapBack(tester);
    expect(find.text('root:home'), findsOneWidget);
    expect(history.locations, ['/']);
  });

  testWidgets('override route jumps straight to the root tab', (tester) async {
    await pumpApp(tester);
    router.push('/a');
    await tester.pumpAndSettle();
    router.push('/to-budgets');
    await tester.pumpAndSettle();

    await tapBack(tester);

    expect(find.text('root:budgets'), findsOneWidget);
    expect(history.locations, ['/?tab=budgets']);
  });

  testWidgets('override also handles the system back gesture', (tester) async {
    await pumpApp(tester);
    router.push('/a');
    await tester.pumpAndSettle();
    router.push('/to-budgets');
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('root:budgets'), findsOneWidget);
  });

  testWidgets('falls back to home when there is no history', (tester) async {
    await pumpApp(tester);

    router.go('/solo');
    await tester.pumpAndSettle();
    expect(history.locations, ['/solo']);
    expect(history.canGoBack, isFalse);

    await tapBack(tester);

    expect(find.text('root:home'), findsOneWidget);
  });

  testWidgets('pops via the Navigator when history is not registered', (
    tester,
  ) async {
    di.getIt.unregister<NavigationHistory>();
    await pumpApp(tester);
    router.push('/a');
    await tester.pumpAndSettle();

    await tapBack(tester);

    expect(find.text('root:home'), findsOneWidget);
  });

  test('AppRouter registers the history it observes with', () {
    final first = AppRouter(navigatorKey: GlobalKey<NavigatorState>());
    expect(di.getIt<NavigationHistory>(), same(first.history));

    final second = AppRouter(navigatorKey: GlobalKey<NavigatorState>());
    expect(di.getIt<NavigationHistory>(), same(second.history));

    first.config.dispose();
    second.config.dispose();
  });
}
