import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import '../../domain/entities/category.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {
  final RecordType? type;
  final bool sortByUsage;
  const LoadCategories({this.type, this.sortByUsage = false});

  @override
  List<Object?> get props => [type, sortByUsage];
}

class CreateCategoryEvent extends CategoryEvent {
  final Category category;

  const CreateCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class UpdateCategoryEvent extends CategoryEvent {
  final Category category;

  const UpdateCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class DeleteCategoryEvent extends CategoryEvent {
  final String id;

  const DeleteCategoryEvent(this.id);

  @override
  List<Object?> get props => [id];
}
