import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/core/services/notification_service.dart';
import 'package:todoapp/features/tasks/domain/task_entity.dart';
import 'package:todoapp/features/tasks/presentation/cubit/task_cubit.dart';

class PomodoroTimerPage extends StatefulWidget {
  final TaskEntity task;

  const PomodoroTimerPage({super.key, required this.task});

  @override
  State<PomodoroTimerPage> createState() => _PomodoroTimerPageState();
}

class _PomodoroTimerPageState extends State<PomodoroTimerPage> {
  static const int _workDuration = 25 * 60; // 25 دقيقة عمل
  static const int _breakDuration = 5 * 60; // 5 دقائق راحة

  int _remainingSeconds = _workDuration;
  bool _isRunning = false;
  bool _isBreak = false;
  Timer? _timer;
  int _completedSessions = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    HapticFeedback.mediumImpact(); // اهتزاز لمسي تفاعلي
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
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
    HapticFeedback.heavyImpact();

    if (!_isBreak) {
      // اكتمال جلسة عمل (25 دقيقة)
      _completedSessions++;
      context.read<TaskCubit>().addFocusMinutes(widget.task, 25);

      // إرسال إشعار للمستخدم
      NotificationService().showInstantNotification(
        id: 999,
        title: 'أحسنت العمل! 🎉🍅',
        body:
            'أكملت 25 دقيقة من التركيز على: "${widget.task.title}". حان وقت استراحة 5 دقائق!',
      );

      setState(() {
        _isBreak = true;
        _remainingSeconds = _breakDuration;
        _isRunning = false;
      });
    } else {
      // اكتمال فترة الاستراحة
      NotificationService().showInstantNotification(
        id: 998,
        title: 'انتهت الاستراحة ☕',
        body: 'هل أنت جاهز لجلسة تركيز جديدة؟',
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('مؤقت بومودورو للتركيز 🍅'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // اسم المهمة التي نركز عليها
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.safety_check,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.task.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
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

              // نوع الجلسة (عمل أو استراحة)
              Text(
                _isBreak
                    ? '☕ استراحة قصيرة (5 دقائق)'
                    : '🧠 جلسة تركيز عميق (25 دقيقة)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _isBreak ? Colors.green : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 36),

              
              Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_isBreak ? Colors.green : theme.colorScheme.primary)
                          .withOpacity(_isRunning ? 0.22 : 0.06),
                      blurRadius: 36,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 240,
                      height: 240,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 12,
                        strokeCap: StrokeCap.round,
                        backgroundColor: theme.colorScheme.surfaceVariant
                            .withOpacity(0.4),
                        valueColor: AlwaysStoppedAnimation(
                          _isBreak ? Colors.green : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(_remainingSeconds),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                            color: _isBreak
                                ? Colors.green
                                : theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isRunning ? 'جاري العد... ⏱️' : 'متوقف مؤقتاً',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // أزرار التحكم (تشغيل / إيقاف / إعادة ضبط)
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
                      iconSize: 26,
                      tooltip: 'إعادة ضبط',
                    ),
                  ),
                  const SizedBox(width: 20),
                  InkWell(
                    onTap: _toggleTimer,
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isBreak
                              ? [Colors.green, Colors.teal]
                              : [
                                  theme.colorScheme.primary,
                                  const Color(0xFF4F46E5),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: (_isBreak
                                    ? Colors.green
                                    : theme.colorScheme.primary)
                                .withOpacity(0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
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
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isRunning ? 'إيقاف مؤقت' : 'بدء التركيز',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'أكملت $_completedSessions جلسات اليوم (${widget.task.focusMinutes + (_completedSessions * 25)} دقيقة تركيز إجمالاً)',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
