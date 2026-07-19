import 'package:flutter/material.dart';
import '../../data/constants/built_in_sounds.dart';
import '../../data/repositories/sound_repository_impl.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_background.dart';

class SoundPickerPage extends StatefulWidget {
  final String selectedSoundId;
  const SoundPickerPage({super.key, required this.selectedSoundId});

  @override
  State<SoundPickerPage> createState() => _SoundPickerPageState();
}

class _SoundPickerPageState extends State<SoundPickerPage> {
  final _soundRepository = SoundRepositoryImpl();
  late String _selected;
  String? _previewing;

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedSoundId;
  }

  @override
  void dispose() {
    _soundRepository.stopPreview();
    super.dispose();
  }

  Future<void> _togglePreview(String id) async {
    if (_previewing == id) {
      await _soundRepository.stopPreview();
      setState(() => _previewing = null);
    } else {
      await _soundRepository.previewSound(id);
      setState(() => _previewing = id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Wake-up sound')),
        body: ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: kBuiltInSounds.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final sound = kBuiltInSounds[index];
            final id = sound['id']!;
            final isSelected = _selected == id;
            final isPreviewing = _previewing == id;
            return Card(
              color: isSelected
                  ? AppColors.mint.withValues(alpha: 0.5)
                  : AppColors.surface,
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                onTap: () {
                  setState(() => _selected = id);
                  Navigator.of(context).pop(id);
                },
                leading: IconButton(
                  icon: Icon(
                    isPreviewing
                        ? Icons.stop_circle_outlined
                        : Icons.play_circle_outline,
                    color: AppColors.mintDark,
                    size: 30,
                  ),
                  onPressed: () => _togglePreview(id),
                ),
                title: Text(
                  sound['name']!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle,
                        color: AppColors.mintDark)
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}
