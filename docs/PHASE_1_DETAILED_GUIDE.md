# 📘 الدليل الشامل والمفصل للمرحلة الأولى (Phase 1 Guide)
> **عنوان المرحلة:** الأساسيات و Clean Architecture في الذاكرة (In-Memory Core)  
> **الهدف:** فهم كيفية بناء هيكل Clean Architecture كامل ومترابط، إدارة الحالة باستخدام Cubit، وتطبيق الـ CRUD والتراجع (Undo) في الذاكرة قبل ربط أي قاعدة بيانات.

---

## 📑 الفهرس
1. [خريطة تدفق البيانات وهيكل المجلدات](#1-خريطة-تدفق-البيانات-وهيكل-المجلدات)
2. [الاعتماديات المطلوبة (Dependencies)](#2-الاعتماديات-المطلوبة-dependencies)
3. [طبقة النطاق (Domain Layer) - كود وشرح](#3-طبقة-النطاق-domain-layer)
4. [طبقة البيانات (Data Layer) - كود وشرح](#4-طبقة-البيانات-data-layer)
5. [طبقة إدارة الحالة (Cubit & State) - كود وشرح](#5-طبقة-إدارة-الحالة-cubit--state)
6. [طبقة واجهة المستخدم (UI) والتراجع (Undo) - كود وشرح](#6-طبقة-واجهة-المستخدم-ui)
7. [نقطة الانطلاق (main.dart) ودعم اللغة العربية](#7-نقطة-الانطلاق-maindart)
8. [خطوات Git لتسجيل المرحلة باحترافية](#8-خطوات-git-لتسجيل-المرحلة)

---

## 1. خريطة تدفق البيانات وهيكل المجلدات

### قاعدة التبعية (The Dependency Rule):
في Clean Architecture، تعتمد الطبقات الخارجية على الطبقات الداخلية، والقلب هو طبقة **Domain**:
```text
[ Presentation Layer (UI & Cubit) ] ──▶ يستدعي ──▶ [ Domain Layer (Entity & Contract) ]
                                                              ▲
[ Data Layer (Model & Repo Impl)  ] ──▶ يطبق العقد ───────────┘
```

### هيكل المجلدات النهائي للمرحلة الأولى:
```text
lib/
├── core/
│   └── theme/
│       └── app_theme.dart                 # ثيم التطبيق المعتمد على Material 3
│
├── features/
│   └── tasks/
│       ├── domain/                        # طبقة النطاق (Dart نقي 100%)
│       │   ├── entities/
│       │   │   └── task_entity.dart       # كائن المهمة النقي
│       │   └── repositories/
│       │       └── task_repository.dart   # العقد البرمجي (Interface)
│       │
│       ├── data/                          # طبقة البيانات
│       │   ├── models/
│       │   │   └── task_model.dart        # نموذج المهمة (تحويلات ووراثة)
│       │   └── repositories/
│       │       └── in_memory_task_repository_impl.dart # تنفيذ المستودع في الذاكرة
│       │
│       └── presentation/                  # طبقة العرض
│           ├── cubit/
│           │   ├── task_state.dart        # حالات الصفحة (Loading, Loaded, Error)
│           │   └── task_cubit.dart        # متحكم منطق الواجهة
│           ├── pages/
│           │   └── tasks_page.dart        # الشاشة الرئيسية
│           └── widgets/
│               ├── task_item_tile.dart    # عنصر المهمة في القائمة
│               └── task_dialog.dart       # نافذة الإضافة والتعديل
│
└── main.dart                              # نقطة الانطلاق وإعداد الثيم واللغة
```

---

## 2. الاعتماديات المطلوبة (Dependencies)

نضيف الحزم التالية في ملف `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  cupertino_icons: ^1.0.8

  # إدارة الحالة
  flutter_bloc: ^8.1.6

  # مقارنة الكائنات بالقيمة بدلاً من المرجع
  equatable: ^2.0.5

  # توليد معرّفات فريدة تلقائياً للمهام
  uuid: ^4.5.1
```

### لماذا هذه الحزم تحديداً؟
* **`flutter_bloc`**: أداة إدارة الحالة الأكثر طلباً وتنظيماً، وسنستخدم منها نمط `Cubit` لبساطته وقوته.
* **`equatable`**: في دارت، إذا قارنت كائنين `Task(id: 1) == Task(id: 1)` فالنتيجة ستكون `false` لأن المقارنة افتراضياً بالمرجع في الذاكرة (`Reference`). حزمة `equatable` تجعل المقارنة بالقيم (`Values`)، مما يسمح للـ Bloc بإعادة رسم الشاشة فقط عند تغير البيانات فعلياً.
* **`uuid`**: لضمان أن كل مهمة يتم إنشاؤها تأخذ `id` فريد لا يتكرر مثل: `"550e8400-e29b-41d4-a716-446655440000"`.

---

## 3. طبقة النطاق (Domain Layer)

> **القاعدة الذهبية:** هذه الطبقة لا تعرف أي شيء عن Flutter، ولا عن قواعد البيانات (Hive/SQLite)، ولا عن الواجهات. إنها كود Dart نقي يمثل روح التطبيق وقواعد عمله.

### 📄 ملف: `lib/features/tasks/domain/entities/task_entity.dart`
```dart
import 'package:equatable/equatable.dart';

/// يمثل كائن المهمة الأساسي في عالم الأعمال (Business Entity).
/// غير قابل للتعديل (Immutable) لضمان أمان البيانات.
class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;

  const TaskEntity({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createdAt,
  });

  /// دالة لإنشاء نسخة جديدة من المهمة مع تعديل حقول معينة
  /// هذا يضمن مبدأ عدم قابلية التعديل المباشر (Immutability).
  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// تحديد الحقول التي يُبنى عليها فحص التساوي
  @override
  List<Object?> get props => [id, title, description, isCompleted, createdAt];
}
```

---

### 📄 ملف: `lib/features/tasks/domain/repositories/task_repository.dart`
```dart
import '../entities/task_entity.dart';

/// العقد البرمجي (Contract): يحدد "ماذا" نريد من طبقة البيانات
/// دون الخوض في "كيف" تُخزن البيانات (ذاكرة، Hive، سيرفر...).
abstract class TaskRepository {
  /// جلب جميع المهام
  Future<List<TaskEntity>> getTasks();

  /// إضافة مهمة جديدة
  Future<void> addTask(TaskEntity task);

  /// تحديث مهمة موجودة
  Future<void> updateTask(TaskEntity task);

  /// حذف مهمة بواسطة معرفها
  Future<void> deleteTask(String taskId);
}
```

---

## 4. طبقة البيانات (Data Layer)

> وظيفة هذه الطبقة تنفيذ العقود المحددة في طبقة Domain. في المرحلة الأولى، سننفذ المستودع في الذاكرة (`InMemory`) لنتمكن من اختبار الواجهات والتفاعل بسرعة والتأكد من صحة المنطق.

### 📄 ملف: `lib/features/tasks/data/models/task_model.dart`
```dart
import '../../domain/entities/task_entity.dart';

/// النموذج (Model) يرث من الكيان (Entity)،
/// ويضيف إليه دوال التحويل من وإلى البيانات الخام (تجهيزاً لـ Hive في المرحلة 2).
class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    super.description = '',
    super.isCompleted = false,
    required super.createdAt,
  });

  /// إنشاء Model من Entity
  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
    );
  }

  /// تحويل الكائن إلى Map (تمهيداً لتخزينه في Hive بدون build_runner)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// قراءة الكائن من Map
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      isCompleted: (map['isCompleted'] as bool?) ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
```

---

### 📄 ملف: `lib/features/tasks/data/repositories/in_memory_task_repository_impl.dart`
```dart
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';

/// تنفيذ المستودع في الذاكرة المؤقتة (RAM).
/// يساعدنا على اختبار كل الميزات والواجهات قبل ربط أي قاعدة بيانات.
class InMemoryTaskRepositoryImpl implements TaskRepository {
  // قائمة داخلية لحفظ المهام أثناء تشغيل التطبيق
  final List<TaskEntity> _tasks = [];

  @override
  Future<List<TaskEntity>> getTasks() async {
    // محاكاة تأخير زمني بسيط لاختبار حالة التحميل (Loading State)
    await Future.delayed(const Duration(milliseconds: 300));
    // إرجاع نسخة غير قابلة للتعديل لمنع التعديل الخارجي المباشر
    return List.unmodifiable(_tasks);
  }

  @override
  Future<void> addTask(TaskEntity task) async {
    _tasks.add(task);
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final index = _tasks.indexWhere((element) => element.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((element) => element.id == taskId);
  }
}
```

---

## 5. طبقة إدارة الحالة (Cubit & State)

### 📄 ملف: `lib/features/tasks/presentation/cubit/task_state.dart`
```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';

/// الحالات المختلفة لشاشة المهام
abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

/// الحالة الأولية عند فتح التطبيق
class TaskInitial extends TaskState {}

/// حالة جاري تحميل البيانات
class TaskLoading extends TaskState {}

/// حالة نجاح تحميل وعرض المهام
class TaskLoaded extends TaskState {
  final List<TaskEntity> tasks;

  const TaskLoaded({required this.tasks});

  @override
  List<Object?> get props => [tasks];
}

/// حالة حدوث خطأ
class TaskError extends TaskState {
  final String message;

  const TaskError({required this.message});

  @override
  List<Object?> get props => [message];
}
```

---

### 📄 ملف: `lib/features/tasks/presentation/cubit/task_cubit.dart`
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository repository;
  final Uuid _uuid = const Uuid();

  // متغير للاحتفاظ بآخر مهمة تم حذفها لدعم التراجع (Undo)
  TaskEntity? _lastDeletedTask;
  int? _lastDeletedIndex;

  TaskCubit({required this.repository}) : super(TaskInitial());

  /// جلب كافة المهام
  Future<void> loadTasks() async {
    emit(TaskLoading());
    try {
      final tasks = await repository.getTasks();
      emit(TaskLoaded(tasks: tasks));
    } catch (e) {
      emit(TaskError(message: 'فشل في تحميل المهام: ${e.toString()}'));
    }
  }

  /// إضافة مهمة جديدة
  Future<void> addTask({required String title, String description = ''}) async {
    try {
      final newTask = TaskEntity(
        id: _uuid.v4(),
        title: title.trim(),
        description: description.trim(),
        isCompleted: false,
        createdAt: DateTime.now(),
      );

      await repository.addTask(newTask);
      await loadTasks(); // تحديث القائمة بالحالة الجديدة
    } catch (e) {
      emit(TaskError(message: 'فشل في إضافة المهمة: ${e.toString()}'));
    }
  }

  /// تبديل حالة إنجاز المهمة (Done / Not Done)
  Future<void> toggleTaskStatus(TaskEntity task) async {
    try {
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      await repository.updateTask(updatedTask);
      await loadTasks();
    } catch (e) {
      emit(TaskError(message: 'فشل في تحديث حالة المهمة'));
    }
  }

  /// تعديل عنوان ووصف المهمة
  Future<void> editTask({
    required TaskEntity task,
    required String newTitle,
    required String newDescription,
  }) async {
    try {
      final updatedTask = task.copyWith(
        title: newTitle.trim(),
        description: newDescription.trim(),
      );
      await repository.updateTask(updatedTask);
      await loadTasks();
    } catch (e) {
      emit(TaskError(message: 'فشل في تعديل المهمة'));
    }
  }

  /// حذف مهمة مع حفظ بياناتها للتراجع
  Future<void> deleteTask(TaskEntity task) async {
    if (state is TaskLoaded) {
      final currentList = (state as TaskLoaded).tasks;
      _lastDeletedIndex = currentList.indexOf(task);
      _lastDeletedTask = task;

      try {
        await repository.deleteTask(task.id);
        await loadTasks();
      } catch (e) {
        emit(TaskError(message: 'فشل في حذف المهمة'));
      }
    }
  }

  /// التراجع عن الحذف (Undo Delete)
  Future<void> undoDelete() async {
    if (_lastDeletedTask != null) {
      try {
        await repository.addTask(_lastDeletedTask!);
        _lastDeletedTask = null;
        _lastDeletedIndex = null;
        await loadTasks();
      } catch (e) {
        emit(TaskError(message: 'فشل في استعادة المهمة المحذوفة'));
      }
    }
  }
}
```

---

## 6. طبقة واجهة المستخدم (UI)

### 📄 ملف: `lib/features/tasks/presentation/widgets/task_item_tile.dart`
```dart
import 'package:flutter/material.dart';
import '../../domain/entities/task_entity.dart';

class TaskItemTile extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskItemTile({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: task.isCompleted
              ? theme.colorScheme.outlineVariant.withOpacity(0.4)
              : theme.colorScheme.primary.withOpacity(0.2),
        ),
      ),
      color: task.isCompleted
          ? theme.colorScheme.surfaceVariant.withOpacity(0.3)
          : theme.colorScheme.surface,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (_) => onToggle(),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted
                ? theme.colorScheme.outline
                : theme.colorScheme.onSurface,
          ),
        ),
        subtitle: task.description.isNotEmpty
            ? Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  color: task.isCompleted
                      ? theme.colorScheme.outline.withOpacity(0.7)
                      : theme.colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'تعديل',
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'حذف',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 📄 ملف: `lib/features/tasks/presentation/widgets/task_dialog.dart`
```dart
import 'package:flutter/material.dart';
import '../../domain/entities/task_entity.dart';

/// نافذة مخصصة تستخدم للإضافة والتعديل معاً
class TaskDialog extends StatefulWidget {
  final TaskEntity? taskToEdit;
  final Function(String title, String description) onSave;

  const TaskDialog({
    super.key,
    this.taskToEdit,
    required this.onSave,
  });

  @override
  State<TaskDialog> createState() => _TaskDialogState();
}

class _TaskDialogState extends State<TaskDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.taskToEdit?.title ?? '');
    _descController = TextEditingController(text: widget.taskToEdit?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(_titleController.text, _descController.text);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.taskToEdit != null;

    return AlertDialog(
      title: Text(isEditing ? 'تعديل المهمة' : 'إضافة مهمة جديدة'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'عنوان المهمة *',
                  hintText: 'اكتب عنوان المهمة هنا...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'يرجى كتابة عنوان للمهمة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'الوصف (اختياري)',
                  hintText: 'تفاصيل إضافية عن المهمة...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(isEditing ? 'حفظ التعديل' : 'إضافة'),
        ),
      ],
    );
  }
}
```

---

### 📄 ملف: `lib/features/tasks/presentation/pages/tasks_page.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task_entity.dart';
import '../cubit/task_cubit.dart';
import '../cubit/task_state.dart';
import '../widgets/task_dialog.dart';
import '../widgets/task_item_tile.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => TaskDialog(
        onSave: (title, description) {
          context.read<TaskCubit>().addTask(title: title, description: description);
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, TaskEntity task) {
    showDialog(
      context: context,
      builder: (dialogContext) => TaskDialog(
        taskToEdit: task,
        onSave: (title, description) {
          context.read<TaskCubit>().editTask(
                task: task,
                newTitle: title,
                newDescription: description,
              );
        },
      ),
    );
  }

  void _handleDelete(BuildContext context, TaskEntity task) {
    final cubit = context.read<TaskCubit>();
    cubit.deleteTask(task);

    // إظهار SnackBar مع زر التراجع (Undo)
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حذف "${task.title}"'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'تراجع',
          textColor: Theme.of(context).colorScheme.inversePrimary,
          onPressed: () {
            cubit.undoDelete();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مهامي اليومية'),
        centerTitle: true,
      ),
      body: BlocConsumer<TaskCubit, TaskState>(
        listener: (context, state) {
          if (state is TaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TaskLoaded) {
            final tasks = state.tasks;

            if (tasks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.checklist_rounded,
                      size: 80,
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد مهام حالياً',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text('اضغط على زر (+) في الأسفل لإضافة مهمتك الأولى'),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskItemTile(
                  task: task,
                  onToggle: () => context.read<TaskCubit>().toggleTaskStatus(task),
                  onEdit: () => _showEditDialog(context, task),
                  onDelete: () => _handleDelete(context, task),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('مهمة جديدة'),
      ),
    );
  }
}
```

---

## 7. نقطة الانطلاق (main.dart) ودعم اللغة العربية

### 📄 ملف: `lib/main.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'features/tasks/data/repositories/in_memory_task_repository_impl.dart';
import 'features/tasks/domain/repositories/task_repository.dart';
import 'features/tasks/presentation/cubit/task_cubit.dart';
import 'features/tasks/presentation/pages/tasks_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ننشئ المستودع ونمرره إلى الـ Cubit
    final TaskRepository taskRepository = InMemoryTaskRepositoryImpl();

    return RepositoryProvider.value(
      value: taskRepository,
      child: BlocProvider(
        create: (context) => TaskCubit(repository: taskRepository)..loadTasks(),
        child: MaterialApp(
          title: 'تطبيق المهام',
          debugShowCheckedModeBanner: false,

          // إعداد اتجاه اللغة العربية من اليمين إلى اليسار (RTL)
          locale: const Locale('ar', 'SA'),
          supportedLocales: const [
            Locale('ar', 'SA'),
            Locale('en', 'US'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // ثيم Material 3
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF3F51B5), // لون نيلي أنيق
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF3F51B5),
              brightness: Brightness.dark,
            ),
          ),
          themeMode: ThemeMode.system,

          home: const TasksPage(),
        ),
      ),
    );
  }
}
```

---

## 8. خطوات Git لتسجيل المرحلة باحترافية

لتطبيق الالتزامات الذرية (Atomic Commits)، يُفضل تقسيم تسجيل عمل المرحلة كالتالي:

1. **إعداد الحزم والمجلدات:**
   ```bash
   git add pubspec.yaml
   git commit -m "chore: add flutter_bloc, equatable, and uuid dependencies"
   ```
2. **طبقة النطاق (Domain):**
   ```bash
   git add lib/features/tasks/domain/
   git commit -m "feat(domain): add task entity and repository contract"
   ```
3. **طبقة البيانات (Data):**
   ```bash
   git add lib/features/tasks/data/
   git commit -m "feat(data): add task model and in-memory repository implementation"
   ```
4. **طبقة العرض والواجهات (Presentation):**
   ```bash
   git add lib/features/tasks/presentation/ lib/main.dart
   git commit -m "feat(presentation): add task cubit, states, tasks page, and undo snackbar"
   ```
5. **دمج الفرع بعد التأكد من التجربة والتشغيل:**
   ```bash
   git checkout develop
   git merge feature/phase-1-basics
   ```

---

### ملخص المفاهيم التي رسخناها في هذه المرحلة:
1. **فصل المسؤوليات (Separation of Concerns):** كل ملف له وظيفة واحدة واضحة.
2. **عزل طبقة الـ Domain:** عدم استيراد Flutter في Domain يجعل الكود قابلاً للاختبار والنقل لأي مكان.
3. **عدم قابلية التعديل (Immutability):** استخدام `copyWith` وتجنب تعديل الكائنات بشكل مباشر.
4. **دورة حياة الحالة في Cubit:** كيف نتنقل بين `TaskLoading` ⬅️ `TaskLoaded` ⬅️ `TaskError`.
5. **التراجع الذكي (Undo):** كيف نحتفظ بالنسخة المحذوفة مؤقتاً في الذاكرة لنعيد إدراجها إذا ضغط المستخدم "تراجع".
