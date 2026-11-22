import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/core/theme/theme_cubit.dart';
import 'package:todoapp/features/tasks/domain/task_entity.dart';
import 'package:todoapp/features/tasks/domain/task_enums.dart';
import 'package:todoapp/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:todoapp/features/tasks/presentation/cubit/task_state.dart';
import 'package:todoapp/features/tasks/presentation/pages/pomodoro_timer_page.dart';
import 'package:todoapp/features/tasks/presentation/pages/statistics_page.dart';
import 'package:todoapp/features/tasks/presentation/widgets/celebration_overlay.dart';
import 'package:todoapp/features/tasks/presentation/widgets/empty_tasks_view.dart';
import 'package:todoapp/features/tasks/presentation/widgets/modern_task_item.dart';
import 'package:todoapp/features/tasks/presentation/widgets/task_bottom_sheet.dart';
import 'package:todoapp/features/tasks/presentation/widgets/task_filter_bar.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final GlobalKey<CelebrationOverlayState> _celebrationKey =
      GlobalKey<CelebrationOverlayState>();
  bool _showFilters = true;

  void _openBottomSheet(BuildContext context, {TaskEntity? taskToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => TaskBottomSheet(
        taskToEdit: taskToEdit,
        onSave:
            (
              title,
              desc,
              dueDate,
              priority,
              category,
              subTasks,
              isPinned,
              recurrence,
            ) {
              if (taskToEdit == null) {
                context.read<TaskCubit>().addTask(
                  title: title,
                  description: desc,
                  dueDate: dueDate,
                  priority: priority,
                  category: category,
                  subTasks: subTasks,
                  isPinned: isPinned,
                  recurrence: recurrence,
                );
              } else {
                context.read<TaskCubit>().editTask(
                  task: taskToEdit,
                  newTitle: title,
                  newDescription: desc,
                  newDueDate: dueDate,
                  newPriority: priority,
                  newCategory: category,
                  newSubTasks: subTasks,
                  newIsPinned: isPinned,
                  newRecurrence: recurrence,
                );
              }
            },
      ),
    );
  }

  void _handleToggleTask(BuildContext context, TaskEntity task) {
    final wasCompleted = task.isCompleted;
    context.read<TaskCubit>().toggleTaskStatus(task);

    if (!wasCompleted) {
      HapticFeedback.heavyImpact();
      final size = MediaQuery.of(context).size;
      _celebrationKey.currentState?.play(
        origin: Offset(size.width * 0.5, size.height * 0.35),
      );
    }
  }

  void _handleDelete(BuildContext context, TaskEntity task) {
    final cubit = context.read<TaskCubit>();
    cubit.deleteTask(task);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${task.title}"'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: Theme.of(context).colorScheme.inversePrimary,
          onPressed: () {
            cubit.undoDelete();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();
    final isDark = themeCubit.isDark(context);
    final theme = Theme.of(context);
    final now = DateTime.now();

    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final dateString =
        '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';

    return CelebrationOverlay(
      key: _celebrationKey,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 20,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dateString,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.primary,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'My Tasks',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          actions: [
            BlocBuilder<TaskCubit, TaskState>(
              builder: (context, state) {
                bool hasActiveFilter = false;
                if (state is TaskLoadedSuccessfully) {
                  hasActiveFilter =
                      state.statusFilter != TaskFilterStatus.all ||
                      state.categoryFilter != null ||
                      state.searchQuery.isNotEmpty;
                }

                return Container(
                  width: 38,
                  height: 38,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: _showFilters || hasActiveFilter
                        ? theme.colorScheme.primary.withOpacity(0.12)
                        : (isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: _showFilters || hasActiveFilter
                          ? theme.colorScheme.primary.withOpacity(0.4)
                          : (isDark
                                ? const Color(0x1FFFFFFF)
                                : const Color(0x0F000000)),
                    ),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    tooltip: _showFilters ? 'Hide Filters' : 'Filter & Search',
                    icon: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Icon(
                          _showFilters
                              ? Icons.close_rounded
                              : Icons.tune_rounded,
                          color: _showFilters || hasActiveFilter
                              ? theme.colorScheme.primary
                              : (isDark
                                    ? Colors.white70
                                    : const Color(0xFF475569)),
                          size: 18,
                        ),
                        if (hasActiveFilter && !_showFilters)
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      setState(() => _showFilters = !_showFilters);
                    },
                  ),
                );
              },
            ),

            Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: isDark
                      ? const Color(0x1FFFFFFF)
                      : const Color(0x0F000000),
                ),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                tooltip: 'Productivity & Analytics',
                icon: Icon(
                  Icons.insights_rounded,
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const StatisticsPage()),
                  );
                },
              ),
            ),

            Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: isDark
                      ? const Color(0x1FFFFFFF)
                      : const Color(0x0F000000),
                ),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                tooltip: isDark ? 'Light Mode' : 'Dark Mode',
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: isDark ? Colors.amber : const Color(0xFF475569),
                  size: 18,
                ),
                onPressed: () {
                  context.read<ThemeCubit>().toggleTheme();
                },
              ),
            ),
            const SizedBox(width: 14),
          ],
        ),

        body: BlocConsumer<TaskCubit, TaskState>(
          listener: (context, state) {
            if (state is TaskError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is TaskInitial) {
              context.read<TaskCubit>().loadTasks();
              return const Center(child: CircularProgressIndicator());
            }

            if (state is TaskLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is TaskLoadedSuccessfully) {
              final tasks = state.filteredTasks;
              final all = state.allTasks;
              final completedCount = all.where((t) => t.isCompleted).length;
              final totalCount = all.length;
              final progressRatio = totalCount > 0
                  ? (completedCount / totalCount)
                  : 0.0;

              return Column(
                children: [
                  if (totalCount > 0)
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 4, 16, 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? const Color(0x1AFFFFFF)
                              : const Color(0x0F000000),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: TweenAnimationBuilder<double>(
                                tween: Tween<double>(
                                  begin: 0.0,
                                  end: progressRatio,
                                ),
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutCubic,
                                builder: (context, animatedRatio, child) {
                                  return LinearProgressIndicator(
                                    value: animatedRatio,
                                    minHeight: 5,
                                    backgroundColor: isDark
                                        ? const Color(
                                            0xFF334155,
                                          ).withOpacity(0.4)
                                        : const Color(0xFFE2E8F0),
                                    valueColor: AlwaysStoppedAnimation(
                                      completedCount == totalCount
                                          ? const Color(0xFF059669)
                                          : theme.colorScheme.primary,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (completedCount == totalCount)
                                const Padding(
                                  padding: EdgeInsets.only(right: 4),
                                  child: Icon(
                                    Icons.check_circle_rounded,
                                    size: 13,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                              Text(
                                completedCount == totalCount
                                    ? 'All Done (100%)'
                                    : '$completedCount/$totalCount (${(progressRatio * 100).toInt()}%)',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: completedCount == totalCount
                                      ? const Color(0xFF059669)
                                      : theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                  AnimatedSize(
                    duration: const Duration(milliseconds: 9000),
                    curve: Curves.easeInSine,
                    child: _showFilters
                        ? const TaskFilterBar()
                        : const SizedBox.shrink(),
                  ),

                  Expanded(
                    child: tasks.isEmpty
                        ? EmptyTasksView(
                            onAddTask: () => _openBottomSheet(context),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.only(top: 4, bottom: 88),
                            itemCount: tasks.length,
                            itemBuilder: (context, index) {
                              final task = tasks[index];
                              return ModernTaskItem(
                               key: ValueKey(task.id),
                                task: task,
                                onToggle: () =>
                                    _handleToggleTask(context, task),
                                onEdit: () =>
                                    _openBottomSheet(context, taskToEdit: task),
                                onDelete: () => _handleDelete(context, task),
                                onTogglePin: () => context
                                    .read<TaskCubit>()
                                    .togglePinTask(task),
                                onOpenPomodoro: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          PomodoroTimerPage(task: task),
                                    ),
                                  );
                                },
                                onToggleSubTask: (subTaskId) => context
                                    .read<TaskCubit>()
                                    .toggleSubTask(task, subTaskId),
                              );
                            },
                          ),
                  ),
                ],
              );
            }

            if (state is TaskError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Colors.red,
                        size: 44,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: () => context.read<TaskCubit>().loadTasks(),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),

        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openBottomSheet(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('New Task'),
        ),
      ),
    );
  }
}
