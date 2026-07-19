package com.dailyspark.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build

/**
 * Fires when an [AlarmManager] exact alarm goes off. Starts the
 * foreground [AlarmRingingService] (which shows the full-screen
 * ringing UI + plays sound/vibration) and re-arms the next occurrence
 * for repeating alarms.
 */
class AlarmReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val alarmId = intent.getStringExtra(AlarmScheduler.EXTRA_ALARM_ID) ?: return
        val store = NativeAlarmStore(context)
        val entry = store.getAlarm(alarmId) ?: return

        val serviceIntent = Intent(context, AlarmRingingService::class.java).apply {
            putExtra(EXTRA_ALARM_ID, alarmId)
            putExtra(EXTRA_LABEL, entry.label)
            putExtra(EXTRA_SOUND_ID, entry.soundId)
            putExtra(EXTRA_VIBRATE, entry.vibrate)
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(serviceIntent)
        } else {
            context.startService(serviceIntent)
        }

        // Re-arm the next occurrence immediately so a repeating alarm
        // is never left unscheduled, even if the user never dismisses.
        AlarmScheduler(context).rearmAfterFiring(alarmId)

        // Notify a running Flutter engine, if any, so it can navigate
        // straight to the ringing page without waiting on the service.
        AlarmSchedulerPlugin.instance?.notifyAlarmFiring(alarmId)
    }

    companion object {
        const val EXTRA_ALARM_ID = "extra_alarm_id"
        const val EXTRA_LABEL = "extra_label"
        const val EXTRA_SOUND_ID = "extra_sound_id"
        const val EXTRA_VIBRATE = "extra_vibrate"
    }
}
