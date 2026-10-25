import 'package:sentry_flutter/sentry_flutter.dart';

/// Replaces anything that could be money or an account number.
const redactedText = '[redacted]';

/// Longest message kept in a Crash Report.
const _maxMessageLength = 200;

/// A currency mark followed by an amount: `Tk 1,500.00`, `৳৫০০`, `Rs.250`.
final _money = RegExp(
  r'(?:tk\.?|bdt|rs\.?|inr|usd|eur|gbp|jpy|৳|\$|€|£|¥)\s*[\d০-৯][\d০-৯,.]*',
  caseSensitive: false,
);

/// A number with a decimal part: `1500.00`, `1,74,094.39`.
final _decimal = RegExp(r'[\d০-৯][\d০-৯,]*\.[\d০-৯]+');

/// Four or more digits, allowing one separator between them: account and
/// card numbers, phone numbers, OTPs, whole amounts.
final _digitRun = RegExp(r'[\d০-৯](?:[ ,.\-]?[\d০-৯]){3,}');

/// Breadcrumbs that can carry what the user typed or read.
const _droppedCategories = {'ui.click', 'ui.text', 'console', 'http', 'sms'};

/// [text] with money, decimals and long digit runs replaced.
String redact(String text) => text
    .replaceAll(_money, redactedText)
    .replaceAll(_decimal, redactedText)
    .replaceAll(_digitRun, redactedText);

/// The first line of [text], redacted and cut to 200 characters. Dart
/// exceptions put their input on later lines (a `FormatException` shows
/// the source text), so those lines are dropped.
String scrubMessage(String text) {
  final firstLine = text.split('\n').first;
  final clean = redact(firstLine);

  return clean.length > _maxMessageLength
      ? '${clean.substring(0, _maxMessageLength)}…'
      : clean;
}

/// [event] with every free-text field scrubbed (ADR 0013).
SentryEvent scrubEvent(SentryEvent event) {
  final message = event.message;
  event.message = message == null
      ? null
      : SentryMessage(scrubMessage(message.formatted));
  for (final exception in event.exceptions ?? const <SentryException>[]) {
    final value = exception.value;
    if (value != null) exception.value = scrubMessage(value);
  }
  event.breadcrumbs = event.breadcrumbs?.map(scrubBreadcrumb).nonNulls.toList();
  // Widget descriptions, which include the text the widget showed.
  event.contexts.remove('flutter_error_details');
  event.request = null;
  event.user = null;

  return event;
}

/// Null for breadcrumbs that can carry user text; otherwise [crumb] with its
/// message scrubbed and its data dropped.
Breadcrumb? scrubBreadcrumb(Breadcrumb? crumb) {
  if (crumb == null || _droppedCategories.contains(crumb.category)) {
    return null;
  }
  final message = crumb.message;
  crumb.message = message == null ? null : scrubMessage(message);
  crumb.data = null;

  return crumb;
}
