enum RecordType {
  income,
  expense;

  String get displayName => this == RecordType.income ? 'Income' : 'Expense';

  // DB values
  String get dbValue => this == RecordType.income ? 'IN' : 'OUT';

  static RecordType fromDbValue(String value) {
    return value == 'IN' ? RecordType.income : RecordType.expense;
  }
}
