import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:todoapp/features/tasks/data/task_model.dart';
import 'package:todoapp/features/tasks/domain/task_entity.dart';
import 'package:todoapp/features/tasks/domain/task_repository.dart';

class HiveTaskRepositoryImp implements TaskRepository {
  final Box<dynamic> _taskBox;

  HiveTaskRepositoryImp({required Box<dynamic> taskBox}) : _taskBox = taskBox;

  @override
  Future<void> addTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      await _taskBox.put(taskModel.id, taskModel.toMap());
    } catch (e) {
      throw Exception('Failed to add task to storage: $e');
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await _taskBox.delete(taskId);
    } catch (e) {
      throw Exception('Failed to delete task from storage: $e');
    }
  }

  @override
  Future<List<TaskEntity>> getTasks() async {
    try {
      final List<TaskEntity> tasks = [];

      for (var value in _taskBox.values) {
        if (value == null) continue;
        try {
          if (value is Map) {
            final Map<String, dynamic> taskMap = Map<String, dynamic>.from(value);
            final taskModel = TaskModel.fromMap(taskMap);
            tasks.add(taskModel);
          }
        } catch (_) {
          // Skip corrupt or unparseable entry gracefully
        }
      }

      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tasks;
    } catch (e) {
      throw Exception('Failed to retrieve tasks from local storage: $e');
    }
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      await _taskBox.put(taskModel.id, taskModel.toMap());
    } catch (e) {
      throw Exception('Failed to update task in storage: $e');
    }
  }
}
