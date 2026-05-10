import 'package:drift/drift.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/database/app_database.dart'
    hide Category, Record;
import 'package:expense_tracker/core/constants/record_type.dart';
import '../../domain/entities/search_filters.dart';
import '../../domain/entities/search_result.dart';
import '../../../records/domain/entities/record.dart';
import "package:expense_tracker/core/constants/source_types.dart";

abstract class SearchLocalDatasource {
  Future<List<SearchResult>> searchRecords(SearchFilters filters);
  Future<void> indexRecord(Record record);
  Future<void> removeRecordFromIndex(String recordId);
  Future<void> rebuildIndex();
}

class SearchLocalDatasourceImpl implements SearchLocalDatasource {
  final AppDatabase db;

  SearchLocalDatasourceImpl({required this.db});

  @override
  Future<List<SearchResult>> searchRecords(SearchFilters filters) async {
    try {
      if (filters.isEmpty) {
        return [];
      }

      String query = '''
        SELECT r.*, expense_fts.description as fts_description
        FROM records r
        INNER JOIN expense_fts ON expense_fts.expense_id = r.id
      ''';

      final conditions = <String>[];
      final args = <dynamic>[];

      if (filters.query != null && filters.query!.isNotEmpty) {
        final ftsQuery = '"${filters.query!}"*';
        conditions.add('expense_fts.description MATCH ?');
        args.add(ftsQuery);
      }

      if (filters.categoryId != null) {
        conditions.add('r.category_id = ?');
        args.add(filters.categoryId);
      }

      if (filters.dateRange != null) {
        conditions.add('r.date >= ? AND r.date <= ?');
        args.add(filters.dateRange!.start.millisecondsSinceEpoch);
        args.add(filters.dateRange!.end.millisecondsSinceEpoch);
      }

      if (filters.minAmount != null) {
        conditions.add('r.amount >= ?');
        args.add(filters.minAmount);
      }

      if (filters.maxAmount != null) {
        conditions.add('r.amount <= ?');
        args.add(filters.maxAmount);
      }

      if (conditions.isNotEmpty) {
        query += ' WHERE ${conditions.join(' AND ')}';
      }

      query += ' ORDER BY r.date DESC';

      final result = await db
          .customSelect(query, variables: args.map((a) => Variable(a)).toList())
          .get();

      return result.map((row) {
        return SearchResult(
          record: _mapToRecord(row),
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
  Future<void> indexRecord(Record record) async {
    try {
      await db.customStatement(
        'INSERT INTO expense_fts (expense_id, description) VALUES (?, ?)',
        [record.id, record.description],
      );
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> removeRecordFromIndex(String recordId) async {
    try {
      await db.customStatement('DELETE FROM expense_fts WHERE expense_id = ?', [
        recordId,
      ]);
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> rebuildIndex() async {
    try {
      await db.customStatement('DELETE FROM expense_fts');

      // Single INSERT...SELECT — no per-row round-trips
      await db.customStatement('''
        INSERT INTO expense_fts (expense_id, description)
        SELECT id, description FROM records
      ''');
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  Record _mapToRecord(QueryRow row) {
    final data = row.data;
    return Record(
      id: data['id'] as String?,
      amount: data['amount'] as double,
      description: data['description'] as String,
      date: data['date'] as DateTime,
      categoryId: data['category_id'] as String?,
      source: ExpenseSource.values.firstWhere(
        (s) => s.name == data['source'],
        orElse: () => ExpenseSource.manual,
      ),
      sourceId: data['source_id'] as String?,
      recordType: RecordType.fromDbValue(data['record_type'] as String),
      createdAt: data['created_at'] as DateTime,
      updatedAt: data['updated_at'] as DateTime,
    );
  }
}
