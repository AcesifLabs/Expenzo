import 'package:equatable/equatable.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import '../../domain/entities/category.dart';

sealed class CategoryState extends Equatable {
  @override
  List<Object?> get props => [];

  const CategoryState();
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

  @override
  List<Object?> get props => [categories, type];

  const CategoryLoaded(this.categories, {this.type});
}

class CategoryError extends CategoryState {
  final String message;

  @override
  List<Object?> get props => [message];

  const CategoryError(this.message);
}

class CategorySearchResults extends CategoryState {
  final List<Category> results;

  @override
  List<Object?> get props => [results];

  const CategorySearchResults(this.results);
}
