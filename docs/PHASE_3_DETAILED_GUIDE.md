<div dir="rtl">

# 📘 الدليل الشامل والمفصل للمرحلة الثالثة (Phase 3 Guide)
> **عنوان المرحلة:** التصميم العصري وتجربة المستخدم (Modern UI/UX & Material 3)  
> **الهدف:** تحويل التطبيق من واجهة تقليدية بسيطة إلى تطبيق فائق الجمال والاحترافية، باعتماد أحدث معايير **Material 3**، نظام ألوان متناسق، خط عربي عصري، دعم كامل للوضع الليلي، واستبدال النوافذ التقليدية بأوراق سفلية حديثة (`ModalBottomSheet`).

---

## 📑 الفهرس
1. [الرؤية التصميمية للمرحلة وما سنتعلمه](#1-الرؤية-التصميمية-للمرحلة-وما-سنتعلمه)
2. [الاعتماديات الجديدة المطلوبة (Dependencies)](#2-الاعتماديات-الجديدة-المطلوبة-dependencies)
3. [بناء نظام الثيم المركزي (AppTheme & ColorScheme)](#3-بناء-نظام-الثيم-المركزي-apptheme--colorscheme)
4. [إدارة الوضع الليلي والنهاري (Theme Cubit)](#4-إدارة-الوضع-الليلي-والنهاري-theme-cubit)
5. [بناء نافذة الإضافة والتعديل السفلية (ModalBottomSheet)](#5-بناء-نافذة-الإضافة-والتعديل-السفلية-modalbottomsheet)
6. [تصميم بطاقة المهمة العصرية (Modern Task Card)](#6-تصميم-بطاقة-المهمة-العصرية-modern-task-card)
7. [تصميم حالة القائمة الفارغة المبتكرة (Empty State)](#7-تصميم-حالة-القائمة-الفارغة-المبتكرة-empty-state)
8. [تحديث الصفحة الرئيسية (TasksPage) ونقطة الانطلاق (main.dart)](#8-تحديث-الصفحة-الرئيسية-taskspage-ونقطة-الانطلاق-maindart)
9. [بروتوكول Git Flow و Commits المرحلة](#9-بروتوكول-git-flow-و-commits-المرحلة)
10. [معيار الانتهاء والاختبار البصري (Done When)](#10-معيار-الانتهاء-والاختبار-البصري-done-when)

---

## 1. الرؤية التصميمية للمرحلة وما سنتعلمه

في المعمارية الهندسية النظيفة، التغيير البصري لا يمس نهائياً منطق العمل (`Domain Layer`) ولا طبقة البيانات (`Data Layer`).  
كل ما سنقوم به يقع داخل:
* `lib/core/theme/`: لضبط الهوية البصرية الموحدة.
* `lib/features/tasks/presentation/`: لترقية المكونات والشاشات.

```text
┌────────────────────────────────────────────────────────┐
│                   نظام المظهر الجديد                   │
├──────────────────────────┬─────────────────────────────┤
│ الوضع النهاري (Light)    │ ألوان منعشة، تباين مريح للعين │
│ الوضع الليلي (Dark)     │ خلفيات داكنة عميقة توفر الطاقة│
│ الخط الطباعي (Typography)│ خط Cairo العربي الاحترافي   │
│ التفاعل (Interactions)   │ ModalBottomSheet ناعم وسريع │
└──────────────────────────┴─────────────────────────────┘
```

---

## 2. الاعتماديات الجديدة المطلوبة (Dependencies)

نضيف حزمة **`google_fonts`** للوصول الفوري إلى أجمل الخطوط العربية الحديثة بدون الحاجة لتنزيل وتضمين ملفات الخطوط يدوياً في مجلد assets:

### الإضافة في `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  cupertino_icons: ^1.0.8

  # إدارة الحالة والكيانات
  flutter_bloc: ^9.1.1
  equatable: ^3.0.0
  uuid: ^4.6.0

  # التخزين المحلي
  hive_ce: ^2.22.0
  hive_ce_flutter: ^2.3.4

  # الخطوط العصرية (المرحلة 3)
  google_fonts: ^6.2.1
```

*(قم بحفظ الملف ثم تنفيذ `flutter pub get`)*.

---

## 3. بناء نظام الثيم المركزي (AppTheme & ColorScheme)

سننشئ ملف الثيم المركزي داخل المجلد المخصص للمشروع:  
📂 `lib/core/theme/app_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // اللون الأساسي المميز (Indigo عصري)
  static const Color primarySeedColor = Color(0xFF4F46E5);

  /// ثيم الوضع النهاري (Light Theme)
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primarySeedColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.light().textTheme),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
        color: Colors.white,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }

  /// ثيم الوضع الليلي (Dark Theme)
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primarySeedColor,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF0F172A), // Slate داكن ومريح
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.2),
            width: 1,
          ),
        ),
        color: const Color(0xFF1E293B),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
      ),
    );
  }
}
```

---

## 4. إدارة الوضع الليلي والنهاري (Theme Cubit)

للسماح للمستخدم بالتبديل بين الوضع الليلي والنهاري عبر زر في الـ AppBar، ننشئ كلاس بسيط لإدارة الثيم:  
📂 `lib/core/theme/theme_cubit.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  /// التبديل بين الوضع الليلي والنهاري
  void toggleTheme() {
    if (state == ThemeMode.dark) {
      emit(ThemeMode.light);
    } else {
      emit(ThemeMode.dark);
    }
  }

  /// التحقق إن كان الوضع النشط داكناً
  bool isDark(BuildContext context) {
    if (state == ThemeMode.system) {
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }
    return state == ThemeMode.dark;
  }
}
```

---

## 5. بناء نافذة الإضافة والتعديل السفلية (ModalBottomSheet)

بدلاً من النافذة المنبثقة القديمة في منتصف الشاشة، سنبني ورقة سفلية سلسة وسهلة الوصول بالإبهام:  
📂 `lib/features/tasks/presentation/widgets/task_bottom_sheet.dart`

```dart
import 'package:flutter/material.dart';
import 'package:todoapp/features/tasks/domain/task_entity.dart';

class TaskBottomSheet extends StatefulWidget {
  final TaskEntity? taskToEdit;
  final void Function(String title, String description) onSave;

  const TaskBottomSheet({
    super.key,
    this.taskToEdit,
    required this.onSave,
  });

  @override
  State<TaskBottomSheet> createState() => _TaskBottomSheetState();
}

class _TaskBottomSheetState extends State<TaskBottomSheet> {
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
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSave(_titleController.text, _descController.text);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.taskToEdit != null;

    return Padding(
      // مراعاة ارتفاع لوحة المفاتيح
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // مقبض السحب العلوي (Drag Handle)
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Text(
              isEditing ? 'تعديل المهمة' : 'مهمة جديدة ✨',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'ما الذي تخطط لإنجازه؟',
                prefixIcon: Icon(Icons.task_alt_rounded),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'يرجى كتابة عنوان للمهمة';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'ملاحظات أو تفاصيل إضافية (اختياري)',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
            const SizedBox(height: 20),
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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 6. تصميم بطاقة المهمة العصرية (Modern Task Card)

سنبني بطاقة مهمة جذابة تفاعلية تحتوي على:
* تأثير شطب سلس ولون خافت عند الإنجاز.
* شارة تاريخ الإنشاء بتنسيق جميل.
* أزرار سريعة ومريحة للتعديل والحذف.

📂 `lib/features/tasks/presentation/widgets/modern_task_item.dart`

```dart
import 'package:flutter/material.dart';
import 'package:todoapp/features/tasks/domain/task_entity.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = task.isCompleted;

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
                : theme.colorScheme.primary.withOpacity(0.15),
            width: 1.2,
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Transform.scale(
            scale: 1.15,
            child: Checkbox(
              value: isDone,
              onChanged: (_) => onToggle(),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 13,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(task.createdAt),
                    style: TextStyle(fontSize: 11, color: theme.colorScheme.outline),
                  ),
                ],
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: theme.colorScheme.outline),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
```

---

## 7. تصميم حالة القائمة الفارغة المبتكرة (Empty State)

بدلاً من الشاشة البيضاء الباهتة، نصمم منظراً مرحباً يشجع المستخدم على البدء:  
📂 `lib/features/tasks/presentation/widgets/empty_tasks_view.dart`

```dart
import 'package:flutter/material.dart';

class EmptyTasksView extends StatelessWidget {
  final VoidCallback onAddTask;

  const EmptyTasksView({super.key, required this.onAddTask});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                size: 80,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد مهام حالياً 🎉',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'يومك منظم وخالٍ من الأعباء، أو ابدأ بإضافة مهمة جديدة وخطط ليوم ناجح!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: onAddTask,
              icon: const Icon(Icons.add_rounded),
              label: const Text('إضافة أول مهمة'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 8. تحديث الصفحة الرئيسية (TasksPage) ونقطة الانطلاق (main.dart)

### أ) تحديث `TasksPage`:
* استدعاء `TaskBottomSheet` عبر `showModalBottomSheet` مع حواف علوية منحنية وتفعيل `isScrollControlled: true`.
* إضافة زر تبديل الوضع الليلي في `AppBar`.
* استخدام `ModernTaskItem` و `EmptyTasksView`.

```dart
void _openBottomSheet(BuildContext context, {TaskEntity? taskToEdit}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => TaskBottomSheet(
      taskToEdit: taskToEdit,
      onSave: (title, desc) {
        if (taskToEdit == null) {
          context.read<TaskCubit>().addTask(title: title, description: desc);
        } else {
          context.read<TaskCubit>().editTask(
                task: taskToEdit,
                newTitle: title,
                newDescription: desc,
              );
        }
      },
    ),
  );
}
```

### ب) ربط `AppTheme` و `ThemeCubit` في `main.dart`:
```dart
runApp(
  MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => ThemeCubit()),
      BlocProvider(create: (_) => TaskCubit(repository: taskRepository)..loadTasks()),
    ],
    child: const MyApp(),
  ),
);
```
وفي بناء `MaterialApp`:
```dart
theme: AppTheme.lightTheme,
darkTheme: AppTheme.darkTheme,
themeMode: context.watch<ThemeCubit>().state,
```

---

## 9. بروتوكول Git Flow و Commits المرحلة

```bash
# 1. التحديث ودمج المرحلة الثانية المستقرة
git checkout develop
git merge feature/phase-2-hive

# 2. إنشاء فرع المرحلة الثالثة
git checkout -b feature/phase-3-ui-ux

# 3. تثبيت google_fonts
git add pubspec.yaml pubspec.lock
git commit -m "chore(deps): add google_fonts for Arabic typography"

# 4. إضافة نظام الثيم الموحد والوضع الليلي
git add lib/core/theme/
git commit -m "feat(theme): implement Material 3 light and dark themes with Cairo font"

# 5. ترقية الواجهات إلى ModalBottomSheet وبطاقات عصرية
git add lib/features/tasks/presentation/
git commit -m "feat(ui): redesign task cards and replace dialog with modal bottom sheet"

# 6. تحديث main وربط الـ ThemeCubit
git add lib/main.dart
git commit -m "feat(main): integrate ThemeCubit and apply centralized app themes"
```

---

## 10. معيار الانتهاء والاختبار البصري (Done When)

تعتبر المرحلة الثالثة مكتملة وناجحة عندما:
1. يظهر التطبيق بخط **Cairo** العربي الجميل بدلاً من الخط الافتراضي للنظام.
2. الضغط على زر الشمس/الهلال في شريط العنوان يُحول التطبيق بالكامل وبنعومة بين **الوضع الليلي والنهاري**.
3. الضغط على زر الإضافة يفتح ورقة أنيقة ناعمة من الأسفل (`BottomSheet`) ترتفع بسلاسة فوق لوحة المفاتيح.
4. بطاقات المهام تبدو عصرية، مع انحناءات لطيفة وتأثير بصري أنيق عند وضع علامة "تم الإنجاز".
5. شاشة الحالة الفارغة تظهر بشكل جذاب ومريح للمستخدم عند عدم وجود مهام.

---

🎯 **الخطوة التالية بعد إتمام هذه المرحلة:** الانتقال إلى **المرحلة 4: التنظيم والبحث والفلترة (Organization & Filtering)** لإضافة تواريخ الاستحقاق، ومستويات الأولوية، وشريط البحث الفوري.

</div>

