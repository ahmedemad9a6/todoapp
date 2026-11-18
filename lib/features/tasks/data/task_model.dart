import 'package:todoapp/features/tasks/domain/sub_task_entity.dart';
import 'package:todoapp/features/tasks/domain/task_entity.dart';
import 'package:todoapp/features/tasks/domain/task_enums.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    super.description = '',
    super.isCompleted = false,
    required super.createdAt,
    super.dueDate,
    super.priority = TaskPriority.medium,
    super.category = TaskCategory.personal,
    super.subTasks = const [],
    super.isPinned = false,
    super.recurrence = TaskRecurrence.none,
    super.streak = 0,
    super.focusMinutes = 0,
  });

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
      dueDate: entity.dueDate,
      priority: entity.priority,
      category: entity.category,
      subTasks: entity.subTasks,
      isPinned: entity.isPinned,
      recurrence: entity.recurrence,
      streak: entity.streak,
      focusMinutes: entity.focusMinutes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority.name,
      'category': category.name,
      'subTasks': subTasks
          .map(
            (s) => {'id': s.id, 'title': s.title, 'isCompleted': s.isCompleted},
          )
          .toList(),
      'isPinned': isPinned,
      'recurrence': recurrence.name,
      'streak': streak,
      'focusMinutes': focusMinutes,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      isCompleted: (map['isCompleted'] as bool?) ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
      dueDate: map['dueDate'] != null
          ? DateTime.parse(map['dueDate'] as String)
          : null,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      category: TaskCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => TaskCategory.personal,
      ),
      subTasks:
          (map['subTasks'] as List<dynamic>?)
              ?.map(
                (item) => SubTaskEntity(
                  id: item['id'] as String,
                  title: item['title'] as String,
                  isCompleted: item['isCompleted'] as bool? ?? false,
                ),
              )
              .toList() ??
          const [],
      isPinned: (map['isPinned'] as bool?) ?? false,
      recurrence: TaskRecurrence.values.firstWhere(
        (e) => e.name == map['recurrence'],
        orElse: () => TaskRecurrence.none,
      ),
      streak: (map['streak'] as int?) ?? 0,
      focusMinutes: (map['focusMinutes'] as int?) ?? 0,
    );
  }
}
