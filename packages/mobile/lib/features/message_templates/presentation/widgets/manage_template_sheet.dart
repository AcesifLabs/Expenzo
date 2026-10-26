import 'package:flutter/material.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

enum ManageTemplateAction { edit, delete }

Future<ManageTemplateAction?> showManageTemplateSheet({
  required BuildContext context,
}) {
  return showModalBottomSheet<ManageTemplateAction>(
    context: context,
    builder: (_) => const ManageTemplateSheet(),
  );
}

class ManageTemplateSheet extends StatelessWidget {
  const ManageTemplateSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              t.messageTemplates.alreadyExists,
              style: AppTypography.titleMedium.copyWith(
                color: colors.onSurface,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(PiconsRegular.pen),
            title: Text(t.messageTemplates.edit),
            onTap: () => Navigator.of(context).pop(ManageTemplateAction.edit),
          ),
          ListTile(
            leading: const Icon(PiconsRegular.trash),
            title: Text(t.messageTemplates.delete),
            onTap: () => Navigator.of(context).pop(ManageTemplateAction.delete),
          ),
        ],
      ),
    );
  }
}
