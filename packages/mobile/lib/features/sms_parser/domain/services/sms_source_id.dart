import 'sms_sender_normalizer.dart';

String smsSourceId({
  required String address,
  required DateTime at,
  required String body,
}) {
  final timestamp = at.toUtc().millisecondsSinceEpoch;

  return '${SmsSenderNormalizer.normalize(address)}:$timestamp:${_fnv1a32(body)}';
}

String legacyScanSourceId({required String address, required DateTime at}) =>
    '${address}_${at.toIso8601String()}'.hashCode.abs().toString();

String _fnv1a32(String input) {
  const int offsetBasis = 0x811C9DC5;
  const int fnvPrime = 0x01000193;
  const int mask32 = 0xFFFFFFFF;

  var hash = offsetBasis;
  for (final unit in input.codeUnits) {
    hash ^= unit;
    hash = (hash * fnvPrime) & mask32;
  }

  return hash.toRadixString(16).padLeft(8, '0');
}
