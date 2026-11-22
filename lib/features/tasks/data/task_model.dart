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
  //converte data forme Entity to TaksModel
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
 // Converte From TaksModel to Map to Store in local database 
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
  //Converte Frome Map to TaskModel to returene list of Taks

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      isCompleted: map['isCompleted'] == true || map['isCompleted'] == 1,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      dueDate: map['dueDate'] != null
          ? DateTime.tryParse(map['dueDate'].toString())
          : null,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == map['priority']?.toString(),
        orElse: () => TaskPriority.medium,
      ),
      category: TaskCategory.values.firstWhere(
        (e) => e.name == map['category']?.toString(),
        orElse: () => TaskCategory.personal,
      ),
      subTasks: (map['subTasks'] is Iterable)
          ? (map['subTasks'] as Iterable).map((item) {
              if (item is Map) {
                return SubTaskEntity(
                  id: item['id']?.toString() ?? '',
                  title: item['title']?.toString() ?? '',
                  isCompleted: item['isCompleted'] == true || item['isCompleted'] == 1,
                );
              }
              return SubTaskEntity(
                id: '',
                title: item?.toString() ?? '',
                isCompleted: false,
              );
            }).toList()
          : const [],
      isPinned: map['isPinned'] == true || map['isPinned'] == 1,
      recurrence: TaskRecurrence.values.firstWhere(
        (e) => e.name == map['recurrence']?.toString(),
        orElse: () => TaskRecurrence.none,
      ),
      streak: int.tryParse(map['streak']?.toString() ?? '0') ?? 0,
      focusMinutes: int.tryParse(map['focusMinutes']?.toString() ?? '0') ?? 0,
    );
  }
}
