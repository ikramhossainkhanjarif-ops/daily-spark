import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm_model.dart';

/// SharedPreferences-backed storage for alarms. Also responsible for
/// writing the plain-JSON mirror at [kNativeAlarmsKey] which
/// `NativeAlarmStore.kt` reads directly (via the same preferences
/// file) so BootReceiver can re-arm alarms without needing Flutter
/// to be running.
class AlarmLocalDataSource {
  static const String _alarmsKey = 'daily_spark_alarms_v1';

  Future<List<AlarmModel>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_alarmsKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => AlarmModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAll(List<AlarmModel> alarms) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(alarms.map((a) => a.toJson()).toList());
    await prefs.setString(_alarmsKey, raw);
  }

  Future<void> upsert(AlarmModel alarm) async {
    final all = await getAll();
    final idx = all.indexWhere((a) => a.id == alarm.id);
    if (idx >= 0) {
      all[idx] = alarm;
    } else {
      all.add(alarm);
    }
    await saveAll(all);
  }

  Future<void> delete(String id) async {
    final all = await getAll();
    all.removeWhere((a) => a.id == id);
    await saveAll(all);
  }
}
