import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The New Transaction sheet's unsaved fields.
typedef TransactionDraft = ({
  RecordType type,
  String amountText,
  String note,
  String? categoryId,
  String? budgetId,
  DateTime date,
});

/// Keeps the New Transaction sheet's fields while the app is in the
/// background. Android may kill the app then (to free memory, or while the
/// camera or gallery is open), which would lose what the user typed.
class TransactionDraftStore {
  static const storageKey = 'new_transaction_draft';

  /// Older drafts are dropped instead of restored.
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

  /// The saved draft, or null when there is none, it is older than
  /// [maxAge], or it can't be read.
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
