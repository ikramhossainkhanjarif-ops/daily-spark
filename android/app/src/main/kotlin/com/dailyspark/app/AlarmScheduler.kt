package com.dailyspark.app

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import java.util.Calendar

/**
 * Wraps [AlarmManager] to schedule exact, wake-from-doze alarms that
 * survive app kill. Actual re-arm-after-fire (for repeating alarms)
 * happens in [AlarmReceiver], since AlarmManager exact alarms are
 * one-shot by design.
 */
class AlarmScheduler(private val context: Context) {

    private val alarmManager =
        context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
    private val store = NativeAlarmStore(context)

    private fun pendingIntentFor(id: String): PendingIntent {
        val intent = Intent(context, AlarmReceiver::class.java).apply {
            action = ACTION_ALARM_FIRE
            putExtra(EXTRA_ALARM_ID, id)
        }
        return PendingIntent.getBroadcast(
            context,
            id.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    /** Computes the next trigger time in millis for a given entry. */
    fun nextTriggerMillis(entry: NativeAlarmStore.AlarmEntry): Long {
        val now = Calendar.getInstance()
        val target = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, entry.hour)
            set(Calendar.MINUTE, entry.minute)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }

        if (entry.repeatDays.isEmpty()) {
            if (target.before(now)) target.add(Calendar.DAY_OF_YEAR, 1)
            return target.timeInMillis
        }

        // Repeat days are 1=Mon..7=Sun; Calendar.DAY_OF_WEEK is 1=Sun..7=Sat.
        fun toCalendarDay(d: Int) = if (d == 7) Calendar.SUNDAY else d + 1

        for (offset in 0..7) {
            val candidate = target.clone() as Calendar
            candidate.add(Calendar.DAY_OF_YEAR, offset)
            val calendarDay = candidate.get(Calendar.DAY_OF_WEEK)
            val matches = entry.repeatDays.any { toCalendarDay(it) == calendarDay }
            if (matches && candidate.after(now)) {
                return candidate.timeInMillis
            }
        }
        // Fallback: one week out on the first configured day.
        target.add(Calendar.DAY_OF_YEAR, 7)
        return target.timeInMillis
    }

    fun scheduleExactAlarm(entry: NativeAlarmStore.AlarmEntry) {
        val triggerAt = nextTriggerMillis(entry)
        setExact(triggerAt, pendingIntentFor(entry.id))
    }

    fun snoozeAlarm(id: String, minutes: Int) {
        val triggerAt = System.currentTimeMillis() + minutes * 60_000L
        setExact(triggerAt, pendingIntentFor(id))
    }

    /** Re-arms the next occurrence for a repeating alarm after it fires. */
    fun rearmAfterFiring(id: String) {
        val entry = store.getAlarm(id) ?: return
        if (entry.repeatDays.isEmpty()) return // one-time alarms don't repeat
        scheduleExactAlarm(entry)
    }

    fun cancelAlarm(id: String) {
        alarmManager.cancel(pendingIntentFor(id))
    }

    fun dismissAlarm(id: String) {
        AlarmRingingService.stopRinging(context, id)
        rearmAfterFiring(id)
    }

    private fun setExact(triggerAt: Long, pendingIntent: PendingIntent) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (alarmManager.canScheduleExactAlarms()) {
                alarmManager.setAlarmClock(
                    AlarmManager.AlarmClockInfo(triggerAt, pendingIntent),
                    pendingIntent,
                )
            } else {
                // Falls back to inexact if the user revoked the permission;
                // the app should prompt them to re-grant it in-app.
                alarmManager.setAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP, triggerAt, pendingIntent,
                )
            }
        } else {
            alarmManager.setAlarmClock(
                AlarmManager.AlarmClockInfo(triggerAt, pendingIntent),
                pendingIntent,
            )
        }
    }

    companion object {
        const val ACTION_ALARM_FIRE = "com.dailyspark.app.ACTION_ALARM_FIRE"
        const val EXTRA_ALARM_ID = "extra_alarm_id"
    }
}
