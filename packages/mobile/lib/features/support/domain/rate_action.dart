import 'package:expense_tracker/core/constants/app_constants.dart';

enum RateAction { storeReview, feedbackEmail }

RateAction rateActionFor(int stars) {
  assert(stars >= 1 && stars <= 5, 'stars must be 1 to 5, got $stars');

  return stars >= AppConstants.minStoreStars
      ? RateAction.storeReview
      : RateAction.feedbackEmail;
}
