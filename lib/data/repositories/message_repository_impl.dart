import '../../domain/entities/motivational_message.dart';
import '../../domain/repositories/message_repository.dart';
import '../datasources/message_local_datasource.dart';

class MessageRepositoryImpl implements MessageRepository {
  final MessageLocalDataSource localDataSource;

  MessageRepositoryImpl({required this.localDataSource});

  @override
  Future<List<MotivationalMessage>> getAllMessages() =>
      localDataSource.getAll();

  @override
  Future<MotivationalMessage?> getMessageById(String id) =>
      localDataSource.getById(id);

  @override
  Future<MotivationalMessage> getNextMessage() => localDataSource.getNext();

  @override
  Future<MotivationalMessage> addCustomMessage(String text) =>
      localDataSource.addCustom(text);

  @override
  Future<void> deleteMessage(String id) => localDataSource.deleteMessage(id);

  @override
  Future<void> resetHiddenBuiltIns() => localDataSource.resetHiddenBuiltIns();
}
