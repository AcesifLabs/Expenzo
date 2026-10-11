import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:expense_tracker/core/router/navigation_history.dart';
import '../../support/pump_localized.dart';

PageRoute<void> _page() =>
    MaterialPageRoute<void>(builder: (_) => const SizedBox.shrink());

Route<void> _dialog() =>
    RawDialogRoute<void>(pageBuilder: (_, _, _) => const SizedBox.shrink());

void main() {
  group('observer bookkeeping', () {
    late NavigationHistory history;

    setUp(() => history = NavigationHistory());

    test('ignores dialogs and sheets', () {
      history.didPush(_page(), null);
      history.didPush(_dialog(), null);

      expect(history.locations, hasLength(1));
      expect(history.canGoBack, isFalse);
    });

    test('didRemove drops the route wherever it is in the stack', () {
      final a = _page();
      final b = _page();
      final c = _page();
      for (final route in [a, b, c]) {
        history.didPush(route, null);
      }

      history.didRemove(b, a);

      expect(history.locations, hasLength(2));
      history.didPop(c, a);
      expect(history.canGoBack, isFalse);
    });

    test('didReplace swaps a tracked page in place', () {
      final a = _page();
      final b = _page();
      final replacement = _page();
      history.didPush(a, null);
      history.didPush(b, a);

      history.didReplace(newRoute: replacement, oldRoute: a);
      history.didPop(b, replacement);

      // Only the replacement is left, so `a` really was swapped out.
      expect(history.locations, hasLength(1));
      history.didPop(replacement, null);
      expect(history.locations, isEmpty);
    });

    test('didReplace appends when the old route was never tracked', () {
      history.didPush(_page(), null);

      history.didReplace(newRoute: _page(), oldRoute: _dialog());

      expect(history.locations, hasLength(2));
    });

    test('didReplace with a non-page route removes the old page', () {
      final a = _page();
      final b = _page();
      history.didPush(a, null);
      history.didPush(b, a);

      history.didReplace(newRoute: _dialog(), oldRoute: b);

      expect(history.locations, hasLength(1));
    });

    test('locations are null without a bound router', () {
      history.didPush(_page(), null);

      expect(history.locations, [null]);
    });
  });

  group('with a router', () {
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
            builder: (_, _) => const Scaffold(body: Text('root')),
            routes: [
              GoRoute(path: 'a', builder: (_, _) => const Text('a')),
              GoRoute(path: 'b', builder: (_, _) => const Text('b')),
            ],
          ),
        ],
      );
      history.bindRouter(router);
    });

    tearDown(() => router.dispose());

    Future<void> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(
        translated(MaterialApp.router(routerConfig: router)),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('a dialog over a page does not count as history', (
      tester,
    ) async {
      await pumpApp(tester);
      router.push('/a');
      await tester.pumpAndSettle();

      final context = tester.element(find.text('a'));
      showDialog<void>(context: context, builder: (_) => const Text('dialog'));
      await tester.pumpAndSettle();

      expect(history.locations, ['/', '/a']);
    });

    testWidgets('pages pushed outside go_router have no location', (
      tester,
    ) async {
      await pumpApp(tester);

      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.push(
        MaterialPageRoute<void>(builder: (_) => const Text('plain')),
      );
      await tester.pumpAndSettle();

      expect(history.locations, ['/', null]);
      expect(history.canGoBack, isTrue);
    });

    testWidgets('pushReplacement replaces the top location', (tester) async {
      await pumpApp(tester);
      router.push('/a');
      await tester.pumpAndSettle();

      router.pushReplacement('/b');
      await tester.pumpAndSettle();

      expect(history.locations, ['/', '/b']);
    });
  });
}
