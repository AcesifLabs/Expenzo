import 'package:expense_tracker/features/family/domain/entities/group_role.dart';
import 'package:expense_tracker/features/family/presentation/helpers/member_actions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/factories/family_factory.dart';

void main() {
  final me = makeGroupMember();
  final other = makeGroupMember(userId: 'user-2', role: GroupRole.member);

  test('a member or viewer gets no actions', () {
    for (final role in [GroupRole.member, GroupRole.viewer]) {
      expect(
        actionsFor(
          group: makeMyGroup(myRole: role),
          target: other,
        ),
        isEmpty,
      );
    }
  });

  test('an admin changes and removes another member', () {
    expect(actionsFor(group: makeMyGroup(), target: other), [
      MemberAction.changeRole,
      MemberAction.remove,
    ]);
  });

  test('an admin changes their own role but leaves instead of removing', () {
    expect(actionsFor(group: makeMyGroup(), target: me), [
      MemberAction.changeRole,
    ]);
  });

  test('isLastMember', () {
    expect(isLastMember(makeMyGroup(members: [me])), isTrue);
    expect(isLastMember(makeMyGroup()), isFalse);
  });
}
