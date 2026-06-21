import 'package:expense_tracker/shared/presentation/widgets/app_error_fallback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// A deterministic exception class used in widget tests. We can't use
// dart:core's `Exception` because it is `abstract` in Dart 3, so
// `Exception('foo')` is not constructible in a way that yields a
// stable, predictable runtime type. This private top-level class
// (private to the test file via the leading underscore) gives us a
// reliable runtime type for the debug-expander assertion.
class _TestBoomException implements Exception {
  const _TestBoomException(this.message);
  final String message;
}

void main() {
  group('AppErrorFallback', () {
    // A unique marker we can search for in the rendered widget tree. The
    // fallback must NEVER render this, regardless of which context is used.
    const secret = 'BOOM_TEST_MARKER_leaked_to_ui';

    Widget wrap(Widget child) {
      return MaterialApp(
        home: child,
      );
    }

    testWidgets('renders without throwing in all four contexts', (
      tester,
    ) async {
      for (final ctx in AppFallbackContext.values) {
        await tester.pumpWidget(
          wrap(
            AppErrorFallback(
              fallbackContext: ctx,
              referenceId: 'ABC123',
              exception: _TestBoomException(secret),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('never renders the exception message or stack', (
      tester,
    ) async {
      // Runs in the test target (debug-mode branch of kDebugMode). The
      // invariant we are checking is that the secret and the stack-trace
      // file marker are absent from the widget tree *before* the user
      // expands the debug expander.
      await tester.pumpWidget(
        wrap(
          AppErrorFallback(
            fallbackContext: AppFallbackContext.build,
            referenceId: 'ABC123',
            exception: _TestBoomException(secret),
            stack: StackTrace.fromString('$secret\nat somefile.dart:42'),
          ),
        ),
      );
      expect(find.textContaining(secret), findsNothing);
      expect(find.textContaining('somefile.dart'), findsNothing);
    });

    testWidgets('never renders the stack trace anywhere in the tree', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          AppErrorFallback(
            fallbackContext: AppFallbackContext.init,
            referenceId: 'ABC123',
            exception: _TestBoomException(secret),
            stack: StackTrace.fromString('$secret\nat somefile.dart:42'),
            onRetry: () {},
            onRestart: () {},
          ),
        ),
      );
      // Even with the debug expander collapsed, the stack-trace line
      // ("at somefile.dart:42") must not be in the tree.
      expect(find.textContaining('somefile.dart'), findsNothing);
      expect(find.textContaining(secret), findsNothing);
    });

    testWidgets('shows the supplied reference id', (tester) async {
      await tester.pumpWidget(
        wrap(
          AppErrorFallback(
            fallbackContext: AppFallbackContext.init,
            referenceId: 'XYZ789',
          ),
        ),
      );
      expect(find.text('Ref: XYZ789'), findsOneWidget);
    });

    testWidgets('invokes onRetry and onRestart when tapped', (tester) async {
      var retry = 0;
      var restart = 0;

      await tester.pumpWidget(
        wrap(
          AppErrorFallback(
            fallbackContext: AppFallbackContext.init,
            referenceId: 'ABC123',
            onRetry: () => retry++,
            onRestart: () => restart++,
          ),
        ),
      );

      await tester.tap(find.text('Try Again'));
      await tester.tap(find.text('Close App'));
      await tester.pump();

      expect(retry, 1);
      expect(restart, 1);
    });

    testWidgets('hides Send Feedback when feedbackBuilder is not provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          AppErrorFallback(
            fallbackContext: AppFallbackContext.build,
            referenceId: 'ABC123',
            onRetry: () {},
            onRestart: () {},
            // feedbackBuilder deliberately omitted
          ),
        ),
      );
      expect(find.text('Send Feedback'), findsNothing);
    });

    testWidgets('shows Send Feedback when feedbackBuilder is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          AppErrorFallback(
            fallbackContext: AppFallbackContext.build,
            referenceId: 'ABC123',
            onRetry: () {},
            onRestart: () {},
            feedbackBuilder: (_) => const Scaffold(body: Text('FEEDBACK')),
          ),
        ),
      );
      expect(find.text('Send Feedback'), findsOneWidget);
    });

    testWidgets('hides Close App when callback is not provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          AppErrorFallback(
            fallbackContext: AppFallbackContext.async,
            referenceId: 'ABC123',
            onRetry: () {},
            // onRestart deliberately omitted
          ),
        ),
      );
      expect(find.text('Close App'), findsNothing);
    });

    testWidgets(
      'debug expander reveals exception runtimeType but never toString',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            AppErrorFallback(
              fallbackContext: AppFallbackContext.init,
              referenceId: 'ABC123',
              exception: _TestBoomException(secret),
            ),
          ),
        );
        // Initially collapsed — exception secret is hidden, and the
        // expander icon shows the "more" chevron.
        expect(find.text('_TestBoomException'), findsNothing);
        expect(find.byIcon(Icons.expand_more), findsOneWidget);

        // Expand. Tap the expander's icon (which is unique to the
        // _DebugDetails InkWell) to avoid the InkWell splash-animation
        // deadlock that pumpAndSettle hits. A single pump() is enough
        // for setState to take effect.
        await tester.tap(find.byIcon(Icons.expand_more));
        await tester.pump();

        // The runtime type is shown, and the icon has flipped.
        expect(find.text('_TestBoomException'), findsOneWidget);
        expect(find.byIcon(Icons.expand_less), findsOneWidget);
        // The full exception message is still NOT shown anywhere.
        expect(find.textContaining(secret), findsNothing);
      },
    );

    testWidgets(
      'formatDebugType strategy overrides the default runtimeType',
      (tester) async {
        await tester.pumpWidget(
          wrap(
            AppErrorFallback(
              fallbackContext: AppFallbackContext.init,
              referenceId: 'ABC123',
              exception: _TestBoomException(secret),
              formatDebugType: (Object e) => 'FAKE',
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.expand_more));
        await tester.pump();

        // The strategy's output is shown instead of the runtime type.
        expect(find.text('FAKE'), findsOneWidget);
        // The runtime type is NOT shown.
        expect(find.text('_TestBoomException'), findsNothing);
      },
    );

    test('generateReferenceId is six uppercase chars', () {
      final id = AppErrorFallback.generateReferenceId();
      expect(id.length, 6);
      expect(RegExp(r'^[0-9A-Z]{6}$').hasMatch(id), isTrue);
    });
  });
}
