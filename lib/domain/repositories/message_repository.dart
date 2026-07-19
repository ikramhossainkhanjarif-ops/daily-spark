import '../entities/motivational_message.dart';

/// Abstract contract for the motivational message pool: built-ins,
/// user customs, and the no-repeat rotation state.
abstract class MessageRepository {
  /// All active messages (built-in minus deleted, plus custom).
  Future<List<MotivationalMessage>> getAllMessages();

  Future<MotivationalMessage?> getMessageById(String id);

  /// Picks the next message using a strict no-repeat algorithm: a
  /// shuffled queue is persisted in SharedPreferences and consumed
  /// one at a time. When exhausted, it reshuffles the full pool.
  Future<MotivationalMessage> getNextMessage();

  Future<MotivationalMessage> addCustomMessage(String text);

  /// Removes a message from the active pool. For built-ins this adds
  /// the id to a "hidden" set rather than mutating the built-in list.
  Future<void> deleteMessage(String id);

  Future<void> resetHiddenBuiltIns();
}
