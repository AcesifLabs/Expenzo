import 'package:expense_tracker/core/theme/category_palette.dart';
import 'package:flutter/material.dart';

import '../helpers/family_dashboard_helpers.dart';

/// One member's circle: their photo, else their initial on the colour of
/// their place in the member list.
class MemberAvatar extends StatelessWidget {
  final String? displayName;
  final String? photoUrl;

  /// The member's position in `MyGroup.members`.
  final int index;
  final double radius;

  const MemberAvatar({
    super.key,
    required this.displayName,
    required this.photoUrl,
    required this.index,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final color = memberAvatarColor(index);
    final photo = photoUrl;

    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      foregroundImage: photo == null ? null : NetworkImage(photo),
      child: Text(
        memberInitial(displayName),
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(color: CategoryPalette.iconOn(color)),
      ),
    );
  }
}
