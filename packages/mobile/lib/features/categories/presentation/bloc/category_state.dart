import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import '../../domain/entities/category.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

class CategoryLoaded extends CategoryState {
  final List<Category> categories;
  final RecordType? type;

  const CategoryLoaded(this.categories, {this.type});

  @override
  List<Object?> get props => [categories, type];
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}

class CategoryInUseError extends CategoryState {
  final String message;

  const CategoryInUseError(this.message);

  @override
  List<Object?> get props => [message];
}
