class SmsSenderNormalizer {
  static final RegExp _whitespacePattern = RegExp(r'\s+');

  static String normalize(String sender) {
    return sender.trim().replaceAll(_whitespacePattern, ' ').toLowerCase();
  }

  static bool matches(String left, String right) {
    return normalize(left) == normalize(right);
  }
}
