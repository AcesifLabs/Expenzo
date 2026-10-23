import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/services/external_pages.dart';

import '../../support/pump_localized.dart';

void main() {
  final page = Uri.parse('https://example.com/privacy');

  /// Pumps a button that opens [page] with [launch]; returns the result.
  Future<bool?> tapOpen(WidgetTester tester, PageLauncher launch) async {
    bool? result;
    await pumpLocalized(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await openExternalPage(
              context,
              () => page,
              launch: launch,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    return result;
  }

  testWidgets('an opened page shows no SnackBar', (tester) async {
    Uri? launched;

    final result = await tapOpen(tester, (uri) async {
      launched = uri;

      return true;
    });

    expect(result, isTrue);
    expect(launched, page);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('a page nothing can open shows the SnackBar', (tester) async {
    final result = await tapOpen(tester, (_) async => false);

    expect(result, isFalse);
    expect(find.text(t.support.help.linkFailed), findsOneWidget);
  });

  testWidgets('a URL that cannot be built shows the SnackBar', (tester) async {
    bool? result;
    await pumpLocalized(
      tester,
      Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await openExternalPage(
              context,
              () => throw StateError('BACKEND_URL is not configured'),
              launch: (_) async => true,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
    expect(find.text(t.support.help.linkFailed), findsOneWidget);
  });

  testWidgets('a throwing launcher counts as not opened', (tester) async {
    final result = await tapOpen(tester, (_) => Future.error(Exception('x')));

    expect(result, isFalse);
    expect(find.text(t.support.help.linkFailed), findsOneWidget);
  });
}
