import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/receipt_scan/presentation/helpers/category_name_matcher.dart';

void main() {
  Category category(String id, String name) => Category(
    id: id,
    name: name,
    emoji: 'tag',
    color: '#FFFFFF',
    type: RecordType.expense,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  final categories = [
    category('1', 'Food & Dining'),
    category('2', 'Transport'),
    category('3', 'Shopping'),
  ];

  group('matchCategoryByName', () {
    test('matches exact name case-insensitively', () {
      final match = matchCategoryByName('food & dining', categories);
      expect(match?.id, '1');
    });

    test('matches partial containment', () {
      final match = matchCategoryByName('Dining', categories);
      expect(match?.id, '1');
    });

    test('returns null when no hint', () {
      expect(matchCategoryByName(null, categories), isNull);
      expect(matchCategoryByName('  ', categories), isNull);
    });

    test('returns null when nothing overlaps', () {
      expect(matchCategoryByName('Astrology', categories), isNull);
    });
  });
}
