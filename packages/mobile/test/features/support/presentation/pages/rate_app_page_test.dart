import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/support/data/services/app_review_service.dart';
import 'package:expense_tracker/features/support/presentation/pages/rate_app_page.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import '../../../../support/pump_localized.dart';

class _MockAppReviewService extends Mock implements AppReviewService {}

void main() {
  late _MockAppReviewService review;

  setUp(() {
    review = _MockAppReviewService();
    when(() => review.requestReview()).thenAnswer((_) async {});
    di.getIt
      ..registerSingleton<AppReviewService>(review)
      // Feature dependencies count as ready: no real modules in this test.
      ..registerSingleton<Future<void>>(
        Future<void>.value(),
        instanceName: 'featureReady',
      );
  });

  tearDown(() => di.getIt.reset());

  /// Rate the app pushed on top of a home page, so it can pop.
  Future<void> pumpRate(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: '/rate',
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Text('home'),
          routes: [
            GoRoute(path: 'rate', builder: (_, _) => const RateAppPage()),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      translated(MaterialApp.router(routerConfig: router)),
    );
    await tester.pumpAndSettle();
  }

  ElevatedButton primary(WidgetTester tester) =>
      tester.widget<ElevatedButton>(find.byType(ElevatedButton));

  Future<void> tapStar(WidgetTester tester, int n) async {
    await tester.tap(find.byTooltip(t.support.rate.starLabel(n: n)));
    await tester.pump();
  }

  testWidgets('the main button is off until a star is chosen', (tester) async {
    await pumpRate(tester);

    expect(primary(tester).onPressed, isNull);
  });

  testWidgets('5 stars asks the store for a review, then closes', (
    tester,
  ) async {
    await pumpRate(tester);

    await tapStar(tester, 5);
    expect(find.text(t.support.rate.writeReview), findsOneWidget);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    verify(() => review.requestReview()).called(1);
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('a second press while busy does nothing', (tester) async {
    final pending = Completer<void>();
    when(() => review.requestReview()).thenAnswer((_) => pending.future);
    await pumpRate(tester);

    await tapStar(tester, 4);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    await tester.tap(find.byType(ElevatedButton), warnIfMissed: false);
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    pending.complete();
    await tester.pumpAndSettle();
    verify(() => review.requestReview()).called(1);
  });

  testWidgets('while a request runs, Maybe later is off', (tester) async {
    final pending = Completer<void>();
    when(() => review.requestReview()).thenAnswer((_) => pending.future);
    await pumpRate(tester);

    await tapStar(tester, 5);
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    final maybeLater = tester.widget<OutlinedButton>(
      find.byType(OutlinedButton),
    );
    expect(maybeLater.onPressed, isNull);
    pending.complete();
    await tester.pumpAndSettle();
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('2 stars asks what to improve and skips the store', (
    tester,
  ) async {
    await pumpRate(tester);

    await tapStar(tester, 2);

    expect(find.text(t.support.rate.tellUs), findsOneWidget);
    verifyNever(() => review.requestReview());
  });

  testWidgets('Maybe later closes the screen', (tester) async {
    await pumpRate(tester);

    await tester.tap(find.text(t.support.rate.maybeLater));
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
  });
}
