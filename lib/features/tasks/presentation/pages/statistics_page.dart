import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/features/tasks/domain/task_entity.dart';
import 'package:todoapp/features/tasks/domain/task_enums.dart';
import 'package:todoapp/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:todoapp/features/tasks/presentation/cubit/task_state.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  void _exportBackup(BuildContext context) async {
    try {
      final jsonString = await context.read<TaskCubit>().exportTasksJson();
      // نسخ النص البرمجي إلى حافظة الجهاز (Clipboard)
      await Clipboard.setData(ClipboardData(text: jsonString));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم نسخ النسخة الاحتياطية (JSON) إلى الحافظة بنجاح 📋',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في التصدير: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImportDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('استيراد نسخة احتياطية (JSON)'),
        content: TextField(
          controller: controller,
          maxLines: 6,
          decoration: const InputDecoration(
            hintText: 'الصق نص الـ JSON هنا...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                try {
                  final count = await context.read<TaskCubit>().importTasksJson(
                    text,
                  );
                  if (context.mounted) {
                    Navigator.of(dialogCtx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم استيراد $count مهمة بنجاح 🎉'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('خطأ في الاستيراد: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('استيراد'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.watch<TaskCubit>().state;

    // استخراج القائمة الكلية لجميع المهام من الـ Cubit
    List<TaskEntity> tasks = [];
    if (state is TaskLoadedSuccessfully) {
      tasks = state.allTasks;
    }

    // حساب المعادلات الحسابية للإحصائيات
    final total = tasks.length;
    final completed = tasks.where((t) => t.isCompleted).length;
    final pending = total - completed;
    final overdue = tasks.where((t) => t.isOverdue).length;
    final rate = total > 0 ? (completed / total) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة الإحصائيات والإنتاجية'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            color: theme.cardTheme.color,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Row(
                children: [
                  // مؤشر دائري جذاب يعرض نسبة الإنجاز
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: rate,
                          strokeWidth: 30,
                          strokeCap: StrokeCap.round,
                          backgroundColor: theme.colorScheme.primary
                              .withOpacity(0.12),
                          valueColor: AlwaysStoppedAnimation(
                            rate == 1.0
                                ? Colors.green.withOpacity(0.4)
                                : theme.colorScheme.primary,
                          ),
                        ),
                        Text(
                          '${(rate * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: rate == 1.0
                                ? Colors.black
                                : theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'معدل الإنجاز العام',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          rate == 1.0
                              ? 'عمل أسطوري! أنجزت كافة مهامك بنجاح 🏆'
                              : 'أنجزت $completed من أصل $total مهمة حتى الآن.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  theme: theme,
                  title: 'إجمالي المهام',
                  value: '$total',
                  icon: Icons.assignment_rounded,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  theme: theme,
                  title: 'المكتملة',
                  value: '$completed',
                  icon: Icons.check_circle_rounded,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  theme: theme,
                  title: 'قيد الإنجاز',
                  value: '$pending',
                  icon: Icons.pending_actions_rounded,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  theme: theme,
                  title: 'المتأخرة',
                  value: '$overdue',
                  icon: Icons.warning_amber_rounded,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: theme.cardTheme.color,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'توزيع المهام حسب الأولوية',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...TaskPriority.values.map((p) {
                    final pCount = tasks.where((t) => t.priority == p).length;
                    final pRatio = total > 0 ? (pCount / total) : 0.0;
                    Color color;
                    if (p == TaskPriority.high)
                      color = Colors.red;
                    else if (p == TaskPriority.medium)
                      color = Colors.orange;
                    else
                      color = Colors.green;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 4,
                                    backgroundColor: color,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(p.label),
                                ],
                              ),
                              Text('$pCount مهمة (${(pRatio * 100).toInt()}%)'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: pRatio,
                            backgroundColor: color.withOpacity(0.12),
                            valueColor: AlwaysStoppedAnimation(color),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            color: theme.cardTheme.color,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.backup_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'إدارة النسخ الاحتياطي (JSON)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'احفظ مهامك كنسخة نصية أو استرجعها في أي جهاز آخر بكل سهولة.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _exportBackup(context),
                          icon: const Icon(Icons.copy_all_rounded, size: 18),
                          label: const Text('تصدير كـ JSON'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: () => _showImportDialog(context),
                          icon: const Icon(Icons.download_rounded, size: 18),
                          label: const Text('استيراد مهام'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required ThemeData theme,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151D2C) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0x1AFFFFFF) : const Color(0x0F000000),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.outline,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
