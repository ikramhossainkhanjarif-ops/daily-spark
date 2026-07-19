import 'package:equatable/equatable.dart';

enum MessageSource { builtIn, custom }

/// A single motivational / encouraging "spark" line shown on the
/// full-screen ringing page.
class MotivationalMessage extends Equatable {
  final String id;
  final String text;
  final MessageSource source;

  const MotivationalMessage({
    required this.id,
    required this.text,
    required this.source,
  });

  bool get isCustom => source == MessageSource.custom;

  @override
  List<Object?> get props => [id, text, source];
}
