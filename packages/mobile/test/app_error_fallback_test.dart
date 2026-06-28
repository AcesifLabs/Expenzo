import 'package:expense_tracker/shared/presentation/widgets/app_error_fallback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestBoomException implements Exception {
  const _TestBoomException(this.message);
  final String message;
}

void main() {
  group('AppErrorFallback', () {
    const secret = 'BOOM_TEST_MARKER_leaked_to_ui';

    Widget wrap(Widget child) {
      return MaterialApp(home: child);
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

    testWidgets('never renders the exception message or stack', (tester) async {
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

        expect(find.text('_TestBoomException'), findsNothing);
        expect(find.byIcon(Icons.expand_more), findsOneWidget);

        await tester.tap(find.byIcon(Icons.expand_more));
        await tester.pump();

        expect(find.text('_TestBoomException'), findsOneWidget);
        expect(find.byIcon(Icons.expand_less), findsOneWidget);

        expect(find.textContaining(secret), findsNothing);
      },
    );

    testWidgets('formatDebugType strategy overrides the default runtimeType', (
      tester,
    ) async {
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

      expect(find.text('FAKE'), findsOneWidget);

      expect(find.text('_TestBoomException'), findsNothing);
    });

    test('generateReferenceId is six uppercase chars', () {
      final id = AppErrorFallback.generateReferenceId();
      expect(id.length, 6);
      expect(RegExp(r'^[0-9A-Z]{6}$').hasMatch(id), isTrue);
    });
  });
}
