import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todoapp/features/tasks/domain/task_enums.dart';
import 'package:todoapp/features/tasks/presentation/cubit/task_cubit.dart';
import 'package:todoapp/features/tasks/presentation/cubit/task_state.dart';

class TaskFilterBar extends StatefulWidget {
  const TaskFilterBar({super.key});

  @override
  State<TaskFilterBar> createState() => _TaskFilterBarState();
}

class _TaskFilterBarState extends State<TaskFilterBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _getCountForStatus(TaskLoadedSuccessfully state, TaskFilterStatus status) {
    switch (status) {
      case TaskFilterStatus.all:
        return state.allTasks.length;
      case TaskFilterStatus.pending:
        return state.allTasks.where((t) => !t.isCompleted).length;
      case TaskFilterStatus.completed:
        return state.allTasks.where((t) => t.isCompleted).length;
      case TaskFilterStatus.today:
        return state.allTasks.where((t) => t.isDueToday).length;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TaskCubit>().state;
    if (state is! TaskLoadedSuccessfully) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
                Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF151D2C)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? const Color(0x1FFFFFFF)
                    : const Color(0x0F000000),
              ),
            ),
            child: TextField(
              controller: _searchController,
              textAlignVertical: TextAlignVertical.center,
              onChanged: (val) {
                context.read<TaskCubit>().search(val);
                setState(() {});
              },
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                hintText: 'ابحث عن مهمة بالاسم أو الوصف...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.outline.withOpacity(0.8),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          _searchController.clear();
                          context.read<TaskCubit>().search('');
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),

                SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: TaskFilterStatus.values.map((status) {
              final isSelected = state.statusFilter == status;
              final count = _getCountForStatus(state, status);

              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.read<TaskCubit>().setStatusFilter(status);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.primary.withOpacity(0.85),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected
                          ? null
                          : (isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : (isDark
                                ? const Color(0x1AFFFFFF)
                                : const Color(0x12000000)),
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: theme.colorScheme.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          status.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : const Color(0xFF475569)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // عداد المهام الصغير داخل الشريحة
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.25)
                                : (isDark
                                    ? Colors.black26
                                    : const Color(0xFFF1F5F9)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
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
