import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:todoapp/features/tasks/domain/task_entity.dart';
import 'package:todoapp/features/tasks/domain/task_enums.dart';
import 'package:todoapp/features/tasks/domain/task_repository.dart';
import 'package:todoapp/features/tasks/presentation/cubit/task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository repository;
  final _uuid = const Uuid();

  TaskEntity? _lastDeletedTask;

  TaskCubit({required this.repository}) : super(TaskInitial());

  /// جلب المهام وتطبيق الفلاتر الحالية
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

  /// البحث الفوري بالنص
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

  /// فلترة بحالة المهمة (الكل / قيد الإنجاز / مكتملة / اليوم)
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

  /// فلترة بنوع التصنيف (عمل / دراسة / شخصي...)
  void setCategoryFilter(TaskCategory? category) {
    if (state is TaskLoadedSuccessfully) {
      final current = state as TaskLoadedSuccessfully;
      final isSame = current.categoryFilter == category;
      final newCategory = isSame
          ? null
          : category; // الضغط عليه مجدداً يلغي التحديد

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

  /// الدالة المركزية لتطبيق الفلاتر والبحث
  List<TaskEntity> _applyFilters({
    required List<TaskEntity> tasks,
    required String query,
    required TaskFilterStatus status,
    required TaskCategory? category,
  }) {
    return tasks.where((task) {
      // 1. فلتر البحث بالنص في العنوان أو الوصف
      final matchesQuery =
          query.isEmpty ||
          task.title.toLowerCase().contains(query.toLowerCase()) ||
          task.description.toLowerCase().contains(query.toLowerCase());

      // 2. فلتر الحالة
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

      // 3. فلتر التصنيف
      final matchesCategory = category == null || task.category == category;

      return matchesQuery && matchesStatus && matchesCategory;
    }).toList();
  }

  /// إضافة مهمة مع الحقول الجديدة
  Future<void> addTask({
    required String title,
    required String description,
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
    TaskCategory category = TaskCategory.personal,
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
      );
      await repository.addTask(newTask);
      await _refreshWithCurrentFilters();
    } catch (e) {
      emit(const TaskError(message: 'فشل في إضافة المهمة'));
    }
  }

  /// تبديل حالة الإنجاز
  Future<void> toggleTaskStatus(TaskEntity task) async {
    try {
      final updated = task.copyWith(isCompleted: !task.isCompleted);
      await repository.updateTask(updated);
      await _refreshWithCurrentFilters();
    } catch (e) {
      emit(const TaskError(message: 'فشل في تحديث حالة المهمة'));
    }
  }

  /// تعديل مهمة
  Future<void> editTask({
    required TaskEntity task,
    required String newTitle,
    required String newDescription,
    DateTime? newDueDate,
    TaskPriority? newPriority,
    TaskCategory? newCategory,
  }) async {
    try {
      final updated = task.copyWith(
        title: newTitle.trim(),
        description: newDescription.trim(),
        dueDate: newDueDate,
        priority: newPriority,
        category: newCategory,
      );
      await repository.updateTask(updated);
      await _refreshWithCurrentFilters();
    } catch (e) {
      emit(const TaskError(message: 'فشل في تعديل المهمة'));
    }
  }

  /// حذف مهمة
  Future<void> deleteTask(TaskEntity task) async {
    try {
      _lastDeletedTask = task;
      await repository.deleteTask(task.id);
      await _refreshWithCurrentFilters();
    } catch (e) {
      emit(const TaskError(message: 'فشل في حذف المهمة'));
    }
  }

  /// تراجع عن الحذف
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

  /// إعادة تحميل مع الحفاظ على الفلاتر المحددة حالياً
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
