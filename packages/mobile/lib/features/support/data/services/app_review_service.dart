import 'package:in_app_review/in_app_review.dart';

import 'package:expense_tracker/core/logger/app_logger.dart';

class AppReviewService {
  final InAppReview _inAppReview;

  AppReviewService({InAppReview? inAppReview})
    : _inAppReview = inAppReview ?? InAppReview.instance;

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
