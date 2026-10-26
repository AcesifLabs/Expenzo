import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/bloc/transformers.dart';
import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';

import '../../domain/entities/onboarding_draft.dart';
import '../../domain/usecases/complete_onboarding.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final CompleteOnboarding completeOnboarding;
  final GetSettings getSettings;

  OnboardingBloc({required this.completeOnboarding, required this.getSettings})
    : super(const OnboardingState()) {
    on<OnboardingStarted>(_onStarted, transformer: concurrent());
    on<IncomeSubmitted>(_onIncome, transformer: concurrent());
    on<RecurringItemAdded>(_onItemAdded, transformer: concurrent());
    on<RecurringItemRemoved>(_onItemRemoved, transformer: concurrent());
    on<RecurringSubmitted>(_onRecurring, transformer: concurrent());
    on<BudgetPlanSubmitted>(_onPlan, transformer: concurrent());
    on<GoalSubmitted>(_onGoal, transformer: concurrent());
    on<GoalDeclined>(_onGoalDeclined, transformer: concurrent());
    on<TimelineChosen>(_onTimeline, transformer: concurrent());
    on<OnboardingStepBack>(_onBack, transformer: concurrent());
    on<OnboardingFinished>(_onSave, transformer: droppable());
    on<OnboardingSkipped>(_onSave, transformer: droppable());
  }

  Future<void> _onStarted(
    OnboardingStarted event,
    Emitter<OnboardingState> emit,
  ) async {
    final loaded = await getSettings(NoParams());
    final income = loaded.fold((_) => null, (s) => s.monthlyIncome);

    if (income == null || state.draft.monthlyIncome != null) return;
    emit(state.copyWith(draft: state.draft.copyWith(monthlyIncome: income)));
  }

  void _onIncome(IncomeSubmitted event, Emitter<OnboardingState> emit) {
    emit(
      _advance(
        state.draft.copyWith(
          monthlyIncome: event.frequency.toMonthly(event.amount),
        ),
      ),
    );
  }

  void _onItemAdded(RecurringItemAdded event, Emitter<OnboardingState> emit) {
    emit(
      state.copyWith(pendingRecurring: [...state.pendingRecurring, event.item]),
    );
  }

  void _onItemRemoved(
    RecurringItemRemoved event,
    Emitter<OnboardingState> emit,
  ) {
    final items = [...state.pendingRecurring];
    if (event.index < 0 || event.index >= items.length) return;
    items.removeAt(event.index);
    emit(state.copyWith(pendingRecurring: items));
  }

  void _onRecurring(RecurringSubmitted event, Emitter<OnboardingState> emit) {
    emit(_advance(state.draft.copyWith(recurring: state.pendingRecurring)));
  }

  void _onPlan(BudgetPlanSubmitted event, Emitter<OnboardingState> emit) {
    emit(_advance(state.draft.copyWith(createBudgets: event.createBudgets)));
  }

  void _onGoal(GoalSubmitted event, Emitter<OnboardingState> emit) {
    final previous = state.draft.goal;

    final keep = previous?.targetAmount == event.target ? previous : null;
    emit(
      _advance(
        state.draft.copyWith(
          goal: GoalDraft(
            name: event.name,
            targetAmount: event.target,
            months: keep?.months,
            customDate: keep?.customDate,
          ),
        ),
      ),
    );
  }

  void _onGoalDeclined(GoalDeclined event, Emitter<OnboardingState> emit) {
    emit(_advance(state.draft.copyWith(clearGoal: true)));
  }

  void _onTimeline(TimelineChosen event, Emitter<OnboardingState> emit) {
    final goal = state.draft.goal;
    if (goal == null) return;
    emit(
      state.copyWith(
        draft: state.draft.copyWith(
          goal: goal.withTimeline(
            months: event.months,
            customDate: event.customDate,
          ),
        ),
      ),
    );
  }

  void _onBack(OnboardingStepBack event, Emitter<OnboardingState> emit) {
    if (!state.canGoBack) return;
    emit(state.copyWith(step: state.step - 1));
  }

  Future<void> _onSave(
    OnboardingEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    if (state.status == OnboardingStatus.saving ||
        state.status == OnboardingStatus.done) {
      return;
    }
    emit(state.copyWith(status: OnboardingStatus.saving));
    final result = await completeOnboarding(state.draft);
    emit(
      result.fold(
        (failure) => state.copyWith(
          status: OnboardingStatus.failure,
          errorText: failureText(failure),
        ),
        (saved) => state.copyWith(status: OnboardingStatus.done, result: saved),
      ),
    );
  }

  OnboardingState _advance(OnboardingDraft draft) => state.copyWith(
    draft: draft,
    step: (state.step + 1).clamp(0, OnboardingState.stepCount - 1),
    status: OnboardingStatus.editing,
  );
}
