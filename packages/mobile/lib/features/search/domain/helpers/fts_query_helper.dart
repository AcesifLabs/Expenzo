String buildFtsMatchQuery(String raw) {
  if (raw.isEmpty) return '';
  final escaped = raw.replaceAll('"', '""');
  final trimmed = escaped.trim();
  if (trimmed.isEmpty) return '';

  return '"$trimmed"*';
}
