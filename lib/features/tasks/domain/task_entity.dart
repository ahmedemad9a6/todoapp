import 'package:equatable/equatable.dart';
import 'package:todoapp/features/tasks/domain/sub_task_entity.dart';
import 'package:todoapp/features/tasks/domain/task_enums.dart';

class TaskEntity extends Equatable {
  final String id; // المعرّف الفريد عالمياً (UUID)
  final String title; // عنوان المهمة الأساسي
  final String description; // تفاصيل وملاحظات إضافية
  final bool isCompleted; // هل المهمة مكتملة
  final DateTime createdAt; // تاريخ وتوقيت إنشاء المهمة
  final DateTime? dueDate; // تاريخ الاستحقاق النهائي (اختياري)
  final TaskPriority priority; // مستوى الأولوية (منخفضة، متوسطة، مرتفعة)
  final TaskCategory category; // تصنيف المهمة (عمل، دراسة، شخصي...)
  final List<SubTaskEntity> subTasks; // قائمة المهام الفرعية (Checklist)
  final bool isPinned; // تثبيت المهمة في قمة الشاشة 📌
  final TaskRecurrence recurrence; // نوع التكرار وبناء العادات 🔄
  final int streak; // عداد أيام الالتزام المتتالية 🔥
  final int focusMinutes; // مجموع دقائق التركيز عبر مؤقت بومودورو ⏱️

  const TaskEntity({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.category = TaskCategory.personal,
    this.subTasks = const [],
    this.isPinned = false,
    this.recurrence = TaskRecurrence.none,
    this.streak = 0,
    this.focusMinutes = 0,
  });

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return due.isBefore(today);
  }

  double get progress {
    if (subTasks.isEmpty) return isCompleted ? 1.0 : 0.0;
    final completedCount = subTasks.where((s) => s.isCompleted).length;
    return completedCount / subTasks.length;
  }

  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? dueDate,
    TaskPriority? priority,
    TaskCategory? category,
    List<SubTaskEntity>? subTasks,
    bool? isPinned,
    TaskRecurrence? recurrence,
    int? streak,
    int? focusMinutes,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      subTasks: subTasks ?? this.subTasks,
      isPinned: isPinned ?? this.isPinned,
      recurrence: recurrence ?? this.recurrence,
      streak: streak ?? this.streak,
      focusMinutes: focusMinutes ?? this.focusMinutes,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    isCompleted,
    createdAt,
    dueDate,
    priority,
    category,
    subTasks,
    isPinned,
    recurrence,
    streak,
    focusMinutes,
  ];
}
