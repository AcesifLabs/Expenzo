/// Escapes user input for safe use in FTS5 MATCH queries.
///
/// Embedded double-quotes are doubled (FTS5 spec), and the result
/// is wrapped as a quoted phrase-prefix query.
///
/// Returns empty string for empty or whitespace-only input.
String buildFtsMatchQuery(String raw) {
  if (raw.isEmpty) return '';
  final escaped = raw.replaceAll('"', '""');
  final trimmed = escaped.trim();
  if (trimmed.isEmpty) return '';

  return '"$trimmed"*';
}
