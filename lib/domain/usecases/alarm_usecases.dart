import '../entities/alarm.dart';
import '../repositories/alarm_repository.dart';

/// Grouped alarm use cases. Kept together since each is a thin,
/// single-purpose wrapper around [AlarmRepository] — this avoids a
/// proliferation of near-identical one-method classes while still
/// keeping the domain layer the single source of business rules.
class GetAlarms {
  final AlarmRepository repository;
  GetAlarms(this.repository);
  Future<List<Alarm>> call() => repository.getAlarms();
}

class SaveAlarm {
  final AlarmRepository repository;
  SaveAlarm(this.repository);
  Future<void> call(Alarm alarm) => repository.saveAlarm(alarm);
}

class DeleteAlarm {
  final AlarmRepository repository;
  DeleteAlarm(this.repository);
  Future<void> call(String id) => repository.deleteAlarm(id);
}

class ToggleAlarm {
  final AlarmRepository repository;
  ToggleAlarm(this.repository);
  Future<void> call(String id, bool enabled) =>
      repository.setEnabled(id, enabled);
}

class RescheduleAllAlarms {
  final AlarmRepository repository;
  RescheduleAllAlarms(this.repository);
  Future<void> call() => repository.rescheduleAll();
}
