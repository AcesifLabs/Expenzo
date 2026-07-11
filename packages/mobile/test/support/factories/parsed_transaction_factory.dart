import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsed_transaction.dart';

ParsedTransaction makeParsedTransaction({
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
    rawMessage: rawMessage ?? 'Your account was debited BDT 250.00',
    amount: amount ?? 250,
    date: date ?? DateTime(2026, 7, 11, 14, 30),
    description: description ?? 'Test transaction',
    categoryId: categoryId,
    sourceType: sourceType ?? AppSourceType.sms,
    sourceId: sourceId ?? 'scan-source-1',
    confidenceScore: confidenceScore ?? 0.95,
    matchedRuleId: matchedRuleId,
    parseFailed: parseFailed ?? false,
    parseError: parseError,
  );
}
