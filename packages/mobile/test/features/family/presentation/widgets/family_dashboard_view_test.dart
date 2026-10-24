import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/family/domain/entities/cached.dart';
import 'package:expense_tracker/features/family/domain/entities/group_summary.dart';
import 'package:expense_tracker/features/family/domain/entities/my_group.dart';
import 'package:expense_tracker/features/family/presentation/bloc/family_bloc.dart';
import 'package:expense_tracker/features/family/presentation/bloc/family_event.dart';
import 'package:expense_tracker/features/family/presentation/bloc/family_state.dart';
import 'package:expense_tracker/features/family/presentation/pages/family_home_page.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../support/factories/family_factory.dart';
import '../../../../support/family_bloc_mock.dart';

void main() {
  final at = DateTime.utc(2026, 4, 15, 12);

  setUpAll(registerFamilyEventFallback);

  FamilyState stateWith({
    Cached<GroupSummary>? summary,
    Failure? summaryFailure,
  }) => FamilyState(
    status: FamilyStatus.ready,
    group: Cached<MyGroup?>(makeMyGroup(), fetchedAt: at),
    summary: summary,
    summaryFailure: summaryFailure,
  );

  Future<MockFamilyBloc> pumpHome(
    WidgetTester tester,
    FamilyState state,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final bloc = familyBlocWith(state);
    final router = GoRouter(
      initialLocation: '/settings/family',
      routes: [
        GoRoute(
          path: '/settings/family',
          builder: (_, _) => BlocProvider<FamilyBloc>.value(
            value: bloc,
            child: const FamilyHomePage(),
          ),
          routes: [
            GoRoute(
              path: 'members',
              builder: (_, _) => const Text('members-page'),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      TranslationProvider(child: MaterialApp.router(routerConfig: router)),
    );
    await tester.pump();

    return bloc;
  }

  testWidgets('shows Spent of planned in the group currency and no income', (
    tester,
  ) async {
    await pumpHome(
      tester,
      stateWith(
        summary: Cached(makeGroupSummary(currencyCode: 'USD'), fetchedAt: at),
      ),
    );

    expect(find.text(t.family.dashboard.spentOfPlanned), findsOneWidget);
    expect(
      find.text(
        t.family.dashboard.spentOfPlannedValue(
          spent: CurrencyFormatter.formatIn(120.5, 'USD'),
          planned: CurrencyFormatter.formatIn(1000, 'USD'),
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining(RegExp('income|balance', caseSensitive: false)),
      findsNothing,
    );
  });

  testWidgets('the gear opens Member Management', (tester) async {
    await pumpHome(
      tester,
      stateWith(summary: Cached(makeGroupSummary(), fetchedAt: at)),
    );

    await tester.tap(find.byTooltip(t.family.dashboard.manageMembers));
    await tester.pumpAndSettle();

    expect(find.text('members-page'), findsOneWidget);
  });

  testWidgets('a summary failure shows the retry', (tester) async {
    final bloc = await pumpHome(
      tester,
      stateWith(summaryFailure: const NetworkFailure(message: 'offline')),
    );

    expect(find.text(t.family.dashboard.summaryFailed), findsOneWidget);
    await tester.tap(find.text(t.common.tryAgain));

    verify(() => bloc.add(const FamilyRefreshRequested())).called(1);
  });
}
