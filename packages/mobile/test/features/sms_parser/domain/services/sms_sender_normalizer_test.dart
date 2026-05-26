import 'package:expense_tracker/features/sms_parser/domain/services/sms_sender_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SmsSenderNormalizer', () {
    test('normalize trims, collapses whitespace, and lowercases', () {
      expect(SmsSenderNormalizer.normalize('  VK   BANK  '), equals('vk bank'));
    });

    test('matches ignores whitespace and case', () {
      expect(SmsSenderNormalizer.matches(' vk-bank ', 'VK-BANK'), isTrue);
    });

    test('matches handles internal whitespace differences', () {
      expect(SmsSenderNormalizer.matches('VK   BANK', 'vk bank'), isTrue);
    });

    test('matches returns false for different senders', () {
      expect(SmsSenderNormalizer.matches('VK-BANK', 'AX-BANK'), isFalse);
    });
  });
}
