import 'package:expense_tracker/i18n/strings.g.dart';

enum RecordType {
  income,
  expense;

  String get displayName => this == RecordType.income
      ? t.enums.recordType.income
      : t.enums.recordType.expense;

  String get dbValue => this == RecordType.income ? 'IN' : 'OUT';

  static RecordType fromDbValue(String value) {
    return value == 'IN' ? RecordType.income : RecordType.expense;
  }
}
