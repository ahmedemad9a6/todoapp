
enum TaskPriority {
  low('منخفضة', 1),
  medium('متوسطة', 2),
  high('مرتفعة', 3);

  final String label; // النص العربي المعروض في الواجهة
  final int value; // القيمة العددية للترتيب والفرز البرمجي
  const TaskPriority(this.label, this.value);
}

enum TaskCategory {
  personal('شخصي', '👤'),
  work('عمل', '💼'),
  study('دراسة', '📚'),
  shopping('تسوق', '🛒'),
  other('عام', '📌');

  final String label; // اسم التصنيف بالعربية
  final String icon; // الرمز التعبيري المعبر عن التصنيف
  const TaskCategory(this.label, this.icon);
}

enum TaskFilterStatus {
  all('الكل'),
  pending('قيد الإنجاز'),
  completed('المكتملة'),
  today('اليوم');

  final String label;
  const TaskFilterStatus(this.label);
}

enum TaskRecurrence {
  none('بدون تكرار', '⏹️'),
  daily('يومياً', '🔄'),
  weekly('أسبوعياً', '📅'),
  monthly('شهرياً', '🗓️');

  final String label;
  final String icon;
  const TaskRecurrence(this.label, this.icon);
}
