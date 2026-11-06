<div dir="rtl">

# 📘 الدليل الشامل والمفصل للمرحلة الخامسة (Phase 5 Guide)
> **عنوان المرحلة:** الإيماءات الذكية والمهام الفرعية والتذكيرات (Gestures, Sub-tasks & Reminders)  
> **الهدف:** رفع مستوى تفاعلية التطبيق لتجربة مستخدم عالمية (Interactive UX)؛ من خلال دعم إيماءات السحب الحركي (`Dismissible`)، تقسيم المهام الكبيرة إلى مهام فرعية تشيك لست (`Sub-tasks Checklist`) مع شريط تقدم الإنجاز، وإضافة التذكيرات المحلية (`Local Notifications`).

---

## 📑 الفهرس
1. [خريطة الميزات والمفاهيم الهندسية للمرحلة](#1-خريطة-الميزات-والمفاهيم-الهندسية-للمرحلة)
2. [الميزة الأولى: إيماءات السحب التفاعلية (Swipe Gestures with Dismissible)](#2-الميزة-الأولى-إيماءات-السحب-التفاعلية)
3. [الميزة الثانية: المهام الفرعية (Sub-tasks Checklist Architecture)](#3-الميزة-الثانية-المهام-الفرعية)
   * [أ) طبقة النطاق: كائن المهمة الفرعية (SubTaskEntity)](#أ-طبقة-النطاق-كائن-المهمة-الفرعية-subtaskentity)
   * [ب) طبقة البيانات: تسلسل المهام الفرعية في Hive](#ب-طبقة-البيانات-تسلسل-المهام-الفرعية-في-hive)
   * [ج) منطق الـ Cubit: تبديل وإضافة المهام الفرعية](#ج-منطق-الـ-cubit-تبديل-وإضافة-المهام-الفرعية)
4. [الميزة الثالثة: التذكيرات والإشعارات المحلية (Local Notifications)](#4-الميزة-الثالثة-التذكيرات-والإشعارات-المحلية)
   * [أ) الاعتماديات وإعداد الأذونات](#أ-الاعتماديات-وإعداد-الأذونات)
   * [ب) خدمة الإشعارات المركزية (NotificationService)](#ب-خدمة-الإشعارات-المركزية-notificationservice)
5. [تحديث الواجهات: شريط تقدم الإنجاز وقائمة الـ Checklist](#5-تحديث-الواجهات-شريط-تقدم-الإنجاز-وقائمة-الـ-checklist)
6. [بروتوكول Git Flow و Commits المرحلة](#6-بروتوكول-git-flow-و-commits-المرحلة)
7. [معيار الانتهاء والاختبار العملي (Done When)](#7-معيار-الانتهاء-والاختبار-العملي)

---

## 1. خريطة الميزات والمفاهيم الهندسية للمرحلة

في هذه المرحلة، سنتعلم مفاهيم متقدمة في واجهات Flutter وإدارة البيانات المتداخلة:

```text
┌────────────────────────────────────────────────────────────────────────┐
│                        المفاهيم الهندسية للمرحلة 5                    │
├───────────────────────┬────────────────────────────────────────────────┤
│ 1. Dismissible        │ التعامل مع حركات السحب لليمين واليسار مع       │
│    Gestures           │ خلفيات متحركة وأيقونات تأكيدية تمنح شعوراً رائعاً.│
├───────────────────────┼────────────────────────────────────────────────┤
│ 2. الكائنات المتداخلة │ كائن SubTaskEntity داخل كائن TaskEntity        │
│    (Nested Entities)  │ وحساب نسبة الإنجاز الرياضية (3 من 5 مكتملة).   │
├───────────────────────┼────────────────────────────────────────────────┤
│ 3. خدمات النظام       │ التعامل مع محرك إشعارات الجهاز والجدولة الزمنية. │
│    (Platform Services)│                                                │
└───────────────────────┴────────────────────────────────────────────────┘
```

---

## 2. الميزة الأولى: إيماءات السحب التفاعلية (Dismissible)

بدلاً من الضغط على خيارات القائمة، يمكن للمستخدم التفاعل مع المهمة فوراً بإصبعه:
* **السحب لليمين (Swipe Right 🟩):** تبديل حالة المهمة بين "مكتملة" أو "قيد الإنجاز" بخلفية خضراء وأيقونة نجاح.
* **السحب لليسار (Swipe Left 🟥):** حذف المهمة فوراً بخلفية حمراء وأيقونة سلة مهملات، مع بقاء شريط التراجع `Undo SnackBar`.

### كيف ندمجها في `ModernTaskItem`؟
نغلف عنصر البطاقة بويدجت **`Dismissible`**:

```dart
Dismissible(
  key: Key(task.id),
  // تحديد اتجاهات السحب المسموحة
  direction: DismissDirection.horizontal,

  // الخلفية عند السحب لليمين (إنجاز المهمة)
  background: Container(
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.symmetric(horizontal: 24),
    decoration: BoxDecoration(
      color: Colors.green.shade600,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        Icon(
          task.isCompleted ? Icons.restart_alt_rounded : Icons.check_circle_rounded,
          color: Colors.white,
          size: 28,
        ),
        const SizedBox(width: 8),
        Text(
          task.isCompleted ? 'إعادة فتح' : 'إنجاز',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  ),

  // الخلفية عند السحب لليسار (حذف المهمة)
  secondaryBackground: Container(
    alignment: Alignment.centerLeft,
    padding: const EdgeInsets.symmetric(horizontal: 24),
    decoration: BoxDecoration(
      color: Colors.red.shade600,
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'حذف',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 8),
        Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
      ],
    ),
  ),

  // القرار البرمجي عند انتهاء السحب
  confirmDismiss: (direction) async {
    if (direction == DismissDirection.startToEnd) {
      // سحب لليمين: تغيير حالة الإنجاز دون إزالة العنصر من الشاشة
      onToggle();
      return false; // لا تحذف العنصر بصرياً
    } else {
      // سحب لليسار: حذف
      return true; // احذف العنصر
    }
  },
  onDismissed: (direction) {
    if (direction == DismissDirection.endToStart) {
      onDelete();
    }
  },
  child: // ... البطاقة الحالية
)
```

---

## 3. الميزة الثانية: المهام الفرعية (Sub-tasks Architecture)

المهام الكبيرة مثل *"التحضير للامتحان"* أو *"تجهيز حقيبة السفر"* تتطلب خطوات فرعية صغيرة (`Checklist`).

### أ) طبقة النطاق: كائن المهمة الفرعية
📂 `lib/features/tasks/domain/sub_task_entity.dart`

```dart
import 'package:equatable/equatable.dart';

class SubTaskEntity extends Equatable {
  final String id;
  final String title;
  final bool isCompleted;

  const SubTaskEntity({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  SubTaskEntity copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return SubTaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [id, title, isCompleted];
}
```

---

### ب) ربط المهام الفرعية داخل `TaskEntity`:
في ملف [`lib/features/tasks/domain/task_entity.dart`](file:///home/ahmed/Desktop/Ahmed%20Flutter/toDoApp/todoapp/lib/features/tasks/domain/task_entity.dart):

```dart
  final List<SubTaskEntity> subTasks; // 👈 إضافة قائمة المهام الفرعية

  // إضافة خاصية ذكية لحساب نسبة الإنجاز
  double get progress {
    if (subTasks.isEmpty) return isCompleted ? 1.0 : 0.0;
    final completedCount = subTasks.where((s) => s.isCompleted).length;
    return completedCount / subTasks.length;
  }
```

---

### ج) طبقة البيانات: التسلسل الآمن في `TaskModel`:
في ملف [`lib/features/tasks/data/task_model.dart`](file:///home/ahmed/Desktop/Ahmed%20Flutter/toDoApp/todoapp/lib/features/tasks/data/task_model.dart):

```dart
  // في toMap:
  'subTasks': subTasks.map((s) => {
    'id': s.id,
    'title': s.title,
    'isCompleted': s.isCompleted,
  }).toList(),

  // في fromMap:
  subTasks: (map['subTasks'] as List<dynamic>?)
          ?.map((item) => SubTaskEntity(
                id: item['id'] as String,
                title: item['title'] as String,
                isCompleted: item['isCompleted'] as bool? ?? false,
              ))
          .toList() ??
      [],
```

---

### د) دوال التحكم في `TaskCubit`:
```dart
  /// تبديل حالة مهمة فرعية
  Future<void> toggleSubTask(TaskEntity task, String subTaskId) async {
    final updatedSubTasks = task.subTasks.map((s) {
      if (s.id == subTaskId) {
        return s.copyWith(isCompleted: !s.isCompleted);
      }
      return s;
    }).toList();

    // إذا اكتملت كل المهام الفرعية، يمكن تحويل المهمة الرئيسية إلى مكتملة تلقائياً!
    final allDone = updatedSubTasks.isNotEmpty && updatedSubTasks.every((s) => s.isCompleted);

    final updatedTask = task.copyWith(
      subTasks: updatedSubTasks,
      isCompleted: allDone ? true : task.isCompleted,
    );

    await repository.updateTask(updatedTask);
    await _refreshWithCurrentFilters();
  }
```

---

## 4. الميزة الثالثة: التذكيرات والإشعارات المحلية (Local Notifications)

تذكير المستخدم بالمهام في وقت استحقاقها أو قبلها بنصف ساعة.

### أ) الاعتماديات في `pubspec.yaml`:
```yaml
dependencies:
  flutter_local_notifications: ^18.0.1
  timezone: ^0.10.0
```

---

### ب) بناء خدمة الإشعارات المركزية:
📂 `lib/core/services/notification_service.dart`

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
  }

  /// إرسال إشعار فوري (تجريبي أو عند إكمال جميع المهام)
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'tasks_channel',
      'تنبيهات المهام',
      channelDescription: 'قناة إرسال تذكيرات مهام التطبيق',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(id, title, body, details);
  }

  /// طلب أذونات الإشعارات في Android 13+
  Future<void> requestPermissions() async {
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
  }
}
```

---

## 5. تحديث الواجهات: شريط التقدم وقائمة المهام الفرعية

في بطاقة المهمة [`ModernTaskItem`](file:///home/ahmed/Desktop/Ahmed%20Flutter/toDoApp/todoapp/lib/features/tasks/presentation/widgets/modern_task_item.dart):
* عند وجود مهام فرعية، نظهر شريط تقدم صغير (`LinearProgressIndicator`) أسفل العنوان:
  ```dart
  if (task.subTasks.isNotEmpty) ...[
    const SizedBox(height: 6),
    Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: task.progress,
              minHeight: 5,
              backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              valueColor: AlwaysStoppedAnimation(
                task.progress == 1.0 ? Colors.green : theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(task.progress * 100).toInt()}%',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  ]
  ```
* يمكن الضغط على سهم لتوسيع وعرض المهام الفرعية كـ `ExpansionTile` أو قائمة فرعية سريعة.

---

## 6. بروتوكول Git Flow و Commits المرحلة

```bash
# 1. التحديث ودمج فرع المرحلة الرابعة
git checkout develop
git merge feature/phase-4-filtering-search

# 2. إنشاء فرع المرحلة الخامسة
git checkout -b feature/phase-5-gestures-reminders

# 3. بعد إضافة إيماءات Dismissible:
git add lib/features/tasks/presentation/widgets/modern_task_item.dart
git commit -m "feat(ui): add swipe gestures with Dismissible for completion and deletion"

# 4. بعد إضافة المهام الفرعية:
git add lib/features/tasks/domain/ lib/features/tasks/data/ lib/features/tasks/presentation/
git commit -m "feat(tasks): support sub-tasks checklist and dynamic progress tracking"

# 5. بعد إعداد خدمة الإشعارات:
git add lib/core/services/ pubspec.yaml pubspec.lock
git commit -m "feat(notifications): setup NotificationService with Android & iOS support"
```

---

## 7. معيار الانتهاء والاختبار العملي (Done When)

تعتبر المرحلة الخامسة مكتملة بنجاح تام عند تحقق السيناريوهات التالية:
1. **اختبار السحب لليمين:** سحب البطاقة لليمين بسلاسة يظهر خلفية خضراء ويحول المهمة إلى "مكتملة".
2. **اختبار السحب لليسار:** سحب البطاقة لليسار يظهر خلفية حمراء ويحذف المهمة مع ظهور شريط التراجع `Undo`.
3. **اختبار المهام الفرعية:** إنشاء مهمة تحتوي على 3 مهام فرعية، وتأشير مهمتين منها، ومشاهدة شريط التقدم يرتفع إلى 66% تلقائياً.
4. **اختبار بقاء المهام الفرعية في Hive:** إغلاق التطبيق وإعادة فتحه، للتأكد من بقاء حالة المهام الفرعية ونسبة إنجازها.

---

🎯 **الخطوة التالية بعد إتمام هذه المرحلة:** الانتقال إلى **المرحلة 6 (الأخيرة): اللمسات الاحترافية والنشر (Production & Polish)** لإضافة الإحصائيات، وشاشة البداية، وتصدير البيانات `JSON Backup`.

</div>

