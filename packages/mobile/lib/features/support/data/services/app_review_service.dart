import 'package:in_app_review/in_app_review.dart';

import 'package:expense_tracker/core/logger/app_logger.dart';

/// Asks the store for a review of the app.
class AppReviewService {
  final InAppReview _inAppReview;

  AppReviewService({InAppReview? inAppReview})
    : _inAppReview = inAppReview ?? InAppReview.instance;

  /// Asks for the in-app review sheet; opens the store page when the sheet is
  /// not available. Never throws.
  ///
  /// Google Play limits how often the sheet appears (a quota), so
  /// [InAppReview.requestReview] may return without showing anything. That is
  /// accepted: there is no fallback for it. Until the app is on Google Play,
  /// neither the sheet nor the store page shows anything useful. On Android
  /// the store page uses the package name `com.acesiflabs.expenzo`; iOS would
  /// need `appStoreId`, not needed while the app is Android-only.
  Future<void> requestReview() async {
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
      } else {
        await _inAppReview.openStoreListing();
      }
    } catch (e, s) {
      appLogger.error('App review request failed', e, s);
    }
  }
}
