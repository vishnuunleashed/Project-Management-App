import 'package:base/presentation/utility/navigator_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_design/data/model/response/call_tracker/call_tracker_model.dart';
import 'package:interior_design/presentation/provider/call_tracker/providers/service_tasks_provider.dart';
import 'package:interior_design/presentation/view/call_tracker/detail_view/_partials/_partials/task_filter_tab.dart';
import 'package:interior_design/presentation/view/call_tracker/add_service_request/widgets/add_task_sheet.dart';
import 'package:interior_design/presentation/view/call_tracker/detail_view/_partials/add_service_task_card.dart';
import 'package:interior_design/presentation/view/call_tracker/detail_view/_partials/dashboard_task_card.dart';
import 'package:interior_design/presentation/provider/call_tracker/add_service_request_provider.dart';
import 'package:base/presentation/utility/base_dialog.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/provider/call_tracker/providers/service_request_dashboard_provider.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:intl/intl.dart';

class AddServiceTasksScreen extends ConsumerWidget {

  const AddServiceTasksScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final provider = ref.watch(addServiceRequestProvider);

    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: provider.tasks.isEmpty
                  ? _buildEmptyState(theme, provider.selectedTaskFilter)
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
                itemCount: provider.tasks.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return AddServiceTaskCard(
                      provider: provider,
                      task: provider.tasks[index],
                      taskIndex: index,
                      onDelete: () => provider.removeTask(index),
                      onEdit: () => showAddTaskSheet(
                          context,
                          ref,
                          editIndex: index,
                          task: provider.tasks[index]
                      ),
                    );
                  },
              ),
            ),
          ],
        ),

        // FAB
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            heroTag: 'add_task_fab',
            backgroundColor: theme.primaryColor,
            onPressed: () => showAddTaskSheet(context, ref),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }


  // ── Empty state ──────────────────────────────────────────────────────────
  String _getEmptyMessage(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.task_notification:
        return "Data not available";
      case TaskFilter.all:
        return 'No tasks yet';
      case TaskFilter.assignment_pending:
        return 'No assignment pending tasks';
      case TaskFilter.assigned:
        return 'No assigned tasks';
      case TaskFilter.accepted:
        return 'No accepted tasks';
      case TaskFilter.submitted:
        return 'No submitted tasks';
      case TaskFilter.send_back:
        return 'No rejected tasks';
      case TaskFilter.reviewed:
        return 'No reviewed tasks';
      case TaskFilter.closed:
        return 'No closed tasks';
      case TaskFilter.rejected:
        return 'No returned tasks';
      case TaskFilter.reopened:
        return 'No reopened tasks';
      case TaskFilter.cancelled:
        return 'No cancelled tasks';
    }
  }

  Widget _buildEmptyState(ThemeData theme, TaskFilter filter) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.checklist_rounded,
            size: 64,
            color: theme.textTheme.bodySmall?.color,
          ),
          const SizedBox(height: 14),
          Text(
            _getEmptyMessage(filter),
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom sheet ─────────────────────────────────────────────────────────
  void showAddTaskSheet(BuildContext context, WidgetRef ref, {int? editIndex, ServiceTaskModel? task}) {
    final provider = ref.read(addServiceRequestProvider);

    if (editIndex == null) {
      provider.clearTaskBottomSheet();
      if (provider.selectedEngineer != null) {
          try {
            final engineer = provider.engineerList.firstWhere((e) => e.name == provider.selectedEngineer);
            provider.setTaskOwner(engineer.id, engineer.name);
          } catch (_) {}
        }
        if (provider.selectedClosureDate != null) {
          provider.taskTargetClosureDate = DateFormat('yyyy-MM-dd').format(provider.selectedClosureDate!);}

    } else {
      provider.fillTaskDetails(task!, editIndex);
    }

    showModalBottomSheet(
      isDismissible: false,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => UncontrolledProviderScope(
        container: ProviderScope.containerOf(context),
        child: AddTaskSheet(
          taskId: task?.id ?? 0,
          task: task ?? ServiceTaskModel(),
          isEditMode: editIndex != null,
          editIndex: editIndex,
        ),
      ),
    );
  }

  void _showSuccess(String message, WidgetRef ref) {
    onSaveDialog(
      title: "Success",
      transNo: "",
      icon: Icons.check_circle_outlined,
      iconColor: bayaInfraGreen,
      message: message,
      onClick: () {
        GoRouter.of(NavigatorKey.navKey.currentState!.context).pop();
        ref.read(callTrackerProvider).loadTickets();
      },
    );
  }

  void _showError(String message) {
    onSaveDialog(
      title: "Error",
      transNo: "",
      icon: Icons.error_outline,
      iconColor: bayaInfraRed,
      message: message,
      onClick: () => GoRouter.of(NavigatorKey.navKey.currentState!.context).pop(),
    );
  }

  void onSaveDialog({
    required String title,
    required String transNo,
    required IconData icon,
    required Color iconColor,
    required String message,
    required VoidCallback onClick,
  }) {
    BaseDialog.show(
        context: NavigatorKey.navKey.currentState!.context,
        title: title,
        message: message,
        transNo: transNo,
        icon: Icon(
          icon,
          color: iconColor,
          size: 36,
        ),
        actions: [
          BaseElevatedButton(
              borderRadius: 24,
              backgroundColor: Theme.of(NavigatorKey.navKey.currentState!.context)
                  .primaryColor,
              onPressed: onClick,
              text: "Ok")
        ]);
  }
}

class TaskCountSummary extends StatelessWidget {
  final int count;
  final TaskFilter selectedFilter;

  const TaskCountSummary({super.key, required this.count, required this.selectedFilter});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 5),
            Text(
              "Count",
              style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
              child: Text(
                '$count',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}