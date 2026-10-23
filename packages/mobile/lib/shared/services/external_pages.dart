import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

/// Opens a URI outside the app; true when something opened it.
typedef PageLauncher = Future<bool> Function(Uri uri);

/// Opens the page [uri] builds in the browser. When it can't be built or
/// nothing can open it, shows a SnackBar.
///
/// [uri] is a builder because the page URLs come from `BACKEND_URL`, which
/// throws in a release build when it isn't set. Offline, the browser shows
/// its own offline page; the app does not check connectivity first.
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
