import 'package:flutter/services.dart';

/// Thin wrapper around the MethodChannel that talks to
/// `AlarmSchedulerPlugin.kt`. This is the ONLY place in the Dart
/// codebase that should reference the channel name or method names,
/// keeping the native contract in one auditable spot.
class NativeAlarmBridge {
  static const MethodChannel _channel =
      MethodChannel('com.dailyspark.app/alarm_scheduler');

  /// Schedules (or reschedules) an exact alarm natively via
  /// AlarmManager. Payload must match [AlarmModel.toNativePayload].
  Future<void> scheduleAlarm(Map<String, dynamic> payload) async {
    await _channel.invokeMethod('scheduleAlarm', payload);
  }

  Future<void> cancelAlarm(String id) async {
    await _channel.invokeMethod('cancelAlarm', {'id': id});
  }

  /// Tells the native side to re-read the SharedPreferences mirror
  /// and re-arm every enabled alarm. Used on cold start as a safety
  /// net alongside BootReceiver.
  Future<void> rescheduleAll(List<Map<String, dynamic>> payloads) async {
    await _channel.invokeMethod('rescheduleAll', {'alarms': payloads});
  }

  /// Called from the ringing page when the user taps Snooze.
  Future<void> snoozeAlarm(String id, int snoozeMinutes) async {
    await _channel.invokeMethod(
      'snoozeAlarm',
      {'id': id, 'snoozeMinutes': snoozeMinutes},
    );
  }

  /// Called from the ringing page when the user taps Dismiss, or when
  /// the foreground ringing service should stop audio/vibration.
  Future<void> dismissAlarm(String id) async {
    await _channel.invokeMethod('dismissAlarm', {'id': id});
  }

  /// Registers a Dart-side callback invoked when `AlarmReceiver.kt`
  /// launches the app for a firing alarm, so the UI can navigate to
  /// the full-screen ringing page with the correct alarm id.
  void setFiringAlarmHandler(Future<void> Function(String alarmId) handler) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onAlarmFiring') {
        final id = (call.arguments as Map)['id'] as String;
        await handler(id);
      }
    });
  }
}
