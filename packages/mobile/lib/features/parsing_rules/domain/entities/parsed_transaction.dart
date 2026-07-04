import 'package:equatable/equatable.dart';

typedef _CoreFields = ({
  String rawMessage,
  double? amount,
  DateTime? date,
  String? description,
  String? categoryId,
  String sourceType,
  String sourceId,
});

typedef _ParsingMeta = ({
  double? confidenceScore,
  String? matchedRuleId,
  bool? parseFailed,
  String? parseError,
});

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
    return _applyMetadata(
      core: (
        rawMessage: rawMessage ?? this.rawMessage,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        description: description ?? this.description,
        categoryId: categoryId ?? this.categoryId,
        sourceType: sourceType ?? this.sourceType,
        sourceId: sourceId ?? this.sourceId,
      ),
      meta: (
        confidenceScore: confidenceScore,
        matchedRuleId: matchedRuleId,
        parseFailed: parseFailed,
        parseError: parseError,
      ),
    );
  }

  ParsedTransaction _applyMetadata({
    required _CoreFields core,
    required _ParsingMeta meta,
  }) {
    return ParsedTransaction(
      rawMessage: core.rawMessage,
      amount: core.amount,
      date: core.date,
      description: core.description,
      categoryId: core.categoryId,
      sourceType: core.sourceType,
      sourceId: core.sourceId,
      confidenceScore: meta.confidenceScore ?? confidenceScore,
      matchedRuleId: meta.matchedRuleId ?? matchedRuleId,
      parseFailed: meta.parseFailed ?? parseFailed,
      parseError: meta.parseError ?? parseError,
    );
  }
}
