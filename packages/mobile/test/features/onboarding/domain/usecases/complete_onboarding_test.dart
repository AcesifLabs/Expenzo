import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/constants/budget_period.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/budgets/domain/entities/budget.dart';
import 'package:expense_tracker/features/budgets/domain/entities/plan_row.dart';
import 'package:expense_tracker/features/budgets/domain/repositories/budget_repository.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal.dart';
import 'package:expense_tracker/features/goals/domain/repositories/goal_repository.dart';
import 'package:expense_tracker/features/onboarding/domain/entities/onboarding_draft.dart';
import 'package:expense_tracker/features/onboarding/domain/entities/onboarding_result.dart';
import 'package:expense_tracker/features/onboarding/domain/usecases/complete_onboarding.dart';
import 'package:expense_tracker/features/recurring/domain/entities/recurring_transaction.dart';
import 'package:expense_tracker/features/recurring/domain/repositories/recurring_repository.dart';
import 'package:expense_tracker/features/settings/domain/entities/user_settings.dart';
import 'package:expense_tracker/features/settings/domain/repositories/settings_repository.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import '../../presentation/widgets/onboarding_test_harness.dart'
    show suggestedRows;

class _MockRecurring extends Mock implements RecurringRepository {}

class _MockBudgets extends Mock implements BudgetRepository {}

class _MockGoals extends Mock implements GoalRepository {}

class _MockSettings extends Mock implements SettingsRepository {}

void main() {
  late _MockRecurring recurring;
  late _MockBudgets budgets;
  late _MockGoals goals;
  late _MockSettings settings;
  late CompleteOnboarding complete;
  final now = DateTime(2026, 10, 24, 9);

  final stored = UserSettings(
    currencyCode: 'BDT',
    emailFetchLimit: 100,
    notificationsEnabled: true,
    theme: 'system',
    onboardingCompleted: false,
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  const rent = RecurringDraft(
    description: 'Rent',
    amount: 1200,
    frequency: RecurringFrequency.monthly,
  );
  const netflix = RecurringDraft(
    description: 'Netflix',
    amount: 25,
    frequency: RecurringFrequency.monthly,
  );
  const fullDraft = OnboardingDraft(
    monthlyIncome: 5000,
    recurring: [rent, netflix],
    budgetRows: suggestedRows,
    goal: GoalDraft(name: 'Laptop', targetAmount: 1999, months: 3),
  );

  setUpAll(() {
    registerFallbackValue(
      RecurringTransaction(
        description: 'x',
        amount: 1,
        frequency: RecurringFrequency.monthly,
        startDate: DateTime(2026),
        nextOccurrence: DateTime(2026),
      ),
    );
    registerFallbackValue(
      Budget(
        name: 'x',
        amount: 1,
        period: BudgetPeriod.monthly,
        startDate: DateTime(2026),
      ),
    );
    registerFallbackValue(const Goal(name: 'x', targetAmount: 1));
    registerFallbackValue(stored);
  });

  setUp(() {
    LocaleSettings.setLocaleSync(AppLocale.en);
    recurring = _MockRecurring();
    budgets = _MockBudgets();
    goals = _MockGoals();
    settings = _MockSettings();
    complete = CompleteOnboarding(
      recurringRepository: recurring,
      budgetRepository: budgets,
      goalRepository: goals,
      settingsRepository: settings,
    );
    when(() => recurring.createRecurring(any())).thenAnswer(
      (i) async => Right(i.positionalArguments.first as RecurringTransaction),
    );
    when(
      () => budgets.createBudget(any()),
    ).thenAnswer((i) async => Right(i.positionalArguments.first as Budget));
    when(
      () => goals.createGoal(any()),
    ).thenAnswer((i) async => Right(i.positionalArguments.first as Goal));
    when(() => settings.getSettings()).thenAnswer((_) async => Right(stored));
    when(() => settings.updateSettings(any())).thenAnswer(
      (i) async => Right(i.positionalArguments.first as UserSettings),
    );
  });

  tearDown(() => LocaleSettings.setLocaleSync(AppLocale.en));

  UserSettings savedSettings() =>
      verify(() => settings.updateSettings(captureAny())).captured.single
          as UserSettings;

  test(
    'a full draft saves recurring items, three budgets and the goal',
    () async {
      final result = await complete(fullDraft, now: now);

      expect(
        result,
        const Right<Failure, OnboardingResult>(
          OnboardingResult(
            recurringCount: 2,
            budgetsCreated: true,
            goalName: 'Laptop',
          ),
        ),
      );
      verify(() => recurring.createRecurring(any())).called(2);
      final created = verify(
        () => budgets.createBudget(captureAny()),
      ).captured.cast<Budget>();

      expect(created.map((b) => b.amount), [1887.5, 1132.5, 755.0]);
      expect(created.map((b) => b.name), ['Needs', 'Wants', 'Savings']);
      expect(
        created.every((b) => b.startDate == DateTime(2026, 10, 1)),
        isTrue,
      );
      final goal =
          verify(() => goals.createGoal(captureAny())).captured.single as Goal;
      expect(goal.targetDate, DateTime(2027, 1, 24));
      expect(goal.monthlyContribution, 1999 / 3);
      expect(goal.savedAmount, 0);
      final saved = savedSettings();
      expect(saved.onboardingCompleted, isTrue);
      expect(saved.monthlyIncome, 5000);
    },
  );

  test('an empty draft only marks onboarding done', () async {
    await complete(const OnboardingDraft(), now: now);

    verifyNever(() => recurring.createRecurring(any()));
    verifyNever(() => budgets.createBudget(any()));
    verifyNever(() => goals.createGoal(any()));
    expect(savedSettings().onboardingCompleted, isTrue);
  });

  test('skipped budgets create none', () async {
    await complete(
      const OnboardingDraft(monthlyIncome: 5000, budgetRows: []),
      now: now,
    );

    verifyNever(() => budgets.createBudget(any()));
  });

  test('rows at 0 are skipped and names are trimmed', () async {
    final result = await complete(
      const OnboardingDraft(
        budgetRows: [
          PlanRow(key: 'a', name: ' Food ', amount: 300),
          PlanRow(key: 'b', name: 'Empty', amount: 0),
        ],
      ),
      now: now,
    );

    final created =
        verify(() => budgets.createBudget(captureAny())).captured.single
            as Budget;
    expect(created.name, 'Food');
    expect(created.period, BudgetPeriod.monthly);
    expect(result.fold((_) => null, (r) => r.budgetsCreated), isTrue);
  });

  test('only zero rows create nothing and report no errors', () async {
    final result = await complete(
      const OnboardingDraft(
        budgetRows: [PlanRow(key: 'b', name: 'Empty', amount: 0)],
      ),
      now: now,
    );

    verifyNever(() => budgets.createBudget(any()));
    expect(result.fold((_) => null, (r) => r.hadErrors), isFalse);
  });

  test('a failed budget marks errors and skips the goal', () async {
    when(
      () => budgets.createBudget(any()),
    ).thenAnswer((_) async => const Left(CacheFailure(message: 'disk')));

    final result = await complete(fullDraft, now: now);

    expect(
      result.fold((_) => null, (r) => r),
      const OnboardingResult(recurringCount: 2, hadErrors: true),
    );
    verifyNever(() => goals.createGoal(any()));
  });

  test('recurring items start next period with auto-create on', () async {
    await complete(const OnboardingDraft(recurring: [rent]), now: now);

    final item =
        verify(() => recurring.createRecurring(captureAny())).captured.single
            as RecurringTransaction;
    expect(item.nextOccurrence, DateTime(2026, 11, 24));
    expect(item.autoCreateExpense, isTrue);
    expect(item.isDue(), isFalse);
  });

  test('a failed goal still marks onboarding done, with errors', () async {
    when(
      () => goals.createGoal(any()),
    ).thenAnswer((_) async => const Left(CacheFailure(message: 'disk')));

    final result = await complete(fullDraft, now: now);

    expect(
      result.fold((_) => null, (r) => r),
      const OnboardingResult(
        recurringCount: 2,
        budgetsCreated: true,
        hadErrors: true,
      ),
    );
    expect(savedSettings().onboardingCompleted, isTrue);
  });

  test('a failed settings write returns Left', () async {
    const failure = CacheFailure(message: 'prefs');
    when(
      () => settings.updateSettings(any()),
    ).thenAnswer((_) async => const Left(failure));

    expect(
      await complete(const OnboardingDraft(), now: now),
      const Left<Failure, OnboardingResult>(failure),
    );
  });
}
