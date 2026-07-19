import 'package:equatable/equatable.dart';
import '../../../domain/entities/alarm.dart';

abstract class AlarmListEvent extends Equatable {
  const AlarmListEvent();
  @override
  List<Object?> get props => [];
}

class LoadAlarms extends AlarmListEvent {
  const LoadAlarms();
}

class UpsertAlarmRequested extends AlarmListEvent {
  final Alarm alarm;
  const UpsertAlarmRequested(this.alarm);
  @override
  List<Object?> get props => [alarm];
}

class DeleteAlarmRequested extends AlarmListEvent {
  final String id;
  const DeleteAlarmRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class ToggleAlarmRequested extends AlarmListEvent {
  final String id;
  final bool enabled;
  const ToggleAlarmRequested(this.id, this.enabled);
  @override
  List<Object?> get props => [id, enabled];
}
