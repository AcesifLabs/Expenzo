import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

typedef PageLauncher = Future<bool> Function(Uri uri);

Future<bool> openExternalPage(
  BuildContext context,
  Uri Function() uri, {
  PageLauncher launch = _launchInBrowser,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final opened = await Future(() => launch(uri())).catchError((Object e) {
    appLogger.error('Opening an external page failed', e);

    return false;
  });
  if (!opened && context.mounted) {
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(t.support.help.linkFailed)));
  }

  return opened;
}

Future<bool> _launchInBrowser(Uri uri) =>
    launchUrl(uri, mode: LaunchMode.externalApplication);
