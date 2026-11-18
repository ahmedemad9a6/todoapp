import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/core/theme/theme_cubit.dart';
import 'package:todoapp/features/tasks/domain/task_entity.dart';
import 'package:todoapp/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:todoapp/features/tasks/presentation/cubit/task_state.dart';
import 'package:todoapp/features/tasks/presentation/pages/pomodoro_timer_page.dart';
import 'package:todoapp/features/tasks/presentation/pages/statistics_page.dart';
import 'package:todoapp/features/tasks/presentation/widgets/empty_tasks_view.dart';
import 'package:todoapp/features/tasks/presentation/widgets/modern_task_item.dart';
import 'package:todoapp/features/tasks/presentation/widgets/task_bottom_sheet.dart';
import 'package:todoapp/features/tasks/presentation/widgets/task_filter_bar.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  void _openBottomSheet(BuildContext context, {TaskEntity? taskToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // للسماح للورقة بالارتفاع فوق لوحة المفاتيح
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                // إضافة مهمة جديدة بالكامل مع التثبيت والتكرار
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
                // تعديل بيانات المهمة الموجودة بما فيها التثبيت والتكرار
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

  void _handleDelete(BuildContext context, TaskEntity task) {
    final cubit = context.read<TaskCubit>();
    cubit.deleteTask(task);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حذف "${task.title}"'),
        behavior: SnackBarBehavior.floating, // شريط عائم بحواف منحنية
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        action: SnackBarAction(
          label: 'تراجع',
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
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    final dateString =
        '${days[now.weekday - 1]}، ${now.day} ${months[now.month - 1]}';

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateString,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'مهامي اليومية ',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? const Color(0x1FFFFFFF)
                    : const Color(0x0F000000),
              ),
            ),
            child: IconButton(
              tooltip: 'الإحصائيات والنسخ الاحتياطي',
              icon: Icon(
                Icons.insights_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StatisticsPage()),
                );
              },
            ),
          ),

          // زر التبديل السريع بين الوضعين النهاري والليلي
          Container(
            margin: const EdgeInsets.only(left: 16, right: 4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? const Color(0x1FFFFFFF)
                    : const Color(0x0F000000),
              ),
            ),
            child: IconButton(
              tooltip: isDark ? 'الوضع النهاري' : 'الوضع الليلي',
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: isDark ? Colors.amber : const Color(0xFF475569),
                size: 20,
              ),
              onPressed: () {
                context.read<ThemeCubit>().toggleTheme();
              },
            ),
          ),
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
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  const Color(0xFF1E293B),
                                  const Color(0xFF151D2C),
                                ]
                              : [
                                  theme.colorScheme.primary.withOpacity(0.08),
                                  theme.colorScheme.secondary.withOpacity(0.04),
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.15),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                completedCount == totalCount
                                    ? 'اكتملت جميع مهامك اليوم بنجاح! 🏆'
                                    : 'أنجزت $completedCount من $totalCount مهام اليوم',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: completedCount == totalCount
                                      ? Colors.orange
                                      : (isDark
                                            ? Colors.white
                                            : const Color(0xFF1E293B)),
                                ),
                              ),
                              Text(
                                '${(progressRatio * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: progressRatio,
                              minHeight: 6,
                              backgroundColor: isDark
                                  ? Colors.white10
                                  : Colors.black.withOpacity(0.06),
                              valueColor: AlwaysStoppedAnimation(
                                completedCount == totalCount
                                    ? Colors.green
                                    : theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // شريط البحث وفلاتر التبويب بالأعلى
                const TaskFilterBar(),

                Expanded(
                  child: tasks.isEmpty
                      ? EmptyTasksView(
                          onAddTask: () => _openBottomSheet(context),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return ModernTaskItem(
                              task: task,
                              onToggle: () => context
                                  .read<TaskCubit>()
                                  .toggleTaskStatus(task),
                              onEdit: () =>
                                  _openBottomSheet(context, taskToEdit: task),
                              onDelete: () => _handleDelete(context, task),
                              onTogglePin: () =>
                                  context.read<TaskCubit>().togglePinTask(task),
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

          return const SizedBox.shrink();
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openBottomSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('مهمة جديدة'),
      ),
    );
  }
}
