/*-------------------------------------------------------------------------------
AUTHOR          : Shamnas Abdulla
CREATED DATE    : 22-01-2026
PURPOSE         :
MODULE/TOPIC    :
REMARKS         : EI0097-26
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#    DATE        MODIFIED BY     TICKET#         DESCRIPTION
--------------------------------------------------------------------------------
01    05/02/2026     Shamnas        EI0112-26       Design correction
02    10/03/2026     Shamnas        EI0097-26       Added count badge per tab
------------------------------------------------------------------------------*/
import 'package:base/presentation/base/base_consumer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_design/presentation/provider/call_tracker/providers/service_tasks_provider.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';

class TaskFilterTab extends ConsumerStatefulWidget {
  const TaskFilterTab({super.key});

  @override
  ConsumerState<TaskFilterTab> createState() => _TaskFilterTabState();
}

class _TaskFilterTabState extends ConsumerState<TaskFilterTab> {
  final ScrollController scrollController = ScrollController();

  /// Approximate width of each tab chip (label + badge + padding + margin).
  /// Adjust this constant if your average tab renders wider/narrower.
  static const double _estimatedTabWidth = 120.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initScrollPosition());
  }

  /// Scrolls the tab bar so that the currently selected filter is visible
  /// (and ideally centred) when the widget first appears.
  void _initScrollPosition() {
    if (!scrollController.hasClients) return;

    final provider = ref.watch(serviceRequestDashboardProvider);
    final selectedFilter = provider.selectedTaskFilter;

    // Build the same filtered list used in the build method so the index
    // matches the rendered order exactly.
    final filters = TaskFilter.values.where((filter) {
      if (filter == TaskFilter.task_notification &&
          (provider.currentTaskId == 0)) {
        return false;
      }
      if (filter == TaskFilter.cancelled) return false;
      return true;
    }).toList();

    final index = filters.indexOf(selectedFilter);
    if (index < 0) return;

    final targetOffset = index * _estimatedTabWidth;
    final viewportWidth = scrollController.position.viewportDimension;

    // Centre the selected tab inside the visible area.
    final centredOffset =
        targetOffset - (viewportWidth / 2) + (_estimatedTabWidth / 2);

    final clampedOffset = centredOffset.clamp(
      scrollController.position.minScrollExtent,
      scrollController.position.maxScrollExtent,
    );

    scrollController.animateTo(
      clampedOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Color _tabColor(BuildContext context, TaskFilter filter, bool isSelected) {
    if (!isSelected) return const Color(0xFFB0BEC5);
    return Theme.of(context).primaryColor;
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseConsumer<ServiceTasksProvider>(
      provider: serviceRequestDashboardProvider,
      builder: (context, provider, _) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SizedBox(
            height: 48,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final filters = TaskFilter.values.where((filter) {
                  // Hide reference_task when currenttaskid is null
                  if (filter == TaskFilter.task_notification &&
                      (provider.currentTaskId == 0)) {
                    return false;
                  }

                  // Hide cancelled as requested
                  if (filter == TaskFilter.cancelled) {
                    return false;
                  }
                  return true;
                }).toList();

                final tabs = filters.map((filter) {
                  final isSelected = provider.selectedTaskFilter == filter;
                  final tabColor = _tabColor(context, filter, isSelected);
                  final count = provider.getCountForFilter(filter);

                  String label;
                  if (filter == TaskFilter.assignment_pending) {
                    label = "PENDING";
                  } else if (filter == TaskFilter.send_back) {
                    label = "REV. REJECTED";
                  } else if (filter == TaskFilter.reviewed) {
                    label = "REVIEWED";
                  } else if (filter == TaskFilter.rejected) {
                    label = "PC. REJECTED";
                  } else {
                    label = filter.name.replaceAll('_', ' ').toUpperCase();
                  }

                  return GestureDetector(
                    onTap: () => provider.changeFilter(filter),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? tabColor.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? tabColor
                              : Colors.grey.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontSize: 9.5,
                              fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? tabColor : Colors.grey,
                            ),
                          ),
                        if (filter != TaskFilter.task_notification) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? tabColor
                                  : Colors.grey.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              count > 99 ? '99+' : '$count',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.grey,
                              ),
                            ),
                          ),
                  ]
                        ],
                      ),
                    ),
                  );
                }).toList();

                return RawScrollbar(
                  controller: scrollController,
                  interactive: false,
                  trackVisibility: false,
                  thickness: 0,
                  padding: EdgeInsets.symmetric(vertical: 0),
                  thumbVisibility: false,
                  thumbColor: Theme.of(context).primaryColor,
                  radius: const Radius.circular(8),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4), // Space for scrollbar
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minWidth: constraints.maxWidth),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: tabs,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

enum TaskFilter {
  task_notification,
  all,
  assignment_pending,
  assigned,
  accepted,
  submitted,
  reviewed,
  send_back,
  closed,
  rejected,
  reopened,
  cancelled,
}
