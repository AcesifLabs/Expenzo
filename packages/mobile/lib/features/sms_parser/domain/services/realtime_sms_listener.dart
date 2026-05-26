import '../entities/incoming_sms_event.dart';

abstract class RealtimeSmsListener {
  Stream<IncomingSmsEvent> get messages;

  Future<List<IncomingSmsEvent>> drainPendingMessages();

  Future<void> start();

  Future<void> stop();
}
