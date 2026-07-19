import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/alarm_usecases.dart';
import 'alarm_list_event.dart';
import 'alarm_list_state.dart';

class AlarmListBloc extends Bloc<AlarmListEvent, AlarmListState> {
  final GetAlarms getAlarms;
  final SaveAlarm saveAlarm;
  final DeleteAlarm deleteAlarm;
  final ToggleAlarm toggleAlarm;

  AlarmListBloc({
    required this.getAlarms,
    required this.saveAlarm,
    required this.deleteAlarm,
    required this.toggleAlarm,
  }) : super(const AlarmListState()) {
    on<LoadAlarms>(_onLoad);
    on<UpsertAlarmRequested>(_onUpsert);
    on<DeleteAlarmRequested>(_onDelete);
    on<ToggleAlarmRequested>(_onToggle);
  }

  Future<void> _onLoad(LoadAlarms event, Emitter<AlarmListState> emit) async {
    emit(state.copyWith(status: AlarmListStatus.loading));
    try {
      final alarms = await getAlarms();
      emit(state.copyWith(status: AlarmListStatus.loaded, alarms: alarms));
    } catch (e) {
      emit(state.copyWith(
        status: AlarmListStatus.error,
        errorMessage: 'Could not load alarms: $e',
      ));
    }
  }

  Future<void> _onUpsert(
    UpsertAlarmRequested event,
    Emitter<AlarmListState> emit,
  ) async {
    await saveAlarm(event.alarm);
    final alarms = await getAlarms();
    emit(state.copyWith(status: AlarmListStatus.loaded, alarms: alarms));
  }

  Future<void> _onDelete(
    DeleteAlarmRequested event,
    Emitter<AlarmListState> emit,
  ) async {
    await deleteAlarm(event.id);
    final alarms = await getAlarms();
    emit(state.copyWith(status: AlarmListStatus.loaded, alarms: alarms));
  }

  Future<void> _onToggle(
    ToggleAlarmRequested event,
    Emitter<AlarmListState> emit,
  ) async {
    await toggleAlarm(event.id, event.enabled);
    final alarms = await getAlarms();
    emit(state.copyWith(status: AlarmListStatus.loaded, alarms: alarms));
  }
}
