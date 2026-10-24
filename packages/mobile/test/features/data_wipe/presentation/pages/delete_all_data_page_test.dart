import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/features/data_wipe/domain/entities/local_data_summary.dart';
import 'package:expense_tracker/features/data_wipe/presentation/bloc/delete_all_data_bloc.dart';
import 'package:expense_tracker/features/data_wipe/presentation/bloc/delete_all_data_event.dart';
import 'package:expense_tracker/features/data_wipe/presentation/bloc/delete_all_data_state.dart';
import 'package:expense_tracker/features/data_wipe/presentation/pages/delete_all_data_page.dart';

import '../../../../support/core_screens.dart';
import '../../../../support/pump_localized.dart';

class _MockDeleteAllDataBloc extends Mock implements DeleteAllDataBloc {}

const _summary = LocalDataSummary(
  transactions: 3,
  budgets: 1,
  categories: 18,
  recurring: 2,
  smsRules: 0,
);

void main() {
  late _MockDeleteAllDataBloc bloc;

  Future<void> pump(WidgetTester tester, DeleteAllDataState state) async {
    await tester.binding.setSurfaceSize(const Size(400, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    bloc = mockBloc(_MockDeleteAllDataBloc(), state);
    await pumpLocalized(
      tester,
      Scaffold(
        body: BlocProvider<DeleteAllDataBloc>.value(
          value: bloc,
          child: const DeleteAllDataView(),
        ),
      ),
    );
  }

  ElevatedButton button(WidgetTester tester) =>
      tester.widget<ElevatedButton>(find.byType(ElevatedButton));

  testWidgets('the button is disabled until DELETE is typed', (tester) async {
    await pump(
      tester,
      const DeleteAllDataState(
        status: DeleteAllDataStatus.ready,
        summary: _summary,
      ),
    );

    expect(button(tester).onPressed, isNull);
  });

  testWidgets('the button is enabled once the bloc allows it', (tester) async {
    await pump(
      tester,
      const DeleteAllDataState(
        status: DeleteAllDataStatus.ready,
        confirmation: 'DELETE',
      ),
    );

    await tester.tap(find.byType(ElevatedButton));

    verify(() => bloc.add(const DeleteAllRequested())).called(1);
  });

  testWidgets('typing sends the confirmation text', (tester) async {
    await pump(
      tester,
      const DeleteAllDataState(status: DeleteAllDataStatus.ready),
    );

    await tester.enterText(find.byType(TextField), 'DELETE');

    verify(() => bloc.add(const DeleteConfirmationChanged('DELETE'))).called(1);
  });

  testWidgets('signed in, the other-devices note is shown', (tester) async {
    await pump(
      tester,
      const DeleteAllDataState(
        status: DeleteAllDataStatus.ready,
        isSignedIn: true,
      ),
    );

    expect(
      find.textContaining('Your other devices keep their copy'),
      findsOneWidget,
    );
  });

  testWidgets('signed out, the note is not shown', (tester) async {
    await pump(
      tester,
      const DeleteAllDataState(status: DeleteAllDataStatus.ready),
    );

    expect(
      find.textContaining('Your other devices keep their copy'),
      findsNothing,
    );
  });

  testWidgets('the counts render', (tester) async {
    await pump(
      tester,
      const DeleteAllDataState(
        status: DeleteAllDataStatus.ready,
        summary: _summary,
      ),
    );

    expect(find.text('3 transactions'), findsOneWidget);
    expect(find.text('1 budget'), findsOneWidget);
    expect(find.text('18 categories'), findsOneWidget);
    expect(find.text('Goals'), findsNothing);
  });

  testWidgets('without a summary the counts are hidden', (tester) async {
    await pump(
      tester,
      const DeleteAllDataState(status: DeleteAllDataStatus.ready),
    );

    expect(find.text('Transactions'), findsOneWidget);
    expect(find.textContaining(RegExp(r'^\d')), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('while deleting there is no back button', (tester) async {
    await pump(
      tester,
      const DeleteAllDataState(
        status: DeleteAllDataStatus.deleting,
        confirmation: 'DELETE',
      ),
    );

    expect(button(tester).onPressed, isNull);
    expect(find.text('Deleting…'), findsOneWidget);
  });

  testWidgets('lists goals when there are some', (tester) async {
    await pump(
      tester,
      const DeleteAllDataState(
        status: DeleteAllDataStatus.ready,
        summary: LocalDataSummary(
          transactions: 3,
          budgets: 1,
          categories: 18,
          recurring: 2,
          smsRules: 0,
          goals: 1,
        ),
      ),
    );

    expect(find.text(t.settings.deleteData.goals), findsOneWidget);
    expect(find.text('1 goal'), findsOneWidget);
  });
}
