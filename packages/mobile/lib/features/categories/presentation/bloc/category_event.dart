import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import '../../domain/entities/category.dart';

abstract class CategoryEvent extends Equatable {
  @override
  List<Object?> get props => [];

  const CategoryEvent();
}

class LoadCategories extends CategoryEvent {
  final RecordType? type;
  final bool sortByUsage;

  @override
  List<Object?> get props => [type, sortByUsage];

  const LoadCategories({this.type, this.sortByUsage = false});
}

class CreateCategoryEvent extends CategoryEvent {
  final Category category;

  @override
  List<Object?> get props => [category];

  const CreateCategoryEvent(this.category);
}

class UpdateCategoryEvent extends CategoryEvent {
  final Category category;

  @override
  List<Object?> get props => [category];

  const UpdateCategoryEvent(this.category);
}

class DeleteCategoryEvent extends CategoryEvent {
  final String id;

  @override
  List<Object?> get props => [id];

  const DeleteCategoryEvent(this.id);
}

class SearchCategoriesEvent extends CategoryEvent {
  final String query;
  final RecordType? type;

  @override
  List<Object?> get props => [query, type];

  const SearchCategoriesEvent({required this.query, this.type});
}
