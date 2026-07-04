import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_state.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_bloc.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_state.dart';
import 'package:expense_tracker/features/records/presentation/pages/record_list_page.dart';

class MockRecordBloc extends Mock implements RecordBloc {}

class MockCategoryBloc extends Mock implements CategoryBloc {}

void main() {
  late MockRecordBloc mockRecordBloc;
  late MockCategoryBloc mockCategoryBloc;

  setUp(() {
    mockRecordBloc = MockRecordBloc();
    mockCategoryBloc = MockCategoryBloc();

    when(() => mockRecordBloc.state).thenReturn(RecordInitial());
    when(
      () => mockRecordBloc.stream,
    ).thenAnswer((_) => Stream<RecordState>.value(RecordInitial()));
    when(() => mockRecordBloc.close()).thenAnswer((_) async {});
    when(() => mockCategoryBloc.state).thenReturn(const CategoryInitial());
    when(
      () => mockCategoryBloc.stream,
    ).thenAnswer((_) => Stream<CategoryState>.value(const CategoryInitial()));
    when(() => mockCategoryBloc.close()).thenAnswer((_) async {});

    di.getIt.registerFactory<RecordBloc>(() => mockRecordBloc);
    di.getIt.registerFactory<CategoryBloc>(() => mockCategoryBloc);
  });

  tearDown(() => di.getIt.reset());

  Widget createTestWidget() {
    return const MaterialApp(home: RecordListPage());
  }

  testWidgets('record list page renders without error', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pump();

    expect(find.byType(RecordListPage), findsOneWidget);
  });
}
