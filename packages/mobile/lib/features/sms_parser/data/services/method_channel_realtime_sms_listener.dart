import 'dart:async';

import 'package:expense_tracker/features/sms_parser/data/mappers/incoming_sms_event_mapper.dart';
import 'package:expense_tracker/features/sms_parser/domain/entities/incoming_sms_event.dart';
import 'package:expense_tracker/features/sms_parser/domain/services/realtime_sms_listener.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class MethodChannelRealtimeSmsListener implements RealtimeSmsListener {
  static const String eventChannelName = 'expenzo/sms_events';
  static const String methodChannelName = 'expenzo/sms_methods';

  static const String _drainPendingMethod = 'drainPendingSmsEvents';

  final EventChannel _eventChannel;
  final MethodChannel _methodChannel;

  StreamSubscription<dynamic>? _subscription;
  final StreamController<IncomingSmsEvent> _messagesController =
      StreamController<IncomingSmsEvent>.broadcast();

  @override
  Stream<IncomingSmsEvent> get messages => _messagesController.stream;

  MethodChannelRealtimeSmsListener({
    EventChannel? eventChannel,
    MethodChannel? methodChannel,
  }) : _eventChannel = eventChannel ?? const EventChannel(eventChannelName),
       _methodChannel = methodChannel ?? const MethodChannel(methodChannelName);

  @override
  Future<List<IncomingSmsEvent>> drainPendingMessages() async {
    try {
      final raw = await _methodChannel.invokeMethod<List<Object?>>(
        _drainPendingMethod,
      );

      return (raw ?? const <Object?>[])
          .whereType<Map<Object?, Object?>>()
          .map(mapIncomingSmsEventPayload)
          .toList(growable: false);
    } on MissingPluginException {
      debugPrint(
        'MethodChannelRealtimeSmsListener: method channel unavailable',
      );

      return const <IncomingSmsEvent>[];
    }
  }

  @override
  Future<void> start() async {
    _subscription ??= _eventChannel.receiveBroadcastStream().listen(
      _onEventPayload,
      onError: _onEventError,
    );
  }

  @override
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  void _onEventPayload(Object? payload) {
    if (payload is Map<Object?, Object?>) {
      _messagesController.add(mapIncomingSmsEventPayload(payload));
    }
  }

  void _onEventError(Object error, StackTrace stackTrace) {
    if (error is MissingPluginException) {
      debugPrint('MethodChannelRealtimeSmsListener: event channel unavailable');

      return;
    }
    _messagesController.addError(error, stackTrace);
  }
}
