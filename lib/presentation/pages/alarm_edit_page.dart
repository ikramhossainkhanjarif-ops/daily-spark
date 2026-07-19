import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/alarm.dart';
import '../bloc/alarm_list/alarm_list_bloc.dart';
import '../bloc/alarm_list/alarm_list_event.dart';
import '../theme/app_colors.dart';
import '../widgets/gradient_background.dart';
import 'sound_picker_page.dart';

class AlarmEditPage extends StatefulWidget {
  final Alarm? existingAlarm;
  const AlarmEditPage({super.key, this.existingAlarm});

  @override
  State<AlarmEditPage> createState() => _AlarmEditPageState();
}

class _AlarmEditPageState extends State<AlarmEditPage> {
  late TimeOfDay _time;
  late TextEditingController _labelController;
  late Set<int> _repeatDays;
  late String _soundId;
  late bool _vibrate;
  late int _snoozeMinutes;

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  void initState() {
    super.initState();
    final existing = widget.existingAlarm;
    _time = TimeOfDay(
      hour: existing?.hour ?? TimeOfDay.now().hour,
      minute: existing?.minute ?? 0,
    );
    _labelController = TextEditingController(text: existing?.label ?? '');
    _repeatDays = (existing?.repeatDays ?? const []).toSet();
    _soundId = existing?.soundId ?? 'morning_chimes';
    _vibrate = existing?.vibrate ?? true;
    _snoozeMinutes = existing?.snoozeMinutes ?? 9;
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.surface,
              dialBackgroundColor: AppColors.mint.withValues(alpha: 0.4),
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _save() {
    final alarm = Alarm(
      id: widget.existingAlarm?.id ?? const Uuid().v4(),
      hour: _time.hour,
      minute: _time.minute,
      label: _labelController.text.trim(),
      isEnabled: widget.existingAlarm?.isEnabled ?? true,
      repeatDays: _repeatDays.toList()..sort(),
      soundId: _soundId,
      vibrate: _vibrate,
      snoozeMinutes: _snoozeMinutes,
    );
    context.read<AlarmListBloc>().add(UpsertAlarmRequested(alarm));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingAlarm != null;
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(isEditing ? 'Edit alarm' : 'New alarm'),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickTime,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 28, horizontal: 32),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.mintDark.withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Text(
                    _time.format(context),
                    style: const TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(
                hintText: 'Label (optional)',
                prefixIcon: Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Repeat',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final day = i + 1;
                final selected = _repeatDays.contains(day);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (selected) {
                      _repeatDays.remove(day);
                    } else {
                      _repeatDays.add(day);
                    }
                  }),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        selected ? AppColors.mintDark : AppColors.surface,
                    child: Text(
                      _dayLabels[i],
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 28),
            Card(
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: const Icon(Icons.music_note_outlined),
                title: const Text('Wake-up sound'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final selected = await Navigator.of(context).push<String>(
                    MaterialPageRoute(
                      builder: (_) => SoundPickerPage(selectedSoundId: _soundId),
                    ),
                  );
                  if (selected != null) setState(() => _soundId = selected);
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: SwitchListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                title: const Text('Vibrate'),
                value: _vibrate,
                onChanged: (v) => setState(() => _vibrate = v),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: const Icon(Icons.snooze_outlined),
                title: const Text('Snooze duration'),
                trailing: DropdownButton<int>(
                  value: _snoozeMinutes,
                  underline: const SizedBox(),
                  items: const [5, 9, 10, 15]
                      .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text('$m min'),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _snoozeMinutes = v);
                  },
                ),
              ),
            ),
            const SizedBox(height: 36),
            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              child: Text(isEditing ? 'Save changes' : 'Create alarm'),
            ),
          ],
        ),
      ),
    );
  }
}
