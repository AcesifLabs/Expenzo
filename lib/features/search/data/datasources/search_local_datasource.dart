import 'package:drift/drift.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/database/app_database.dart' hide Category, Expense;
import '../../domain/entities/search_filters.dart';
import '../../domain/entities/search_result.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/domain/entities/expense_source.dart';

abstract class SearchLocalDatasource {
  Future<List<SearchResult>> searchExpenses(SearchFilters filters);
  Future<void> indexExpense(Expense expense);
  Future<void> removeExpenseFromIndex(int expenseId);
  Future<void> rebuildIndex();
}

class SearchLocalDatasourceImpl implements SearchLocalDatasource {
  final AppDatabase db;

  SearchLocalDatasourceImpl({required this.db});

  @override
  Future<List<SearchResult>> searchExpenses(SearchFilters filters) async {
    try {
      if (filters.isEmpty) {
        return [];
      }

      String query = '''
        SELECT e.*, expense_fts.description as fts_description
        FROM expenses e
        INNER JOIN expense_fts ON expense_fts.expense_id = e.id
      ''';

      final conditions = <String>[];
      final args = <dynamic>[];

      if (filters.query != null && filters.query!.isNotEmpty) {
        final ftsQuery = '"${filters.query!}"*';
        conditions.add('expense_fts.description MATCH ?');
        args.add(ftsQuery);
      }

      if (filters.categoryId != null) {
        conditions.add('e.category_id = ?');
        args.add(filters.categoryId);
      }

      if (filters.dateRange != null) {
        conditions.add('e.date >= ? AND e.date <= ?');
        args.add(filters.dateRange!.start.millisecondsSinceEpoch);
        args.add(filters.dateRange!.end.millisecondsSinceEpoch);
      }

      if (filters.minAmount != null) {
        conditions.add('e.amount >= ?');
        args.add(filters.minAmount);
      }

      if (filters.maxAmount != null) {
        conditions.add('e.amount <= ?');
        args.add(filters.maxAmount);
      }

      if (conditions.isNotEmpty) {
        query += ' WHERE ${conditions.join(' AND ')}';
      }

      query += ' ORDER BY e.date DESC';

      final result = await db
          .customSelect(query, variables: args.map((a) => Variable(a)).toList())
          .get();

      return result.map((row) {
        return SearchResult(
          expense: _mapToExpense(row),
          relevanceScore: filters.query != null
              ? (row.data['fts_description'] as String?)
                        ?.split(' ')
                        .where((word) => word.contains(filters.query!))
                        .length
                        .toDouble() ??
                    0
              : null,
        );
      }).toList();
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> indexExpense(Expense expense) async {
    try {
      await db.customStatement(
        'INSERT INTO expense_fts (expense_id, description) VALUES (?, ?)',
        [expense.id, expense.description],
      );
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> removeExpenseFromIndex(int expenseId) async {
    try {
      await db.customStatement('DELETE FROM expense_fts WHERE expense_id = ?', [
        expenseId,
      ]);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> rebuildIndex() async {
    try {
      await db.customStatement('DELETE FROM expense_fts');

      final expenses = await db.select(db.expenses).get();
      for (final expense in expenses) {
        await db.customStatement(
          'INSERT INTO expense_fts (expense_id, description) VALUES (?, ?)',
          [expense.id, expense.description],
        );
      }
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  Expense _mapToExpense(QueryRow row) {
    final data = row.data;
    return Expense(
      id: data['id'] as int?,
      amount: data['amount'] as double,
      description: data['description'] as String,
      date: data['date'] as DateTime,
      categoryId: data['category_id'] as int?,
      source: ExpenseSource.values.firstWhere(
        (s) => s.name == data['source'],
        orElse: () => ExpenseSource.manual,
      ),
      sourceId: data['source_id'] as String?,
      createdAt: data['created_at'] as DateTime,
      updatedAt: data['updated_at'] as DateTime,
    );
  }
}
