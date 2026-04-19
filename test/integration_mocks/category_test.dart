import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';
import 'package:expense_tracker/features/categories/domain/usecases/create_category.dart';
import 'package:expense_tracker/features/categories/domain/usecases/update_category.dart';
import 'package:expense_tracker/features/categories/domain/usecases/delete_category.dart';
import 'package:expense_tracker/features/categories/domain/usecases/get_categories.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  group('Category Use Case Tests', () {
    late MockCategoryRepository mockRepository;
    late GetCategories getCategoriesUseCase;
    late CreateCategory createCategoryUseCase;
    late UpdateCategory updateCategoryUseCase;
    late DeleteCategory deleteCategoryUseCase;

    final now = DateTime.now();
    final testCategory = Category(
      id: 1,
      name: 'Food',
      emoji: '🍔',
      color: '#FF5733',
      isDefault: false,
      createdAt: now,
      updatedAt: now,
    );

    final testCategories = [
      testCategory,
      Category(
        id: 2,
        name: 'Transport',
        emoji: '🚗',
        color: '#33FF57',
        isDefault: false,
        createdAt: now,
        updatedAt: now,
      ),
    ];

    setUpAll(() {
      registerFallbackValue(testCategory);
      registerFallbackValue(DateTime.now());
    });

    setUp(() {
      mockRepository = MockCategoryRepository();
      getCategoriesUseCase = GetCategories(mockRepository);
      createCategoryUseCase = CreateCategory(mockRepository);
      updateCategoryUseCase = UpdateCategory(mockRepository);
      deleteCategoryUseCase = DeleteCategory(mockRepository);
    });

    test('getCategories returns list of categories', () async {
      when(
        () => mockRepository.getCategories(),
      ).thenAnswer((_) async => Right(testCategories));

      final result = await getCategoriesUseCase(NoParams());

      expect(result.isRight(), true);
      result.fold((failure) => fail('Should not return failure'), (categories) {
        expect(categories.length, 2);
        expect(categories.first.name, 'Food');
      });
    });

    test('createCategory creates and returns category', () async {
      when(
        () => mockRepository.createCategory(any()),
      ).thenAnswer((_) async => Right(testCategory));

      final result = await createCategoryUseCase(testCategory);

      expect(result.isRight(), true);
      verify(() => mockRepository.createCategory(testCategory)).called(1);
    });

    test('updateCategory updates and returns category', () async {
      when(
        () => mockRepository.updateCategory(any()),
      ).thenAnswer((_) async => Right(testCategory));

      final result = await updateCategoryUseCase(testCategory);

      expect(result.isRight(), true);
      verify(() => mockRepository.updateCategory(testCategory)).called(1);
    });

    test('deleteCategory deletes successfully', () async {
      when(
        () => mockRepository.deleteCategory(any()),
      ).thenAnswer((_) async => const Right(unit));

      await deleteCategoryUseCase(1);

      verify(() => mockRepository.deleteCategory(1)).called(1);
    });

    test('watchCategories returns stream of categories', () async {
      when(
        () => mockRepository.watchCategories(),
      ).thenAnswer((_) => Stream.value(testCategories));

      await expectLater(
        mockRepository.watchCategories(),
        emits(testCategories),
      );
    });

    test('getCategoryById returns category', () async {
      when(
        () => mockRepository.getCategoryById(any()),
      ).thenAnswer((_) async => Right(testCategory));

      final result = await mockRepository.getCategoryById(1);

      expect(result.isRight(), true);
      result.fold((failure) => fail('Should not return failure'), (category) {
        expect(category, testCategory);
        expect(category.id, 1);
      });
    });
  });

  group('Category Entity Tests', () {
    test('should create category with required fields', () {
      final now = DateTime.now();
      final category = Category(
        name: 'Food',
        emoji: '🍔',
        color: '#FF5733',
        createdAt: now,
        updatedAt: now,
      );

      expect(category.name, 'Food');
      expect(category.emoji, '🍔');
      expect(category.color, '#FF5733');
      expect(category.id, null);
      expect(category.isDefault, false);
    });

    test('should create category with all fields', () {
      final now = DateTime.now();
      final category = Category(
        id: 1,
        name: 'Transport',
        emoji: '🚗',
        color: '#33FF57',
        isDefault: true,
        createdAt: now,
        updatedAt: now,
      );

      expect(category.id, 1);
      expect(category.name, 'Transport');
      expect(category.emoji, '🚗');
      expect(category.color, '#33FF57');
      expect(category.isDefault, true);
    });

    test('should copy category with updated fields', () {
      final now = DateTime.now();
      final original = Category(
        id: 1,
        name: 'Food',
        emoji: '🍔',
        color: '#FF5733',
        createdAt: now,
        updatedAt: now,
      );

      final updated = original.copyWith(name: 'Groceries', emoji: '🛒');

      expect(updated.id, 1);
      expect(updated.name, 'Groceries');
      expect(updated.emoji, '🛒');
      expect(updated.color, '#FF5733');
    });

    test('should support equatable equality', () {
      final now = DateTime.now();
      final category1 = Category(
        id: 1,
        name: 'Food',
        emoji: '🍔',
        color: '#FF5733',
        createdAt: now,
        updatedAt: now,
      );
      final category2 = Category(
        id: 1,
        name: 'Food',
        emoji: '🍔',
        color: '#FF5733',
        createdAt: now,
        updatedAt: now,
      );

      expect(category1, equals(category2));
    });
  });
}
