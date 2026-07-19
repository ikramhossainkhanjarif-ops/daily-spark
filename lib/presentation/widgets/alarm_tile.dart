import 'package:flutter/material.dart';
import '../../domain/entities/alarm.dart';
import '../theme/app_colors.dart';

class AlarmTile extends StatelessWidget {
  final Alarm alarm;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const AlarmTile({
    super.key,
    required this.alarm,
    required this.onToggle,
    required this.onTap,
    required this.onDelete,
  });

  String get _timeLabel {
    final h = alarm.hour % 12 == 0 ? 12 : alarm.hour % 12;
    final m = alarm.minute.toString().padLeft(2, '0');
    final period = alarm.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }

  String get _repeatLabel {
    if (alarm.repeatDays.isEmpty) return 'One time';
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sorted = [...alarm.repeatDays]..sort();
    return sorted.map((d) => names[d - 1]).join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(alarm.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 28),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.redAccent),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _timeLabel,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alarm.label.isNotEmpty ? alarm.label : _repeatLabel,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(value: alarm.isEnabled, onChanged: onToggle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
