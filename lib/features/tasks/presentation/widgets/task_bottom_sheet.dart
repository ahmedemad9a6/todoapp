import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import 'package:todoapp/features/tasks/domain/sub_task_entity.dart';
import 'package:todoapp/features/tasks/domain/task_entity.dart';
import 'package:todoapp/features/tasks/domain/task_enums.dart';

class TaskBottomSheet extends StatefulWidget {
  final TaskEntity? taskToEdit;
  // إن وُجد، نكون في وضع "التعديل"، وإن كان null نكون في وضع "الإضافة"
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
  onSave; // دالة الحفظ التي تُمرر البيانات المعدلة للواجهة الرئيسية والـ Cubit

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
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    final task = widget.taskToEdit;
    // تعبئة البيانات مسبقاً إذا كنا في وضع تعديل مهمة حالية
    _titleController = TextEditingController(text: task?.title ?? '');
    _descController = TextEditingController(text: task?.description ?? '');
    _subTaskInputController = TextEditingController();
    _selectedDueDate = task?.dueDate;
    _selectedPriority = task?.priority ?? TaskPriority.medium;
    _selectedCategory = task?.category ?? TaskCategory.personal;
    _subTasks = List.from(task?.subTasks ?? []);
    _isPinned = task?.isPinned ?? false;
    _selectedRecurrence = task?.recurrence ?? TaskRecurrence.none;
  }

  @override
  void dispose() {
    // التخلص من المتحكمات لمنع تسرب الذاكرة (Memory Leaks)
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
      locale: const Locale('ar', 'SA'),
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
      widget.onSave(
        _titleController.text,
        _descController.text,
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
    final isEditing = widget.taskToEdit != null;

    return Padding(
      // مراعاة ارتفاع لوحة المفاتيح التلقائي عبر viewInsets.bottom
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 16,
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
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              Text(
                isEditing ? 'تعديل المهمة' : 'إضافة مهمة',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleController,
                autofocus: !isEditing,
                decoration: const InputDecoration(
                  hintText: 'عنوان المهمة...',
                  prefixIcon: Icon(Icons.task_alt_rounded),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'يرجى إدخال عنوان للمهمة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'ملاحظات وتفاصيل إضافية (اختياري)',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDueDate,
                      icon: const Icon(Icons.calendar_today_rounded, size: 18),
                      label: Text(
                        _selectedDueDate == null
                            ? 'تحديد موعد الاستحقاق'
                            : 'الموعد: ${_selectedDueDate!.year}/${_selectedDueDate!.month}/${_selectedDueDate!.day}',
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  if (_selectedDueDate != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'إلغاء التاريخ',
                      icon: const Icon(Icons.close_rounded, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _selectedDueDate = null;
                        });
                      },
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              Text(
                'مستوى الأولوية:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<TaskPriority>(
                segments: TaskPriority.values.map((priority) {
                  final color = _getPriorityColor(priority);
                  return ButtonSegment<TaskPriority>(
                    value: priority,
                    label: Text(priority.label),
                    icon: Icon(Icons.flag_rounded, color: color, size: 18),
                  );
                }).toList(),
                selected: {_selectedPriority},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _selectedPriority = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 16),

              Text(
                'التصنيف:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: TaskCategory.values.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(
                        avatar: Text(cat.icon),
                        label: Text(cat.label),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'تكرار المهمة (بناء العادات):',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: TaskRecurrence.values.map((rec) {
                    final isSelected = _selectedRecurrence == rec;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(
                        avatar: Text(rec.icon),
                        label: Text(rec.label),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedRecurrence = rec;
                            });
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // خيار تثبيت المهمة في القمة (Pinned Task)
              Container(
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(
                    0.35,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: SwitchListTile(
                  secondary: const Icon(
                    Icons.push_pin_rounded,
                    color: Colors.amber,
                  ),
                  title: const Text(
                    'تثبيت في القمة ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'تظهر هذه المهمة دائماً في أعلى القائمة',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _isPinned,
                  onChanged: (val) {
                    setState(() {
                      _isPinned = val;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'المهام الفرعية (Checklist):',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _subTaskInputController,
                      decoration: const InputDecoration(
                        hintText: 'إضافة خطوة فرعية...',
                        isDense: true,
                        prefixIcon: Icon(
                          Icons.subdirectory_arrow_right_rounded,
                        ),
                      ),
                      onSubmitted: (_) => _addSubTask(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: _addSubTask,
                    icon: const Icon(Icons.add_rounded),
                    tooltip: 'إضافة الخطوة',
                  ),
                ],
              ),

              if (_subTasks.isNotEmpty) ...[
                const SizedBox(height: 10),
                Column(
                  children: List.generate(_subTasks.length, (index) {
                    final item = _subTasks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(
                            0.3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline_rounded,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.title,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  _subTasks.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],

              const SizedBox(height: 24),

              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  isEditing ? 'حفظ التعديلات' : 'إضافة المهمة',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
