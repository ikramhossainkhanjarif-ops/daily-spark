import 'package:equatable/equatable.dart';

/// Pure domain entity representing a single alarm.
/// Contains no Flutter, storage, or platform-channel dependencies.
class Alarm extends Equatable {
  final String id;
  final int hour;
  final int minute;
  final String label;
  final bool isEnabled;

  /// Days of week this alarm repeats on. 1 = Monday ... 7 = Sunday.
  /// Empty list means a one-time alarm.
  final List<int> repeatDays;

  final String soundId;
  final bool vibrate;
  final int snoozeMinutes;

  /// If set, this alarm rings using this custom message instead of a
  /// randomly selected one from the pool.
  final String? pinnedMessageId;

  const Alarm({
    required this.id,
    required this.hour,
    required this.minute,
    this.label = '',
    this.isEnabled = true,
    this.repeatDays = const [],
    this.soundId = 'default',
    this.vibrate = true,
    this.snoozeMinutes = 9,
    this.pinnedMessageId,
  });

  bool get isOneTime => repeatDays.isEmpty;

  Alarm copyWith({
    String? id,
    int? hour,
    int? minute,
    String? label,
    bool? isEnabled,
    List<int>? repeatDays,
    String? soundId,
    bool? vibrate,
    int? snoozeMinutes,
    String? pinnedMessageId,
    bool clearPinnedMessage = false,
  }) {
    return Alarm(
      id: id ?? this.id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      label: label ?? this.label,
      isEnabled: isEnabled ?? this.isEnabled,
      repeatDays: repeatDays ?? this.repeatDays,
      soundId: soundId ?? this.soundId,
      vibrate: vibrate ?? this.vibrate,
      snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
      pinnedMessageId:
          clearPinnedMessage ? null : (pinnedMessageId ?? this.pinnedMessageId),
    );
  }

  @override
  List<Object?> get props => [
        id,
        hour,
        minute,
        label,
        isEnabled,
        repeatDays,
        soundId,
        vibrate,
        snoozeMinutes,
        pinnedMessageId,
      ];
}
