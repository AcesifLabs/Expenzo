import 'package:drift/native.dart';
import 'package:expense_tracker/core/database/app_database.dart'
    hide ParsingRule;
import 'package:expense_tracker/core/database/daos/parsing_rule_dao.dart';
import 'package:expense_tracker/features/parsing_rules/data/datasources/parsing_rules_local_datasource.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/date_order.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsing_rule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ParsingRulesLocalDatasourceImpl datasource;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    datasource = ParsingRulesLocalDatasourceImpl(ParsingRuleDao(db));
  });

  tearDown(() => db.close());

  ParsingRule rule({DateOrder dateOrder = DateOrder.dmy}) => ParsingRule(
    id: 'r1',
    name: 'Bank',
    triggerWords: const ['debited'],
    amountPattern: r'(\d+)',
    sourceType: SourceType.sms,
    isEnabled: true,
    priority: 0,
    dateOrder: dateOrder,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  test('a month/day rule is saved and read back as month/day', () async {
    await datasource.createRule(rule(dateOrder: DateOrder.mdy));

    expect((await datasource.getRuleById('r1'))?.dateOrder, DateOrder.mdy);
  });

  test('changing it back to day/month is saved', () async {
    await datasource.createRule(rule(dateOrder: DateOrder.mdy));
    await datasource.updateRule(rule());

    expect((await datasource.getRuleById('r1'))?.dateOrder, DateOrder.dmy);
  });

  group('DateOrder.fromName', () {
    test('reads the stored names', () {
      expect(DateOrder.fromName('mdy'), DateOrder.mdy);
      expect(DateOrder.fromName('dmy'), DateOrder.dmy);
    });

    test('anything else reads as day/month', () {
      expect(DateOrder.fromName(null), DateOrder.dmy);
      expect(DateOrder.fromName('MDY'), DateOrder.dmy);
      expect(DateOrder.fromName(''), DateOrder.dmy);
    });
  });
}
