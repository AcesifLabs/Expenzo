import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_state.dart';

import '../../support/factories/record_factory.dart';

void main() {
  group('RecordLoaded.copyWith clear semantics', () {
    late RecordLoaded base;

    setUp(() {
      base = RecordLoaded(
        records: [makeRecord()],
        total: 1,
        hasMore: false,
        searchQuery: '',
        filterStartDate: DateTime(2024, 1, 1),
        filterEndDate: DateTime(2024, 6, 30),
        filterCategoryIds: ['cat-1', 'cat-2'],
        filterRecordType: 'expense',
      );
    });

    test('omitting a filter field preserves the existing value', () {
      final copy = base.copyWith();
      expect(copy.filterStartDate, base.filterStartDate);
      expect(copy.filterEndDate, base.filterEndDate);
      expect(copy.filterCategoryIds, base.filterCategoryIds);
      expect(copy.filterRecordType, base.filterRecordType);
    });

    test('explicitly passing null clears filterStartDate', () {
      final copy = base.copyWith(filterStartDate: null);
      expect(copy.filterStartDate, isNull);
      // other filters unchanged
      expect(copy.filterEndDate, base.filterEndDate);
      expect(copy.filterCategoryIds, base.filterCategoryIds);
      expect(copy.filterRecordType, base.filterRecordType);
    });

    test('explicitly passing null clears filterEndDate', () {
      final copy = base.copyWith(filterEndDate: null);
      expect(copy.filterEndDate, isNull);
      expect(copy.filterStartDate, base.filterStartDate);
    });

    test('explicitly passing null clears filterCategoryIds', () {
      final copy = base.copyWith(filterCategoryIds: null);
      expect(copy.filterCategoryIds, isNull);
      expect(copy.filterStartDate, base.filterStartDate);
    });

    test('explicitly passing null clears filterRecordType', () {
      final copy = base.copyWith(filterRecordType: null);
      expect(copy.filterRecordType, isNull);
      expect(copy.filterStartDate, base.filterStartDate);
    });

    test('setting a new value works', () {
      final newDate = DateTime(2025, 1, 1);
      final copy = base.copyWith(filterStartDate: newDate);
      expect(copy.filterStartDate, newDate);
      expect(copy.filterEndDate, base.filterEndDate);
    });

    test('non-filter fields work with ?? semantics (unchanged behavior)', () {
      final copy = base.copyWith(
        records: [makeRecord(id: 'new-rec')],
        total: 99,
        searchQuery: 'search',
      );
      expect(copy.records.first.id, 'new-rec');
      expect(copy.total, 99);
      expect(copy.searchQuery, 'search');
      // filters unchanged
      expect(copy.filterStartDate, base.filterStartDate);
    });

    test('all filters can be cleared simultaneously', () {
      final copy = base.copyWith(
        filterStartDate: null,
        filterEndDate: null,
        filterCategoryIds: null,
        filterRecordType: null,
      );
      expect(copy.filterStartDate, isNull);
      expect(copy.filterEndDate, isNull);
      expect(copy.filterCategoryIds, isNull);
      expect(copy.filterRecordType, isNull);
    });

    test('clearing a filter that is already null stays null', () {
      final noFilters = RecordLoaded(records: [makeRecord()]);
      final copy = noFilters.copyWith(filterStartDate: null);
      expect(copy.filterStartDate, isNull);
    });
  });
}
