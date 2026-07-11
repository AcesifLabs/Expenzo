import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/ai_assistant/domain/usecases/redact_ai_context.dart';

void main() {
  const redactAiContext = RedactAiContext();

  group('RedactAiContext', () {
    test('redacts email addresses', () {
      final result = redactAiContext('Contact me at asif@example.com');

      expect(result, contains('[REDACTED_EMAIL]'));
      expect(result, isNot(contains('asif@example.com')));
    });

    test('redacts phone numbers', () {
      final result = redactAiContext('Phone: +880 1712 345678');

      expect(result, contains('[REDACTED_PHONE]'));
    });

    test('redacts long numeric identifiers but preserves last four digits', () {
      final result = redactAiContext('Account 1234 5678 9012 3456');

      expect(result, contains('[REDACTED_NUMBER_3456]'));
      expect(result, isNot(contains('1234 5678 9012 3456')));
    });
  });
}
