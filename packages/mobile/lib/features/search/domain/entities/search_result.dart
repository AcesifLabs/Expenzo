import 'package:equatable/equatable.dart';
import '../../../records/domain/entities/record.dart';

class SearchResult extends Equatable {
  final Record record;
  final double? relevanceScore;

  @override
  List<Object?> get props => [record, relevanceScore];

  const SearchResult({required this.record, this.relevanceScore});
}
