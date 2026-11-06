<div dir="rtl">

# 📘 الدليل الشامل والمفصل للمرحلة الرابعة (Phase 4 Guide)
> **عنوان المرحلة:** التنظيم والبحث والتصنيف (Organization, Filtering & Search)  
> **الهدف:** الانتقال بتطبيق المهام من مجرد قائمة بسيطة إلى أداة إنتاجية متكاملة؛ من خلال إضافة تواريخ الاستحقاق (`Due Date`)، مستويات الأولوية، تصنيفات المهام، شريط بحث فوري، وفلاتر ذكية لعرض مهام اليوم والمكتملة دون تكرار جلب البيانات من التخزين.

---

## 📑 الفهرس
1. [خريطة التطوير والمفاهيم الهندسية المكتسبة](#1-خريطة-التطوير-والمفاهيم-الهندسية-المكتسبة)
2. [ترقية طبقة النطاق (Domain Layer) - إضافة الأولويات والتصنيفات](#2-ترقية-طبقة-النطاق-domain-layer)
3. [ترقية طبقة البيانات (Data Layer) - الحفظ الآمن في Hive](#3-ترقية-طبقة-البيانات-data-layer)
4. [معمارية الفلترة والبحث في الـ Cubit (دون فقدان القائمة الأصلية)](#4-معمارية-الفلترة-والبحث-في-الـ-cubit)
5. [تطوير واجهة الإضافة (اختيار التاريخ، الأولوية، والتصنيف)](#5-تطوير-واجهة-الإضافة)
6. [بناء مكونات الواجهة الحديثة (Search Bar & Filter Chips)](#6-بناء-مكونات-الواجهة-الحديثة)
7. [تحديث بطاقة المهمة (ModernTaskItem) بالشارات والألوان](#7-تحديث-بطاقة-المهمة-moderntaskitem-بالشارات-والألوان)
8. [بروتوكول Git Flow و Commits المرحلة](#8-بروتوكول-git-flow-و-commits-المرحلة)
9. [معيار الانتهاء والاختبار العملي (Done When)](#9-معيار-الانتهاء-والاختبار-العملي)

---

## 1. خريطة التطوير والمفاهيم الهندسية المكتسبة

في هذه المرحلة، سنواجه تحديات واقعية يمر بها كل مطور برمجيات محترف:

```text
┌────────────────────────────────────────────────────────────────────────┐
│                        المفاهيم الهندسية للمرحلة 4                    │
├───────────────────────┬────────────────────────────────────────────────┤
│ 1. تطور النماذج       │ إضافة حقول جديدة مع حماية البيانات القديمة في    │
│    (Model Evolution)  │ قاعدة البيانات من الانهيار (Backward Compat).  │
├───────────────────────┼────────────────────────────────────────────────┤
│ 2. الـ In-Memory      │ تصفية وبحث لحظي في الذاكرة لسرعة استجابة 60fps  │
│    Filtering          │ دون الحاجة لطلب قراءة جديدة من القرص الصلب.   │
├───────────────────────┼────────────────────────────────────────────────┤
│ 3. مقارنة التواريخ     │ التعامل الدقيق مع الوقت (تحديد مهام اليوم،      │
│    (DateTime Handling)│ المهام المتأخرة، وتنسيق الوقت بصرياً).         │
└───────────────────────┴────────────────────────────────────────────────┘
```

---

## 2. ترقية طبقة النطاق (Domain Layer)

سنضيف تصنيفات محددة (`Enums`) تمثل الأولوية ونوع التصنيف، ونحدث كائن المهمة.

### أ) تعريف الـ Enums في ملف:  
📂 `lib/features/tasks/domain/task_enums.dart`

```dart
/// مستويات الأولوية
enum TaskPriority {
  low('منخفضة', 1),
  medium('متوسطة', 2),
  high('مرتفعة', 3);

  final String label;
  final int value;
  const TaskPriority(this.label, this.value);
}

/// تصنيفات المهام
enum TaskCategory {
  personal('شخصي', '👤'),
  work('عمل', '💼'),
  study('دراسة', '📚'),
  shopping('تسوق', '🛒'),
  other('عام', '📌');

  final String label;
  final String icon;
  const TaskCategory(this.label, this.icon);
}

/// أنواع الفلترة لحالة المهمة
enum TaskFilterStatus {
  all('الكل'),
  pending('قيد الإنجاز'),
  completed('المكتملة'),
  today('اليوم');

  final String label;
  const TaskFilterStatus(this.label);
}
```

---

### ب) تحديث كائن المهمة النقي:  
📂 `lib/features/tasks/domain/task_entity.dart`

```dart
import 'package:equatable/equatable.dart';
import 'package:todoapp/features/tasks/domain/task_enums.dart';

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? dueDate;             // 👈 تاريخ الاستحقاق (اختياري)
  final TaskPriority priority;         // 👈 مستوى الأولوية
  final TaskCategory category;         // 👈 التصنيف

  const TaskEntity({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.category = TaskCategory.personal,
  });

  /// فحص هل المهمة مستحقة اليوم
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  /// فحص هل المهمة متأخرة عن موعدها
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return due.isBefore(today);
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
      ];
}
```

---

## 3. ترقية طبقة البيانات (Data Layer)

يجب أن نضمن أن قراءة البيانات القديمة المخزنة سابقاً في Hive لن تتسبب بأي خطأ حتى لو لم تكن تحتوي على الحقول الجديدة (**Backward Compatibility**).

### تحديث نموذج المهمة:  
📂 `lib/features/tasks/data/task_model.dart`

```dart
import 'package:todoapp/features/tasks/domain/task_entity.dart';
import 'package:todoapp/features/tasks/domain/task_enums.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    super.description = '',
    super.isCompleted = false,
    required super.createdAt,
    super.dueDate,
    super.priority = TaskPriority.medium,
    super.category = TaskCategory.personal,
  });

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      isCompleted: entity.isCompleted,
      createdAt: entity.createdAt,
      dueDate: entity.dueDate,
      priority: entity.priority,
      category: entity.category,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority.name,       // حفظ كنص (low, medium, high)
      'category': category.name,       // حفظ كنص (personal, work...)
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      isCompleted: (map['isCompleted'] as bool?) ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate'] as String) : null,
      // قراءة آمنة مع قيمة افتراضية للبيانات القديمة
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      category: TaskCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => TaskCategory.personal,
      ),
    );
  }
}
```

---

## 4. معمارية الفلترة والبحث في الـ Cubit

### الفكرة الهندسية:
لا نريد جلب البيانات من Hive في كل مرة يبحث فيها المستخدم، بل نحتفظ في الـ State بـ:
1. **`allTasks`**: القائمة الكاملة المجلوبة من قاعدة البيانات (المصدر الحقيقي للبيانات).
2. **`filteredTasks`**: القائمة الناتجة بعد تطبيق شروط البحث والفلترة النشطة (وهي التي تُعرض في الواجهة).
3. معايير الفلترة الحالية: `searchQuery`, `statusFilter`, `selectedCategory`.

```text
قاعدة بيانات Hive ──▶ allTasks (القائمة الأصلية)
                             │
                      تطبيق الفلترة (Query + Status + Category)
                             ▼
                      filteredTasks ──▶ الواجهة (ListView)
```

---

### أ) تحديث حالات الصفحة:  
📂 `lib/features/tasks/presentation/cubit/task_state.dart`

```dart
import 'package:equatable/equatable.dart';
import 'package:todoapp/features/tasks/domain/task_entity.dart';
import 'package:todoapp/features/tasks/domain/task_enums.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoadedSuccessfully extends TaskState {
  final List<TaskEntity> allTasks;
  final List<TaskEntity> filteredTasks;
  final String searchQuery;
  final TaskFilterStatus statusFilter;
  final TaskCategory? categoryFilter;

  const TaskLoadedSuccessfully({
    required this.allTasks,
    required this.filteredTasks,
    this.searchQuery = '',
    this.statusFilter = TaskFilterStatus.all,
    this.categoryFilter,
  });

  TaskLoadedSuccessfully copyWith({
    List<TaskEntity>? allTasks,
    List<TaskEntity>? filteredTasks,
    String? searchQuery,
    TaskFilterStatus? statusFilter,
    TaskCategory? categoryFilter,
    bool clearCategoryFilter = false,
  }) {
    return TaskLoadedSuccessfully(
      allTasks: allTasks ?? this.allTasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter ?? this.statusFilter,
      categoryFilter: clearCategoryFilter ? null : (categoryFilter ?? this.categoryFilter),
    );
  }

  @override
  List<Object?> get props => [
        allTasks,
        filteredTasks,
        searchQuery,
        statusFilter,
        categoryFilter,
      ];
}

class TaskError extends TaskState {
  final String message;

  const TaskError({required this.message});

  @override
  List<Object?> get props => [message];
}
```

---

### ب) تحديث الـ Cubit بمنطق الفلترة اللحظي:  
📂 `lib/features/tasks/presentation/cubit/task_cubit.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:todoapp/features/tasks/domain/task_entity.dart';
import 'package:todoapp/features/tasks/domain/task_enums.dart';
import 'package:todoapp/features/tasks/domain/task_repository.dart';
import 'package:todoapp/features/tasks/presentation/cubit/task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskRepository repository;
  final _uuid = const Uuid();

  TaskEntity? _lastDeletedTask;

  TaskCubit({required this.repository}) : super(TaskInitial());

  /// جلب المهام وتطبيق الفلاتر الحالية
  Future<void> loadTasks() async {
    try {
      emit(TaskLoading());
      final tasks = await repository.getTasks();
      final filtered = _applyFilters(
        tasks: tasks,
        query: '',
        status: TaskFilterStatus.all,
        category: null,
      );
      emit(TaskLoadedSuccessfully(
        allTasks: tasks,
        filteredTasks: filtered,
      ));
    } catch (e) {
      emit(TaskError(message: 'فشل في تحميل المهام: $e'));
    }
  }

  /// البحث الفوري بالنص
  void search(String query) {
    if (state is TaskLoadedSuccessfully) {
      final current = state as TaskLoadedSuccessfully;
      final filtered = _applyFilters(
        tasks: current.allTasks,
        query: query,
        status: current.statusFilter,
        category: current.categoryFilter,
      );
      emit(current.copyWith(searchQuery: query, filteredTasks: filtered));
    }
  }

  /// فلترة بحالة المهمة (الكل / قيد الإنجاز / مكتملة / اليوم)
  void setStatusFilter(TaskFilterStatus status) {
    if (state is TaskLoadedSuccessfully) {
      final current = state as TaskLoadedSuccessfully;
      final filtered = _applyFilters(
        tasks: current.allTasks,
        query: current.searchQuery,
        status: status,
        category: current.categoryFilter,
      );
      emit(current.copyWith(statusFilter: status, filteredTasks: filtered));
    }
  }

  /// فلترة بنوع التصنيف (عمل / دراسة / شخصي...)
  void setCategoryFilter(TaskCategory? category) {
    if (state is TaskLoadedSuccessfully) {
      final current = state as TaskLoadedSuccessfully;
      final isSame = current.categoryFilter == category;
      final newCategory = isSame ? null : category; // الضغط عليه مجدداً يلغي التحديد

      final filtered = _applyFilters(
        tasks: current.allTasks,
        query: current.searchQuery,
        status: current.statusFilter,
        category: newCategory,
      );
      emit(current.copyWith(
        categoryFilter: newCategory,
        clearCategoryFilter: newCategory == null,
        filteredTasks: filtered,
      ));
    }
  }

  /// الدالة المركزية لتطبيق الفلاتر والبحث
  List<TaskEntity> _applyFilters({
    required List<TaskEntity> tasks,
    required String query,
    required TaskFilterStatus status,
    required TaskCategory? category,
  }) {
    return tasks.where((task) {
      // 1. فلتر البحث بالنص في العنوان أو الوصف
      final matchesQuery = query.isEmpty ||
          task.title.toLowerCase().contains(query.toLowerCase()) ||
          task.description.toLowerCase().contains(query.toLowerCase());

      // 2. فلتر الحالة
      bool matchesStatus = true;
      switch (status) {
        case TaskFilterStatus.all:
          matchesStatus = true;
          break;
        case TaskFilterStatus.pending:
          matchesStatus = !task.isCompleted;
          break;
        case TaskFilterStatus.completed:
          matchesStatus = task.isCompleted;
          break;
        case TaskFilterStatus.today:
          matchesStatus = task.isDueToday;
          break;
      }

      // 3. فلتر التصنيف
      final matchesCategory = category == null || task.category == category;

      return matchesQuery && matchesStatus && matchesCategory;
    }).toList();
  }

  /// إضافة مهمة مع الحقول الجديدة
  Future<void> addTask({
    required String title,
    required String description,
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
    TaskCategory category = TaskCategory.personal,
  }) async {
    try {
      final newTask = TaskEntity(
        id: _uuid.v4(),
        title: title.trim(),
        description: description.trim(),
        createdAt: DateTime.now(),
        dueDate: dueDate,
        priority: priority,
        category: category,
      );
      await repository.addTask(newTask);
      await _refreshWithCurrentFilters();
    } catch (e) {
      emit(const TaskError(message: 'فشل في إضافة المهمة'));
    }
  }

  /// تبديل حالة الإنجاز
  Future<void> toggleTaskStatus(TaskEntity task) async {
    try {
      final updated = task.copyWith(isCompleted: !task.isCompleted);
      await repository.updateTask(updated);
      await _refreshWithCurrentFilters();
    } catch (e) {
      emit(const TaskError(message: 'فشل في تحديث حالة المهمة'));
    }
  }

  /// تعديل مهمة
  Future<void> editTask({
    required TaskEntity task,
    required String newTitle,
    required String newDescription,
    DateTime? newDueDate,
    TaskPriority? newPriority,
    TaskCategory? newCategory,
  }) async {
    try {
      final updated = task.copyWith(
        title: newTitle.trim(),
        description: newDescription.trim(),
        dueDate: newDueDate,
        priority: newPriority,
        category: newCategory,
      );
      await repository.updateTask(updated);
      await _refreshWithCurrentFilters();
    } catch (e) {
      emit(const TaskError(message: 'فشل في تعديل المهمة'));
    }
  }

  /// حذف مهمة
  Future<void> deleteTask(TaskEntity task) async {
    try {
      _lastDeletedTask = task;
      await repository.deleteTask(task.id);
      await _refreshWithCurrentFilters();
    } catch (e) {
      emit(const TaskError(message: 'فشل في حذف المهمة'));
    }
  }

  /// تراجع عن الحذف
  Future<void> undoDelete() async {
    if (_lastDeletedTask != null) {
      try {
        await repository.addTask(_lastDeletedTask!);
        _lastDeletedTask = null;
        await _refreshWithCurrentFilters();
      } catch (e) {
        emit(const TaskError(message: 'فشل في استعادة المهمة'));
      }
    }
  }

  /// إعادة تحميل مع الحفاظ على الفلاتر المحددة حالياً
  Future<void> _refreshWithCurrentFilters() async {
    if (state is TaskLoadedSuccessfully) {
      final current = state as TaskLoadedSuccessfully;
      final tasks = await repository.getTasks();
      final filtered = _applyFilters(
        tasks: tasks,
        query: current.searchQuery,
        status: current.statusFilter,
        category: current.categoryFilter,
      );
      emit(current.copyWith(allTasks: tasks, filteredTasks: filtered));
    } else {
      await loadTasks();
    }
  }
}
```

---

## 5. تطوير واجهة الإضافة (ModalBottomSheet)

سنقوم بترقية ورقة الإضافة لدعم اختيار:
1. **تاريخ الاستحقاق (`dueDate`):** عبر `showDatePicker`.
2. **مستوى الأولوية:** خيارات ملونة (منخفضة 🟢 / متوسطة 🟡 / مرتفعة 🔴).
3. **التصنيف:** أيقونات لاختيار تصنيف المهمة (عمل، دراسة، شخصي...).

### التحديث في: `lib/features/tasks/presentation/widgets/task_bottom_sheet.dart`:
* إضافة منتقي التاريخ مع زر إزالة التاريخ.
* إضافة `SegmentedButton` أو شرائح لاختيار الأولوية والتصنيف بسهولة وجمال بصري.

---

## 6. بناء مكونات الواجهة الحديثة

سنبني مكونات منظمة لعرض شريط البحث وشرائح الفلترة:

### أ) شريط البحث وشريط الفلترة:  
📂 `lib/features/tasks/presentation/widgets/task_filter_bar.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/features/tasks/domain/task_enums.dart';
import 'package:todoapp/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:todoapp/features/tasks/presentation/cubit/task_state.dart';

class TaskFilterBar extends StatelessWidget {
  const TaskFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TaskCubit>().state;
    if (state is! TaskLoadedSuccessfully) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Column(
      children: [
        // 1. شريط البحث
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SearchBar(
            hintText: 'ابحث عن مهمة...',
            leading: const Icon(Icons.search_rounded),
            elevation: const WidgetStatePropertyAll(0),
            backgroundColor: WidgetStatePropertyAll(
              theme.colorScheme.surfaceVariant.withOpacity(0.35),
            ),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (val) => context.read<TaskCubit>().search(val),
          ),
        ),

        // 2. شريط فلترة الحالة (الكل / قيد الإنجاز / المكتملة / اليوم)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: TaskFilterStatus.values.map((status) {
              final isSelected = state.statusFilter == status;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: FilterChip(
                  label: Text(status.label),
                  selected: isSelected,
                  onSelected: (_) =>
                      context.read<TaskCubit>().setStatusFilter(status),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
```

---

## 7. تحديث بطاقة المهمة بالشارات والألوان

سنضيف إلى [`ModernTaskItem`](file:///home/ahmed/Desktop/Ahmed%20Flutter/toDoApp/todoapp/lib/features/tasks/presentation/widgets/modern_task_item.dart):
* **شارة الأولوية:** نقطة أو شارة بلون مميز (أحمر للمرتفعة، برتقالي للمتوسطة، أخضر للمنخفضة).
* **أيقونة التصنيف:** رمز تعبيري أو أيقونة تعبر عن (عمل 💼 / دراسة 📚).
* **تاريخ الاستحقاق والتنبيه عند التأخر:**
  * إذا كانت المهمة متأخرة عن موعدها تظهر باللون الأحمر التحذيري ⚠️.
  * إذا كانت مستحقة اليوم تظهر مع شارة "اليوم".

---

## 8. بروتوكول Git Flow و Commits المرحلة

```bash
# 1. التحديث ودمج فرع المرحلة الثالثة
git checkout develop
git merge feature/phase-3-ui-ux

# 2. إنشاء فرع المرحلة الرابعة
git checkout -b feature/phase-4-filtering-search

# 3. بعد ترقية النماذج و Enums:
git add lib/features/tasks/domain/ lib/features/tasks/data/
git commit -m "feat(domain): add task priority, category enums, and update task model"

# 4. بعد تطبيق الفلترة في الـ Cubit:
git add lib/features/tasks/presentation/cubit/
git commit -m "feat(cubit): implement in-memory search and multi-criteria filtering"

# 5. بعد تحديث الواجهات وشريط البحث:
git add lib/features/tasks/presentation/widgets/ lib/features/tasks/presentation/pages/
git commit -m "feat(ui): add search bar, filter chips, and priority badges"
```

---

## 9. معيار الانتهاء والاختبار العملي (Done When)

تعتبر المرحلة الرابعة مكتملة بنجاح عند استيفاء الاختبارات التالية:
1. **اختبار الإضافة:** إضافة مهمة جديدة وتحديد تاريخ استحقاق وأولوية مرتفعة وتصنيف "عمل".
2. **اختبار البحث:** كتابة حرف أو كلمة في شريط البحث وملاحظة فلترة القائمة فورياً بدون أي تأخير.
3. **اختبار فلاتر الحالة:** الضغط على شريحة "المكتملة" أو "اليوم" ورؤية تصفية المهام بدقة.
4. **اختبار بقاء البيانات:** إغلاق التطبيق وإعادة فتحه، للتأكد من أن المهام الجديدة والقديمة تظهر بأولوياتها وتواريخها وتصنيفاتها المحفوظة في Hive دون أخطاء.

---

🎯 **الخطوة التالية بعد إتمام هذه المرحلة:** الانتقال إلى **المرحلة 5: التذكيرات والإيماءات الذكية (Reminders & Gestures)** لجدولة الإشعارات المحلية وتفعيل السحب الحركي للحذف والإنجاز (`Dismissible`).

</div>

