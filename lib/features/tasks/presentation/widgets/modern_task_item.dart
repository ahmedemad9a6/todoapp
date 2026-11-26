import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todoapp/features/tasks/domain/task_entity.dart';
import 'package:todoapp/features/tasks/domain/task_enums.dart';

class ModernTaskItem extends StatefulWidget {
  final TaskEntity task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onTogglePin;
  final VoidCallback? onOpenPomodoro;
  final void Function(String subTaskId)? onToggleSubTask;

  const ModernTaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.onTogglePin,
    this.onOpenPomodoro,
    this.onToggleSubTask,
  });

  @override
  State<ModernTaskItem> createState() => _ModernTaskItemState();
}

class _ModernTaskItemState extends State<ModernTaskItem> {
  bool _isExpanded = false;

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return const Color(0xFFF43F5E); // Rose 500 راقي وعصري
      case TaskPriority.medium:
        return const Color(0xFF0284C7); // Sky Blue 600 بديل رائع وأنيق للأصفر
      case TaskPriority.low:
        return const Color(0xFF10B981); // Emerald 500 زمردي مريح
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final task = widget.task;
    final isDone = task.isCompleted;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Dismissible(
        key: Key(task.id),
        direction: DismissDirection.horizontal,
        background: Container(
          alignment: AlignmentDirectional.centerStart,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDone ? Icons.restart_alt_rounded : Icons.check_circle_rounded,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                isDone ? 'Reopen' : 'Complete',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        secondaryBackground: Container(
          alignment: AlignmentDirectional.centerEnd,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF43F5E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
            ],
          ),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            HapticFeedback.mediumImpact();
            widget.onToggle();
            return false;
          } else if (direction == DismissDirection.endToStart) {
            HapticFeedback.mediumImpact();
            widget.onDelete();
            return true;
          }
          return false;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: isDone
                ? (theme.brightness == Brightness.dark
                      ? const Color(0xFF0F172A).withOpacity(0.5)
                      : const Color(0xFFF1F5F9).withOpacity(0.7))
                : (theme.brightness == Brightness.dark
                      ? const Color(0xFF1E293B)
                      : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: task.isPinned
                  ? const Color(0xFF6366F1).withOpacity(0.5)
                  : (task.isOverdue && !isDone
                        ? const Color(0xFFF43F5E).withOpacity(0.35)
                        : (theme.brightness == Brightness.dark
                              ? const Color(0x1EFFFFFF)
                              : const Color(0xFFE2E8F0))),
              width: task.isPinned ? 1.5 : 1.0,
            ),
            boxShadow: isDone
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        theme.brightness == Brightness.dark ? 0.22 : 0.04,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      leading: InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          widget.onToggle();
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDone
                                ? const Color(0xFF10B981)
                                : Colors.transparent,
                            border: Border.all(
                              color: isDone
                                  ? const Color(0xFF10B981)
                                  : (theme.brightness == Brightness.dark
                                        ? const Color(0x40FFFFFF)
                                        : const Color(0xFF94A3B8)),
                              width: 1.8,
                            ),
                          ),
                          child: isDone
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 15,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                      title: Row(
                        children: [
                          if (task.isPinned) ...[
                            const Icon(
                              Icons.push_pin_rounded,
                              size: 13,
                              color: Color(0xFF6366F1),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Expanded(
                            child: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: isDone
                                    ? theme.colorScheme.outline
                                    : (theme.brightness == Brightness.dark
                                          ? const Color(0xFFF8FAFC)
                                          : const Color(0xFF0F172A)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (task.description.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              task.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: isDone
                                    ? theme.colorScheme.outline.withOpacity(0.7)
                                    : theme.colorScheme.onSurfaceVariant,
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                          ],

                          const SizedBox(height: 8),

                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceVariant
                                      .withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  task.category.label,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                              if (task.priority != TaskPriority.low)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getPriorityColor(
                                      task.priority,
                                    ).withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        radius: 3,
                                        backgroundColor: _getPriorityColor(
                                          task.priority,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        task.priority.label,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                          color: _getPriorityColor(
                                            task.priority,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              if (task.dueDate != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: task.isOverdue
                                        ? const Color(
                                            0xFFF43F5E,
                                          ).withOpacity(0.10)
                                        : (task.isDueToday
                                              ? const Color(
                                                  0xFF0284C7,
                                                ).withOpacity(0.12)
                                              : theme.colorScheme.surfaceVariant
                                                    .withOpacity(0.4)),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        task.isOverdue
                                            ? Icons.error_outline_rounded
                                            : (task.isDueToday
                                                  ? Icons.access_time_rounded
                                                  : Icons
                                                        .calendar_today_rounded),
                                        size: 11,
                                        color: task.isOverdue
                                            ? const Color(0xFFF43F5E)
                                            : (task.isDueToday
                                                  ? const Color(0xFF0284C7)
                                                  : theme.colorScheme.outline),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        task.isOverdue
                                            ? 'Overdue'
                                            : (task.isDueToday
                                                  ? 'Today'
                                                  : _formatDate(task.dueDate!)),
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                          color: task.isOverdue
                                              ? const Color(0xFFF43F5E)
                                              : (task.isDueToday
                                                    ? const Color(0xFF0284C7)
                                                    : theme
                                                          .colorScheme
                                                          .outline),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              if (task.subTasks.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceVariant
                                        .withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_box_outlined,
                                        size: 11,
                                        color: theme.colorScheme.outline,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${task.subTasks.where((s) => s.isCompleted).length}/${task.subTasks.length}',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              if (task.recurrence != TaskRecurrence.none)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.repeat_rounded,
                                        size: 11,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        task.recurrence.label,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w500,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              if (task.focusMinutes > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF6366F1,
                                    ).withOpacity(0.10),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.timer_outlined,
                                        size: 11,
                                        color: Color(0xFF6366F1),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${task.focusMinutes}m',
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF6366F1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (task.subTasks.isNotEmpty)
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              icon: Icon(
                                _isExpanded
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.checklist_rounded,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                              tooltip: 'Checklist',
                              onPressed: () {
                                setState(() {
                                  _isExpanded = !_isExpanded;
                                });
                              },
                            ),

                          PopupMenuButton<String>(
                            //   visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            icon: Icon(
                              Icons.more_vert_rounded,
                              size: 20,
                              color: theme.colorScheme.outline,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onSelected: (val) {
                              if (val == 'pomodoro')
                                widget.onOpenPomodoro?.call();
                              if (val == 'pin') widget.onTogglePin?.call();
                              if (val == 'edit') widget.onEdit();
                              if (val == 'delete') widget.onDelete();
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(
                                value: 'pomodoro',
                                child: Row(
                                  children: [
                                    Icon(Icons.timer_outlined, size: 18),
                                    SizedBox(width: 8),
                                    Text('Focus Timer'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'pin',
                                child: Row(
                                  children: [
                                    Icon(
                                      task.isPinned
                                          ? Icons.push_pin_outlined
                                          : Icons.push_pin_rounded,
                                      size: 18,
                                      color: const Color(0xFF6366F1),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      task.isPinned ? 'Unpin' : 'Pin to Top',
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 18),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (_isExpanded && task.subTasks.isNotEmpty) ...[
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        child: Column(
                          children: task.subTasks.map((subTask) {
                            return InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                widget.onToggleSubTask?.call(subTask.id);
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: subTask.isCompleted,
                                      onChanged: (_) {
                                        HapticFeedback.lightImpact();
                                        widget.onToggleSubTask?.call(
                                          subTask.id,
                                        );
                                      },
                                      visualDensity: VisualDensity.compact,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        subTask.title,
                                        style: TextStyle(
                                          fontSize: 13,
                                          decoration: subTask.isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                          color: subTask.isCompleted
                                              ? theme.colorScheme.outline
                                              : theme.colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),

                // Left priority stripe (Positioned in Stack - zero layout bugs)
                Positioned(
                  left: 0,
                  top: 10,
                  bottom: 10,
                  child: Container(
                    width: 3.5,
                    decoration: BoxDecoration(
                      color: isDone
                          ? Colors.transparent
                          : _getPriorityColor(task.priority),
                      borderRadius: const BorderRadius.horizontal(
                        right: Radius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
