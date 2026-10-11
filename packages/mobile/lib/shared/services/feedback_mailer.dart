import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:expense_tracker/core/config/app_config.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

/// The `mailto:` link for a feedback email. [errorReference] is the ID shown
/// on an error screen, so a report can be matched to its log entry.
Uri feedbackMailUri({String? errorReference, String? platform}) {
  final lines = [
    '',
    '',
    '---',
    'Device: ${platform ?? '${Platform.operatingSystem} ${Platform.operatingSystemVersion}'}',
    if (errorReference != null) 'Error reference: $errorReference',
  ];

  return Uri(
    scheme: 'mailto',
    path: AppConfig.feedbackEmail,
    // Uri.queryParameters would encode spaces as "+", which mail apps keep.
    query:
        'subject=${Uri.encodeComponent(t.common.feedback.subject)}'
        '&body=${Uri.encodeComponent(lines.join('\n'))}',
  );
}

/// Opens the user's mail app with a feedback email. Without a mail app,
/// shows the address so it can be copied.
Future<void> sendFeedback(
  BuildContext context, {
  String? errorReference,
}) async {
  final opened = await launchUrl(
    feedbackMailUri(errorReference: errorReference),
  ).catchError((_) => false);
  // The start-up error screen sits above the navigator; nothing to show on.
  if (opened || !context.mounted || Navigator.maybeOf(context) == null) return;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(t.common.sendFeedback),
      content: SelectableText(
        t.common.feedback.noMailApp(email: AppConfig.feedbackEmail),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            await Clipboard.setData(
              const ClipboardData(text: AppConfig.feedbackEmail),
            );
            if (dialogContext.mounted) Navigator.pop(dialogContext);
          },
          child: Text(t.common.feedback.copyAddress),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(t.common.close),
        ),
      ],
    ),
  );
}
