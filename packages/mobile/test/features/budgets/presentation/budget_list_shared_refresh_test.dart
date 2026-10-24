import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_bloc.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_event.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_state.dart';
import 'package:expense_tracker/features/budgets/presentation/pages/budget_list_page.dart';
import 'package:expense_tracker/features/family/domain/entities/cached.dart';
import 'package:expense_tracker/features/family/domain/entities/my_group.dart';
import 'package:expense_tracker/features/family/domain/repositories/family_repository.dart';
import 'package:expense_tracker/features/family/domain/usecases/get_group_summary.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/core_screens.dart';
import '../../../support/factories/family_factory.dart';
import '../../../support/pump_localized.dart';

class _MockFamilyRepository extends Mock implements FamilyRepository {}

class _MockGetGroupSummary extends Mock implements GetGroupSummary {}

class _FakeBudgetEvent extends Fake implements BudgetEvent {}

void main() {
  late _MockFamilyRepository repository;
  late _MockGetGroupSummary getSummary;
  late MockBudgetBloc bloc;
  MyGroup? cachedGroup;

  setUpAll(() {
    registerFallbackValue(const GroupIdParams('x'));
    registerFallbackValue(_FakeBudgetEvent());
  });

  setUp(() {
    repository = _MockFamilyRepository();
    getSummary = _MockGetGroupSummary();
    when(() => repository.cachedGroup).thenAnswer((_) => cachedGroup);
    when(() => getSummary(any())).thenAnswer(
      (_) async => Right(Cached(makeGroupSummary(), fetchedAt: DateTime(2026))),
    );
    di.getIt
      ..registerSingleton<FamilyRepository>(repository)
      ..registerSingleton<GetGroupSummary>(getSummary);
    bloc = mockBloc<MockBudgetBloc, BudgetState>(
      MockBudgetBloc(),
      const BudgetLoaded([]),
    );
    when(() => bloc.add(any())).thenReturn(null);
  });

  tearDown(() async {
    await di.getIt.unregister<FamilyRepository>();
    await di.getIt.unregister<GetGroupSummary>();
  });

  Future<void> pumpList(WidgetTester tester) => pumpLocalized(
    tester,
    const BudgetListView(),
    wrap: (app) => BlocProvider<BudgetBloc>.value(value: bloc, child: app),
  );

  testWidgets('in a group, opening the tab fetches the summary and reloads', (
    tester,
  ) async {
    cachedGroup = makeMyGroup();

    await pumpList(tester);
    await tester.pump();

    verify(() => getSummary(const GroupIdParams('group-1'))).called(1);
    verify(() => bloc.add(const LoadBudgets())).called(1);
  });

  testWidgets('outside a group no summary is requested', (tester) async {
    cachedGroup = null;

    await pumpList(tester);
    await tester.pump();

    verifyNever(() => getSummary(any()));
  });
}
