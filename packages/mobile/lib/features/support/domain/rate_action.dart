import 'package:expense_tracker/core/constants/app_constants.dart';

/// What Rate the app does with the chosen stars.
enum RateAction { storeReview, feedbackEmail }

/// 4–5 stars go to the store; 1–3 stars ask what to improve.
RateAction rateActionFor(int stars) {
  assert(stars >= 1 && stars <= 5, 'stars must be 1 to 5, got $stars');

  return stars >= AppConstants.minStoreStars
      ? RateAction.storeReview
      : RateAction.feedbackEmail;
}
