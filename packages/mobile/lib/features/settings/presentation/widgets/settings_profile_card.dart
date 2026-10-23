import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';

import 'package:expense_tracker/core/router/settings_route.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/auth/presentation/helpers/user_display.dart';
import 'package:expense_tracker/features/auth/presentation/widgets/user_avatar.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';

/// The account at the top of Settings: opens My profile when signed in, or
/// Sign in as a guest.
class SettingsProfileCard extends StatelessWidget {
  const SettingsProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final profileT = t.settings.profile;
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final authState = context.watch<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;
    final title = user == null ? profileT.guestName : userDisplayName(user);
    final subtitle = user == null ? profileT.guestSubtitle : user.email;

    return AppCard(
      backgroundColor: palette.surface,
      borderRadius: AppSpacing.radiusCard,
      padding: AppSpacing.paddingMd,
      onTap: () => context.push(
        user == null ? '/login' : SettingsRoute.profile.location,
      ),
      child: Row(
        children: [
          UserAvatar(user: user, radius: 24),
          const SizedBox(width: AppSpacing.smd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null && subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            PiconsRegular.caretRight,
            size: AppSpacing.iconSm,
            color: palette.textSecondary,
          ),
        ],
      ),
    );
  }
}
