# 📘 الدليل الشامل والمفصل للمرحلة الثانية (Phase 2 Guide)
> **عنوان المرحلة:** الحفظ المحلي الدائم باستخدام Hive (Local Persistence with Hive)  
> **الهدف:** استبدال التخزين المؤقت في الذاكرة (RAM) بقاعدة بيانات محلية دائمة وسريعة، واختبار قوة الـ Clean Architecture حيث نغير طبقة البيانات دون المساس بواجهات التطبيق أو منطق الـ Cubit.

---

## 📑 الفهرس
1. [سحر المعمارية النظيفة: ماذا سيتغير وماذا سيبقى ثابتاً؟](#1-سحر-المعمارية-النظيفة-ماذا-سيتغير-وماذا-سيبقى-ثابتاً)
2. [الاعتماديات المطلوبة (Dependencies)](#2-الاعتماديات-المطلوبة-dependencies)
3. [مفهوم التخزين في Hive (Key-Value Box)](#3-مفهوم-التخزين-في-hive-key-value-box)
4. [إنشاء مستودع Hive (HiveTaskRepositoryImpl) - كود وشرح مفصل](#4-إنشاء-مستودع-hive-hivetaskrepositoryimpl)
5. [تهيئة Hive وتمرير المستودع في (main.dart)](#5-تهيئة-hive-وتمرير-المستودع-في-maindart)
6. [فخاخ برمجية وحلول هندسية (Type Casting & Edge Cases)](#6-فخاخ-برمجية-وحلول-هندسية)
7. [خطوات Git المنظمة للفرع (Git Flow & Atomic Commits)](#7-خطوات-git-المنظمة-للفرع)
8. [معيار الانتهاء والاختبار العملي (Done When)](#8-معيار-الانتهاء-والاختبار-العملي)

---

## 1. سحر المعمارية النظيفة: ماذا سيتغير وماذا سيبقى ثابتاً؟

في المرحلة الأولى، كان تدفق البيانات كالتالي:
```text
[ UI (TasksPage) ] ──▶ [ TaskCubit ] ──▶ [ TaskRepository (Contract) ]
                                                   ▲
                                        [ InMemoryTaskRepositoryImpl ] (RAM)
```

في المرحلة الثانية، سنلاحظ الإعجاز الحقيقي لـ **مبدأ عكس التبعية (Dependency Inversion Principle)**:
```text
[ UI (TasksPage) ] ──▶ [ TaskCubit ] ──▶ [ TaskRepository (Contract) ]
                                                   ▲
                                          [ HiveTaskRepositoryImpl ] (Storage 💾)
```

* **ما الذي لن يتغير إطلاقاً؟ (0% تغيير):**
  * الواجهات (`TasksPage`, `TaskDialog`, `TaskItemTile`).
  * إدارة الحالة (`TaskCubit`, `TaskState`).
  * النطاق (`TaskEntity`, `TaskRepository`).
  * النموذج الأساسي (`TaskModel`).
* **ما الذي سنضيفه ونعدله فقط؟:**
  * إضافة كلاس جديد في طبقة البيانات: `HiveTaskRepositoryImpl`.
  * تغيير سطر التهيئة في `main.dart` لنمرر مستودع Hive بدلاً من مستودع الذاكرة.

---

## 2. الاعتماديات المطلوبة (Dependencies)

نستخدم حزمة **`hive_ce`** و **`hive_ce_flutter`** (النسخة المجتمعية الحديثة والمستمرة من Hive)، أو الحزمة الأصلية `hive_flutter`.  
تتميز بأنها:
* سريعة جداً ومكتوبة بلغة Dart نقية.
* لا تحتاج إلى توليد كود (`build_runner`) أو `TypeAdapters` معقدة عندما نخزن البيانات كـ `Map<String, dynamic>`.

### الإضافة في `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  cupertino_icons: ^1.0.8

  # إدارة الحالة والكيانات (من المرحلة 1)
  flutter_bloc: ^9.1.1
  equatable: ^3.0.0
  uuid: ^4.6.0

  # التخزين المحلي (المرحلة 2)
  hive_ce: ^2.11.3
  hive_ce_flutter: ^2.3.1
```
*(ثم نقوم بتشغيل `flutter pub get` في الطرفية).*

---

## 3. مفهوم التخزين في Hive (Key-Value Box)

تعمل Hive بمفهوم **الصناديق (Boxes)**:
* الصندوق يشبه جدولاً مبسطاً أو ملف تخزين مستقل.
* نخزن البيانات بداخله بنظام **مفتاح وقيمة (Key-Value Pair)**:
  * **المفتاح (Key):** هو معرّف المهمة الفريد `task.id` (مثال: `"uuid-123"`).
  * **القيمة (Value):** هي خريطة البيانات `Map<String, dynamic>` الناتجة عن دالة `taskModel.toMap()`.

```text
┌────────────────────────────────────────────────────────┐
│                   Box: 'tasks_box'                     │
├──────────────────────┬─────────────────────────────────┤
│ Key (String)         │ Value (Map<String, dynamic>)    │
├──────────────────────┼─────────────────────────────────┤
│ "a1b2-task-id"       │ {'id': '..', 'title': '..', ..} │
│ "c3d4-task-id"       │ {'id': '..', 'title': '..', ..} │
└──────────────────────┴─────────────────────────────────┘
```

---

## 4. إنشاء مستودع Hive (HiveTaskRepositoryImpl)

سننشئ ملفاً جديداً في طبقة البيانات:  
📂 `lib/features/tasks/data/repositories/hive_task_repository_impl.dart` (أو مباشرة داخل `lib/features/tasks/data/`).

```dart
import 'package:hive_ce/hive.dart';
import 'package:todoapp/features/tasks/data/task_model.dart';
import 'package:todoapp/features/tasks/domain/task_entity.dart';
import 'package:todoapp/features/tasks/domain/task_repository.dart';

class HiveTaskRepositoryImpl implements TaskRepository {
  final Box _tasksBox;

  /// نمرر الصندوق عبر الـ Constructor (Dependency Injection)
  HiveTaskRepositoryImpl({required Box tasksBox}) : _tasksBox = tasksBox;

  @override
  Future<List<TaskEntity>> getTasks() async {
    try {
      final List<TaskEntity> tasks = [];

      for (var value in _tasksBox.values) {
        // تحويل نوع البيانات القادم من Hive بأمان
        final Map<String, dynamic> taskMap = Map<String, dynamic>.from(value as Map);
        final taskModel = TaskModel.fromMap(taskMap);
        tasks.add(taskModel);
      }

      // ترتيب المهام من الأحدث إلى الأقدم بناءً على تاريخ الإنشاء
      tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return tasks;
    } catch (e) {
      throw Exception('فشل في جلب المهام من التخزين المحلي: $e');
    }
  }

  @override
  Future<void> addTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      // استخدام id كمفتاح فريد في الصندوق
      await _tasksBox.put(taskModel.id, taskModel.toMap());
    } catch (e) {
      throw Exception('فشل في حفظ المهمة: $e');
    }
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    try {
      final taskModel = TaskModel.fromEntity(task);
      // تحديث القيمة المخزنة تحت نفس المفتاح
      await _tasksBox.put(taskModel.id, taskModel.toMap());
    } catch (e) {
      throw Exception('فشل في تحديث المهمة: $e');
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await _tasksBox.delete(taskId);
    } catch (e) {
      throw Exception('فشل في حذف المهمة من التخزين: $e');
    }
  }
}
```

### 💡 تحليل الكود وملاحظات هندسية:
1. **لماذا `_tasksBox.put(taskModel.id, ...)`؟**  
   طريقة `put` تضمن عدم تكرار المهمة؛ إن كانت موجودة مسبقاً يتم تحديثها، وإن لم تكن موجودة يتم إنشاؤها فوراً.
2. **الترتيب (`tasks.sort`):**  
   صندوق Hive يحفظ بترتيب الإدخال، لذلك قمنا بترتيب العناصر برمجياً عبر `createdAt` لضمان ظهور المهام الأحدث في أعلى القائمة دائماً.
3. **معالجة الاستثناءات (`try / catch`):**  
   حماية التطبيق من الانهيار عند حدوث أي خطأ في القراءة أو الكتابة على القرص الصلب.

---

## 5. تهيئة Hive وتمرير المستودع في (main.dart)

يجب تهيئة Hive وفتح الصندوق المخصص للمهام **قبل** تشغيل `runApp()`.

### التعديل في `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'package:todoapp/features/tasks/data/hive_task_repository_impl.dart';
import 'package:todoapp/features/tasks/domain/task_repository.dart';
import 'package:todoapp/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:todoapp/features/tasks/presentation/pages/tasks_page.dart';

void main() async {
  // 1. ضمان تهيئة خدمات فلاتر الأساسية
  WidgetsFlutterBinding.ensureInitialized();

  // 2. تهيئة Hive لمسار التطبيق
  await Hive.initFlutter();

  // 3. فتح صندوق المهام
  const String tasksBoxName = 'tasks_box';
  final Box tasksBox = await Hive.openBox(tasksBoxName);

  // 4. إنشاء المستودع الجديد بحقن الصندوق
  final TaskRepository taskRepository = HiveTaskRepositoryImpl(tasksBox: tasksBox);

  // 5. تشغيل التطبيق مع تمرير المستودع
  runApp(MyApp(taskRepository: taskRepository));
}

class MyApp extends StatelessWidget {
  final TaskRepository taskRepository;

  const MyApp({super.key, required this.taskRepository});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: taskRepository,
      child: BlocProvider(
        create: (context) => TaskCubit(repository: taskRepository)..loadTasks(),
        child: MaterialApp(
          title: 'تطبيق المهام',
          debugShowCheckedModeBanner: false,
          locale: const Locale('ar', 'SA'),
          supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF3F51B5),
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

## 6. فخاخ برمجية وحلول هندسية (Edge Cases)

### الفخ الأول: مشكلة `type '_Map<dynamic, dynamic>' is not a subtype of type 'Map<String, dynamic>'`
* **المشكلة:** عند استرجاع البيانات من Hive، يرجع المحتوى كـ `Map<dynamic, dynamic>`. وإذا مررته مباشرة إلى `TaskModel.fromMap` فسيحدث خطأ تشغيلي (Runtime Error).
* **الحل الهندسي:** استخدام التحويل الآمن:
  ```dart
  final taskMap = Map<String, dynamic>.from(value as Map);
  ```

### الفخ الثاني: بقاء `Future.delayed` القديم
* في مستودع الذاكرة المؤقت، كنا نضع 5 ثوانٍ لاختبار الـ Loading.
* في مستودع Hive، القراءة سريعة جداً. يمكنك ترك تأخير رمزي (مثل 500 ميلي ثانية) إذا رغبت في تجربة رؤية الـ Loader، أو حذف التأخير للوصول إلى أقصى سرعة استجابة.

---

## 7. خطوات Git المنظمة للفرع (Git Flow & Atomic Commits)

نتبع نفس المنهجية الاحترافية بإنشاء فرع مستقل للمرحلة الثانية:

```bash
# 1. التأكد من حفظ وإنهاء المرحلة الأولى على develop
git checkout develop
git merge feature/phase-1-basics

# 2. إنشاء فرع المرحلة الثانية
git checkout -b feature/phase-2-hive

# 3. بعد إضافة حزم Hive:
git add pubspec.yaml pubspec.lock
git commit -m "chore(deps): add hive_ce and hive_ce_flutter dependencies"

# 4. بعد بناء مستودع Hive:
git add lib/features/tasks/data/hive_task_repository_impl.dart
git commit -m "feat(data): implement HiveTaskRepositoryImpl with Box storage"

# 5. بعد تحديث main.dart:
git add lib/main.dart
git commit -m "feat(main): initialize Hive storage and inject Hive repository"
```

---

## 8. معيار الانتهاء والاختبار العملي (Done When)

تعتبر المرحلة الثانية مكتملة بنجاح 100% عندما تُحقق سيناريو الاختبار التالي:
1. تشغيل التطبيق وإضافة 3 مهام جديدة.
2. تعديل إحدى المهام وتغيير حالة مهمة أخرى إلى "مكتملة".
3. **إغلاق التطبيق تماماً (Kill App / إغلاقه من مدير التطبيقات بالهاتف).**
4. إعادة فتح التطبيق من جديد:
   * **النتيجة المتوقعة:** تظهر جميع المهام بحالاتها ونصوصها دون نقصان أي حرف!
5. حذف مهمة والضغط على زر "تراجع (Undo)":
   * **النتيجة المتوقعة:** تعود المهمة وتُحفظ من جديد في Hive بشكل طبيعي.

---

🎯 **الخطوة التالية بعد إتمام هذه المرحلة:** الانتقال إلى **المرحلة 3: التصميم العصري وتجربة المستخدم (Modern UI/UX)** لدعم الوضع الليلي، والخطوط العربية، وبطاقات المهام الاحترافية.

