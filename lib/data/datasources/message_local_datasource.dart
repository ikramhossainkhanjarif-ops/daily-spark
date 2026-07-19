import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/built_in_messages.dart';
import '../models/motivational_message_model.dart';

/// Handles the motivational message pool: the 200 built-ins, any
/// user-added customs, a hidden-built-in-ids set (soft delete), and
/// the shuffled no-repeat rotation queue.
class MessageLocalDataSource {
  static const String _customKey = 'daily_spark_custom_messages_v1';
  static const String _hiddenKey = 'daily_spark_hidden_builtins_v1';
  static const String _queueKey = 'daily_spark_message_queue_v1';

  Future<List<MotivationalMessageModel>> _getCustom() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_customKey);
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) =>
            MotivationalMessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveCustom(List<MotivationalMessageModel> customs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _customKey,
      jsonEncode(customs.map((c) => c.toJson()).toList()),
    );
  }

  Future<Set<String>> _getHiddenBuiltInIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_hiddenKey) ?? []).toSet();
  }

  Future<void> _saveHiddenBuiltInIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_hiddenKey, ids.toList());
  }

  Future<List<MotivationalMessageModel>> getAll() async {
    final hidden = await _getHiddenBuiltInIds();
    final builtIns = kBuiltInMessages
        .where((m) => !hidden.contains(m['id']))
        .map((m) => MotivationalMessageModel.builtIn(m['id']!, m['text']!));
    final customs = await _getCustom();
    return [...builtIns, ...customs];
  }

  Future<MotivationalMessageModel?> getById(String id) async {
    final all = await getAll();
    for (final m in all) {
      if (m.id == id) return m;
    }
    return null;
  }

  Future<MotivationalMessageModel> addCustom(String text) async {
    final customs = await _getCustom();
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final message = MotivationalMessageModel.custom(id, text.trim());
    customs.add(message);
    await _saveCustom(customs);
    return message;
  }

  Future<void> deleteMessage(String id) async {
    if (id.startsWith('custom_')) {
      final customs = await _getCustom();
      customs.removeWhere((c) => c.id == id);
      await _saveCustom(customs);
    } else {
      final hidden = await _getHiddenBuiltInIds();
      hidden.add(id);
      await _saveHiddenBuiltInIds(hidden);
    }
    // Keep the rotation queue consistent with the active pool.
    await _pruneQueue(id);
  }

  Future<void> resetHiddenBuiltIns() async {
    await _saveHiddenBuiltInIds({});
  }

  Future<void> _pruneQueue(String removedId) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = prefs.getStringList(_queueKey);
    if (queue == null) return;
    queue.remove(removedId);
    await prefs.setStringList(_queueKey, queue);
  }

  /// Strict no-repeat selection: consumes ids from a persisted,
  /// shuffled queue. When the queue is empty, reshuffles the full
  /// active pool (built-ins minus hidden, plus customs) before
  /// popping the next id.
  Future<MotivationalMessageModel> getNext() async {
    final prefs = await SharedPreferences.getInstance();
    var queue = prefs.getStringList(_queueKey) ?? [];
    final all = await getAll();
    final validIds = all.map((m) => m.id).toSet();

    // Drop any stale ids (deleted messages) that might linger.
    queue = queue.where(validIds.contains).toList();

    if (queue.isEmpty) {
      queue = all.map((m) => m.id).toList()..shuffle(Random());
    }

    final nextId = queue.removeAt(0);
    await prefs.setStringList(_queueKey, queue);

    return all.firstWhere(
      (m) => m.id == nextId,
      orElse: () => all.isNotEmpty
          ? all.first
          : MotivationalMessageModel.builtIn(
              'fallback', 'Good morning! Today is yours to shine in.'),
    );
  }
}
