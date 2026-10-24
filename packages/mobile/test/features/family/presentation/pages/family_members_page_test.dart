import 'package:expense_tracker/features/family/domain/entities/cached.dart';
import 'package:expense_tracker/features/family/domain/entities/group_role.dart';
import 'package:expense_tracker/features/family/domain/entities/my_group.dart';
import 'package:expense_tracker/features/family/presentation/bloc/family_bloc.dart';
import 'package:expense_tracker/features/family/presentation/bloc/family_event.dart';
import 'package:expense_tracker/features/family/presentation/bloc/family_state.dart';
import 'package:expense_tracker/features/family/presentation/pages/family_members_page.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:picons/picons.dart';

import '../../../../support/factories/family_factory.dart';
import '../../../../support/family_bloc_mock.dart';
import '../../../../support/pump_localized.dart';

void main() {
  setUpAll(registerFamilyEventFallback);

  Future<MockFamilyBloc> pumpMembers(
    WidgetTester tester,
    GroupRole myRole,
  ) async {
    final bloc = familyBlocWith(
      FamilyState(
        status: FamilyStatus.ready,
        group: Cached<MyGroup?>(
          makeMyGroup(myRole: myRole),
          fetchedAt: DateTime.utc(2026),
        ),
      ),
    );
    await pumpLocalized(
      tester,
      const FamilyMembersPage(),
      wrap: (app) => BlocProvider<FamilyBloc>.value(value: bloc, child: app),
    );

    return bloc;
  }

  testWidgets('an admin changes a member to Viewer', (tester) async {
    final bloc = await pumpMembers(tester, GroupRole.admin);

    await tester.tap(find.text(t.family.dashboard.memberFallback));
    await tester.pumpAndSettle();
    await tester.tap(find.text(t.family.members.changeRole));
    await tester.pumpAndSettle();
    await tester.tap(find.text(t.family.roles.viewer).last);
    await tester.pumpAndSettle();

    verify(
      () => bloc.add(
        const FamilyRoleChangeRequested(
          userId: 'user-2',
          role: GroupRole.viewer,
        ),
      ),
    ).called(1);
  });

  testWidgets('a member sees no carets and no Delete group', (tester) async {
    await pumpMembers(tester, GroupRole.member);

    expect(find.byIcon(PiconsRegular.caretRight), findsNothing);
    expect(find.text(t.family.members.deleteGroup), findsNothing);
    expect(find.text(t.family.members.leave), findsOneWidget);
  });
}
