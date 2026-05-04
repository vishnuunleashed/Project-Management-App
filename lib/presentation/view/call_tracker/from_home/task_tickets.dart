import 'package:base/core/loader_value.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/call_tracker/task_model.dart';
import 'package:interior_design/presentation/provider/call_tracker/from_home/tasks_wise_ticket_provider.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/call_tracker/detail_view/_partials/_partials/task_filter_tab.dart';
import 'package:interior_design/presentation/view/call_tracker/from_home/partials/service_task_filter.dart';
import 'package:interior_design/presentation/view/call_tracker/widgets/status_badge_parent.dart';
import 'package:interior_design/presentation/view/project_details/partials/empty_list_view.dart';
import 'package:interior_design/utils/routes.dart';

class ServiceTasksTicketListScreen extends ConsumerStatefulWidget {
  const ServiceTasksTicketListScreen({super.key});

  @override
  ConsumerState<ServiceTasksTicketListScreen> createState() =>
      _CallTrackerPageState();
}

class _CallTrackerPageState
    extends ConsumerState<ServiceTasksTicketListScreen> with RouteAware{

  @override
  void didPopNext() {
    final TasksWiseTicketProvider provider = ref.read(tasksWiseTicketProvider);
    if(provider.isFromDashboard){
      provider.loadTasksFromDashboard();
    }
    else{
      provider.loadTasksFromHome();
    }
    super.didPopNext();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ObserverUtils.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    ObserverUtils.routeObserver.unsubscribe(this);
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseView<TasksWiseTicketProvider>(
      initState: (context, provider, ref) {},
      appBar: CustomAppBar(
        title: Row(
          children: [
            Text("Service Task Status"),
          ],
        ),
      ),
      provider: tasksWiseTicketProvider,
      builder: (context, provider, ref) {

        return (provider.loadingStatus.loader == Loader.loading) ? SizedBox.shrink() : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding:
              const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    "Service Ticket Tasks",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (ref
                      .watch(tasksWiseTicketProvider)
                      .tasksTicket
                      .isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.primaryColor
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${ref.watch(tasksWiseTicketProvider).tasksTicket.length}",
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Visibility(
              visible: provider.isFromDashboard,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Card(
                        color: theme.cardColor,
                        elevation: 0.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.dashboard_outlined,
                                size: 14,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 8),

                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(
                                      flex: 2,
                                      child: Text(
                                        provider.serviceTrackerHeader ?? "",
                                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),

                                    if ((provider.serviceTrackerSubHeader ?? "").isNotEmpty) ...[
                                      const SizedBox(width: 4),
                                      Flexible(
                                        flex: 1,
                                        child: Text(
                                          "- ${provider.serviceTrackerSubHeader}",
                                          style: Theme.of(context).textTheme.labelSmall,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ),

            Visibility(
              visible: provider.isFromDashboard,
                child: ServiceTaskDashboardFilterTab(providerRef: tasksWiseTicketProvider)),
            // ── List ────────────────────────────────────────────────
            (provider.tasksTicket.isEmpty)
                ?    Expanded(
                  child: Center(
                          child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          EmptyListView(
                          emptyText: "No pending service tasks found.",

                          ),
                          const SizedBox(height: 8),
                          ],
                          ),
                          ),
                )
                :
            Expanded(
              child: RefreshIndicator(
                onRefresh: ()async{
                  provider.loadTasksFromHome(changeStart: true);
                },
                color: theme.primaryColor,
                child: ListView.builder(
                  controller: provider.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
                  itemCount: provider.tasksTicket.length,
                  itemBuilder: (context, index) {
                    final tasksTicket = provider.tasksTicket[index];
                    return ServiceTasksTicketCard(
                      tasksTicket: tasksTicket,
                      provider: provider,
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card
// ─────────────────────────────────────────────────────────────────────────────

class ServiceTasksTicketCard extends ConsumerWidget {
  final TaskModel tasksTicket;
  final TasksWiseTicketProvider provider;

  const ServiceTasksTicketCard({
    super.key,
    required this.tasksTicket,
    required this.provider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        elevation: 0.5,
        color: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            GoRouter.of(context).pushNamed(
              AppRoutes.serviceDetailsScreenDirect,
              extra: {
                "transid": tasksTicket.ticketId,
                "taskId":tasksTicket.id,
                "selectedTaskFilter": _resolveTaskFilter(tasksTicket.statusCode),
              },
            );
          },
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Card content ─────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Top row: serial + ticket no + status ──
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "T${tasksTicket.slno}",
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: bayaInfraWhiteColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withValues(alpha: 0.1),
                                // border: Border.all(
                                //   color: theme.dividerColor,
                                //   width: 0.5,
                                // ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.confirmation_number_outlined,
                                    size: 12,
                                    color: theme.primaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    tasksTicket.ticketNo ?? '—',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                           _buildTaskStatusBadge(context, tasksTicket.statusCode ?? "")
                          ],
                        ),

                        // ── Not In Scope badge ────────────────────
                        if (tasksTicket.workStatusCode == "NOTINSCOPE") ...[
                          const SizedBox(height: 8),
                          _buildNotInScopeBadge(
                              context, tasksTicket.workStatusName ?? ""),
                        ],

                        // ── Description ──────────────────────────
                        if (tasksTicket.description != null &&
                            tasksTicket.description!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _buildTextRow(
                            context,
                            icon: Icons.subject_rounded,
                            text: tasksTicket.description!,
                          ),
                        ],

                        // ── Status remarks ───────────────────────
                        if (tasksTicket.statusRemarks != null &&
                            tasksTicket.statusRemarks!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          _buildTextRow(
                            context,
                            icon: Icons.description_outlined,
                            text: tasksTicket.statusRemarks!,
                          ),
                        ],
// ── Client dependency ─────────────────────
                        if (tasksTicket.clientDependencyYN == true) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.link_rounded,
                                  size: 13,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  "Client Dependent",
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.amber,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        // ── Divider + meta grid ───────────────────
                        const SizedBox(height: 10),
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          color: theme.dividerColor,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetaItem(
                                context,
                                icon: Icons.person_outline_rounded,
                                label: "Task Owner",
                                value: (tasksTicket.assignedEngineerName != null &&
                                    tasksTicket.assignedEngineerName!
                                        .isNotEmpty)
                                    ? tasksTicket.assignedEngineerName!
                                    : null,
                                fallback: "Unassigned",
                              ),
                            ),
                            Expanded(
                              child: _buildMetaItem(
                                context,
                                icon: Icons.calendar_today_outlined,
                                label: "Target closure",
                                value: formatDate(tasksTicket.targetClosureDate ?? ""),
                                fallback: "—",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextRow(
      BuildContext context, {
        required IconData icon,
        required String text,
      }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: theme.primaryColor),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.labelMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMetaItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String? value,
        required String fallback,
      }) {
    final theme = Theme.of(context);
    final hasValue = value != null && value.isNotEmpty;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14,
              color: theme.primaryColor),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w400
                ),
              ),
              const SizedBox(height: 1),
              Text(
                hasValue ? value : fallback,
                style: theme.textTheme.labelMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  TaskFilter _resolveTaskFilter(String? statusCode) {
    return switch (statusCode) {
      "SUBMITTED" => TaskFilter.submitted,
      "PENDING" || "ASSIGNMENT_PENDING" => TaskFilter.assignment_pending,
      "REVIEWD" || "REVIEWED" => TaskFilter.reviewed,
      "SEND_BACK" => TaskFilter.send_back,
      "ASSIGNED" => TaskFilter.assigned,
      "ACCEPTED" => TaskFilter.accepted,
      "CLOSED" => TaskFilter.closed,
      "REJECTED" => TaskFilter.rejected,
      "REOPENED" => TaskFilter.reopened,
      "CANCELLED" => TaskFilter.cancelled,
      _ => TaskFilter.all,
    };
  }
}

Widget _buildNotInScopeBadge(
    BuildContext context, String status,) {
  Color textColor = bayaInfraWhiteColor;
  String displayStatus = status;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [new4, new4.withValues(alpha: 0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.block, size: 12, color: textColor),
        const SizedBox(width: 6),
        Text(
          displayStatus,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    ),
  );
}

String formatDate(String date) {
  if(date.isEmpty){
    return "";
  }
  final parsedDate = DateTime.parse(date);
  return "${parsedDate.day.toString().padLeft(2, '0')}-"
      "${parsedDate.month.toString().padLeft(2, '0')}-"
      "${parsedDate.year}";
}

Widget _buildTaskStatusBadge(
    BuildContext context, String status) {
  Color backgroundColor;
  Color textColor = bayaInfraWhiteColor;
  IconData icon;
  String displayStatus = status;

  switch (status.toUpperCase()) {
    case "ASSIGNMENT_PENDING":
    case "PENDING":
      backgroundColor = const Color(0xFFE2E8F0);
      textColor = const Color(0xFF475569);
      icon = Icons.pending_outlined;
      displayStatus = "PENDING";
      break;
    case "ASSIGNED":
      backgroundColor = const Color(0xFFE0F2FE);
      textColor = const Color(0xFF0369A1);
      icon = Icons.person_outline;
      displayStatus = "ASSIGNED";
      break;
    case "ACCEPTED":
    case "IN_PROGRESS":
      backgroundColor = const Color(0xFFD8FCD8);
      textColor = const Color(0xFF1C811C);
      icon = Icons.play_circle_outline;
      displayStatus = status.toUpperCase();
      break;
    case "SUBMITTED":
      backgroundColor = const Color(0xFFDBEAFE);
      textColor = const Color(0xFF1D4ED8);
      icon = Icons.send_rounded;
      displayStatus = "SUBMITTED";
      break;
    case "REVIEWD":
    case "REVIEWED":
      backgroundColor = const Color(0xFFEDE9FE);
      textColor = const Color(0xFF6D28D9);
      icon = Icons.rate_review_outlined;
      displayStatus = "REVIEWED";
      break;
    case "SEND_BACK":
      backgroundColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFFDC2626);
      icon = Icons.replay;
      displayStatus = "REJECTED";
      break;
    case "REJECTED":
      backgroundColor = const Color(0xFFFEE2E2);
      textColor = const Color(0xFFDC2626);
      icon = Icons.assignment_return_outlined;
      displayStatus = "REJECTED";
      break;
    case "CLOSED":
      backgroundColor = const Color(0xFF1C811C);
      textColor = Colors.white;
      icon = Icons.check_circle_outline;
      displayStatus = "CLOSED";
      break;
    case "REOPENED":
      backgroundColor = const Color(0xFFFAD4FA);
      textColor = const Color(0xFFC5219C);
      icon = Icons.history_rounded;
      displayStatus = "REOPENED";
      break;
    case "CANCELLED":
      backgroundColor = const Color(0xFFDC2626);
      textColor = Colors.white;
      icon = Icons.cancel_outlined;
      displayStatus = "CANCELLED";
      break;
    default:
      backgroundColor = bayaInfraGreyColor;
      textColor = Colors.white;
      icon = Icons.help_outline;
      displayStatus = status.toUpperCase();
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: textColor.withValues(alpha: 0.2),
        width: 1,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: textColor),
        const SizedBox(width: 6),
        Text(
          displayStatus,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: textColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            fontSize: 10,
          ),
        ),
      ],
    ),
  );
}