import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/support/domain/rate_action.dart';

void main() {
  test('1 to 3 stars open the feedback email', () {
    for (final stars in [1, 2, 3]) {
      expect(rateActionFor(stars), RateAction.feedbackEmail, reason: '$stars');
    }
  });

  test('4 and 5 stars go to the store review', () {
    for (final stars in [4, 5]) {
      expect(rateActionFor(stars), RateAction.storeReview, reason: '$stars');
    }
  });
}
