import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';
import 'package:expense_tracker/features/settings/domain/usecases/update_settings.dart';

import '../../data/datasources/onboarding_local_datasource.dart';

/// Settings saved before onboarding existed have no onboarding flag. On the
/// first start after the update, an install that already has data counts as
/// onboarded; one without data sees onboarding. A known flag is never
/// changed here.
class ResolveOnboardingStatus {
  final GetSettings getSettings;
  final UpdateSettings updateSettings;
  final OnboardingLocalDatasource local;

  ResolveOnboardingStatus({
    required this.getSettings,
    required this.updateSettings,
    required this.local,
  });

  /// Whether onboarding is done.
  Future<Either<Failure, bool>> call() async {
    final loaded = await getSettings(NoParams());

    return loaded.fold(Left.new, (settings) async {
      final known = settings.onboardingCompleted;
      if (known != null) return Right(known);
      final completed = await local.hasUserData();
      final saved = await updateSettings(
        settings.copyWith(
          onboardingCompleted: completed,
          updatedAt: DateTime.now().toUtc(),
        ),
      );

      return saved.map((_) => completed);
    });
  }
}
