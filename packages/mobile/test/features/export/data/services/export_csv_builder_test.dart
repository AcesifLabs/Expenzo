import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/constants/app_constants.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/features/export/data/services/export_csv_builder.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

const _builder = ExportCsvBuilder();
final _stamp = DateTime(2026);

Record _record({
  String id = 'r1',
  double amount = -1234.5,
  String description = 'Lunch',
  String recordType = 'OUT',
  String? categoryId,
  String? budgetId,
  DateTime? date,
}) => Record(
  id: id,
  amount: amount,
  description: description,
  date: date ?? DateTime(2026, 3, 7, 9, 5, 3),
  categoryId: categoryId,
  budgetId: budgetId,
  source: 'manual',
  recordType: recordType,
  createdAt: _stamp,
  updatedAt: _stamp,
);

Category _category(String id, String name) => Category(
  id: id,
  name: name,
  emoji: 'tag',
  color: '#2196F3',
  isDefault: true,
  categoryType: 'OUT',
  usageCount: 4,
  createdAt: _stamp,
  updatedAt: _stamp,
);

Budget _budget(String id, String name) => Budget(
  id: id,
  name: name,
  amount: 5000,
  period: 'monthly',
  startDate: DateTime(2026, 1, 1),
  rolloverEnabled: true,
  rolloverAmount: 120.5,
  isEnabled: true,
  createdAt: _stamp,
  updatedAt: _stamp,
);

/// Rows of [text] after the BOM.
List<List<dynamic>> _rows(String text) {
  expect(text.startsWith('﻿'), isTrue, reason: 'missing UTF-8 BOM');

  return Csv().decode(text.substring(1));
}

String _transactions(
  List<Record> records, {
  Map<String, Category> categoriesById = const {},
  Map<String, Budget> budgetsById = const {},
}) => _builder.transactions(
  records,
  categoriesById: categoriesById,
  budgetsById: budgetsById,
  currencyCode: 'BDT',
);

void main() {
  test('transactions header matches the documented columns', () {
    expect(_rows(_transactions([])).single, [
      'date',
      'type',
      'amount',
      'currency',
      'category',
      'budget',
      'description',
      'source',
    ]);
  });

  test('an expense row has a positive two-decimal amount and an ISO date', () {
    final row = _rows(_transactions([_record()]))[1];

    expect(row, [
      '2026-03-07T09:05:03',
      'expense',
      '1234.50',
      'BDT',
      '',
      '',
      'Lunch',
      'manual',
    ]);
  });

  test('an income row has type income', () {
    final row = _rows(
      _transactions([_record(amount: 800, recordType: 'IN')]),
    )[1];

    expect(row[1], 'income');
    expect(row[2], '800.00');
  });

  test('category and budget names are the stored names; missing are empty', () {
    final text = _transactions(
      [
        _record(categoryId: 'c1', budgetId: 'b1'),
        _record(id: 'r2', categoryId: 'gone', budgetId: 'gone'),
      ],
      categoriesById: {'c1': _category('c1', 'Groceries')},
      budgetsById: {'b1': _budget('b1', 'Household')},
    );
    final rows = _rows(text);

    expect(rows[1].sublist(4, 6), ['Groceries', 'Household']);
    expect(rows[2].sublist(4, 6), ['', '']);
    expect(text.contains('null'), isFalse);
  });

  test('seed names and the placeholder budget stay as stored in bn', () {
    LocaleSettings.setLocaleSync(AppLocale.bn);
    addTearDown(() => LocaleSettings.setLocaleSync(AppLocale.en));

    final text = _transactions(
      [_record(categoryId: 'default_out_food', budgetId: 'b1')],
      categoriesById: {
        'default_out_food': _category('default_out_food', 'Food & Dining'),
      },
      budgetsById: {'b1': _budget('b1', AppConstants.defaultBudgetName)},
    );
    final row = _rows(text)[1];

    expect(row[0], '2026-03-07T09:05:03');
    expect(row.sublist(4, 6), ['Food & Dining', 'Unnamed budget']);
    expect(RegExp('[০-৯]').hasMatch(text), isFalse);
  });

  test('a description with a comma, quote and newline round-trips', () {
    const description = 'Tea, "special"\nand cake';

    expect(
      _rows(_transactions([_record(description: description)]))[1][6],
      description,
    );
  });

  test('each formula lead character gets a quote prefix', () {
    for (final lead in ['=', '+', '-', '@', '\t', '\r']) {
      final row = _rows(
        _transactions([_record(description: '${lead}SUM(A1)')]),
      )[1];

      expect(row[6], "'${lead}SUM(A1)", reason: 'lead ${lead.codeUnits}');
    }
  });

  test('budgets header and one row', () {
    final rows = _rows(_builder.budgets([_budget('b1', 'Rent')]));

    expect(rows, [
      [
        'name',
        'amount',
        'period',
        'start_date',
        'rollover_enabled',
        'rollover_amount',
        'enabled',
      ],
      ['Rent', '5000.00', 'monthly', '2026-01-01', 'true', '120.50', 'true'],
    ]);
  });

  test('categories header and one row', () {
    final rows = _rows(_builder.categories([_category('c1', 'Transport')]));

    expect(rows, [
      ['name', 'type', 'default', 'usage_count'],
      ['Transport', 'expense', 'true', '4'],
    ]);
  });

  test('an empty list gives only the header', () {
    expect(_rows(_builder.budgets([])), hasLength(1));
    expect(_rows(_builder.categories([])), hasLength(1));
  });
}
