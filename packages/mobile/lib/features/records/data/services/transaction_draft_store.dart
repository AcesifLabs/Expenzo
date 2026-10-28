import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef TransactionDraft = ({
  RecordType type,
  String amountText,
  String note,
  String? categoryId,
  String? budgetId,
  DateTime date,
});

class TransactionDraftStore {
  static const storageKey = 'new_transaction_draft';

  static const maxAge = Duration(days: 1);

  final SharedPreferences prefs;

  const TransactionDraftStore(this.prefs);

  Future<void> save(TransactionDraft draft) => prefs.setString(
    storageKey,
    jsonEncode({
      'type': draft.type.dbValue,
      'amount': draft.amountText,
      'note': draft.note,
      'categoryId': draft.categoryId,
      'budgetId': draft.budgetId,
      'date': draft.date.toIso8601String(),
      'savedAt': clock.now().toIso8601String(),
    }),
  );

  TransactionDraft? load() {
    final raw = prefs.getString(storageKey);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, Object?>;
      final savedAt = DateTime.parse(json['savedAt'] as String);
      if (clock.now().difference(savedAt) > maxAge) return null;

      return (
        type: RecordType.fromDbValue(json['type'] as String),
        amountText: json['amount'] as String,
        note: json['note'] as String,
        categoryId: json['categoryId'] as String?,
        budgetId: json['budgetId'] as String?,
        date: DateTime.parse(json['date'] as String),
      );
    } on Object {
      return null;
    }
  }

  Future<void> clear() => prefs.remove(storageKey);
}
