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

    if (state.searchQuery.isEmpty && _searchController.text.isNotEmpty) {
      _searchController.clear();
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Search Bar with Integrated Category Selector
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0x1FFFFFFF) : const Color(0x0F000000),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      context.read<TaskCubit>().search(val);
                      setState(() {});
                    },
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: 'Search tasks...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.outline,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
                if (_searchController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 16),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _searchController.clear();
                      context.read<TaskCubit>().search('');
                      setState(() {});
                    },
                  ),
                Container(
                  height: 20,
                  width: 1,
                  color: isDark ? const Color(0x1FFFFFFF) : const Color(0x1A000000),
                ),
                // Category Filter Menu inside Search Bar
                PopupMenuButton<TaskCategory?>(
                  initialValue: state.categoryFilter,
                  tooltip: 'Filter by category',
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (cat) {
                    HapticFeedback.selectionClick();
                    context.read<TaskCubit>().setCategoryFilter(cat);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          state.categoryFilter != null
                              ? Icons.filter_alt_rounded
                              : Icons.folder_outlined,
                          size: 15,
                          color: state.categoryFilter != null
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 5),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 80),
                          child: Text(
                            state.categoryFilter?.label ?? 'Category',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: state.categoryFilter != null
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outline,
                            ),
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.arrow_drop_down,
                          size: 16,
                          color: theme.colorScheme.outline,
                        ),
                      ],
                    ),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem<TaskCategory?>(
                      value: null,
                      child: Text('All Categories'),
                    ),
                    const PopupMenuDivider(),
                    ...TaskCategory.values.map(
                      (cat) => PopupMenuItem<TaskCategory?>(
                        value: cat,
                        child: Text(cat.label),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Row 2: Clean, Symmetrical Segmented Bar for Status
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: TaskFilterStatus.values.map((status) {
                final isSelected = state.statusFilter == status;
                final count = _getCountForStatus(state, status);

                return Expanded(
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      context.read<TaskCubit>().setStatusFilter(status);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? const Color(0xFF334155) : Colors.white)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                status.label,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                  color: isSelected
                                      ? (isDark ? Colors.white : const Color(0xFF0F172A))
                                      : theme.colorScheme.outline,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '($count)',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.outline.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
