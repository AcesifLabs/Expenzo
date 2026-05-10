import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/records/presentation/widgets/record_filter_modal.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_bloc.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_state.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_event.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MockRecordBloc extends Mock implements RecordBloc {}
class MockCategoryBloc extends Mock implements CategoryBloc {}
class FakeCategoryEvent extends Fake implements CategoryEvent {}

void main() {
  late MockRecordBloc mockRecordBloc;
  late MockCategoryBloc mockCategoryBloc;

  setUpAll(() {
    registerFallbackValue(FakeCategoryEvent());
  });

  setUp(() {
    mockRecordBloc = MockRecordBloc();
    mockCategoryBloc = MockCategoryBloc();

    when(() => mockCategoryBloc.state).thenReturn(const CategoryLoaded([], type: null));
    when(() => mockRecordBloc.state).thenReturn(const RecordInitial());
    when(() => mockCategoryBloc.add(any())).thenReturn(null);
    when(() => mockCategoryBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockRecordBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCategoryBloc.close()).thenAnswer((_) async => null);
    when(() => mockRecordBloc.close()).thenAnswer((_) async => null);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: MultiBlocProvider(
          providers: [
            BlocProvider<RecordBloc>.value(value: mockRecordBloc),
            BlocProvider<CategoryBloc>.value(value: mockCategoryBloc),
          ],
          child: RecordFilterModal(
            onApply: ({startDate, endDate, categoryIds, recordType}) {},
            onClear: () {},
          ),
        ),
      ),
    );
  }

  testWidgets('should render modal with core sections', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    expect(find.text('Filter Records'), findsOneWidget);
    expect(find.text('Date Range'), findsOneWidget);
    expect(find.text('Record Type'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Apply Filter'), findsOneWidget);
    expect(find.text('Clear Filter'), findsOneWidget);
  });

  testWidgets('should show date range picker when date section tapped', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pump();

    await tester.tap(find.text('Select date range'));
    await tester.pumpAndSettle();

    expect(find.byType(DateRangePickerDialog), findsOneWidget);
  });
}
