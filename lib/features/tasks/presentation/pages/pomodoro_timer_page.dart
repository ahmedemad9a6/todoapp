import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/core/services/notification_service.dart';
import 'package:todoapp/features/tasks/domain/task_entity.dart';
import 'package:todoapp/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:todoapp/features/tasks/presentation/cubit/task_state.dart';
import 'package:todoapp/features/tasks/presentation/widgets/celebration_overlay.dart';

class PomodoroTimerPage extends StatefulWidget {
  final TaskEntity task;

  const PomodoroTimerPage({super.key, required this.task});

  @override
  State<PomodoroTimerPage> createState() => _PomodoroTimerPageState();
}

class _PomodoroTimerPageState extends State<PomodoroTimerPage>
    with SingleTickerProviderStateMixin {
  static const int _workDuration = 25 * 60;
  static const int _breakDuration = 5 * 60;

  int _remainingSeconds = _workDuration;
  bool _isRunning = false;
  bool _isBreak = false;
  Timer? _timer;
  int _completedSessions = 0;

  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;
  final GlobalKey<CelebrationOverlayState> _celebrationKey =
      GlobalKey<CelebrationOverlayState>();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _glowAnimation = Tween<double>(begin: 0.12, end: 0.36).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    HapticFeedback.mediumImpact();
    if (_isRunning) {
      _timer?.cancel();
      _pulseController.stop();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _pulseController.repeat(reverse: true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
        } else {
          _onTimerComplete();
        }
      });
    }
  }

  void _onTimerComplete() {
    _timer?.cancel();
    _pulseController.stop();
    HapticFeedback.heavyImpact();

    if (!_isBreak) {
      _completedSessions++;

      final state = context.read<TaskCubit>().state;
      TaskEntity targetTask = widget.task;
      if (state is TaskLoadedSuccessfully) {
        targetTask = state.allTasks.firstWhere(
          (t) => t.id == widget.task.id,
          orElse: () => widget.task,
        );
      }
      context.read<TaskCubit>().addFocusMinutes(targetTask, 25);

      final size = MediaQuery.of(context).size;
      _celebrationKey.currentState?.play(
        origin: Offset(size.width * 0.5, size.height * 0.4),
      );

      NotificationService().showInstantNotification(
        id: 999,
        title: 'Focus Session Complete',
        body:
            'You completed 25 minutes of focus on: "${widget.task.title}". Time for a 5-minute break.',
      );

      setState(() {
        _isBreak = true;
        _remainingSeconds = _breakDuration;
        _isRunning = false;
      });
    } else {
      NotificationService().showInstantNotification(
        id: 998,
        title: 'Break Ended',
        body: 'Ready for your next focus session?',
      );

      setState(() {
        _isBreak = false;
        _remainingSeconds = _workDuration;
        _isRunning = false;
      });
    }
  }

  void _resetTimer() {
    HapticFeedback.lightImpact();
    _timer?.cancel();
    _pulseController.stop();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _isBreak ? _breakDuration : _workDuration;
    });
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalSeconds = _isBreak ? _breakDuration : _workDuration;
    final progress = 1.0 - (_remainingSeconds / totalSeconds);

    return CelebrationOverlay(
      key: _celebrationKey,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Focus Timer'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          widget.task.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    _isBreak
                        ? 'Short Break (5 min)'
                        : 'Deep Focus Session (25 min)',
                    key: ValueKey(_isBreak),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _isBreak ? const Color(0xFF10B981) : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    final glowOpacity = _isRunning ? _glowAnimation.value : 0.06;
                    final currentColor =
                        _isBreak ? const Color(0xFF10B981) : theme.colorScheme.primary;

                    return Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: currentColor.withOpacity(glowOpacity),
                            blurRadius: _isRunning ? 36 : 16,
                            spreadRadius: _isRunning ? 4 : 1,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 230,
                        height: 230,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 10,
                          strokeCap: StrokeCap.round,
                          backgroundColor: theme.colorScheme.surfaceVariant
                              .withOpacity(0.4),
                          valueColor: AlwaysStoppedAnimation(
                            _isBreak ? const Color(0xFF10B981) : theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(_remainingSeconds),
                            style: TextStyle(
                              fontSize: 46,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                              color: _isBreak
                                  ? const Color(0xFF10B981)
                                  : theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isRunning ? 'In Progress' : 'Paused',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _resetTimer,
                        icon: const Icon(Icons.refresh_rounded),
                        iconSize: 24,
                        tooltip: 'Reset',
                      ),
                    ),
                    const SizedBox(width: 20),
                    InkWell(
                      onTap: _toggleTimer,
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: _isBreak
                              ? const Color(0xFF10B981)
                              : theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: (_isBreak
                                      ? const Color(0xFF10B981)
                                      : theme.colorScheme.primary)
                                  .withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isRunning
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isRunning ? 'Pause' : 'Start Focus',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: theme.colorScheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$_completedSessions sessions completed (${widget.task.focusMinutes + (_completedSessions * 25)}m focus)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
