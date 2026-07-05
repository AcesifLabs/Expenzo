import 'dart:async';

class SyncTriggered {}

class SyncEventBus {
  static final SyncEventBus _instance = SyncEventBus._internal();
  final StreamController<SyncTriggered> _controller =
      StreamController<SyncTriggered>.broadcast();

  Stream<SyncTriggered> get events => _controller.stream;

  factory SyncEventBus() => _instance;
  SyncEventBus._internal();

  void trigger() => _controller.add(SyncTriggered());
  void dispose() => _controller.close();
}
