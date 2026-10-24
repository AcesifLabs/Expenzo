import 'package:expense_tracker/features/family/domain/entities/cached.dart';
import 'package:expense_tracker/features/family/domain/entities/invite_code.dart';
import 'package:expense_tracker/features/family/domain/entities/my_group.dart';
import 'package:expense_tracker/features/family/presentation/bloc/family_bloc.dart';
import 'package:expense_tracker/features/family/presentation/bloc/family_event.dart';
import 'package:expense_tracker/features/family/presentation/bloc/family_state.dart';
import 'package:expense_tracker/features/family/presentation/pages/family_invite_page.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/factories/family_factory.dart';
import '../../../../support/family_bloc_mock.dart';
import '../../../../support/pump_localized.dart';

void main() {
  final now = DateTime.utc(2026, 3, 1, 10);
  final invite = InviteCode(
    code: 'RF4XK2',
    expiresAt: now.add(const Duration(hours: 48)),
  );

  setUpAll(registerFamilyEventFallback);

  testWidgets('shows the code and regenerates after confirming', (
    tester,
  ) async {
    final bloc = familyBlocWith(
      FamilyState(
        status: FamilyStatus.ready,
        group: Cached<MyGroup?>(makeMyGroup(invite: invite), fetchedAt: now),
      ),
    );
    await pumpLocalized(
      tester,
      FamilyInvitePage(clock: () => now),
      wrap: (app) => BlocProvider<FamilyBloc>.value(value: bloc, child: app),
    );

    expect(find.text('RF4XK2'), findsOneWidget);

    await tester.tap(find.text(t.family.invite.regenerate));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(TextButton, t.family.invite.regenerate).last,
    );
    await tester.pumpAndSettle();

    verify(
      () => bloc.add(const FamilyInviteRequested(regenerate: true)),
    ).called(1);
  });
}
