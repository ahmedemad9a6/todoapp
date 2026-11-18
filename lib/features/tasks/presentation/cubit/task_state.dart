import 'package:equatable/equatable.dart';
import 'package:todoapp/features/tasks/domain/task_entity.dart';
import 'package:todoapp/features/tasks/domain/task_enums.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoadedSuccessfully extends TaskState {
  final List<TaskEntity> allTasks;       
  final List<TaskEntity> filteredTasks;  // القائمة المفلترة المعروضة حالياً على الشاشة بعد تطبيق البحث والتصنيف
  final String searchQuery;              // نص البحث الفوري المكتوب حالياً
  final TaskFilterStatus statusFilter;   // فلتر الحالة النشط (الكل، قيد الإنجاز، المكتملة، اليوم)
  final TaskCategory? categoryFilter;    // فلتر التصنيف النشط (عمل، شخصي...) أو null لعرض الجميع

  const TaskLoadedSuccessfully({
    required this.allTasks,
    required this.filteredTasks,
    this.searchQuery = '',
    this.statusFilter = TaskFilterStatus.all,
    this.categoryFilter,
  });

  TaskLoadedSuccessfully copyWith({
    List<TaskEntity>? allTasks,
    List<TaskEntity>? filteredTasks,
    String? searchQuery,
    TaskFilterStatus? statusFilter,
    TaskCategory? categoryFilter,
    bool clearCategoryFilter = false,
  }) {
    return TaskLoadedSuccessfully(
      allTasks: allTasks ?? this.allTasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      categoryFilter: clearCategoryFilter
          ? null
          : (categoryFilter ?? this.categoryFilter),
    );
  }

  @override
  List<Object?> get props => [
    allTasks,
    filteredTasks,
    searchQuery,
    statusFilter,
    categoryFilter,
  ];
}

class TaskError extends TaskState {
  final String message;

  const TaskError({required this.message});

  @override
  List<Object?> get props => [message];
}
