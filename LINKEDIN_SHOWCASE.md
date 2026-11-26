# 🚀 Modern Flutter ToDo & Productivity Suite (Showcase & LinkedIn Brief)

> **ملف شامل لتوثيق المشروع لعرضه على LinkedIn والـ Portfolio**  
> هذا الملف يحتوي على كافة التفاصيل التقنية، المعمارية الهندسية، الميزات، والتحديات البرمجية التي تم حلها، مكتوب ومصمم لتقديمه لأي نموذج ذكاء اصطناعي (مثل Claude) لصياغة منشور احترافي وجذاب.

---

## 📌 1. نظرة عامة على المشروع (Project Overview)
* **اسم التطبيق:** TaskFlow / Modern ToDo & Productivity Suite
* **التقنية الأساسية:** Flutter 3.x & Dart 3.x
* **الهدف:** تطبيق إنتاجية متكامل لإدارة المهام وتنظيم الوقت، يجمع بين البساطة الفائقة في تجربة المستخدم (UX) وقوة الأنظمة البرمجية للمؤسسات (Clean Architecture & Offline-First).
* **الفلسفة التصميمية:** مستوحاة من أفضل التطبيقات العالمية مثل **Linear**, **Apple iOS (Cashmere Slate)**, و **Things 3**.

---

## 🏗️ 2. المعمارية الهندسية ونمط إدارة الحالة (Architecture & State Management)
تم بناء المشروع باتباع مبادئ **Clean Architecture** الصارمة لضمان سهولة الاختبار (Testability)، التوسع (Scalability)، وفصل المسؤوليات:

### 🔹 الطبقات (Layers):
1. **Domain Layer (قلب التطبيق - Pure Dart):**
   * خالية من أي اعتماد على Flutter أو مكتبات خارجية.
   * تحتوي على الـ Entities: `TaskEntity` (مع `Equatable`)، `SubTaskEntity`.
   * تحتوي على الـ Enums الأساسية: `TaskPriority`, `TaskCategory`, `TaskRecurrence`, `TaskFilterStatus`.
   * العقود والواجهات: `TaskRepository`.

2. **Data Layer (طبقة البيانات والتخزين المحلي):**
   * **Offline-First:** التخزين المحلي فائق السرعة باستخدام **Hive CE (Community Edition)**.
   * `TaskModel` مع تحويلات آمنة جداً للأنماط (`fromMap` / `toMap`)، معالجة الـ Null Safety بدقة، وتحصين البيانات من أي Runtime TypeErrors.
   * `HiveTaskRepositoryImp` التي تنفذ مستودع البيانات مع إدارة الأخطاء (Error Handling).

3. **Presentation Layer (واجهة المستخدم وإدارة الحالة):**
   * إدارة الحالة بنمط **BLoC / Cubit (`flutter_bloc`)**:
     * `TaskCubit` & `TaskState`: لمعالجة تدفق البيانات، البحث، والفلترة المتعددة.
     * `ThemeCubit`: لإدارة الثيم الفاتح والداكن بسلاسة.
   * مكونات واجهة قابلة لإعادة الاستخدام (Modular Reusable Widgets).

---

## ✨ 3. أبرز الميزات والوظائف (Key Features)

### 📝 1. إدارة متقدمة للمهام (Advanced Task Management):
* **العمليات الكاملة (CRUD):** إضافة، تعديل، حذف، واسترجاع فوري (Undo via Floating SnackBar).
* **نظام الأولويات الدلالي (Semantic Priority System):**
  * 🔴 **High (عالية):** بلون Rose 500 (`#F43F5E`).
  * 🔵 **Medium (متوسطة):** بلون Sky Blue 600 (`#0284C7`) كبديل عصري للأصفر المزعج.
  * 🟢 **Low (منخفضة):** بلون Emerald 500 (`#10B981`).
* **التصنيفات الذكية (Categories):** عمل (Work)، شخصي (Personal)، دراسة (Study)، صحة (Health)، أخرى (Other).
* **إدارة التواريخ الذكية (Smart Deadlines):**
  * تمييز المهام المتأخرة (Overdue)، مهام اليوم (Today)، والمهام المجدولة مستقبلاً مع كبسولات زمنية ملونة.
* **تثبيت المهام (Pin to Top):** إمكانية تثبيت المهام الهامة لتظهر دائماً في مقدمة القائمة مع أيقونة وإطار إنديجو أنيق.
* **المهام المتكررة والعادات (Recurrence & Streaks):** دعم التكرار (يومي، أسبوعي، شهري) مع عدّاد الالتزام (Streak Counter 🔥).
* **قوائم المهام الفرعية (Subtasks Checklist):** إضافة خطوات إنجاز داخل كل مهمة مع شريط تقدم حي (Progress Bar) وحساب نسبة الإنجاز تلقائياً.

### ⏱️ 2. مؤقت بومودورو للتركيز المدمج (Integrated Pomodoro Focus Timer):
* مؤقت بومودورو متكامل مع مهام التطبيق (جلسات تركيز 25 دقيقة + استراحة 5 دقائق).
* مؤشر دائري نابض مع توهج بصري حي (`_glowAnimation`).
* **تسجيل وقت التركيز:** يتم تجميع وحفظ دقائق التركيز الفعلية داخل كل مهمة (`focusMinutes`) وعرضها كبادج أنيق وفي لوحة الإحصائيات!

### 🎉 3. التحفيز ومحرك الاحتفال (Gamification & Confetti Engine):
* محرك جزيئات وفيزياء احتفال مخصص بالكامل (`CelebrationOverlay`):
  * إطلاق 45+ قطعة قصاصات ملونة (Confetti Particles) بزوايا وسرعات عشوائية عند إنجاز المهمة مع اهتزاز لمسي قوي (Haptic Feedback) لتعزيز شعور الإنجاز.

### 🔍 4. البحث والفلترة متعددة المعايير (Smart Search & Filtering):
* بحث فوري وتفاعلي بالاسم والتفاصيل مع مزامنة لحظية.
* شريط تجزئة تفاعلي للحالات: (All, Pending, Completed, Today).
* فلترة مدمجة بالتصنيفات داخل حقل البحث.

### 📊 5. لوحة الإحصائيات والنسخ الاحتياطي (Analytics & Backup Dashboard):
* **حلقة إنجاز تفاعلية (Apple Health-style Progress Ring):** تعرض نسبة الإنجاز العامة للأنشطة مع انتقال حركي ناعم (`TweenAnimationBuilder`).
* بطاقات مقاييس رقمية متحركة: المهام المكتملة، قيد التنفيذ، المتأخرة، وإجمالي دقائق التركيز.
* رسم بياني لتوزيع المهام حسب الأولوية والتصنيف.
* **النسخ الاحتياطي السحابي/المحلي (JSON Backup & Restore):**
  * تصدير فوري لكل المهام كملف JSON ونسخه للحافظة بلمسة واحدة.
  * استرجاع المهام واستيرادها من كود JSON مع التحقق من صحة البيانات.

---

## 🎨 4. نظام التصميم وتجربة المستخدم (UI/UX & Design System)

* **حل مشكلة إجهاد العين في الوضع الفاتح (Light Mode Redesign):**
  * تم استبدال البياض الناصع المجهد للعين بخلفية **Cashmere Slate (`#F2F4F7`)** المستوحاة من نظام iOS.
  * بطاقات بيضاء عائمة مع إطار مايكرو فائق النعومة (`#E2E8F0`) وظلال محيطية لطيفة (`blurRadius: 10`).
  * تباين نصوص مريح للشبكية: `#0F172A` للعناوين و `#334155` للنصوص العادية.
* **الوضع الداكن الفخم (Dark Mode):**
  * خلفية Slate 900 (`#0F172A`) وبطاقات Slate 800 (`#1E293B`) بدلاً من الأسود الميت، مما يوفر راحة تامة لشاشات OLED.
* **التناسق الحركي واللمسي (Micro-interactions & Haptics):**
  * اهتزازات لمسية عند السحب، النقر، الإنجاز، والحذف (`HapticFeedback`).
  * رسوم متحركة ناعمة للبطاقات والأشرطة (`AnimatedContainer`, `AnimatedSize`, `TweenAnimationBuilder`).
  * الحذف والإنجاز بالسحب الجانبي السلس (`Dismissible`).

---

## 🛠️ 5. الحزم والتقنيات المستخدمة (Tech Stack)
* **Framework:** Flutter (Android, iOS, Linux, Desktop Ready)
* **Language:** Dart
* **State Management:** `flutter_bloc` (Cubit)
* **Local Database:** `hive_ce` & `hive_ce_flutter`
* **Typography:** `google_fonts` (Inter)
* **Value Equality:** `equatable`
* **ID Generation:** `uuid`
* **Notifications:** `flutter_local_notifications`
* **Window Management:** `window_manager`

---

## 💡 6. التحديات الهندسية والحلول (Engineering Challenges Solved)
1. **أداء القوائم غير المحدودة (Unbounded List Layouts):**
   * حل مشكلة انهيار الـ `IntrinsicHeight` داخل الـ `ListView` عبر استبدالها بـ `Stack` و `Positioned` للشريط الجانبي الملون للأولويات، مما جعل التمرير بسرعة 60/120 FPS.
2. **منع تسريب الذاكرة (Memory Leak Prevention):**
   * إدارة دورة حياة المؤقتات (`Timer.cancel()`) والمراقبين (`AnimationController.dispose()`) في الشاشات وصفحة الـ Splash.
3. **تأمين البيانات ضد أخطاء النوع (Runtime Type Safety):**
   * تحصين `TaskModel.fromMap` ضد البيانات الفارغة أو الخاطئة باستخدام فحوصات صارمة `value is Map` و `int.tryParse`.
4. **تجربة التمرير وتفادي التداخل (FAB Collision Avoidance):**
   * ضبط الحشو السفلي التفاعلي (`88px`) لضمان عدم حجب زر الإضافة العائم لأي بطاقة مهمة في نهاية القائمة.

---

## 📝 7. مقترح محاور لمنشور لينكد إن (LinkedIn Post Angles for Claude)
إذا أردت توجيه كلود لكتابة المنشور، يمكنك اختيار أحد هذه الزوايا:
1. **الزاوية الهندسية (Software Architecture Angle):** التركيز على تطبيق Clean Architecture مع BLoC و Hive في تطبيق حقيقي عالي الأداء.
2. **زاوية الـ UI/UX والتصميم (Design System Angle):** التركيز على كيفية التخلص من البياض الناصع وبناء ثيم مريح للعين مستوحى من Apple و Linear مع ميكرو-أنيميشنز واحتفال جزيئات.
3. **زاوية الإنتاجية الشاملة (Productivity Tool Angle):** دمج بومودورو مع المهام وتتبع فترات التركيز وإحصائيات الإنجاز بأسلوب Apple Health.

