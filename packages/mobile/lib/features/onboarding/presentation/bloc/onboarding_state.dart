import 'package:equatable/equatable.dart';

import '../../domain/entities/onboarding_draft.dart';
import '../../domain/entities/onboarding_result.dart';

enum OnboardingStatus { editing, saving, done, failure }

class OnboardingState extends Equatable {
  /// The five setup pages.
  static const stepCount = 5;

  final OnboardingDraft draft;

  /// 0 to [stepCount] - 1.
  final int step;

  /// Rows on the recurring page before Continue copies them to [draft].
  final List<RecurringDraft> pendingRecurring;
  final OnboardingStatus status;
  final OnboardingResult? result;
  final String? errorText;

  bool get canGoBack => step > 0 && status == OnboardingStatus.editing;

  @override
  List<Object?> get props => [
    draft,
    step,
    pendingRecurring,
    status,
    result,
    errorText,
  ];

  const OnboardingState({
    this.draft = const OnboardingDraft(),
    this.step = 0,
    this.pendingRecurring = const [],
    this.status = OnboardingStatus.editing,
    this.result,
    this.errorText,
  });

  /// [errorText] is cleared unless given.
  OnboardingState copyWith({
    OnboardingDraft? draft,
    int? step,
    List<RecurringDraft>? pendingRecurring,
    OnboardingStatus? status,
    OnboardingResult? result,
    String? errorText,
  }) {
    return OnboardingState(
      draft: draft ?? this.draft,
      step: step ?? this.step,
      pendingRecurring: pendingRecurring ?? this.pendingRecurring,
      status: status ?? this.status,
      result: result ?? this.result,
      errorText: errorText,
    );
  }
}
