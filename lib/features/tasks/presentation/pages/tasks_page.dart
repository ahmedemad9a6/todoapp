import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/core/theme/theme_cubit.dart';
import 'package:todoapp/features/tasks/domain/task_entity.dart';
import 'package:todoapp/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:todoapp/features/tasks/presentation/cubit/task_state.dart';
import 'package:todoapp/features/tasks/presentation/widgets/empty_tasks_view.dart';
import 'package:todoapp/features/tasks/presentation/widgets/modern_task_item.dart';
import 'package:todoapp/features/tasks/presentation/widgets/task_bottom_sheet.dart';
import 'package:todoapp/features/tasks/presentation/widgets/task_filter_bar.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});
  void _openBottomSheet(BuildContext context, {TaskEntity? taskToEdit}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => TaskBottomSheet(
        taskToEdit: taskToEdit,
        onSave: (title, desc, dueDate, priority, category) {
          // 👈 استقبل كل المتغيرات
          if (taskToEdit == null) {
            context.read<TaskCubit>().addTask(
              title: title,
              description: desc,
              dueDate: dueDate,
              priority: priority,
              category: category,
            );
          } else {
            context.read<TaskCubit>().editTask(
              task: taskToEdit,
              newTitle: title,
              newDescription: desc,
              newDueDate: dueDate,
              newPriority: priority,
              newCategory: category,
            );
          }
        },
      ),
    );
  }

  void _handleDelete(BuildContext context, TaskEntity task) {
    final cubit = context.read<TaskCubit>();
    cubit.deleteTask(task);

    // إظهار SnackBar مع زر التراجع (Undo)
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حذف "${task.title}"'),
        behavior: SnackBarBehavior.floating,
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
    final themeCubit = context.watch<ThemeCubit>();
    final isDark = themeCubit.isDark(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('مهامي اليومية'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: isDark ? 'الوضع النهاري' : 'الوضع الليلي',
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            onPressed: () {
              context.read<ThemeCubit>().toggleTheme();
            },
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
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TaskLoadedSuccessfully) {
            final tasks = state.filteredTasks; // 👈 استخدمنا filteredTasks

            return Column(
              children: [
                // شريط البحث والفلترة بالأعلى
                const TaskFilterBar(),

                // قائمة المهام
                Expanded(
                  child: tasks.isEmpty
                      ? EmptyTasksView(
                          onAddTask: () => _openBottomSheet(context),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 10),
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
        icon: const Icon(Icons.add_rounded),
        label: const Text('مهمة جديدة'),
      ),
    );
  }
}
