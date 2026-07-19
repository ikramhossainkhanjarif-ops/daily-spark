import '../entities/alarm_sound.dart';

abstract class SoundRepository {
  List<AlarmSound> getBundledSounds();

  AlarmSound getSoundById(String id);

  /// Plays a short preview of the given sound for the picker UI.
  Future<void> previewSound(String id);

  Future<void> stopPreview();
}
