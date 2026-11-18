import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:todoapp/features/tasks/data/task_model.dart';
import 'package:todoapp/features/tasks/domain/task_entity.dart';
import 'package:todoapp/features/tasks/domain/task_repository.dart';

class HiveTaskRepositoryImp implements TaskRepository {
  // الصندوق الداخلي الخاص بقاعدة البيانات
  final Box<dynamic> _taskBox;

  // حقن التبعية (Dependency Injection) عبر الـ Constructor
  HiveTaskRepositoryImp({required Box<dynamic> taskBox}) : _taskBox = taskBox;

  @override
  Future<void> addTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      // استخدام taskModel.id كمفتاح يضمن عدم التكرار
      await _taskBox.put(taskModel.id, taskModel.toMap());
    } catch (e) {
      throw Exception('فشل في إضافة المهمة إلى التخزين: $e');
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
      final List<TaskEntity> tasks = [];

      for (var value in _taskBox.values) {
        // تحويل آمن لنوع البيانات القادمة من Hive
        final Map<String, dynamic> taskMap = Map<String, dynamic>.from(
          value as Map,
        );
        final taskModel = TaskModel.fromMap(taskMap);
        tasks.add(taskModel);
      }

      // ترتيب المهام تنازلياً بحيث تظهر المهمة الأحدث أولاً
      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tasks;
    } catch (e) {
      throw Exception('فشل في جلب المهام من التخزين المحلي: $e');
    }
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      // وضع البيانات المحدثة تحت نفس المفتاح يقوم بتحديثها تلقائياً
      await _taskBox.put(taskModel.id, taskModel.toMap());
    } catch (e) {
      throw Exception('فشل في تحديث المهمة في التخزين: $e');
    }
  }
}
