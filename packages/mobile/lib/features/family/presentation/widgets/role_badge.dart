import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/group_role.dart';
import '../helpers/member_actions.dart';

class RoleBadge extends StatelessWidget {
  final GroupRole role;

  const RoleBadge({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: palette.surfaceHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Text(
        roleName(role),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: role.isAdmin ? palette.accent : palette.textSecondary,
        ),
      ),
    );
  }
}
