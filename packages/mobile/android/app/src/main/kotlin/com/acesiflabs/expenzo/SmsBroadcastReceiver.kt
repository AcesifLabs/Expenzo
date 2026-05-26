package com.acesiflabs.expenzo

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony
import android.telephony.SmsMessage

class SmsBroadcastReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) {
            return
        }

        val messages = extractMessages(intent)
        if (messages.isEmpty()) {
            return
        }

        val sender = messages.first().displayOriginatingAddress ?: ""
        val isSingleLogicalMessage = messages.all {
            (it.displayOriginatingAddress ?: "") == sender
        }

        if (isSingleLogicalMessage) {
            val combinedBody = buildString {
                messages.forEach { append(it.displayMessageBody ?: "") }
            }
            val payload = mapOf(
                "sender" to sender,
                "body" to combinedBody,
                "timestamp" to messages.first().timestampMillis
            )
            SmsEventStore.appendEvent(context, payload, fromReceiver = true)
            return
        }

        for (message in messages) {
            val payload = mapOf(
                "sender" to (message.displayOriginatingAddress ?: ""),
                "body" to (message.displayMessageBody ?: ""),
                "timestamp" to message.timestampMillis
            )
            SmsEventStore.appendEvent(context, payload, fromReceiver = true)
        }
    }

    private fun extractMessages(intent: Intent): List<SmsMessage> {
        val fromIntent = Telephony.Sms.Intents.getMessagesFromIntent(intent)
        if (fromIntent.isNotEmpty()) {
            return fromIntent.toList()
        }

        val extras = intent.extras ?: return emptyList()
        val pdus = extras.get("pdus") as? Array<*> ?: return emptyList()
        val format = extras.getString("format")

        return pdus.mapNotNull { pdu ->
            val bytes = pdu as? ByteArray ?: return@mapNotNull null
            SmsMessage.createFromPdu(bytes, format)
        }
    }
}
