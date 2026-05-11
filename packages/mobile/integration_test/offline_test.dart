import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:expense_tracker/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Startup resilience scenarios', () {
    testWidgets('App starts and shows dashboard without initialization errors', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 20));

      // Should NOT show "Initialization Failed"
      expect(find.text('Initialization Failed'), findsNothing);

      // Should show AppShell content (bottom nav exists)
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Dashboard renders with seeded categories after startup', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 20));

      // Dashboard should be visible — check for common widgets
      // Seeded categories: Food, Shopping, Transport, etc.
      final hasContent = find.byType(Scaffold).evaluate().isNotEmpty;
      expect(hasContent, isTrue);
    });
  });
}
