import 'package:get_it/get_it.dart';
import 'package:expense_tracker/core/database/daos/category_dao.dart';
import 'package:expense_tracker/features/categories/data/datasources/category_local_datasource.dart';
import 'package:expense_tracker/features/categories/data/repositories/category_repository_impl.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';
import 'package:expense_tracker/features/categories/domain/usecases/create_category.dart';
import 'package:expense_tracker/features/categories/domain/usecases/delete_category.dart';
import 'package:expense_tracker/features/categories/domain/usecases/get_categories.dart';
import 'package:expense_tracker/features/categories/domain/usecases/update_category.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';

void initCategoryModule(GetIt getIt) {
  getIt.registerLazySingleton<CategoryLocalDatasource>(
    () => CategoryLocalDatasourceImpl(categoryDao: getIt<CategoryDao>()),
  );
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(
      localDatasource: getIt<CategoryLocalDatasource>(),
    ),
  );
  getIt.registerLazySingleton(() => GetCategories(getIt<CategoryRepository>()));
  getIt.registerLazySingleton(
    () => CreateCategory(getIt<CategoryRepository>()),
  );
  getIt.registerLazySingleton(
    () => UpdateCategory(getIt<CategoryRepository>()),
  );
  getIt.registerLazySingleton(
    () => DeleteCategory(getIt<CategoryRepository>()),
  );
  getIt.registerFactory<CategoryBloc>(
    () => CategoryBloc(
      getCategories: getIt<GetCategories>(),
      createCategory: getIt<CreateCategory>(),
      updateCategory: getIt<UpdateCategory>(),
      deleteCategory: getIt<DeleteCategory>(),
    ),
  );
}
