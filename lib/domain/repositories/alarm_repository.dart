import '../entities/alarm.dart';

/// Abstract contract for alarm persistence + native scheduling.
/// Implemented in the data layer using SharedPreferences + MethodChannel.
abstract class AlarmRepository {
  Future<List<Alarm>> getAlarms();

  Future<Alarm?> getAlarmById(String id);

  /// Persists the alarm locally AND schedules it natively via the
  /// platform channel so it survives app kill / device reboot.
  Future<void> saveAlarm(Alarm alarm);

  Future<void> deleteAlarm(String id);

  /// Enables/disables an alarm, updating both local storage and the
  /// native exact-alarm schedule.
  Future<void> setEnabled(String id, bool enabled);

  /// Re-arms all enabled alarms with the native scheduler. Used on
  /// app startup as a safety net alongside the native BootReceiver.
  Future<void> rescheduleAll();
}
