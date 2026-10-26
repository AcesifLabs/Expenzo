import 'package:sentry_flutter/sentry_flutter.dart';

const redactedText = '[redacted]';

const _maxMessageLength = 200;

final _money = RegExp(
  r'(?:tk\.?|bdt|rs\.?|inr|usd|eur|gbp|jpy|৳|\$|€|£|¥)\s*[\d০-৯][\d০-৯,.]*',
  caseSensitive: false,
);

final _decimal = RegExp(r'[\d০-৯][\d০-৯,]*\.[\d০-৯]+');

final _digitRun = RegExp(r'[\d০-৯](?:[ ,.\-]?[\d০-৯]){3,}');

const _droppedCategories = {'ui.click', 'ui.text', 'console', 'http', 'sms'};

String redact(String text) => text
    .replaceAll(_money, redactedText)
    .replaceAll(_decimal, redactedText)
    .replaceAll(_digitRun, redactedText);

String scrubMessage(String text) {
  final firstLine = text.split('\n').first;
  final clean = redact(firstLine);

  return clean.length > _maxMessageLength
      ? '${clean.substring(0, _maxMessageLength)}…'
      : clean;
}

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

  event.contexts.remove('flutter_error_details');
  event.request = null;
  event.user = null;

  return event;
}

Breadcrumb? scrubBreadcrumb(Breadcrumb? crumb) {
  if (crumb == null || _droppedCategories.contains(crumb.category)) {
    return null;
  }
  final message = crumb.message;
  crumb.message = message == null ? null : scrubMessage(message);
  crumb.data = null;

  return crumb;
}
