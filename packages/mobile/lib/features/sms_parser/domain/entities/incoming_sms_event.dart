import 'package:equatable/equatable.dart';
import '../services/sms_sender_normalizer.dart';

class IncomingSmsEvent extends Equatable {
  final String address;
  final String body;
  final DateTime receivedAt;

  String get sourceId {
    final bodyHash = _fnv1a32(body);
    final timestamp = receivedAt.toUtc().millisecondsSinceEpoch;
    final normalizedAddress = SmsSenderNormalizer.normalize(address);

    return '$normalizedAddress:$timestamp:$bodyHash';
  }

  const IncomingSmsEvent({
    required this.address,
    required this.body,
    required this.receivedAt,
  });

  static String _fnv1a32(String input) {
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

  @override
  List<Object?> get props => [address, body, receivedAt];
}
