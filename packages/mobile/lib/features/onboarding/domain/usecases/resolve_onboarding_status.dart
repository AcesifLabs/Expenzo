import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';
import 'package:expense_tracker/features/settings/domain/usecases/update_settings.dart';

import '../../data/datasources/onboarding_local_datasource.dart';

class ResolveOnboardingStatus {
  final GetSettings getSettings;
  final UpdateSettings updateSettings;
  final OnboardingLocalDatasource local;

  ResolveOnboardingStatus({
    required this.getSettings,
    required this.updateSettings,
    required this.local,
  });

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
