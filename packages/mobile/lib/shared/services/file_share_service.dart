import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';

enum ShareOutcome { shared, dismissed }

/// Opens the system share sheet for files the app wrote.
class FileShareService {
  const FileShareService();

  /// Shares the file at [path]. Platform errors are logged and rethrown.
  Future<ShareOutcome> shareFile(
    String path, {
    required String mimeType,
    String? subject,
  }) async {
    try {
      final result = await Share.shareXFiles([
        XFile(path, mimeType: mimeType),
      ], subject: subject);

      return outcomeFor(result.status);
    } catch (e, s) {
      appLogger.error('File share failed', e, s);
      rethrow;
    }
  }

  /// [ShareResultStatus.unavailable] means the sheet was shown but the
  /// platform can't report what the user did, so it counts as shared.
  @visibleForTesting
  static ShareOutcome outcomeFor(ShareResultStatus status) => switch (status) {
    ShareResultStatus.dismissed => ShareOutcome.dismissed,
    ShareResultStatus.success ||
    ShareResultStatus.unavailable => ShareOutcome.shared,
  };
}
