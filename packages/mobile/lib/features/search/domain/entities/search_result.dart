import 'package:equatable/equatable.dart';

class SearchResult extends Equatable {
  final String recordId;
  final double amount;
  final String description;
  final DateTime date;
  final double? relevanceScore;

  @override
  List<Object?> get props => [
    recordId,
    amount,
    description,
    date,
    relevanceScore,
  ];

  const SearchResult({
    required this.recordId,
    required this.amount,
    required this.description,
    required this.date,
    this.relevanceScore,
  });

  SearchResult copyWith({
    String? recordId,
    double? amount,
    String? description,
    DateTime? date,
    double? relevanceScore,
  }) {
    return SearchResult(
      recordId: recordId ?? this.recordId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      date: date ?? this.date,
      relevanceScore: relevanceScore ?? this.relevanceScore,
    );
  }
}
