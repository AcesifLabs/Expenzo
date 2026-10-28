import 'package:csv/csv.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/database/app_database.dart';

class ExportCsvBuilder {
  static final _csv = Csv(addBom: true);

  static const _formulaLeads = {'=', '+', '-', '@', '\t', '\r'};

  const ExportCsvBuilder();

  String transactions(
    List<Record> records, {
    required Map<String, Category> categoriesById,
    required Map<String, Budget> budgetsById,
    required String currencyCode,
  }) {
    return _csv.encode([
      [
        'date',
        'type',
        'amount',
        'currency',
        'category',
        'budget',
        'description',
        'source',
      ],
      for (final record in records)
        _transactionRow(
          record,
          categoryName: categoriesById[record.categoryId]?.name,
          budgetName: budgetsById[record.budgetId]?.name,
          currencyCode: currencyCode,
        ),
    ]);
  }

  String budgets(List<Budget> budgets) {
    return _csv.encode([
      [
        'name',
        'amount',
        'period',
        'start_date',
        'rollover_enabled',
        'rollover_amount',
        'enabled',
      ],
      for (final budget in budgets) _budgetRow(budget),
    ]);
  }

  String categories(List<Category> categories) {
    return _csv.encode([
      ['name', 'type', 'default', 'usage_count'],
      for (final category in categories) _categoryRow(category),
    ]);
  }

  List<String> _transactionRow(
    Record record, {
    required String? categoryName,
    required String? budgetName,
    required String currencyCode,
  }) {
    return [
      _isoDateTime(record.date),
      RecordType.fromDbValue(record.recordType).name,
      record.amount.abs().toStringAsFixed(2),
      currencyCode,
      _safeCell(categoryName ?? ''),
      _safeCell(budgetName ?? ''),
      _safeCell(record.description),
      record.source,
    ];
  }

  List<String> _budgetRow(Budget budget) {
    return [
      _safeCell(budget.name),
      budget.amount.toStringAsFixed(2),
      budget.period,
      _isoDate(budget.startDate),
      '${budget.rolloverEnabled}',
      budget.rolloverAmount.toStringAsFixed(2),
      '${budget.isEnabled}',
    ];
  }

  List<String> _categoryRow(Category category) {
    return [
      _safeCell(category.name),
      RecordType.fromDbValue(category.categoryType).name,
      '${category.isDefault}',
      '${category.usageCount}',
    ];
  }

  static String _safeCell(String value) {
    if (value.isEmpty || !_formulaLeads.contains(value[0])) return value;

    return "'$value";
  }

  static String _isoDate(DateTime date) =>
      '${_pad(date.year, 4)}-${_pad(date.month)}-${_pad(date.day)}';

  static String _isoDateTime(DateTime date) =>
      '${_isoDate(date)}T${_pad(date.hour)}:${_pad(date.minute)}:'
      '${_pad(date.second)}';

  static String _pad(int value, [int width = 2]) =>
      value.toString().padLeft(width, '0');
}
