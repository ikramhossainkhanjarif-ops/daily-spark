import 'package:audioplayers/audioplayers.dart';
import '../../domain/entities/alarm_sound.dart';
import '../../domain/repositories/sound_repository.dart';
import '../constants/built_in_sounds.dart';

class SoundRepositoryImpl implements SoundRepository {
  final AudioPlayer _previewPlayer = AudioPlayer();

  @override
  List<AlarmSound> getBundledSounds() => kBuiltInSounds
      .map((s) => AlarmSound(
            id: s['id']!,
            displayName: s['name']!,
            assetPath: s['asset']!,
          ))
      .toList();

  @override
  AlarmSound getSoundById(String id) {
    final match = kBuiltInSounds.firstWhere(
      (s) => s['id'] == id,
      orElse: () => kBuiltInSounds.first,
    );
    return AlarmSound(
      id: match['id']!,
      displayName: match['name']!,
      assetPath: match['asset']!,
    );
  }

  @override
  Future<void> previewSound(String id) async {
    final sound = getSoundById(id);
    await _previewPlayer.stop();
    final path = sound.assetPath.replaceFirst('assets/', '');
    await _previewPlayer.play(AssetSource(path));
  }

  @override
  Future<void> stopPreview() async {
    await _previewPlayer.stop();
  }
}
