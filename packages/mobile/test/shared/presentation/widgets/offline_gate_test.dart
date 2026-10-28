import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_error_state.dart';
import 'package:expense_tracker/shared/presentation/widgets/offline_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_localized.dart';

void main() {
  testWidgets('shows the offline message when there is no network link', (
    tester,
  ) async {
    await pumpLocalized(
      tester,
      OfflineGate(
        checkOnline: () async => false,
        child: const Text('online-child'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppErrorState), findsOneWidget);
    expect(find.text(t.common.errors.network), findsOneWidget);
    expect(find.text('online-child'), findsNothing);
  });

  testWidgets('shows the child when online', (tester) async {
    await pumpLocalized(
      tester,
      OfflineGate(
        checkOnline: () async => true,
        child: const Text('online-child'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('online-child'), findsOneWidget);
    expect(find.byType(AppErrorState), findsNothing);
  });

  testWidgets('Try again re-checks and reveals the child when online', (
    tester,
  ) async {
    var online = false;
    await pumpLocalized(
      tester,
      OfflineGate(
        checkOnline: () async => online,
        child: const Text('online-child'),
      ),
    );
    await tester.pumpAndSettle();

    online = true;
    await tester.tap(find.text(t.common.tryAgain));
    await tester.pumpAndSettle();

    expect(find.text('online-child'), findsOneWidget);
  });
}
