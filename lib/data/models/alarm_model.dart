import '../../domain/entities/alarm.dart';

/// Data-layer representation of [Alarm] with JSON (de)serialization for
/// SharedPreferences storage and for the MethodChannel payload sent to
/// the native Kotlin scheduler.
class AlarmModel extends Alarm {
  const AlarmModel({
    required super.id,
    required super.hour,
    required super.minute,
    super.label,
    super.isEnabled,
    super.repeatDays,
    super.soundId,
    super.vibrate,
    super.snoozeMinutes,
    super.pinnedMessageId,
  });

  factory AlarmModel.fromEntity(Alarm alarm) => AlarmModel(
        id: alarm.id,
        hour: alarm.hour,
        minute: alarm.minute,
        label: alarm.label,
        isEnabled: alarm.isEnabled,
        repeatDays: alarm.repeatDays,
        soundId: alarm.soundId,
        vibrate: alarm.vibrate,
        snoozeMinutes: alarm.snoozeMinutes,
        pinnedMessageId: alarm.pinnedMessageId,
      );

  factory AlarmModel.fromJson(Map<String, dynamic> json) => AlarmModel(
        id: json['id'] as String,
        hour: json['hour'] as int,
        minute: json['minute'] as int,
        label: json['label'] as String? ?? '',
        isEnabled: json['isEnabled'] as bool? ?? true,
        repeatDays: (json['repeatDays'] as List<dynamic>? ?? [])
            .map((e) => e as int)
            .toList(),
        soundId: json['soundId'] as String? ?? 'default',
        vibrate: json['vibrate'] as bool? ?? true,
        snoozeMinutes: json['snoozeMinutes'] as int? ?? 9,
        pinnedMessageId: json['pinnedMessageId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'hour': hour,
        'minute': minute,
        'label': label,
        'isEnabled': isEnabled,
        'repeatDays': repeatDays,
        'soundId': soundId,
        'vibrate': vibrate,
        'snoozeMinutes': snoozeMinutes,
        'pinnedMessageId': pinnedMessageId,
      };

  /// Payload shape expected by `AlarmSchedulerPlugin.kt`.
  Map<String, dynamic> toNativePayload() => {
        'id': id,
        'hour': hour,
        'minute': minute,
        'label': label,
        'repeatDays': repeatDays,
        'soundId': soundId,
        'vibrate': vibrate,
      };
}
