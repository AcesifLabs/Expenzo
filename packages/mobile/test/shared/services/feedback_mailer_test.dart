import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/core/config/app_config.dart';
import 'package:expense_tracker/shared/services/feedback_mailer.dart';

void main() {
  test('addresses the feedback inbox with a subject', () {
    final uri = feedbackMailUri(platform: 'android 14');

    expect(uri.scheme, 'mailto');
    expect(uri.path, AppConfig.feedbackEmail);
    expect(uri.queryParameters['subject'], t.common.feedback.subject);
  });

  test('the body carries the device and the error reference', () {
    final uri = feedbackMailUri(
      errorReference: 'ABC123',
      platform: 'android 14',
    );
    final body = uri.queryParameters['body'] ?? '';

    expect(body, contains('Device: android 14'));
    expect(body, contains('Error reference: ABC123'));

    expect(uri.toString(), isNot(contains('+')));
  });
}
