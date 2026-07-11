class RedactAiContext {
  const RedactAiContext();

  String call(String input) {
    var output = input;

    output = output.replaceAll(
      RegExp(r'\b[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[A-Za-z]{2,}\b'),
      '[REDACTED_EMAIL]',
    );

    output = output.replaceAll(
      RegExp(r'\+\d[\d\s\-()]{7,}\d\b'),
      '[REDACTED_PHONE]',
    );

    output = output.replaceAllMapped(RegExp(r'\b(?:\d[ -]?){8,}\d\b'), (match) {
      final raw = match.group(0) ?? '';
      final digits = raw.replaceAll(RegExp(r'\D'), '');
      if (digits.length < 8) {
        return raw;
      }

      final suffix = digits.substring(digits.length - 4);

      return '[REDACTED_NUMBER_$suffix]';
    });

    return output;
  }
}
