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
      throw Exception('Failed to update task: $e');
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await _taskBox.delete(taskId);
    } catch (e) {
      throw Exception('فشل في حذف المهمة من التخزين: $e');
    }
  }

  @override
  Future<List<TaskEntity>> getTasks() async {
    try {
      final List<TaskEntity> task = [];
      for (var value in _taskBox.values) {
        final Map<String, dynamic> taskMap = Map<String, dynamic>.from(
          value as Map,
        );
        final taskModel = TaskModel.fromMap(taskMap);
        task.add(taskModel);
      }
      task.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return task;
    } catch (e) {
      throw Exception('Failed to get tasks: $e');
    }
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      await _taskBox.put(taskModel.id, taskModel.toMap());
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }
}
