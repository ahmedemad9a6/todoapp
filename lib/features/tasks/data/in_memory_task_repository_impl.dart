import 'package:todoapp/features/tasks/domain/task_entity.dart';
import 'package:todoapp/features/tasks/domain/task_repository.dart';

class InMemoryTaskRepositoryImpl implements TaskRepository {
  final List<TaskEntity> _tasks = [];

  @override
  Future<void> addTask(TaskEntity task) async {
    _tasks.add(task);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((e) => e.id == taskId);
  }

  @override
  Future<List<TaskEntity>> getTasks() async {
    await Future.delayed(const Duration(microseconds: 1));
    return List.unmodifiable(
      _tasks,
    ); //!unmodified makes it read only to the cubit.
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }
  }
}
