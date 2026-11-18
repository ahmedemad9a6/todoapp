import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todoapp/features/tasks/domain/task_entity.dart';
import 'package:todoapp/features/tasks/domain/task_enums.dart';

class ModernTaskItem extends StatefulWidget {
  final TaskEntity task; // كائن المهمة المعروض
  final VoidCallback onToggle; // دالة تبديل حالة المهمة الرئيسية
  final VoidCallback onEdit; // دالة فتح نافذة التعديل
  final VoidCallback onDelete; // دالة حذف المهمة
  final VoidCallback? onTogglePin; // دالة تثبيت/إلغاء تثبيت المهمة 📌
  final VoidCallback? onOpenPomodoro; // دالة فتح مؤقت بومودورو 🍅
  final void Function(String subTaskId)?
  onToggleSubTask; // دالة تبديل حالة الخطوة الفرعية

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
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final task = widget.task;
    final isDone = task.isCompleted;
    final priorityColor = _getPriorityColor(task.priority);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      // ويدجت السحب الحركي التفاعلي (Dismissible Gestures)
      child: Dismissible(
        key: Key(task.id),
        direction: DismissDirection.horizontal,

                background: Container(
          alignment: AlignmentDirectional.centerStart,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.green.shade600,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isDone ? Icons.restart_alt_rounded : Icons.check_circle_rounded,
                color: Colors.white,
                size: 26,
              ),
              const SizedBox(width: 8),
              Text(
                isDone ? 'إعادة فتح' : 'إنجاز',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),

                secondaryBackground: Container(
          alignment: AlignmentDirectional.centerEnd,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.red.shade600,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'حذف',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 26),
            ],
          ),
        ),

        // القرار عند إتمام السحب
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            // اهتزاز لمسي متوسط عند الإنجاز بالسحب
            HapticFeedback.mediumImpact();
            widget.onToggle();
            return false;
          } else {
            // اهتزاز لمسي قوي عند الحذف بالسحب
            HapticFeedback.heavyImpact();
            widget.onDelete();
            return false;
          }
        },

        
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isDone
                ? (theme.brightness == Brightness.dark
                      ? const Color(0xFF131926).withOpacity(0.6)
                      : const Color(0xFFF1F5F9).withOpacity(0.7))
                : (theme.brightness == Brightness.dark
                      ? const Color(0xFF151D2C)
                      : Colors.white),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDone
                  ? (theme.brightness == Brightness.dark
                        ? const Color(0x14FFFFFF)
                        : const Color(0x0D000000))
                  : (task.isPinned
                        ? Colors.amber.withOpacity(0.65)
                        : (task.isOverdue
                              ? Colors.red.withOpacity(0.4)
                              : (theme.brightness == Brightness.dark
                                    ? const Color(0x1EFFFFFF)
                                    : const Color(0x0F000000)))),
              width: task.isPinned ? 1.6 : 1.2,
            ),
            boxShadow: isDone
                ? []
                : [
                    BoxShadow(
                      color: task.isPinned
                          ? Colors.amber.withOpacity(0.08)
                          : (theme.brightness == Brightness.dark
                                ? Colors.black.withOpacity(0.3)
                                : Colors.black.withOpacity(0.04)),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                // زر الاختيار الدائري العصري (Modern Circular Checkbox)
                leading: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    widget.onToggle();
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isDone
                          ? const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      border: Border.all(
                        color: isDone
                            ? Colors.transparent
                            : (theme.brightness == Brightness.dark
                                  ? const Color(0x40FFFFFF)
                                  : const Color(0x33000000)),
                        width: 2,
                      ),
                      boxShadow: isDone
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFF10B981,
                                ).withOpacity(0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: isDone
                        ? const Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),

                // عنوان المهمة مع شارة التثبيت إن كانت مثبتة
                title: Row(
                  children: [
                    if (task.isPinned) ...[
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.push_pin_rounded,
                          size: 13,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
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
                    // وصف المهمة
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDone
                              ? theme.colorScheme.outline.withOpacity(0.7)
                              : theme.colorScheme.onSurfaceVariant,
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ],

                    // شريط تقدم إنجاز المهام الفرعية (LinearProgressIndicator)
                    if (task.subTasks.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: task.progress,
                                minHeight: 6,
                                backgroundColor: theme
                                    .colorScheme
                                    .surfaceVariant
                                    .withOpacity(0.5),
                                valueColor: AlwaysStoppedAnimation(
                                  task.progress == 1.0
                                      ? Colors.green
                                      : theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(task.progress * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: task.progress == 1.0
                                  ? Colors.green
                                  : theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 10),

                    // صف الشارات (التصنيف، الأولوية، الموعد، التكرار، الـ Streak، بومودورو)
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant.withOpacity(
                              0.4,
                            ),
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
                              CircleAvatar(
                                radius: 3,
                                backgroundColor: priorityColor,
                              ),
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

                        if (task.recurrence != TaskRecurrence.none)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${task.recurrence.icon} ${task.recurrence.label}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                          ),

                        if (task.streak > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '🔥 ${task.streak} أيام',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ),

                        if (task.focusMinutes > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '🍅 ${task.focusMinutes} د',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                          ),

                        
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
                                        ? theme.colorScheme.primary.withOpacity(
                                            0.12,
                                          )
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

                // أزرار وخيارات البطاقة
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // زر فتح وإغلاق قائمة المهام الفرعية
                    if (task.subTasks.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.checklist_rounded,
                          color: theme.colorScheme.primary,
                        ),
                        tooltip: 'عرض المهام الفرعية',
                        onPressed: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                      ),

                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: theme.colorScheme.outline,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      onSelected: (val) {
                        if (val == 'pomodoro') widget.onOpenPomodoro?.call();
                        if (val == 'pin') widget.onTogglePin?.call();
                        if (val == 'edit') widget.onEdit();
                        if (val == 'delete') widget.onDelete();
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'pomodoro',
                          child: Row(
                            children: [
                              Icon(
                                Icons.timer_rounded,
                                size: 20,
                                color: Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text('مؤقت بومودورو 🍅'),
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
                                size: 20,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                task.isPinned
                                    ? 'إلغاء التثبيت'
                                    : 'تثبيت في القمة 📌',
                              ),
                            ],
                          ),
                        ),
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
                              Icon(
                                Icons.delete_outline,
                                size: 20,
                                color: Colors.red,
                              ),
                              SizedBox(width: 8),
                              Text('حذف', style: TextStyle(color: Colors.red)),
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
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    children: task.subTasks.map((subTask) {
                      return InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          widget.onToggleSubTask?.call(subTask.id);
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Checkbox(
                                value: subTask.isCompleted,
                                onChanged: (_) {
                                  HapticFeedback.lightImpact();
                                  widget.onToggleSubTask?.call(subTask.id);
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
        ),
      ),
    );
  }
}
