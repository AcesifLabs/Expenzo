import 'package:get_it/get_it.dart';
import 'package:expense_tracker/features/support/data/services/app_review_service.dart';

void initSupportModule(GetIt getIt) {
  getIt.registerLazySingleton<AppReviewService>(AppReviewService.new);
}
