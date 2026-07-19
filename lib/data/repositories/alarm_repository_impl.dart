import '../../domain/entities/alarm.dart';
import '../../domain/repositories/alarm_repository.dart';
import '../datasources/alarm_local_datasource.dart';
import '../datasources/native_alarm_bridge.dart';
import '../models/alarm_model.dart';

class AlarmRepositoryImpl implements AlarmRepository {
  final AlarmLocalDataSource localDataSource;
  final NativeAlarmBridge nativeBridge;

  AlarmRepositoryImpl({
    required this.localDataSource,
    required this.nativeBridge,
  });

  @override
  Future<List<Alarm>> getAlarms() => localDataSource.getAll();

  @override
  Future<Alarm?> getAlarmById(String id) async {
    final all = await localDataSource.getAll();
    for (final a in all) {
      if (a.id == id) return a;
    }
    return null;
  }

  @override
  Future<void> saveAlarm(Alarm alarm) async {
    final model = AlarmModel.fromEntity(alarm);
    await localDataSource.upsert(model);
    if (model.isEnabled) {
      await nativeBridge.scheduleAlarm(model.toNativePayload());
    } else {
      await nativeBridge.cancelAlarm(model.id);
    }
  }

  @override
  Future<void> deleteAlarm(String id) async {
    await localDataSource.delete(id);
    await nativeBridge.cancelAlarm(id);
  }

  @override
  Future<void> setEnabled(String id, bool enabled) async {
    final existing = await getAlarmById(id);
    if (existing == null) return;
    final updated = AlarmModel.fromEntity(existing.copyWith(isEnabled: enabled));
    await localDataSource.upsert(updated);
    if (enabled) {
      await nativeBridge.scheduleAlarm(updated.toNativePayload());
    } else {
      await nativeBridge.cancelAlarm(id);
    }
  }

  @override
  Future<void> rescheduleAll() async {
    final all = await localDataSource.getAll();
    final enabled = all.where((a) => a.isEnabled).toList();
    await nativeBridge.rescheduleAll(
      enabled.map((a) => a.toNativePayload()).toList(),
    );
  }
}
