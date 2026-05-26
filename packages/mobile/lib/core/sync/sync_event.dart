import 'dart:async';

class SyncTriggered {}

class SyncEventBus {
  static final SyncEventBus _instance = SyncEventBus._internal();
  factory SyncEventBus() => _instance;
  SyncEventBus._internal();
  final _controller = StreamController<SyncTriggered>.broadcast();
  Stream<SyncTriggered> get events => _controller.stream;
  void trigger() => _controller.add(SyncTriggered());
  void dispose() => _controller.close();
}
