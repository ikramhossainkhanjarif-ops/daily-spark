package com.dailyspark.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Re-arms every enabled alarm directly from the native
 * [NativeAlarmStore] mirror after a device reboot — no Flutter
 * engine needs to spin up for this to work.
 */
class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED &&
            intent.action != "android.intent.action.QUICKBOOT_POWERON"
        ) {
            return
        }

        val store = NativeAlarmStore(context)
        val scheduler = AlarmScheduler(context)
        AlarmRingingService.createNotificationChannel(context)

        store.getAllAlarms().forEach { entry ->
            scheduler.scheduleExactAlarm(entry)
        }
    }
}
