import '../../domain/entities/motivational_message.dart';

class MotivationalMessageModel extends MotivationalMessage {
  const MotivationalMessageModel({
    required super.id,
    required super.text,
    required super.source,
  });

  factory MotivationalMessageModel.builtIn(String id, String text) =>
      MotivationalMessageModel(
        id: id,
        text: text,
        source: MessageSource.builtIn,
      );

  factory MotivationalMessageModel.custom(String id, String text) =>
      MotivationalMessageModel(
        id: id,
        text: text,
        source: MessageSource.custom,
      );

  factory MotivationalMessageModel.fromJson(Map<String, dynamic> json) =>
      MotivationalMessageModel(
        id: json['id'] as String,
        text: json['text'] as String,
        source: (json['source'] as String) == 'custom'
            ? MessageSource.custom
            : MessageSource.builtIn,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'source': source == MessageSource.custom ? 'custom' : 'builtIn',
      };
}
