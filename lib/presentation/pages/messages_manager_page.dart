import 'package:flutter/material.dart';
import '../../domain/entities/motivational_message.dart';
import '../../domain/usecases/message_usecases.dart';
import '../../data/datasources/message_local_datasource.dart';
import '../../data/repositories/message_repository_impl.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_background.dart';

class MessagesManagerPage extends StatefulWidget {
  const MessagesManagerPage({super.key});

  @override
  State<MessagesManagerPage> createState() => _MessagesManagerPageState();
}

class _MessagesManagerPageState extends State<MessagesManagerPage> {
  late final MessageRepositoryImpl _repository;
  late final GetAllMessages _getAll;
  late final AddCustomMessage _addCustom;
  late final DeleteMessage _delete;

  List<MotivationalMessage> _messages = [];
  bool _loading = true;
  final _newMessageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _repository = MessageRepositoryImpl(
      localDataSource: MessageLocalDataSource(),
    );
    _getAll = GetAllMessages(_repository);
    _addCustom = AddCustomMessage(_repository);
    _delete = DeleteMessage(_repository);
    _load();
  }

  @override
  void dispose() {
    _newMessageController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final messages = await _getAll();
    setState(() {
      _messages = messages;
      _loading = false;
    });
  }

  Future<void> _addMessage() async {
    final text = _newMessageController.text.trim();
    if (text.isEmpty) return;
    await _addCustom(text);
    _newMessageController.clear();
    await _load();
  }

  Future<void> _deleteMessage(String id) async {
    await _delete(id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Your spark pool')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newMessageController,
                      decoration: const InputDecoration(
                        hintText: 'Write your own morning affirmation…',
                      ),
                      onSubmitted: (_) => _addMessage(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    onPressed: _addMessage,
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.mintDark,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: _messages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            title: Text(message.text),
                            leading: Icon(
                              message.isCustom
                                  ? Icons.edit_note_outlined
                                  : Icons.auto_awesome_outlined,
                              color: AppColors.mintDark,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.close,
                                  color: AppColors.textSecondary),
                              onPressed: () => _deleteMessage(message.id),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
