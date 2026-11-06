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
