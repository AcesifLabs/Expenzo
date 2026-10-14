import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/router/settings_route.dart';
import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_event.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_card.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

/// One-time Home card pointing to Settings → Auto-import (docs/adr/0006).
///
/// Shown until the user dismisses it or grants SMS access.
class AutoImportPromptCard extends StatefulWidget {
  const AutoImportPromptCard({super.key});

  @override
  State<AutoImportPromptCard> createState() => _AutoImportPromptCardState();
}

class _AutoImportPromptCardState extends State<AutoImportPromptCard> {
  bool? _hasSmsAccess;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    final status = await Permission.sms.status;
    if (mounted) setState(() => _hasSmsAccess = status.isGranted);
  }

  Future<void> _openAutoImport() async {
    await context.push(SettingsRoute.autoImport.location);
    if (mounted) await _checkAccess();
  }

  Widget _buildCard(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final strings = t.dashboard.autoImport;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageGutter,
        AppSpacing.md,
        AppSpacing.pageGutter,
        0,
      ),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(PiconsRegular.chatText, color: palette.brand),
            const SizedBox(width: AppSpacing.smd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.title, style: textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    strings.body,
                    style: textTheme.bodySmall?.copyWith(
                      color: palette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => unawaited(_openAutoImport()),
                        child: Text(strings.setUp),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      TextButton(
                        onPressed: () => di.getIt<SettingsBloc>().add(
                          const DismissAutoImportPrompt(),
                        ),
                        child: Text(t.common.notNow),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      bloc: di.getIt<SettingsBloc>(),
      builder: (context, state) {
        final dismissed = state is SettingsLoaded
            ? state.settings.autoImportPromptDismissed
            : true;
        if (dismissed || _hasSmsAccess != false) {
          return const SizedBox.shrink();
        }

        return _buildCard(context);
      },
    );
  }
}
