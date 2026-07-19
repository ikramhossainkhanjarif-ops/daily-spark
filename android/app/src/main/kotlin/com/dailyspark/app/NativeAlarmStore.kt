package com.dailyspark.app

import android.content.Context
import android.content.SharedPreferences
import org.json.JSONArray
import org.json.JSONObject

/**
 * Native-side mirror of the alarm list, stored in its own
 * SharedPreferences file (separate from Flutter's) so it can be read
 * synchronously by [BootReceiver] and [AlarmReceiver] without
 * spinning up a Flutter engine.
 */
class NativeAlarmStore(context: Context) {

    data class AlarmEntry(
        val id: String,
        val hour: Int,
        val minute: Int,
        val label: String,
        val repeatDays: List<Int>, // 1=Mon .. 7=Sun, empty = one-time
        val soundId: String,
        val vibrate: Boolean,
    ) {
        fun toJson(): JSONObject = JSONObject().apply {
            put("id", id)
            put("hour", hour)
            put("minute", minute)
            put("label", label)
            put("repeatDays", JSONArray(repeatDays))
            put("soundId", soundId)
            put("vibrate", vibrate)
        }

        companion object {
            fun fromJson(json: JSONObject): AlarmEntry {
                val daysArray = json.optJSONArray("repeatDays") ?: JSONArray()
                val days = (0 until daysArray.length()).map { daysArray.getInt(it) }
                return AlarmEntry(
                    id = json.getString("id"),
                    hour = json.getInt("hour"),
                    minute = json.getInt("minute"),
                    label = json.optString("label", ""),
                    repeatDays = days,
                    soundId = json.optString("soundId", "default"),
                    vibrate = json.optBoolean("vibrate", true),
                )
            }

            @Suppress("UNCHECKED_CAST")
            fun fromMethodArgs(args: Map<*, *>): AlarmEntry {
                val days = (args["repeatDays"] as? List<Int>) ?: emptyList()
                return AlarmEntry(
                    id = args["id"] as String,
                    hour = args["hour"] as Int,
                    minute = args["minute"] as Int,
                    label = (args["label"] as? String) ?: "",
                    repeatDays = days,
                    soundId = (args["soundId"] as? String) ?: "default",
                    vibrate = (args["vibrate"] as? Boolean) ?: true,
                )
            }
        }
    }

    private val prefs: SharedPreferences =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    companion object {
        const val PREFS_NAME = "daily_spark_native_alarms"
        const val KEY_ALARMS = "alarms_json"
    }

    fun getAllAlarms(): List<AlarmEntry> {
        val raw = prefs.getString(KEY_ALARMS, null) ?: return emptyList()
        val array = JSONArray(raw)
        return (0 until array.length()).map { AlarmEntry.fromJson(array.getJSONObject(it)) }
    }

    fun saveAllAlarms(entries: List<AlarmEntry>) {
        val array = JSONArray()
        entries.forEach { array.put(it.toJson()) }
        prefs.edit().putString(KEY_ALARMS, array.toString()).apply()
    }

    fun saveAlarm(entry: AlarmEntry) {
        val current = getAllAlarms().toMutableList()
        val idx = current.indexOfFirst { it.id == entry.id }
        if (idx >= 0) current[idx] = entry else current.add(entry)
        saveAllAlarms(current)
    }

    fun removeAlarm(id: String) {
        val current = getAllAlarms().filterNot { it.id == id }
        saveAllAlarms(current)
    }

    fun getAlarm(id: String): AlarmEntry? = getAllAlarms().find { it.id == id }
}
