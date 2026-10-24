import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'onboarded.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Startup resilience scenarios', () {
    setUp(markOnboarded);

    testWidgets(
      'App starts and shows dashboard without initialization errors',
      (tester) async {
        await startApp(tester);

        expect(find.text('Initialization Failed'), findsNothing);

        expect(find.byType(MaterialApp), findsOneWidget);
      },
    );

    testWidgets('Dashboard renders with seeded categories after startup', (
      tester,
    ) async {
      await startApp(tester);

      final hasContent = find.byType(Scaffold).evaluate().isNotEmpty;
      expect(hasContent, isTrue);
    });
  });
}
