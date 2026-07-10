import 'package:flutter/material.dart';
import 'package:picons/picons.dart';

/// The action the user chose in the [ManageTemplateSheet].
enum ManageTemplateAction { edit, delete }

/// Shows the "Template already exists" management bottom sheet for a
/// long-pressed matched message. Returns the chosen action, or `null`
/// if the sheet was dismissed without a selection.
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
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Template already exists',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(PiconsRegular.pen),
            title: const Text('Edit template'),
            onTap: () => Navigator.of(context).pop(ManageTemplateAction.edit),
          ),
          ListTile(
            leading: const Icon(PiconsRegular.trash),
            title: const Text('Delete template'),
            onTap: () => Navigator.of(context).pop(ManageTemplateAction.delete),
          ),
        ],
      ),
    );
  }
}
