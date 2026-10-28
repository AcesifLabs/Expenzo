import 'package:expense_tracker/core/utils/strict_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('real days come back unchanged', () {
    expect(strictDate(2028, 2, 29), DateTime(2028, 2, 29));
    expect(strictDate(2026, 12, 31), DateTime(2026, 12, 31));
  });

  test('days that do not exist are null', () {
    expect(strictDate(2026, 2, 31), isNull);
    expect(strictDate(2027, 2, 29), isNull);
    expect(strictDate(2026, 13, 1), isNull);
    expect(strictDate(2026, 0, 10), isNull);
    expect(strictDate(2026, 4, 0), isNull);
  });
}
