enum TaskPriority {
  low('Low', 1),
  medium('Medium', 2),
  high('High', 3);

  final String label;
  final int value;
  const TaskPriority(this.label, this.value);
}

enum TaskCategory {
  personal('Personal'),
  work('Work'),
  study('Study'),
  shopping('Shopping'),
  other('General');

  final String label;
const TaskCategory(this.label);
}

enum TaskFilterStatus {
  all('All'),
  pending('In Progress'),
  completed('Completed'),
  today('Today');

  final String label;
  const TaskFilterStatus(this.label);
}

enum TaskRecurrence {
  none('Does not repeat'),
  daily('Daily'),
  weekly('Weekly'),
  monthly('Monthly');

  final String label;
  const TaskRecurrence(this.label);
}
