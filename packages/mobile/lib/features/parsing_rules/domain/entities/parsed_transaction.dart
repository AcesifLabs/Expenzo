import 'package:equatable/equatable.dart';

class ParsedTransaction extends Equatable {
  final String rawMessage;
  final double? amount;
  final DateTime? date;
  final String? description;
  final String? categoryId;
  final String sourceType;
  final String sourceId;
  final double confidenceScore;
  final String? matchedRuleId;
  final bool parseFailed;
  final String? parseError;

  @override
  List<Object?> get props => [
    rawMessage,
    amount,
    date,
    description,
    categoryId,
    sourceType,
    sourceId,
    confidenceScore,
    matchedRuleId,
    parseFailed,
    parseError,
  ];

  const ParsedTransaction({
    required this.rawMessage,
    this.amount,
    this.date,
    this.description,
    this.categoryId,
    required this.sourceType,
    required this.sourceId,
    required this.confidenceScore,
    this.matchedRuleId,
    required this.parseFailed,
    this.parseError,
  });

  bool isHighConfidence() => confidenceScore >= 0.9;
  bool isMediumConfidence() => confidenceScore >= 0.7;
  bool isLowConfidence() => confidenceScore < 0.7;

  ParsedTransaction copyWith({
    String? rawMessage,
    double? amount,
    DateTime? date,
    String? description,
    String? categoryId,
    String? sourceType,
    String? sourceId,
    double? confidenceScore,
    String? matchedRuleId,
    bool? parseFailed,
    String? parseError,
  }) {
    return ParsedTransaction(
      rawMessage: rawMessage ?? this.rawMessage,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      matchedRuleId: matchedRuleId ?? this.matchedRuleId,
      parseFailed: parseFailed ?? this.parseFailed,
      parseError: parseError ?? this.parseError,
    );
  }
}
