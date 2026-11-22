import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:todoapp/features/tasks/domain/sub_task_entity.dart';
import 'package:todoapp/features/tasks/domain/task_entity.dart';
import 'package:todoapp/features/tasks/domain/task_enums.dart';

class TaskBottomSheet extends StatefulWidget {
  final TaskEntity? taskToEdit;
  final void Function(
    String title,
    String description,
    DateTime? dueDate,
    TaskPriority priority,
    TaskCategory category,
    List<SubTaskEntity> subTasks,
    bool isPinned,
    TaskRecurrence recurrence,
  )
  onSave;

  const TaskBottomSheet({super.key, this.taskToEdit, required this.onSave});

  @override
  State<TaskBottomSheet> createState() => _TaskBottomSheetState();
}

class _TaskBottomSheetState extends State<TaskBottomSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _subTaskInputController;
  final _formKey = GlobalKey<FormState>();

  DateTime? _selectedDueDate;
  late TaskPriority _selectedPriority;
  late TaskCategory _selectedCategory;
  late List<SubTaskEntity> _subTasks;
  late bool _isPinned;
  late TaskRecurrence _selectedRecurrence;
  bool _showAdvancedDetails = false;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    final task = widget.taskToEdit;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descController = TextEditingController(text: task?.description ?? '');
    _subTaskInputController = TextEditingController();
    _selectedDueDate = task?.dueDate;
    _selectedPriority = task?.priority ?? TaskPriority.medium;
    _selectedCategory = task?.category ?? TaskCategory.personal;
    _subTasks = List.from(task?.subTasks ?? []);
    _isPinned = task?.isPinned ?? false;
    _selectedRecurrence = task?.recurrence ?? TaskRecurrence.none;

    if (task != null &&
        (task.description.isNotEmpty ||
            task.subTasks.isNotEmpty ||
            task.recurrence != TaskRecurrence.none ||
            task.isPinned)) {
      _showAdvancedDetails = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _subTaskInputController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  void _addSubTask() {
    final text = _subTaskInputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _subTasks.add(
          SubTaskEntity(id: _uuid.v4(), title: text, isCompleted: false),
        );
        _subTaskInputController.clear();
      });
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      HapticFeedback.lightImpact();
      widget.onSave(
        _titleController.text.trim(),
        _descController.text.trim(),
        _selectedDueDate,
        _selectedPriority,
        _selectedCategory,
        _subTasks,
        _isPinned,
        _selectedRecurrence,
      );
      Navigator.of(context).pop();
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return const Color(0xFFDC2626);
      case TaskPriority.medium:
        return const Color(0xFFD97706);
      case TaskPriority.low:
        return const Color(0xFF059669);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.taskToEdit != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 20,
        right: 20,
        top: 14,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'Edit Task' : 'New Task',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  if (_selectedDueDate != null)
                    InkWell(
                      onTap: () => setState(() => _selectedDueDate = null),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.close_rounded,
                              size: 12,
                              color: Colors.red,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Clear Date',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _titleController,
                autofocus: !isEditing,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: 'What needs to be done?',
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF8FAFC),
                  prefixIcon: Icon(
                    Icons.check_circle_outline_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    InkWell(
                      onTap: _pickDueDate,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _selectedDueDate != null
                              ? theme.colorScheme.primary.withOpacity(0.12)
                              : (isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedDueDate != null
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 13,
                              color: _selectedDueDate != null
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outline,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _selectedDueDate == null
                                  ? 'Due Date'
                                  : '${_selectedDueDate!.month}/${_selectedDueDate!.day}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _selectedDueDate != null
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    PopupMenuButton<TaskPriority>(
                      initialValue: _selectedPriority,
                      onSelected: (p) => setState(() => _selectedPriority = p),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(
                            _selectedPriority,
                          ).withOpacity(0.10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 3.5,
                              backgroundColor: _getPriorityColor(
                                _selectedPriority,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _selectedPriority.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _getPriorityColor(_selectedPriority),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, size: 16),
                          ],
                        ),
                      ),
                      itemBuilder: (context) => TaskPriority.values.map((p) {
                        return PopupMenuItem(
                          value: p,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 3.5,
                                backgroundColor: _getPriorityColor(p),
                              ),
                              const SizedBox(width: 8),
                              Text(p.label),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(width: 8),

                    PopupMenuButton<TaskCategory>(
                      initialValue: _selectedCategory,
                      onSelected: (c) => setState(() => _selectedCategory = c),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.folder_outlined,
                              size: 14,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _selectedCategory.label,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down, size: 16),
                          ],
                        ),
                      ),
                      itemBuilder: (context) => TaskCategory.values.map((c) {
                        return PopupMenuItem(value: c, child: Text(c.label));
                      }).toList(),
                    ),
                  ],
                ),
              ),

              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(
                      () => _showAdvancedDetails = !_showAdvancedDetails,
                    );
                  },
                  icon: Icon(
                    _showAdvancedDetails
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                  ),
                  label: Text(
                    _showAdvancedDetails
                        ? 'Hide Details'
                        : 'More Details (Notes, Checklist, Recurrence)',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ),
              ),

              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _descController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Notes and description...',
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF8FAFC),
                        prefixIcon: const Icon(Icons.notes_rounded, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Pin to Top',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            value: _isPinned,
                            onChanged: (val) => setState(() => _isPinned = val),
                          ),
                        ),
                        DropdownButton<TaskRecurrence>(
                          value: _selectedRecurrence,
                          underline: const SizedBox(),
                          items: TaskRecurrence.values.map((r) {
                            return DropdownMenuItem(
                              value: r,
                              child: Text(
                                r.label,
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null)
                              setState(() => _selectedRecurrence = val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _subTaskInputController,
                            decoration: InputDecoration(
                              hintText: 'Add subtask step...',
                              isDense: true,
                              filled: true,
                              fillColor: isDark
                                  ? const Color(0xFF1E293B)
                                  : const Color(0xFFF8FAFC),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onSubmitted: (_) => _addSubTask(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          onPressed: _addSubTask,
                          icon: const Icon(Icons.add, size: 18),
                        ),
                      ],
                    ),

                    if (_subTasks.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      ..._subTasks.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final st = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.subdirectory_arrow_right_rounded,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  st.title,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() => _subTasks.removeAt(idx));
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
                crossFadeState: _showAdvancedDetails
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
              const SizedBox(height: 12),

              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  isEditing ? 'Save Changes' : 'Save Task',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
