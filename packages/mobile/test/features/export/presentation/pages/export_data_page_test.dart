import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/features/export/domain/entities/export_request.dart';
import 'package:expense_tracker/features/export/presentation/bloc/export_bloc.dart';
import 'package:expense_tracker/features/export/presentation/bloc/export_event.dart';
import 'package:expense_tracker/features/export/presentation/bloc/export_state.dart';
import 'package:expense_tracker/features/export/presentation/pages/export_data_page.dart';

import '../../../../support/core_screens.dart';
import '../../../../support/pump_localized.dart';

class _MockExportBloc extends Mock implements ExportBloc {}

void main() {
  late _MockExportBloc bloc;

  Future<void> pump(WidgetTester tester, ExportState state) async {
    await tester.binding.setSurfaceSize(const Size(400, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    bloc = mockBloc(_MockExportBloc(), state);
    await pumpLocalized(
      tester,
      Scaffold(
        body: BlocProvider<ExportBloc>.value(
          value: bloc,
          child: ExportDataView(clock: () => DateTime(2026, 6, 30, 10)),
        ),
      ),
    );
  }

  testWidgets('shows the sections and no format choice', (tester) async {
    await pump(tester, const ExportState());

    expect(find.text('Export your financial data'), findsOneWidget);
    expect(find.text('DATE RANGE'), findsOneWidget);
    expect(find.text('INCLUDE'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('PDF'), findsNothing);
  });

  testWidgets('preset subtitles start on the range start until Present', (
    tester,
  ) async {
    await pump(tester, const ExportState());

    expect(find.text('Jan 1, 2026 – Present'), findsNWidgets(2));
    expect(find.text('Apr 1, 2026 – Present'), findsOneWidget);
  });

  testWidgets('a picked custom range shows its dates', (tester) async {
    await pump(
      tester,
      ExportState(
        range: ExportRange.custom,
        customStart: DateTime(2026, 3, 5),
        customEnd: DateTime(2026, 3, 20),
      ),
    );

    expect(find.text('Mar 5, 2026 – Mar 20, 2026'), findsOneWidget);
  });

  testWidgets('tapping Export adds ExportRequested', (tester) async {
    await pump(tester, const ExportState());

    await tester.tap(find.widgetWithText(ElevatedButton, 'Export data'));

    verify(() => bloc.add(const ExportRequested())).called(1);
  });

  testWidgets('Custom range opens the picker and selects nothing yet', (
    tester,
  ) async {
    await pump(tester, const ExportState());

    await tester.tap(find.text('Custom range'));
    await tester.pumpAndSettle();

    expect(find.byType(DateRangePickerDialog), findsOneWidget);
    verifyNever(() => bloc.add(const ExportRangeSelected(ExportRange.custom)));
  });

  testWidgets('a preset row adds ExportRangeSelected', (tester) async {
    await pump(tester, const ExportState());

    await tester.tap(find.text('This year'));

    verify(
      () => bloc.add(const ExportRangeSelected(ExportRange.thisYear)),
    ).called(1);
  });

  testWidgets('an empty range shows its message', (tester) async {
    await pump(
      tester,
      const ExportState(
        status: ExportStatus.empty,
        errorMessage: 'No transactions in this range',
      ),
    );

    expect(find.text('No transactions in this range'), findsOneWidget);
  });

  testWidgets('with nothing selected the button is disabled', (tester) async {
    await pump(tester, const ExportState(contents: {}));

    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Export data'),
    );

    expect(button.onPressed, isNull);
    expect(find.text('Choose at least one thing to export'), findsOneWidget);
  });

  testWidgets('while exporting the button is disabled and says so', (
    tester,
  ) async {
    await pump(tester, const ExportState(status: ExportStatus.exporting));

    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Preparing export…'),
    );

    expect(button.onPressed, isNull);
  });
}
