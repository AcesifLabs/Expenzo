import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/features/support/data/services/app_review_service.dart';

class _MockInAppReview extends Mock implements InAppReview {}

void main() {
  late _MockInAppReview inAppReview;
  late AppReviewService service;

  setUp(() {
    inAppReview = _MockInAppReview();
    service = AppReviewService(inAppReview: inAppReview);
    when(() => inAppReview.requestReview()).thenAnswer((_) async {});
    when(
      () => inAppReview.openStoreListing(
        appStoreId: any(named: 'appStoreId'),
        microsoftStoreId: any(named: 'microsoftStoreId'),
      ),
    ).thenAnswer((_) async {});
  });

  test('asks for the review sheet when it is available', () async {
    when(() => inAppReview.isAvailable()).thenAnswer((_) async => true);

    await service.requestReview();

    verify(() => inAppReview.requestReview()).called(1);
    verifyNever(() => inAppReview.openStoreListing());
  });

  test('opens the store page when the sheet is not available', () async {
    when(() => inAppReview.isAvailable()).thenAnswer((_) async => false);

    await service.requestReview();

    verify(() => inAppReview.openStoreListing()).called(1);
    verifyNever(() => inAppReview.requestReview());
  });

  test('a plugin error does not reach the caller', () async {
    when(() => inAppReview.isAvailable()).thenAnswer((_) async => true);
    when(() => inAppReview.requestReview()).thenThrow(Exception('quota'));

    await expectLater(service.requestReview(), completes);
  });
}
