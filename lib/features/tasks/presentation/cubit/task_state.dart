import 'package:equatable/equatable.dart';
import 'package:todoapp/features/tasks/domain/task_entity.dart';

abstract class TaskState extends Equatable {
  const TaskState();
  @override
  List<Object> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoadedSuccessfully extends TaskState {
  final List<TaskEntity> tasks;
  final bool? isLastPage;

  const TaskLoadedSuccessfully({required this.tasks, this.isLastPage});

  @override // should to know what do this line and how it works
  List<Object> get props => [tasks, isLastPage!];
}

class TaskError extends TaskState {
  final String message;
  const TaskError({required this.message});
  // @override
  // List<Object?> get props => [message];
}
