import 'package:equatable/equatable.dart';
import '../../../expenses/domain/entities/expense.dart';

class SearchResult extends Equatable {
  final Expense expense;
  final double? relevanceScore;

  const SearchResult({required this.expense, this.relevanceScore});

  @override
  List<Object?> get props => [expense, relevanceScore];
}
