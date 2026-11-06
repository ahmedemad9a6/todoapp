import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:todoapp/features/tasks/domain/task_entity.dart';
import 'package:todoapp/features/tasks/domain/task_enums.dart';

class ModernTaskItem extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ModernTaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = task.isCompleted;
    final priorityColor = _getPriorityColor(task.priority);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isDone
              ? theme.colorScheme.surfaceVariant.withOpacity(0.2)
              : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDone
                ? theme.colorScheme.outlineVariant.withOpacity(0.3)
                : (task.isOverdue
                      ? Colors.red.withOpacity(0.4)
                      : theme.colorScheme.primary.withOpacity(0.15)),
            width: task.isOverdue && !isDone ? 1.5 : 1.2,
          ),
          boxShadow: isDone
              ? []
              : [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Transform.scale(
            scale: 1.15,
            child: Checkbox(
              value: isDone,
              onChanged: (_) => onToggle(),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              activeColor: theme.colorScheme.primary,
            ),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              decoration: isDone ? TextDecoration.lineThrough : null,
              color: isDone
                  ? theme.colorScheme.outline
                  : theme.colorScheme.onSurface,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  task.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDone
                        ? theme.colorScheme.outline.withOpacity(0.7)
                        : theme.colorScheme.onSurfaceVariant,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
              const SizedBox(height: 10),

              // صف الشارات (التصنيف، الأولوية، التاريخ)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // 1. شارة التصنيف
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${task.category.icon} ${task.category.label}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // 2. شارة الأولوية
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(radius: 3, backgroundColor: priorityColor),
                        const SizedBox(width: 4),
                        Text(
                          task.priority.label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: priorityColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. شارة موعد الاستحقاق (إن وُجد)
                  if (task.dueDate != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: task.isOverdue
                            ? Colors.red.withOpacity(0.12)
                            : (task.isDueToday
                                  ? theme.colorScheme.primary.withOpacity(0.12)
                                  : theme.colorScheme.surfaceVariant
                                        .withOpacity(0.4)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            task.isOverdue
                                ? Icons.warning_amber_rounded
                                : Icons.event_rounded,
                            size: 13,
                            color: task.isOverdue
                                ? Colors.red
                                : (task.isDueToday
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outline),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            task.isOverdue
                                ? 'متأخرة (${_formatDate(task.dueDate!)})'
                                : (task.isDueToday
                                      ? 'مستحقة اليوم'
                                      : _formatDate(task.dueDate!)),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: task.isOverdue
                                  ? Colors.red
                                  : (task.isDueToday
                                        ? theme.colorScheme.primary
                                        : theme.colorScheme.outline),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: theme.colorScheme.outline,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onSelected: (val) {
              if (val == 'edit') onEdit();
              if (val == 'delete') onDelete();
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20),
                    SizedBox(width: 8),
                    Text('تعديل'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('حذف', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }
}
