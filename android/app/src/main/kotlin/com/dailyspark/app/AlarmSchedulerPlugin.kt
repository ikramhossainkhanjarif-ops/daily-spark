package com.dailyspark.app

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * Bridges Flutter's `NativeAlarmBridge` to the native scheduling
 * pipeline (AlarmScheduler + NativeAlarmStore). This is the only
 * class Dart code should ever call into for alarm scheduling.
 *
 * Channel name MUST match `native_alarm_bridge.dart`:
 * "com.dailyspark.app/alarm_scheduler"
 */
class AlarmSchedulerPlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var scheduler: AlarmScheduler
    private lateinit var store: NativeAlarmStore

    companion object {
        const val CHANNEL_NAME = "com.dailyspark.app/alarm_scheduler"

        // Retained so AlarmRingingActivity / broadcast handlers can push
        // "onAlarmFiring" events back to Dart if the engine is already
        // running (e.g. app was in background, not fully killed).
        var instance: AlarmSchedulerPlugin? = null
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        scheduler = AlarmScheduler(binding.applicationContext)
        store = NativeAlarmStore(binding.applicationContext)
        instance = this
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        instance = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "consumePendingLaunchAlarm" -> {
    val id = MainActivity.pendingLaunchAlarmId
    MainActivity.pendingLaunchAlarmId = null
    result.success(id)
}
            "scheduleAlarm" -> {
                val args = call.arguments as Map<*, *>
                val entry = NativeAlarmStore.AlarmEntry.fromMethodArgs(args)
                store.saveAlarm(entry)
                scheduler.scheduleExactAlarm(entry)
                result.success(null)
            }
            "cancelAlarm" -> {
                val id = (call.arguments as Map<*, *>)["id"] as String
                store.removeAlarm(id)
                scheduler.cancelAlarm(id)
                result.success(null)
            }
            "rescheduleAll" -> {
                val args = call.arguments as Map<*, *>
                @Suppress("UNCHECKED_CAST")
                val alarms = args["alarms"] as List<Map<String, Any?>>
                val entries = alarms.map { NativeAlarmStore.AlarmEntry.fromMethodArgs(it) }
                store.saveAllAlarms(entries)
                entries.forEach { scheduler.scheduleExactAlarm(it) }
                result.success(null)
            }
            "snoozeAlarm" -> {
                val args = call.arguments as Map<*, *>
                val id = args["id"] as String
                val minutes = (args["snoozeMinutes"] as? Int) ?: 9
                scheduler.snoozeAlarm(id, minutes)
                result.success(null)
            }
            "dismissAlarm" -> {
                val id = (call.arguments as Map<*, *>)["id"] as String
                scheduler.dismissAlarm(id)
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    /** Notifies Dart that an alarm is firing so the UI can navigate. */
    fun notifyAlarmFiring(alarmId: String) {
        channel.invokeMethod("onAlarmFiring", mapOf("id" to alarmId))
    }
}
