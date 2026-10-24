import 'package:expense_tracker/features/family/presentation/bloc/family_bloc.dart';
import 'package:expense_tracker/features/family/presentation/bloc/family_event.dart';
import 'package:expense_tracker/features/family/presentation/bloc/family_state.dart';
import 'package:expense_tracker/features/family/presentation/pages/family_join_page.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/family_bloc_mock.dart';
import '../../../../support/pump_localized.dart';

void main() {
  setUpAll(registerFamilyEventFallback);

  Future<MockFamilyBloc> pumpJoin(
    WidgetTester tester, {
    bool busy = false,
  }) async {
    final bloc = familyBlocWith(
      FamilyState(status: FamilyStatus.ready, busy: busy),
    );
    await pumpLocalized(
      tester,
      const FamilyJoinPage(),
      wrap: (app) => BlocProvider<FamilyBloc>.value(value: bloc, child: app),
    );

    return bloc;
  }

  ElevatedButton joinButton(WidgetTester tester) =>
      tester.widget<ElevatedButton>(find.byType(ElevatedButton));

  testWidgets('a typed lowercase code with spaces joins as RF4XK2', (
    tester,
  ) async {
    final bloc = await pumpJoin(tester);
    expect(joinButton(tester).onPressed, isNull);

    await tester.enterText(find.byType(TextField), ' rf4 xk2 ');
    await tester.pump();
    await tester.tap(find.text(t.family.join.submit));

    verify(() => bloc.add(const FamilyJoinRequested('RF4XK2'))).called(1);
  });

  testWidgets('a code with a lookalike keeps Join disabled', (tester) async {
    await pumpJoin(tester);

    await tester.enterText(find.byType(TextField), 'RF4XK0');
    await tester.pump();

    expect(joinButton(tester).onPressed, isNull);
    expect(find.text(t.family.join.codeInvalid), findsOneWidget);
  });

  testWidgets('while joining the button shows progress and is disabled', (
    tester,
  ) async {
    await pumpJoin(tester, busy: true);

    expect(joinButton(tester).onPressed, isNull);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
