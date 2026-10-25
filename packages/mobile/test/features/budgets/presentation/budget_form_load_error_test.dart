import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/budgets/domain/repositories/budget_repository.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_bloc.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_state.dart';
import 'package:expense_tracker/features/budgets/presentation/pages/budget_form_page.dart';
import 'package:expense_tracker/features/family/domain/services/budget_access.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_error_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/core_screens.dart';
import '../../../support/pump_localized.dart';

class _MockBudgetRepository extends Mock implements BudgetRepository {}

void main() {
  late _MockBudgetRepository budgets;

  setUp(() {
    budgets = _MockBudgetRepository();
    di.getIt.registerSingleton<BudgetRepository>(budgets);
    di.getIt.registerSingleton(BudgetAccess(currentGroup: () => null));
  });

  tearDown(() async {
    await di.getIt.reset();
  });

  testWidgets('a failed budget load shows AppErrorState with retry', (
    tester,
  ) async {
    when(() => budgets.getBudgetById('missing')).thenAnswer(
      (_) async => const Left(CacheFailure(message: 'Budget not found')),
    );

    await pumpLocalized(
      tester,
      const BudgetFormPage(budgetId: 'missing'),
      wrap: (app) => BlocProvider<BudgetBloc>.value(
        value: mockBloc<MockBudgetBloc, BudgetState>(
          MockBudgetBloc(),
          const BudgetInitial(),
        ),
        child: app,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppErrorState), findsOneWidget);
    expect(find.text(t.common.errors.storage), findsOneWidget);
    expect(find.text(t.common.tryAgain), findsOneWidget);
  });
}
