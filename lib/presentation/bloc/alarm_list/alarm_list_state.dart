import 'package:equatable/equatable.dart';
import '../../../domain/entities/alarm.dart';

enum AlarmListStatus { initial, loading, loaded, error }

class AlarmListState extends Equatable {
  final AlarmListStatus status;
  final List<Alarm> alarms;
  final String? errorMessage;

  const AlarmListState({
    this.status = AlarmListStatus.initial,
    this.alarms = const [],
    this.errorMessage,
  });

  AlarmListState copyWith({
    AlarmListStatus? status,
    List<Alarm>? alarms,
    String? errorMessage,
  }) {
    return AlarmListState(
      status: status ?? this.status,
      alarms: alarms ?? this.alarms,
      errorMessage: errorMessage,
    );
  }

  List<Alarm> get sortedAlarms {
    final copy = [...alarms];
    copy.sort((a, b) {
      final aMinutes = a.hour * 60 + a.minute;
      final bMinutes = b.hour * 60 + b.minute;
      return aMinutes.compareTo(bMinutes);
    });
    return copy;
  }

  @override
  List<Object?> get props => [status, alarms, errorMessage];
}
