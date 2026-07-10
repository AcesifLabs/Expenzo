import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/search/domain/helpers/fts_query_helper.dart';

void main() {
  group('buildFtsMatchQuery', () {
    test('wraps plain text in quoted phrase-prefix', () {
      expect(buildFtsMatchQuery('hello'), '"hello"*');
    });

    test('escapes embedded double-quotes by doubling', () {
      // Input: say "hi"
      // After escaping: say ""hi""
      // Wrapped as phrase-prefix: "say ""hi""*
      expect(buildFtsMatchQuery('say "hi"'), '"say ""hi"""*');
    });

    test('handles empty string', () {
      expect(buildFtsMatchQuery(''), '');
    });

    test('handles whitespace-only input', () {
      expect(buildFtsMatchQuery('   '), '');
    });

    test('trims surrounding whitespace', () {
      expect(buildFtsMatchQuery('  hello  '), '"hello"*');
    });

    test('handles FTS operators as literal text', () {
      // OR, AND, NEAR, NOT should be treated as literal words, not operators
      expect(buildFtsMatchQuery('a OR b'), '"a OR b"*');
      expect(buildFtsMatchQuery('NEAR(a b)'), '"NEAR(a b)"*');
    });

    test('handles single double-quote', () {
      // Input: "
      // After escaping: ""
      // Wrapped: """*
      expect(buildFtsMatchQuery('"'), '""""*');
    });

    test('preserves unicode characters', () {
      expect(buildFtsMatchQuery('৳100'), '"৳100"*');
    });
  });
}
