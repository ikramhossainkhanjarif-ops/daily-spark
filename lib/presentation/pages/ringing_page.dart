import 'package:flutter/material.dart';
import '../../data/datasources/message_local_datasource.dart';
import '../../data/datasources/native_alarm_bridge.dart';
import '../../data/repositories/message_repository_impl.dart';
import '../../domain/entities/motivational_message.dart';
import '../../domain/usecases/message_usecases.dart';
import '../theme/app_colors.dart';
import '../widgets/floating_stars_animation.dart';

/// Full-screen view shown over the lock screen when an alarm fires.
/// Displays a random no-repeat motivational message, a soft pastel
/// gradient with ambient particles, and large Snooze/Dismiss actions.
class RingingPage extends StatefulWidget {
  final String alarmId;
  final int snoozeMinutes;

  const RingingPage({
    super.key,
    required this.alarmId,
    this.snoozeMinutes = 9,
  });

  @override
  State<RingingPage> createState() => _RingingPageState();
}

class _RingingPageState extends State<RingingPage>
    with SingleTickerProviderStateMixin {
  final _nativeBridge = NativeAlarmBridge();
  late final GetNextMessage _getNextMessage;

  MotivationalMessage? _message;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    final repository = MessageRepositoryImpl(
      localDataSource: MessageLocalDataSource(),
    );
    _getNextMessage = GetNextMessage(repository);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _loadMessage();
  }

  Future<void> _loadMessage() async {
    final message = await _getNextMessage();
    if (mounted) setState(() => _message = message);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _onSnooze() async {
    await _nativeBridge.snoozeAlarm(widget.alarmId, widget.snoozeMinutes);
    if (mounted) Navigator.of(context).maybePop();
  }

  Future<void> _onDismiss() async {
    await _nativeBridge.dismissAlarm(widget.alarmId);
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // require explicit Snooze/Dismiss
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.ringingGradient,
            ),
          ),
          child: Stack(
            children: [
              const Positioned.fill(
                child: FloatingStarsAnimation(),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 24),
                  child: Column(
                    children: [
                      const Spacer(),
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final scale =
                              1.0 + (_pulseController.value * 0.06);
                          return Transform.scale(scale: scale, child: child);
                        },
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.wb_sunny_rounded,
                            size: 44,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      Text(
                        _currentTimeLabel(),
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 28),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Text(
                          _message?.text ?? 'Good morning! Let\'s make today count.',
                          key: ValueKey(_message?.id),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const Spacer(flex: 2),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _onSnooze,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Colors.white, width: 1.5),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20),
                              ),
                              child: Text('Snooze ${widget.snoozeMinutes}m'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _onDismiss,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.mintDark,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 20),
                              ),
                              child: const Text('Dismiss'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _currentTimeLabel() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
