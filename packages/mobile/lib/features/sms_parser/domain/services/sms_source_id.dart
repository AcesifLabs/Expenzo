import 'sms_sender_normalizer.dart';

/// A record's `source_id` for an SMS: sender, time and a hash of the text,
/// so two different messages never share it. Used by live imports and inbox
/// scans alike, so [at] must be the same moment on both: the time on the
/// message itself (the PDU timestamp, the inbox's `date_sent`), not when
/// the phone received it.
String smsSourceId({
  required String address,
  required DateTime at,
  required String body,
}) {
  final timestamp = at.toUtc().millisecondsSinceEpoch;

  return '${SmsSenderNormalizer.normalize(address)}:$timestamp:${_fnv1a32(body)}';
}

/// The id inbox scans gave records before database v20: a 30-bit hash of
/// sender and time, which different messages can share. Only for finding
/// messages imported back then.
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
