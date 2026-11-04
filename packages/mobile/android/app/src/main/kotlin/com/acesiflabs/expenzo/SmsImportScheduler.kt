package com.acesiflabs.expenzo

import android.content.Context
import android.os.Build
import androidx.work.Data
import androidx.work.ExistingWorkPolicy
import androidx.work.OneTimeWorkRequest
import androidx.work.OutOfQuotaPolicy
import androidx.work.WorkManager
import dev.fluttercommunity.workmanager.BackgroundWorker

/**
 * Runs the Dart SMS parser for a message that arrived while no Flutter engine
 * was listening (app closed or killed). The work goes through the workmanager
 * plugin's [BackgroundWorker], which calls the app's Dart background dispatcher
 * with [TASK_NAME] and the message as input data.
 *
 * Messages are also kept in [SmsEventStore], so anything this job misses is
 * parsed on the next app open. Records are de-duplicated by SMS id.
 */
object SmsImportScheduler {
    /** Must match `BackgroundTaskNames.smsImport` in Dart. */
    const val TASK_NAME = "expenzo.smsImport"

    // The plugin hands keys with this prefix to Dart as inputData.
    private const val PAYLOAD_PREFIX = "payload_"

    fun enqueue(context: Context, payload: Map<String, Any>) {
        val data = Data.Builder().putString(BackgroundWorker.DART_TASK_KEY, TASK_NAME)
        for ((key, value) in payload) {
            when (value) {
                is String -> data.putString(PAYLOAD_PREFIX + key, value)
                is Long -> data.putLong(PAYLOAD_PREFIX + key, value)
                is Int -> data.putInt(PAYLOAD_PREFIX + key, value)
            }
        }

        val request = OneTimeWorkRequest.Builder(BackgroundWorker::class.java)
            .setInputData(data.build())
        // BackgroundWorker has no foreground info, which expedited work needs
        // before Android 12. Older versions run it as normal one-off work.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            request.setExpedited(OutOfQuotaPolicy.RUN_AS_NON_EXPEDITED_WORK_REQUEST)
        }

        // One chain so messages are parsed one at a time, in arrival order.
        WorkManager.getInstance(context).enqueueUniqueWork(
            TASK_NAME,
            ExistingWorkPolicy.APPEND_OR_REPLACE,
            request.build(),
        )
    }
}
