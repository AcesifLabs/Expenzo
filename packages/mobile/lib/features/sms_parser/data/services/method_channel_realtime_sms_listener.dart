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

  MethodChannelRealtimeSmsListener({
    EventChannel? eventChannel,
    MethodChannel? methodChannel,
  }) : _eventChannel = eventChannel ?? const EventChannel(eventChannelName),
       _methodChannel = methodChannel ?? const MethodChannel(methodChannelName);

  @override
  Stream<IncomingSmsEvent> get messages => _messagesController.stream;

  @override
  Future<List<IncomingSmsEvent>> drainPendingMessages() async {
    List<dynamic>? raw;
    try {
      raw = await _methodChannel.invokeMethod<List<dynamic>>(
        _drainPendingMethod,
      );
    } on MissingPluginException {
      debugPrint(
        'MethodChannelRealtimeSmsListener: method channel unavailable',
      );
      return const <IncomingSmsEvent>[];
    }

    return (raw ?? const <dynamic>[])
        .whereType<Map<dynamic, dynamic>>()
        .map(mapIncomingSmsEventPayload)
        .toList(growable: false);
  }

  @override
  Future<void> start() async {
    _subscription ??= _eventChannel.receiveBroadcastStream().listen(
      (payload) {
        if (payload is Map<dynamic, dynamic>) {
          _messagesController.add(mapIncomingSmsEventPayload(payload));
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (error is MissingPluginException) {
          debugPrint(
            'MethodChannelRealtimeSmsListener: event channel unavailable',
          );
          return;
        }
        _messagesController.addError(error, stackTrace);
      },
    );
  }

  @override
  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
