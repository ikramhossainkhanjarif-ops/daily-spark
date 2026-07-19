import '../entities/motivational_message.dart';
import '../repositories/message_repository.dart';

class GetAllMessages {
  final MessageRepository repository;
  GetAllMessages(this.repository);
  Future<List<MotivationalMessage>> call() => repository.getAllMessages();
}

class GetNextMessage {
  final MessageRepository repository;
  GetNextMessage(this.repository);
  Future<MotivationalMessage> call() => repository.getNextMessage();
}

class AddCustomMessage {
  final MessageRepository repository;
  AddCustomMessage(this.repository);
  Future<MotivationalMessage> call(String text) =>
      repository.addCustomMessage(text);
}

class DeleteMessage {
  final MessageRepository repository;
  DeleteMessage(this.repository);
  Future<void> call(String id) => repository.deleteMessage(id);
}

class ResetHiddenBuiltIns {
  final MessageRepository repository;
  ResetHiddenBuiltIns(this.repository);
  Future<void> call() => repository.resetHiddenBuiltIns();
}
