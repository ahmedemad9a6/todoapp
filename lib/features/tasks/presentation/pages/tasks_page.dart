import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/features/tasks/domain/task_entity.dart';
import 'package:todoapp/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:todoapp/features/tasks/presentation/cubit/task_state.dart';
import 'package:todoapp/features/tasks/presentation/widgets/task_dialog.dart';
import 'package:todoapp/features/tasks/presentation/widgets/task_entity.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => TaskDialog(
        onSave: (title, description) {
          context.read<TaskCubit>().addTask(
            title: title,
            description: description,
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, TaskEntity task) {
    showDialog(
      context: context,
      builder: (dialogContext) => TaskDialog(
        taskToEdit: task,
        onSave: (title, description) {
          context.read<TaskCubit>().editTask(
            task: task,
            newTitle: title,
            newDescription: description,
          );
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
    return Scaffold(
      appBar: AppBar(title: const Text('مهامي اليومية'), centerTitle: true),
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
            final tasks = state.tasks;

            if (tasks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.checklist_rounded,
                      size: 80,
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد مهام حالياً',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('اضغط على زر (+) في الأسفل لإضافة مهمتك الأولى'),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskItemTile(
                  task: task,
                  onToggle: () =>
                      context.read<TaskCubit>().toggleTaskStatus(task),
                  onEdit: () => _showEditDialog(context, task),
                  onDelete: () => _handleDelete(context, task),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('مهمة جديدة'),
      ),
    );
  }
}
