import 'package:drift/drift.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/database/app_database.dart'
    hide Category, Record;
import '../../domain/entities/search_filters.dart';
import '../../domain/entities/search_result.dart';
import '../../../records/domain/entities/record.dart';

abstract class SearchLocalDatasource {
  /// Throws: [CacheException] if a database error occurs.
  Future<List<SearchResult>> searchRecords(SearchFilters filters);
  Future<void> indexRecord(Record record);
  Future<void> removeRecordFromIndex(String recordId);
  Future<void> rebuildIndex();
}

class SearchLocalDatasourceImpl implements SearchLocalDatasource {
  final AppDatabase db;

  SearchLocalDatasourceImpl({required this.db});

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<List<SearchResult>> searchRecords(SearchFilters filters) async {
    try {
      if (filters.isEmpty) {
        return [];
      }

      final conditions = <String>[];
      final args = <Object>[];

      _addQueryCondition(filters, conditions, args);
      _addCategoryCondition(filters, conditions, args);
      _addDateRangeCondition(filters, conditions, args);
      _addAmountConditions(filters, conditions, args);

      final query = _buildQuery(conditions);

      final result = await db
          .customSelect(query, variables: args.map((a) => Variable(a)).toList())
          .get();

      return result.map((row) {
        final data = row.data;
        return SearchResult(
          recordId: data['id'] as String,
          amount: _toDouble(data['amount']),
          description: data['description'] as String,
          date: _intToDateTime(data['date']),
          relevanceScore: _computeRelevanceScore(data, filters.query),
        );
      }).toList();
    } catch (e, s) {
      print('Error: $e\n$s');
      throw CacheException(message: e.toString());
    }
  }

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<void> indexRecord(Record record) async {
    try {
      await db.customStatement(
        'INSERT INTO expense_fts (expense_id, description) VALUES (?, ?)',
        [record.id, record.description],
      );
    } catch (e, s) {
      print('Error: $e\n$s');
      throw CacheException(message: e.toString());
    }
  }

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<void> removeRecordFromIndex(String recordId) async {
    try {
      await db.customStatement('DELETE FROM expense_fts WHERE expense_id = ?', [
        recordId,
      ]);
    } catch (e, s) {
      print('Error: $e\n$s');
      throw CacheException(message: e.toString());
    }
  }

  /// Throws: [CacheException] if a database error occurs.
  @override
  Future<void> rebuildIndex() async {
    try {
      await db.customStatement('DELETE FROM expense_fts');

      await db.customStatement('''
        INSERT INTO expense_fts (expense_id, description)
        SELECT id, description FROM records
      ''');
    } catch (e, s) {
      print('Error: $e\n$s');
      throw CacheException(message: e.toString());
    }
  }

  String _buildQuery(List<String> conditions) {
    String query = '''
      SELECT r.*, expense_fts.description as fts_description
      FROM records r
      INNER JOIN expense_fts ON expense_fts.expense_id = r.id
    ''';

    if (conditions.isNotEmpty) {
      query += ' WHERE ${conditions.join(' AND ')}';
    }

    query += ' ORDER BY r.date DESC';

    return query;
  }

  void _addQueryCondition(
    SearchFilters filters,
    List<String> conditions,
    List<Object> args,
  ) {
    final query = filters.query;
    if (query != null && query.isNotEmpty) {
      conditions.add('expense_fts.description MATCH ?');
      args.add('"$query"*');
    }
  }

  void _addCategoryCondition(
    SearchFilters filters,
    List<String> conditions,
    List<Object> args,
  ) {
    final categoryId = filters.categoryId;
    if (categoryId != null) {
      conditions.add('r.category_id = ?');
      args.add(categoryId);
    }
  }

  void _addDateRangeCondition(
    SearchFilters filters,
    List<String> conditions,
    List<Object> args,
  ) {
    final dateRange = filters.dateRange;
    if (dateRange != null) {
      conditions.add('r.date >= ? AND r.date <= ?');
      args.add(dateRange.start.millisecondsSinceEpoch ~/ 1000);
      args.add(dateRange.end.millisecondsSinceEpoch ~/ 1000);
    }
  }

  void _addAmountConditions(
    SearchFilters filters,
    List<String> conditions,
    List<Object> args,
  ) {
    final minAmount = filters.minAmount;
    if (minAmount != null) {
      conditions.add('r.amount >= ?');
      args.add(minAmount);
    }

    final maxAmount = filters.maxAmount;
    if (maxAmount != null) {
      conditions.add('r.amount <= ?');
      args.add(maxAmount);
    }
  }

  double _computeRelevanceScore(Map<String, dynamic> row, String? query) {
    if (query == null) return 0;

    final description = row['fts_description'] as String?;
    if (description == null) return 0;

    return description
        .split(' ')
        .where((word) => word.contains(query))
        .length
        .toDouble();
  }

  double _toDouble(Object value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    throw CacheException(
      message: 'Unexpected amount type: ${value.runtimeType}',
    );
  }

  DateTime _intToDateTime(Object value) {
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    if (value is DateTime) return value;
    throw CacheException(message: 'Unexpected date type: ${value.runtimeType}');
  }
}
