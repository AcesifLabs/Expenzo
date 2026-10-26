import 'package:expense_tracker/core/logger/crash_scrubber.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../features/sms_parser/sms_corpus_loader.dart';

final _leak = RegExp(
  r'[\d০-৯][\d০-৯,]*\.[\d০-৯]|[\d০-৯](?:[ ,.\-]?[\d০-৯]){3,}',
);

void main() {
  group('redact', () {
    const cases = {
      'Tk 1,500.00 debited': '[redacted] debited',
      'Paid ৳৫০০ to shop': 'Paid [redacted] to shop',
      'Rs.250 spent': '[redacted] spent',
      'A/C ***4521 balance 74,094.39': 'A/C ***[redacted] balance [redacted]',
      'OTP 482913': 'OTP [redacted]',
      'card 4111 1111 1111 1111': 'card [redacted]',
      'item 3 of 12': 'item 3 of 12',
    };
    cases.forEach((input, expected) {
      test('"$input"', () => expect(redact(input), expected));
    });
  });

  test('scrubMessage keeps only the first line', () {
    const formatError = 'FormatException: Invalid amount\nTk 900 at SHOP X';

    expect(scrubMessage(formatError), 'FormatException: Invalid amount');
  });

  test('scrubMessage cuts long text', () {
    expect(scrubMessage('x' * 500).length, 201);
  });

  test('every corpus SMS loses its amounts and account numbers', () async {
    final workbooks = await loadSmsCorpus();
    final bodies = [
      for (final book in workbooks)
        for (final fixture in book.fixtures) fixture.body,
    ];
    expect(bodies, isNotEmpty);

    for (final body in bodies) {
      final event = scrubEvent(
        SentryEvent(
          message: SentryMessage('Parse failed: $body'),
          exceptions: [SentryException(type: 'StateError', value: body)],
          breadcrumbs: [Breadcrumb(message: body, category: 'navigation')],
        ),
      );
      final texts = [
        event.message?.formatted,
        ...?event.exceptions?.map((e) => e.value),
        ...?event.breadcrumbs?.map((b) => b.message),
      ].nonNulls;

      for (final text in texts) {
        expect(_leak.hasMatch(text), isFalse, reason: 'leaked in "$text"');
      }
    }
  });

  test('scrubEvent drops widget details, request and user', () {
    final event = scrubEvent(
      SentryEvent(
        contexts: Contexts()..['flutter_error_details'] = {'info': 'Tk 50'},
        request: SentryRequest(url: 'https://example.com'),
        user: SentryUser(id: 'u1'),
      ),
    );

    expect(event.contexts.containsKey('flutter_error_details'), isFalse);
    expect(event.request, isNull);
    expect(event.user, isNull);
  });

  group('scrubBreadcrumb', () {
    for (final category in ['ui.click', 'console', 'http', 'sms']) {
      test('drops $category', () {
        expect(scrubBreadcrumb(Breadcrumb(category: category)), isNull);
      });
    }

    test('keeps navigation without data', () {
      final crumb = scrubBreadcrumb(
        Breadcrumb(
          category: 'navigation',
          message: '/records/1234567',
          data: {'arguments': 'Tk 50'},
        ),
      );

      expect(crumb?.message, '/records/[redacted]');
      expect(crumb?.data, isNull);
    });
  });
}
