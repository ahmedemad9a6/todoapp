import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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
  )
  onSave;

  const TaskBottomSheet({super.key, this.taskToEdit, required this.onSave});

  @override
  State<TaskBottomSheet> createState() => _TaskBottomSheetState();
}

class _TaskBottomSheetState extends State<TaskBottomSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  final _formKey = GlobalKey<FormState>();

  DateTime? _selectedDueDate;
  late TaskPriority _selectedPriority;
  late TaskCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    final task = widget.taskToEdit;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descController = TextEditingController(text: task?.description ?? '');
    _selectedDueDate = task?.dueDate;
    _selectedPriority = task?.priority ?? TaskPriority.medium;
    _selectedCategory = task?.category ?? TaskCategory.personal;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
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

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSave(
        _titleController.text,
        _descController.text,
        _selectedDueDate,
        _selectedPriority,
        _selectedCategory,
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
              // مقبض السحب العلوي
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
                isEditing ? 'تعديل المهمة' : 'مهمة جديدة ✨',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // حقل العنوان
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

              // حقل الوصف
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'ملاحظات وتفاصيل إضافية (اختياري)',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 16),

              // اختيار تاريخ الاستحقاق
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

              // اختيار مستوى الأولوية
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

              // اختيار التصنيف
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
              const SizedBox(height: 24),

              // زر الحفظ
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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
