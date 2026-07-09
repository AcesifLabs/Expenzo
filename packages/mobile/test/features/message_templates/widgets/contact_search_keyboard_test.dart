import 'package:expense_tracker/features/message_templates/presentation/pages/contact_selector_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('detects keyboard collapse when inset drops to zero', () {
    expect(
      keyboardJustCollapsed(previousBottomInset: 300, currentBottomInset: 0),
      isTrue,
    );
  });

  test('does not treat keyboard opening as a collapse', () {
    expect(
      keyboardJustCollapsed(previousBottomInset: 0, currentBottomInset: 300),
      isFalse,
    );
  });

  test('does not treat a still-open keyboard as a collapse', () {
    expect(
      keyboardJustCollapsed(previousBottomInset: 300, currentBottomInset: 300),
      isFalse,
    );
  });

  test('does not treat an already-closed keyboard as a collapse', () {
    expect(
      keyboardJustCollapsed(previousBottomInset: 0, currentBottomInset: 0),
      isFalse,
    );
  });
}
