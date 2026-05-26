package com.acesiflabs.expenzo

import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel
import org.json.JSONArray
import org.json.JSONObject

object SmsEventStore {
    private const val PREFS_NAME = "sms_event_store"
    private const val KEY_PENDING_EVENTS = "pending_events"

    @Volatile
    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    @Synchronized
    fun setEventSink(sink: EventChannel.EventSink?) {
        eventSink = sink
    }

    fun appendEvent(context: Context, payload: Map<String, Any>, fromReceiver: Boolean = false) {
        val payloadJson = JSONObject(payload).toString()
        val sharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        synchronized(this) {
            val raw = sharedPreferences.getString(KEY_PENDING_EVENTS, null)
            val array = try {
                if (raw.isNullOrBlank()) JSONArray() else JSONArray(raw)
            } catch (_: Exception) {
                JSONArray()
            }
            array.put(payloadJson)
            val editor = sharedPreferences.edit().putString(KEY_PENDING_EVENTS, array.toString())
            if (fromReceiver) {
                editor.commit()
            } else {
                editor.apply()
            }
        }
        val sink = eventSink ?: return
        mainHandler.post {
            sink.success(payload)
        }
    }

    fun drainPendingEvents(context: Context): List<Map<String, Any>> {
        val sharedPreferences = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        synchronized(this) {
            val raw = sharedPreferences.getString(KEY_PENDING_EVENTS, null)
            sharedPreferences.edit().remove(KEY_PENDING_EVENTS).apply()

            if (raw.isNullOrBlank()) {
                return emptyList()
            }

            val array = try {
                JSONArray(raw)
            } catch (_: Exception) {
                JSONArray()
            }
            return List(array.length()) { index -> array.optString(index, "") }
                .mapNotNull { parsePayload(it) }
        }
    }

    private fun parsePayload(rawPayload: String): Map<String, Any>? {
        if (rawPayload.isBlank()) {
            return null
        }
        return try {
            val json = JSONObject(rawPayload)
            mapOf(
                "sender" to json.optString("sender", ""),
                "body" to json.optString("body", ""),
                "timestamp" to json.optLong("timestamp", 0L)
            )
        } catch (_: Exception) {
            null
        }
    }
}
