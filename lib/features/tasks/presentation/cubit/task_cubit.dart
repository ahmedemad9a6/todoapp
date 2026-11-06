import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/features/tasks/domain/task_entity.dart';
import 'package:todoapp/features/tasks/domain/task_repository.dart';
import 'package:uuid/uuid.dart';

import 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository repository;
  final Uuid _uuid = const Uuid();

  // متغير للاحتفاظ بآخر مهمة تم حذفها لدعم التراجع (Undo)
  TaskEntity? _lastDeletedTask;
  int? _lastDeletedIndex;

  TaskCubit({required this.repository}) : super(TaskInitial());

  /// جلب كافة المهام
  Future<void> loadTasks() async {
    emit(TaskLoading());
    try {
      final tasks = await repository.getTasks();
      emit(TaskLoadedSuccessfully(tasks: tasks));
    } catch (e) {
      emit(TaskError(message: 'فشل في تحميل المهام: ${e.toString()}'));
    }
  }

  /// إضافة مهمة جديدة
  Future<void> addTask({required String title, String description = ''}) async {
    try {
      final newTask = TaskEntity(
        id: _uuid.v4(),
        title: title.trim(),
        description: description.trim(),
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      await repository.addTask(newTask);
      await loadTasks(); // تحديث القائمة بالحالة الجديدة
    } catch (e) {
      emit(TaskError(message: 'فشل في إضافة المهمة: ${e.toString()}'));
    }
  }

  /// تبديل حالة إنجاز المهمة (Done / Not Done)
  Future<void> toggleTaskStatus(TaskEntity task) async {
    try {
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      await repository.updateTask(updatedTask);
      await loadTasks();
    } catch (e) {
      emit(TaskError(message: 'فشل في تحديث حالة المهمة'));
    }
  }

  /// تعديل عنوان ووصف المهمة
  Future<void> editTask({
    required TaskEntity task,
    required String newTitle,
    required String newDescription,
  }) async {
    try {
      final updatedTask = task.copyWith(
        title: newTitle.trim(),
        description: newDescription.trim(),
      );
      await repository.updateTask(updatedTask);
      await loadTasks();
    } catch (e) {
      emit(TaskError(message: 'فشل في تعديل المهمة'));
    }
  }

  /// حذف مهمة مع حفظ بياناتها للتراجع
  Future<void> deleteTask(TaskEntity task) async {
    if (state is TaskLoadedSuccessfully) {
      final currentList = (state as TaskLoadedSuccessfully).tasks;
      _lastDeletedIndex = currentList.indexOf(task);
      _lastDeletedTask = task;

      try {
        await repository.deleteTask(task.id);
        await loadTasks();
      } catch (e) {
        emit(TaskError(message: 'فشل في حذف المهمة'));
      }
    }
  }

  /// التراجع عن الحذف (Undo Delete)
  Future<void> undoDelete() async {
    if (_lastDeletedTask != null) {
      try {
        await repository.addTask(_lastDeletedTask!);
        _lastDeletedTask = null;
        _lastDeletedIndex = null;
        await loadTasks();
      } catch (e) {
        emit(TaskError(message: 'فشل في استعادة المهمة المحذوفة'));
      }
    }
  }
}
