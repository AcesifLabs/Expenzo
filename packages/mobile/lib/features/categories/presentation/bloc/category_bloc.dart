import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import '../../domain/usecases/create_category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/update_category.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategories getCategories;
  final CreateCategory createCategory;
  final UpdateCategory updateCategory;
  final DeleteCategory deleteCategory;
  RecordType? _lastRequestedType;

  CategoryBloc({
    required this.getCategories,
    required this.createCategory,
    required this.updateCategory,
    required this.deleteCategory,
  }) : super(const CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<CreateCategoryEvent>(_onCreateCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    _lastRequestedType = event.type;
    emit(const CategoryLoading());
    final result = await getCategories(
      GetCategoriesParams(type: event.type, sortByUsage: event.sortByUsage),
    );
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (categories) => emit(CategoryLoaded(categories, type: event.type)),
    );
  }

  Future<void> _onCreateCategory(
    CreateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    final result = await createCategory(event.category);
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (_) => add(LoadCategories(type: _lastRequestedType, sortByUsage: true)),
    );
  }

  Future<void> _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    final result = await updateCategory(event.category);
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (_) => add(LoadCategories(type: _lastRequestedType, sortByUsage: true)),
    );
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());
    final result = await deleteCategory(event.id);
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (_) => add(LoadCategories(type: _lastRequestedType, sortByUsage: true)),
    );
  }
}
