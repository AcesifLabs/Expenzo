package com.acesiflabs.expenzo

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val SMS_EVENT_CHANNEL = "expenzo/sms_events"
        private const val SMS_METHOD_CHANNEL = "expenzo/sms_methods"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    SmsEventStore.setEventSink(events)
                }

                override fun onCancel(arguments: Any?) {
                    SmsEventStore.setEventSink(null)
                }
            })

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SMS_METHOD_CHANNEL)
            .setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
                when (call.method) {
                    "drainPendingSmsEvents" -> {
                        result.success(SmsEventStore.drainPendingEvents(applicationContext))
                    }

                    else -> result.notImplemented()
                }
            }
    }
}
