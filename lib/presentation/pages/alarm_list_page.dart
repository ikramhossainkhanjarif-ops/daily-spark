import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/alarm_list/alarm_list_bloc.dart';
import '../bloc/alarm_list/alarm_list_event.dart';
import '../bloc/alarm_list/alarm_list_state.dart';
import '../theme/app_colors.dart';
import '../widgets/alarm_tile.dart';
import '../widgets/gradient_background.dart';
import 'alarm_edit_page.dart';
import 'messages_manager_page.dart';

class AlarmListPage extends StatelessWidget {
  const AlarmListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Daily Spark'),
          actions: [
            IconButton(
              icon: const Icon(Icons.auto_awesome_outlined),
              tooltip: 'Motivational messages',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MessagesManagerPage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocBuilder<AlarmListBloc, AlarmListState>(
          builder: (context, state) {
            if (state.status == AlarmListStatus.loading ||
                state.status == AlarmListStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.alarms.isEmpty) {
              return _EmptyState(onAdd: () => _openEditor(context));
            }
            final alarms = state.sortedAlarms;
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: alarms.length,
              itemBuilder: (context, index) {
                final alarm = alarms[index];
                return AlarmTile(
                  alarm: alarm,
                  onToggle: (value) => context
                      .read<AlarmListBloc>()
                      .add(ToggleAlarmRequested(alarm.id, value)),
                  onTap: () => _openEditor(context, alarm: alarm),
                  onDelete: () => context
                      .read<AlarmListBloc>()
                      .add(DeleteAlarmRequested(alarm.id)),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openEditor(context),
          icon: const Icon(Icons.add),
          label: const Text('New alarm'),
        ),
      ),
    );
  }

  void _openEditor(BuildContext context, {dynamic alarm}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AlarmEditPage(existingAlarm: alarm),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.mint,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.alarm_add_outlined,
                  size: 44, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 24),
            const Text(
              'No alarms yet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Set your first Daily Spark alarm and\nwake up to a little encouragement.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Create an alarm'),
            ),
          ],
        ),
      ),
    );
  }
}
