import 'package:base/presentation/base/base_consumer.dart';
import 'package:base/presentation/views/base_loading_spinner.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
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

class ServiceTasksScreen extends ConsumerStatefulWidget {
  const ServiceTasksScreen({super.key});

  @override
  ConsumerState<ServiceTasksScreen> createState() => _ServiceTasksScreenState();
}

class _ServiceTasksScreenState extends ConsumerState<ServiceTasksScreen> {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = ref.watch(serviceRequestDashboardProvider);

    return BaseConsumer(
      provider: serviceRequestDashboardProvider,
      initState: (context, provider, ref) {
        final state = GoRouterState.of(context);
        final extra = state.extra as Map<String, dynamic>?;
        if (extra != null && extra["taskId"] != null) {
          final taskId = extra["taskId"];
          final index = provider.displayedTasks.indexWhere((task) => task.id == taskId);
          if (index != -1) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (itemScrollController.isAttached) {
                itemScrollController.scrollTo(
                  index: index,
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOut,
                );
              }
            });
          }
        }
      },
      builder: (context,provider,ref) {
        return Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TaskFilterTab(),
                  ],
                ),
                Expanded(
                  child: provider.displayedTasks.isEmpty
                      ? _buildEmptyState(theme, provider.selectedTaskFilter)
                      : ScrollablePositionedList.separated(
                    itemScrollController: itemScrollController,
                    itemPositionsListener: itemPositionsListener,
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
                    itemCount: provider.displayedTasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      return DashboardTaskCard(
                          provider: provider,
                          task: provider.displayedTasks[index],
                          taskIndex: index,
                      );

                    },
                  ),
                ),
                if (provider.selectedTaskFilter == TaskFilter.assigned &&
                    provider.tasks.any((item) =>
                        item.statusCode == "ASSIGNED" &&
                        (item.assignedUserId == provider.loggedInUserID ||
                            provider.isSuperUser)))
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: BaseElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: theme.cardColor,
                            title: Text('Accept Assignment',
                                style: theme.textTheme.titleMedium),
                            content: Text(
                                'Do you want to Accept Assignment for this service ticket?\n\nThis will mark all assigned tasks as Accepted and ticket as In Progress.',
                                style: theme.textTheme.titleSmall),
                            actions: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.2,
                                    child: BaseElevatedButton(
                                      onPressed: () => GoRouter.of(context).pop(),
                                      text: 'Cancel',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.2,
                                    child: BaseElevatedButton(
                                      onPressed: () {
                                        GoRouter.of(context).pop();
                                        if (provider is ServiceRequestDashboardProvider) {
                                          provider.acceptAssignment(
                                            onSuccess: (msg) => _showSuccess(msg, ref),
                                            onFailure: (err) =>
                                                _showError(err.toString()),
                                          );
                                        }
                                      },
                                      text: 'Confirm',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                      text: 'Accept Assignment',
                    ),
                  ),
              ],
            ),
            Visibility(
              visible: provider.showLoaderForClose,
              child: BaseLoadingSpinner(
                progress: 0,
              ),
            ),



          ],
        );
      }
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



  void _showSuccess(String message, WidgetRef ref) {
    onSaveDialog(
      title: "Success",
      transNo: "",
      icon: Icons.check_circle_outlined,
      iconColor: bayaInfraGreen,
      message: "Task accepted Successfully.",
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