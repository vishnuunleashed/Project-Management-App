import 'package:base/presentation/base/base_consumer.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_dialog.dart';
import 'package:base/presentation/utility/navigator_key.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:base/presentation/views/loading_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/call_tracker/call_tracker_model.dart';
import 'package:interior_design/presentation/provider/call_tracker/providers/service_request_dashboard_provider.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/call_tracker/detail_view/_partials/_partials/task_filter_tab.dart';
import 'package:interior_design/presentation/view/call_tracker/widgets/status_badge_parent.dart';
import 'package:interior_design/presentation/view/service_tasks/service_tasks_screen.dart';
import 'package:interior_design/utils/routes.dart';
import '_partials/service_ticket_detail_tab_one.dart';

class ServiceDetailsScreen extends ConsumerStatefulWidget {
  const ServiceDetailsScreen({super.key});

  @override
  ConsumerState<ServiceDetailsScreen> createState() =>
      _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends ConsumerState<ServiceDetailsScreen> with RouteAware,TickerProviderStateMixin {
  // ── RouteAware lifecycle ───────────────────────────────────────────────

  bool _tabControllerInitialized = false;
  late TabController _tabController;

  @override
  void didPopNext() {
    final provider = ref.read(serviceDetailsLandingProvider);
    provider.refreshIfNeeded();

    final dashProvider = ref.read(serviceRequestDashboardProvider);
    dashProvider.fetchCallTrackerInfo(taskId: dashProvider.currentTaskId);

    super.didPopNext();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ObserverUtils.routeObserver.subscribe(this, ModalRoute.of(context)!);
    if (!_tabControllerInitialized) {
      _tabControllerInitialized = true;

      //  Now safely initialize with the correct initialIndex
      _tabController = TabController(
        length: 2,
        vsync: this,
        initialIndex: 0,
      );
    }

  }

  @override
  void dispose() {
    ObserverUtils.routeObserver.unsubscribe(this);

    super.dispose();
  }


  int innerTabIndex = 0;
  bool _tasksSynced = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseView<ServiceRequestDashboardProvider>(
      initState: (context, provider, ref) {
        final state = GoRouterState.of(context);
        final extra = state.extra as Map<String, dynamic>?;
        _tabController = TabController(length: 2, vsync: this);
        provider.initState(extra: extra);


        if (extra!["notificationid"] != null) {
          provider.setNotificationId(extra["notificationid"]);
        } else if (extra["notificationId"] != null) {
          provider.setNotificationId(extra["notificationId"]);
        }

        if (extra!["selectedTaskFilter"] != null) {
          provider.changeFilter(extra["selectedTaskFilter"]);
          _tabController.animateTo(1);
        } else {
          // Default to 'all' filter when coming from dashboard
          provider.changeFilter(TaskFilter.all);
        }
      },
      appBar: CustomAppBar(
        title: const Text("Service Details"),

      ),
      provider: serviceRequestDashboardProvider,
      builder: (context, provider, ref) {
        CallTicketModel? ticket = provider.currentTicket;
        if (ticket == null) {
          _tasksSynced = false;
          return const SizedBox(height: 0);
        }

        if (!_tasksSynced) {
          _tasksSynced = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(serviceTasksProvider)
                .tasks =
                List.from(ticket.tasks ?? []);
          });
        }

        if (provider.desiredInnerTabIndex != -1 &&
            provider.desiredInnerTabIndex !=
                100) { // Using 100 as a sentinel or just checking != -1
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_tabController.index != provider.desiredInnerTabIndex) {
              _tabController.animateTo(provider.desiredInnerTabIndex);
            }
            provider.resetDesiredTab();
          });
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _buildTicketHeader(context, theme, ticket),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.1)),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: false,
                tabAlignment: TabAlignment.fill,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerHeight: 0,
                indicator: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: theme.textTheme.titleLarge?.color
                    ?.withValues(alpha: 0.6),
                labelStyle: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                unselectedLabelStyle: theme.textTheme.titleLarge,
                tabs: const [
                  Tab(text: 'Service Ticket'),
                  Tab(text: 'Tasks'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                // Default physics allows swiping
                children: [
                  const ServiceTicketDetailTabOne(),
                  ServiceTasksScreen(),
                ],
              ),
            ),

            //  Common bottom bar
            // _buildCommonBottom(context, theme, ticket, provider),
          ],
        );
      },
    );
  }

  Widget _buildTicketHeader(BuildContext context, ThemeData theme,
      CallTicketModel ticket) {
    final theme = Theme.of(context);
    return BaseConsumer(
        provider: serviceRequestDashboardProvider,
        builder: (context, provider, ref) {
          return Card(
            elevation: 0.5,
            margin: EdgeInsets.zero,
            color: Theme
                .of(context)
                .cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                width: 0.5,
                color: Theme
                    .of(context)
                    .cardColor,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: 12.0, horizontal: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ticket No : ',
                              style: theme.textTheme.titleSmall,
                            ),
                            Text(
                              ticket.ticketNo ?? '',
                              style: theme.textTheme.titleSmall,
                            ),

                          ],
                        ),
                      ),
                      StatusBadge(
                        status: ticket.status ?? '',
                        size: StatusButtonSize.compact,
                      ),
                    ],
                  ),

                ],
              ),
            ),
          );
        }
    );
  }




  Widget _buildCommonBottom(BuildContext context,
      ThemeData theme,
      CallTicketModel ticket,
      ServiceRequestDashboardProvider provider,) {
    // final allTasksReviewed = provider.tasks.isNotEmpty &&
    //     provider.tasks.every((task) => task.statusCode == "REVIEWD");

    // final showSaveTasks = innerTabIndex == 1;

    // final showCancel = (provider.loggedInUserID == ticket.coordinateuserid ||
    //         provider.isSuperUser) &&
    //     ticket.statusCode != "CANCELLED" &&
    //     ticket.statusCode != "CLOSED";

    // if (!showCancel) return const SizedBox.shrink();
    // final showSubmitReview = (ticket.statusCode == "IN_PROGRESS" ||
    //         ticket.statusCode == "REJECTED") &&
    //     (provider.loggedInUserID == ticket.assignedUserId ||
    //         provider.isSuperUser) && allTasksReviewed;
    // final showReviewWork = ticket.statusCode == "SUBMITTED" &&
    //     (provider.loggedInUserID == ticket.serviceReportUserId ||
    //         provider.isSuperUser);
    // final showClose = ticket.statusCode == "IN_PROGRESS" && allTasksReviewed &&
    //     (provider.loggedInUserID == ticket.coordinateuserid ||
    //         provider.isSuperUser);

    return Card(
      color: theme.cardColor,
      margin: EdgeInsets.zero,
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            // Accept Assignment moved to tasks list bottom

            // Close Ticket
            // if (showClose)
            //   Padding(
            //     padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 4),
            //     child: BaseElevatedButton(
            //       onPressed: () =>
            //           _showNotifyConfirmation(
            //             context,
            //             title: "Close Tasks",
            //             message: "Are you sure you want to close all tasks?",
            //             onConfirm: (notify) =>
            //                 provider.closeServiceTicket(
            //                   notifyClient: notify,
            //                   onSuccess: (msg) => _showSuccess( msg),
            //                   onFailure: (err) =>
            //                       _showError( err.toString()),
            //                 ),
            //           ),
            //       text: 'Close Tasks',
            //     ),
            //   ),

            // Cancel Ticket (New)
            // if ((provider.loggedInUserID == ticket.coordinateuserid ||
            //     provider.isSuperUser) && ticket.statusCode != "CANCELLED" &&
            //     ticket.statusCode != "CLOSED")
            //   Padding(
            //     padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
            //     child: BaseElevatedButton(
            //       onPressed: () =>
            //           _showNotifyConfirmation(
            //             context,
            //             title: "Cancel Ticket",
            //             message: "Are you sure you want to cancel this service ticket?",
            //             onConfirm: (notify) =>
            //                 provider.cancelServiceTicket(
            //                   notifyClient: notify,
            //                   onSuccess: () =>
            //                       _showSuccess(
            //                        "Ticket cancelled successfully"),
            //                   onFailure: (err) =>
            //                       _showError( err.toString()),
            //                 ),
            //           ),
            //       text: 'Cancel Ticket',
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }

  void _showNotifyConfirmation(BuildContext context,
      {required String title, required String message, required Function(bool) onConfirm}) {
    bool notify = false;
    showDialog(
      context: context,
      builder: (context) =>
          StatefulBuilder(
            builder: (context, setState) =>
                AlertDialog(
                  backgroundColor: Theme
                      .of(context)
                      .cardColor,
                  title: Text(title, style: Theme
                      .of(context)
                      .textTheme
                      .titleLarge),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(message, style: Theme
                          .of(context)
                          .textTheme
                          .labelLarge),
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text("Notify client via email?",
                            style: TextStyle(fontSize: 14)),
                        value: notify,
                        onChanged: (val) =>
                            setState(() => notify = val ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ],
                  ),
                  actions: [
                    Row(
                      children: [
                        Expanded(
                          child: BaseElevatedButton(
                            fontWeight: FontWeight.w700,
                            backgroundColor: bayaInfraDisabledColor,
                            onPressed: () => GoRouter.of(context).pop(),
                            text: "Cancel",
                          ),
                        ),
                        SizedBox(width: 8,),
                        Expanded(
                          child: BaseElevatedButton(
                            backgroundColor: Theme.of(context).primaryColor,
                            onPressed: () {
                              GoRouter.of(context).pop();
                              onConfirm(notify);
                            },
                            text: "Confirm"),
                        ),
                      ],
                    ),
                    
                  ],
                ),
          ),
    );
  }

  String getRemainingTime(String targetClosureDate) {
    final targetDate = DateTime.parse(targetClosureDate);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final difference = targetDate
        .difference(today)
        .inDays;

    if (difference < 0) {
      return 'Delayed';
    } else if (difference == 0) {
      return 'Due today';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else {
      return '$difference day${difference > 1 ? 's' : ''} left';
    }
  }
}

void _showSuccess(String message) {
  onSaveDialog(
    title: "Success",
    transNo: "",
    icon: Icons.check_circle_outlined,
    iconColor: bayaInfraGreen,
    message: message,
    onClick: () {
      GoRouter.of(NavigatorKey.navKey.currentState!.context).pop();
      ProviderScope.containerOf(NavigatorKey.navKey.currentState!.context,).read(callTrackerProvider).loadTickets();
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
    onClick: () =>  GoRouter.of(NavigatorKey.navKey.currentState!.context).pop(),
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
            backgroundColor: Theme
                .of(NavigatorKey.navKey.currentState!.context)
                .primaryColor,
            onPressed: onClick,
            text: "Ok")
      ]);
}
