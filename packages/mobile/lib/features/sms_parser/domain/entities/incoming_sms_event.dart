import 'package:equatable/equatable.dart';
import '../services/sms_source_id.dart';

class IncomingSmsEvent extends Equatable {
  final String address;
  final String body;
  final DateTime receivedAt;

  String get sourceId =>
      smsSourceId(address: address, at: receivedAt, body: body);

  @override
  List<Object?> get props => [address, body, receivedAt];

  const IncomingSmsEvent({
    required this.address,
    required this.body,
    required this.receivedAt,
  });
}
