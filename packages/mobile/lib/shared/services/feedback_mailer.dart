import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:expense_tracker/core/config/app_config.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

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

    query:
        'subject=${Uri.encodeComponent(t.common.feedback.subject)}'
        '&body=${Uri.encodeComponent(lines.join('\n'))}',
  );
}

Future<void> sendFeedback(
  BuildContext context, {
  String? errorReference,
}) async {
  final opened = await launchUrl(
    feedbackMailUri(errorReference: errorReference),
  ).catchError((_) => false);

  if (opened || !context.mounted || Navigator.maybeOf(context) == null) return;

  final feedbackStrings = t.common.feedback;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(t.common.sendFeedback),
      content: SelectableText(
        feedbackStrings.noMailApp(email: AppConfig.feedbackEmail),
      ),
      actions: [
        TextButton(
          onPressed: () => unawaited(_copyFeedbackAddress(dialogContext)),
          child: Text(feedbackStrings.copyAddress),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(t.common.close),
        ),
      ],
    ),
  );
}

Future<void> _copyFeedbackAddress(BuildContext dialogContext) async {
  await Clipboard.setData(const ClipboardData(text: AppConfig.feedbackEmail));
  if (dialogContext.mounted) Navigator.pop(dialogContext);
}
