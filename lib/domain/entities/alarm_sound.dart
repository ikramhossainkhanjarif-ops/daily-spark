import 'package:equatable/equatable.dart';

/// One entry in the bundled sound catalog.
class AlarmSound extends Equatable {
  final String id;
  final String displayName;

  /// Path relative to the Flutter asset bundle, e.g. `assets/sounds/chime.mp3`.
  final String assetPath;

  const AlarmSound({
    required this.id,
    required this.displayName,
    required this.assetPath,
  });

  @override
  List<Object?> get props => [id, displayName, assetPath];
}
