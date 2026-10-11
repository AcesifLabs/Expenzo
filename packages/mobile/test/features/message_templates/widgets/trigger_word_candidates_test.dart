import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/message_templates/presentation/pages/template_editor_page.dart';

void main() {
  const bankSms =
      'Your A/C XX1234 debited by BDT 450.00 at DARAZ on 11-Oct-26. '
      'Avl Bal BDT 9,550.00';

  test('keeps inner punctuation so the word still matches the SMS', () {
    final words = triggerWordCandidates(bankSms);

    expect(words, contains('A/C'));
    expect(words, contains('11-Oct-26'));
    for (final word in words) {
      expect(bankSms.toLowerCase(), contains(word.toLowerCase()));
    }
  });

  test('leaves out amounts and plain numbers', () {
    final words = triggerWordCandidates(bankSms);

    expect(words, isNot(contains('450.00')));
    expect(words, isNot(contains('9,550.00')));
    expect(words, isNot(contains('45000')));
    expect(words, isNot(contains('955000')));
  });

  test('trims punctuation at the edges', () {
    expect(triggerWordCandidates('Paid, (debited) "now".'), [
      'Paid',
      'debited',
      'now',
    ]);
  });

  test('shows repeated words once, in first-seen order', () {
    expect(triggerWordCandidates('BDT 10 sent. bdt 20 sent'), ['BDT', 'sent']);
  });
}
