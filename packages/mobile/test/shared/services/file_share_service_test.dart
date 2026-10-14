import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';
import 'package:expense_tracker/shared/services/file_share_service.dart';

void main() {
  test('success and unavailable map to shared', () {
    expect(
      FileShareService.outcomeFor(ShareResultStatus.success),
      ShareOutcome.shared,
    );
    expect(
      FileShareService.outcomeFor(ShareResultStatus.unavailable),
      ShareOutcome.shared,
    );
  });

  test('dismissed maps to dismissed', () {
    expect(
      FileShareService.outcomeFor(ShareResultStatus.dismissed),
      ShareOutcome.dismissed,
    );
  });
}
