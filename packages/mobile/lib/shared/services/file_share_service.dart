import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';

enum ShareOutcome { shared, dismissed }

class FileShareService {
  const FileShareService();

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

  Future<ShareOutcome> shareText(String text) async {
    try {
      final result = await Share.share(text);

      return outcomeFor(result.status);
    } catch (e, s) {
      appLogger.error('Text share failed', e, s);
      rethrow;
    }
  }

  @visibleForTesting
  static ShareOutcome outcomeFor(ShareResultStatus status) => switch (status) {
    ShareResultStatus.dismissed => ShareOutcome.dismissed,
    ShareResultStatus.success ||
    ShareResultStatus.unavailable => ShareOutcome.shared,
  };
}
