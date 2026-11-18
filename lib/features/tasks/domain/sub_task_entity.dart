import 'package:equatable/equatable.dart';

class SubTaskEntity extends Equatable {
  final String id;          // المعرف الفريد للمهمة الفرعية
  final String title;       // عنوان الخطوة الفرعية
  final bool isCompleted;   // حالة الإنجاز (تمت أو لم تتم)

  const SubTaskEntity({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  SubTaskEntity copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return SubTaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [id, title, isCompleted];
}
