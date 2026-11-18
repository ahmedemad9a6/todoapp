import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:todoapp/features/tasks/data/task_model.dart';
import 'package:todoapp/features/tasks/domain/sub_task_entity.dart';
import 'package:todoapp/features/tasks/domain/task_entity.dart';
import 'package:todoapp/features/tasks/domain/task_enums.dart';
import 'package:todoapp/features/tasks/domain/task_repository.dart';
import 'package:todoapp/features/tasks/presentation/cubit/task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository repository;
  final _uuid = const Uuid();

  TaskEntity? _lastDeletedTask;

  TaskCubit({required this.repository}) : super(TaskInitial());

  Future<void> loadTasks() async {
    try {
      emit(TaskLoading());
      final tasks = await repository.getTasks();
      final filtered = _applyFilters(
        tasks: tasks,
        query: '',
        status: TaskFilterStatus.all,
        category: null,
      );
      emit(TaskLoadedSuccessfully(allTasks: tasks, filteredTasks: filtered));
    } catch (e) {
      emit(TaskError(message: 'فشل في تحميل المهام: $e'));
    }
  }

  void search(String query) {
    if (state is TaskLoadedSuccessfully) {
      final current = state as TaskLoadedSuccessfully;
      final filtered = _applyFilters(
        tasks: current.allTasks,
        query: query,
        status: current.statusFilter,
        category: current.categoryFilter,
      );
      emit(current.copyWith(searchQuery: query, filteredTasks: filtered));
    }
  }

  void setStatusFilter(TaskFilterStatus status) {
    if (state is TaskLoadedSuccessfully) {
      final current = state as TaskLoadedSuccessfully;
      final filtered = _applyFilters(
        tasks: current.allTasks,
        query: current.searchQuery,
        status: status,
        category: current.categoryFilter,
      );
      emit(current.copyWith(statusFilter: status, filteredTasks: filtered));
    }
  }

  void setCategoryFilter(TaskCategory? category) {
    if (state is TaskLoadedSuccessfully) {
      final current = state as TaskLoadedSuccessfully;
      final isSame = current.categoryFilter == category;
      final newCategory = isSame ? null : category;

      final filtered = _applyFilters(
        tasks: current.allTasks,
        query: current.searchQuery,
        status: current.statusFilter,
        category: newCategory,
      );
      emit(
        current.copyWith(
          categoryFilter: newCategory,
          clearCategoryFilter: newCategory == null,
          filteredTasks: filtered,
        ),
      );
    }
  }

  List<TaskEntity> _applyFilters({
    required List<TaskEntity> tasks,
    required String query,
    required TaskFilterStatus status,
    required TaskCategory? category,
  }) {
    final filtered = tasks.where((task) {
      // مطابقة البحث
      final matchesQuery =
          query.isEmpty ||
          task.title.toLowerCase().contains(query.toLowerCase()) ||
          task.description.toLowerCase().contains(query.toLowerCase());

      // مطابقة الحالة
      bool matchesStatus = true;
      switch (status) {
        case TaskFilterStatus.all:
          matchesStatus = true;
          break;
        case TaskFilterStatus.pending:
          matchesStatus = !task.isCompleted;
          break;
        case TaskFilterStatus.completed:
          matchesStatus = task.isCompleted;
          break;
        case TaskFilterStatus.today:
          matchesStatus = task.isDueToday;
          break;
      }

      // مطابقة التصنيف
      final matchesCategory = category == null || task.category == category;

      return matchesQuery && matchesStatus && matchesCategory;
    }).toList();

    //  فرز ذكي: تظهر المهام المثبتة (Pinned) دائماً في أعلى القائمة
    filtered.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return 0;
    });

    return filtered;
  }

  Future<void> addTask({
    required String title,
    required String description,
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
    TaskCategory category = TaskCategory.personal,
    List<SubTaskEntity> subTasks = const [],
    bool isPinned = false,
    TaskRecurrence recurrence = TaskRecurrence.none,
  }) async {
    try {
      final newTask = TaskEntity(
        id: _uuid.v4(),
        title: title.trim(),
        description: description.trim(),
        createdAt: DateTime.now(),
        dueDate: dueDate,
        priority: priority,
        category: category,
        subTasks: subTasks,
        isPinned: isPinned,
        recurrence: recurrence,
        streak: 0,
        focusMinutes: 0,
      );
      await repository.addTask(newTask);
      await _refreshWithCurrentFilters();
    } catch (e) {
      emit(const TaskError(message: 'فشل في إضافة المهمة'));
    }
  }

  Future<void> toggleTaskStatus(TaskEntity task) async {
    try {
      final willBeCompleted = !task.isCompleted;
      final newStreak =
          (willBeCompleted && task.recurrence != TaskRecurrence.none)
          ? task.streak + 1
          : task.streak;

      final updated = task.copyWith(
        isCompleted: willBeCompleted,
        streak: newStreak,
      );
      await repository.updateTask(updated);
      await _refreshWithCurrentFilters();
    } catch (e) {
      emit(const TaskError(message: 'فشل في تحديث حالة المهمة'));
    }
  }

  Future<void> togglePinTask(TaskEntity task) async {
    try {
      final updated = task.copyWith(isPinned: !task.isPinned);
      await repository.updateTask(updated);
      await _refreshWithCurrentFilters();
    } catch (e) {
      emit(const TaskError(message: 'فشل في تغيير تثبيت المهمة'));
    }
  }

  Future<void> addFocusMinutes(TaskEntity task, int minutes) async {
    try {
      final updated = task.copyWith(focusMinutes: task.focusMinutes + minutes);
      await repository.updateTask(updated);
      await _refreshWithCurrentFilters();
    } catch (e) {
      emit(const TaskError(message: 'فشل في حفظ دقائق التركيز'));
    }
  }

  Future<void> toggleSubTask(TaskEntity task, String subTaskId) async {
    try {
      final updatedSubTasks = task.subTasks.map((s) {
        if (s.id == subTaskId) {
          return s.copyWith(isCompleted: !s.isCompleted);
        }
        return s;
      }).toList();

      final allDone =
          updatedSubTasks.isNotEmpty &&
          updatedSubTasks.every((s) => s.isCompleted);

      final updatedTask = task.copyWith(
        subTasks: updatedSubTasks,
        isCompleted: allDone ? true : task.isCompleted,
      );

      await repository.updateTask(updatedTask);
      await _refreshWithCurrentFilters();
    } catch (e) {
      emit(const TaskError(message: 'فشل في تحديث المهمة الفرعية'));
    }
  }

  Future<void> editTask({
    required TaskEntity task,
    required String newTitle,
    required String newDescription,
    DateTime? newDueDate,
    TaskPriority? newPriority,
    TaskCategory? newCategory,
    List<SubTaskEntity>? newSubTasks,
    bool? newIsPinned,
    TaskRecurrence? newRecurrence,
  }) async {
    try {
      final updated = task.copyWith(
        title: newTitle.trim(),
        description: newDescription.trim(),
        dueDate: newDueDate,
        priority: newPriority,
        category: newCategory,
        subTasks: newSubTasks ?? task.subTasks,
        isPinned: newIsPinned ?? task.isPinned,
        recurrence: newRecurrence ?? task.recurrence,
      );
      await repository.updateTask(updated);
      await _refreshWithCurrentFilters();
    } catch (e) {
      emit(const TaskError(message: 'فشل في تعديل المهمة'));
    }
  }

  Future<void> deleteTask(TaskEntity task) async {
    try {
      _lastDeletedTask = task;
      await repository.deleteTask(task.id);
      await _refreshWithCurrentFilters();
    } catch (e) {
      emit(const TaskError(message: 'فشل في حذف المهمة'));
    }
  }

  Future<void> undoDelete() async {
    if (_lastDeletedTask != null) {
      try {
        await repository.addTask(_lastDeletedTask!);
        _lastDeletedTask = null;
        await _refreshWithCurrentFilters();
      } catch (e) {
        emit(const TaskError(message: 'فشل في استعادة المهمة'));
      }
    }
  }

  Future<String> exportTasksJson() async {
    final tasks = await repository.getTasks();
    final list = tasks.map((t) => TaskModel.fromEntity(t).toMap()).toList();
    return const JsonEncoder.withIndent('  ').convert(list);
  }

  Future<int> importTasksJson(String jsonString) async {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! List) throw Exception('صيغة غير صالحة');
      int count = 0;
      for (final item in decoded) {
        if (item is Map) {
          final taskModel = TaskModel.fromMap(Map<String, dynamic>.from(item));
          await repository.addTask(taskModel);
          count++;
        }
      }
      await _refreshWithCurrentFilters();
      return count;
    } catch (e) {
      throw Exception('فشل في استيراد البيانات: $e');
    }
  }

  Future<void> _refreshWithCurrentFilters() async {
    if (state is TaskLoadedSuccessfully) {
      final current = state as TaskLoadedSuccessfully;
      final tasks = await repository.getTasks();
      final filtered = _applyFilters(
        tasks: tasks,
        query: current.searchQuery,
        status: current.statusFilter,
        category: current.categoryFilter,
      );
      emit(current.copyWith(allTasks: tasks, filteredTasks: filtered));
    } else {
      await loadTasks();
    }
  }
}
