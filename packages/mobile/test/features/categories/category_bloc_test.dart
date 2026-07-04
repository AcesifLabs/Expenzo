import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/domain/usecases/get_categories.dart';
import 'package:expense_tracker/features/categories/domain/usecases/create_category.dart';
import 'package:expense_tracker/features/categories/domain/usecases/update_category.dart';
import 'package:expense_tracker/features/categories/domain/usecases/delete_category.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_event.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_state.dart';

class MockGetCategories extends Mock implements GetCategories {}

class MockCreateCategory extends Mock implements CreateCategory {}

void main() {
  late MockGetCategories mockGetCategories;
  late MockCreateCategory mockCreateCategory;
  late CategoryBloc bloc;

  final testCategory = Category(
    id: 'cat-1',
    name: 'Groceries',
    emoji: '🛒',
    color: '#FF0000',
    type: RecordType.expense,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUpAll(() {
    registerFallbackValue(_GetCategoriesParamsFake());
    registerFallbackValue(_CategoryFake());
  });

  setUp(() {
    mockGetCategories = MockGetCategories();
    mockCreateCategory = MockCreateCategory();
    bloc = CategoryBloc(
      getCategories: mockGetCategories,
      createCategory: mockCreateCategory,
      updateCategory: MockUpdateCategory(),
      deleteCategory: MockDeleteCategory(),
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('LoadCategories', () {
    test('emits [CategoryLoading, CategoryLoaded] on success', () async {
      when(
        () => mockGetCategories(any()),
      ).thenAnswer((_) async => Right([testCategory]));

      final expected = [
        isA<CategoryLoading>(),
        isA<CategoryLoaded>().having(
          (s) => s.categories.length,
          'categories length',
          1,
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const LoadCategories(type: RecordType.expense));
    });

    test('emits [CategoryLoading, CategoryError] on failure', () async {
      when(
        () => mockGetCategories(any()),
      ).thenAnswer((_) async => Left(ServerFailure(message: 'Failed to load')));

      final expected = [
        isA<CategoryLoading>(),
        isA<CategoryError>().having(
          (s) => s.message,
          'message',
          'Failed to load',
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(const LoadCategories());
    });
  });

  group('CreateCategoryEvent', () {
    test('emits loading then reloads after create success', () async {
      when(
        () => mockCreateCategory(any()),
      ).thenAnswer((_) async => Right(testCategory));
      when(
        () => mockGetCategories(any()),
      ).thenAnswer((_) async => Right([testCategory]));

      final expected = [
        isA<CategoryLoading>(),
        isA<CategoryLoaded>().having((s) => s.categories, 'categories', [
          testCategory,
        ]),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(CreateCategoryEvent(testCategory));
    });

    test('emits [CategoryLoading, CategoryError] on create failure', () async {
      when(
        () => mockCreateCategory(any()),
      ).thenAnswer((_) async => Left(ServerFailure(message: 'Create failed')));

      final expected = [
        isA<CategoryLoading>(),
        isA<CategoryError>().having(
          (s) => s.message,
          'message',
          'Create failed',
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expected));
      bloc.add(CreateCategoryEvent(testCategory));
    });
  });
}

class MockUpdateCategory extends Mock implements UpdateCategory {}

class MockDeleteCategory extends Mock implements DeleteCategory {}

class _GetCategoriesParamsFake extends Fake implements GetCategoriesParams {}

class _CategoryFake extends Fake implements Category {}
