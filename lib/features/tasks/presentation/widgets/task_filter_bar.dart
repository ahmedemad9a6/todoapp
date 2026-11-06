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
