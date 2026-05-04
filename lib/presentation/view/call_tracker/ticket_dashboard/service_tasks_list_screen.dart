import 'package:base/core/loader_value.dart';
import 'package:base/presentation/base/base_consumer.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/call_tracker/call_tracker_model.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/presentation/provider/call_tracker/dashboard_filter_provider.dart';
import 'package:interior_design/presentation/provider/call_tracker/service_ticket_dashboard_provider.dart';
import 'package:interior_design/presentation/provider/call_tracker/ticket_dashboard/service_tasks_provider.dart';

import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/call_tracker/detail_view/_partials/_partials/task_filter_tab.dart';
import 'package:interior_design/presentation/view/call_tracker/widgets/status_badge_parent.dart';
import 'package:interior_design/presentation/view/common/cached_image_view.dart';
import 'package:interior_design/presentation/view/common/client_multi_select.dart';
import 'package:interior_design/presentation/view/common/common_date_picker.dart';
import 'package:interior_design/presentation/view/common/common_selection_dialog.dart';
import 'package:interior_design/presentation/view/common/view_profile_image.dart';
import 'package:interior_design/presentation/view/project_details/partials/empty_list_view.dart';
import 'package:interior_design/utils/routes.dart';
import 'package:intl/intl.dart';

class ServiceTasksListScreen extends ConsumerStatefulWidget {
  const ServiceTasksListScreen({super.key});

  @override
  ConsumerState<ServiceTasksListScreen> createState() => _CallTrackerPageState();
}

class _CallTrackerPageState extends ConsumerState<ServiceTasksListScreen> {

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return BaseView<ServiceTasksListProvider>(
      initState: (context, provider, ref) {

      },
      appBar: CustomAppBar(
        title: Row(
          children: [
            Text("Service Tickets",),
          ],
        ),
      ),
      provider: serviceTasksListProvider,

      // virtualFloatingActionButton: BaseConsumer(
      //     provider: serviceTasksListProvider,
      //     builder: (context, provider, ref) {
      //       final dashboardProvider = ref.read(serviceTicketDashboardProvider);
      //       return Padding(
      //         padding: const EdgeInsets.only(bottom: 56),
      //         child: Row(
      //           children: [
      //             FloatingActionButton(
      //                 backgroundColor: Theme.of(context).primaryColor,
      //                 heroTag: "Filter",
      //                 child: Icon(Icons.filter_list,color: bayaInfraWhiteColor,),
      //                 onPressed: () {
      //                   showModalBottomSheet(
      //                     context: context,
      //                     isScrollControlled: true,
      //                     backgroundColor: Colors.transparent,
      //                     builder: (context) =>  ServiceDashBoardFilterBottomSheet(serviceTasksListProvider: provider,dashboardProvider: dashboardProvider,),
      //                   );
      //                 }
      //             ),
      //           ],
      //         ),
      //       );
      //     }
      // ),
      builder: (context, provider, ref) {

        if(provider.loadingStatus.loader == Loader.loading){
          return SizedBox();
        }
        if (provider.serviceTasks.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                EmptyListView(
                    emptyText: "No pending service serviceTasks found.",
              ),
                const SizedBox(height: 8),
               
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0),
                      child:  Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: "Service Tickets ",
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            TextSpan(
                              text: provider.serviceTasks.isEmpty
                                  ? ''
                                  : "(${provider.serviceTasks.first.totalRecords})",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      )
                  ),



                ],
              ),
            ),
            SizedBox(height: 2,),
            Padding(
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
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: provider.refreshTickets,
                color: theme.primaryColor,
                child: ListView.builder(
                  controller: provider.scrollController,
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 4,horizontal: 4),
                  itemCount: provider.serviceTasks.length,
                  itemBuilder: (context, index) {

                    final serviceTasks = provider.serviceTasks[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: index == (provider.serviceTasks.length - 1)?86:0),
                      child: TicketCard(
                        ticket: serviceTasks ,
                        provider: provider,
                      ),
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





class TicketCard extends StatelessWidget {
  final CallTicketModel ticket;
  final ServiceTasksListProvider provider;
  final bool isFromDashboard;

  const TicketCard({
    super.key,
    required this.ticket,
    required this.provider,
    this.isFromDashboard = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0.5,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          if (ticket.statusCode != "CANCELLED") {
            GoRouter.of(context).pushNamed(
              AppRoutes.serviceCallTrackerDetailViewDirect,
              extra: {
                "transid": ticket.id,
                "isFromCallTracker": isFromDashboard,
              },
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header Row ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(

                    children: [
                      SizedBox(
                        height: 50,
                        width: 50,
                        child: SvgPicture.asset(
                            "assets/svgs/task_icon.svg"),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Ticket No",style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),),
                          const SizedBox(width: 4),
                          Text(
                            ticket.ticketNo ?? '',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  StatusBadge(
                    status: ticket.status ?? "",
                    size: StatusButtonSize.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // --- Ticket ID & Description ---

              if (ticket.description != null && ticket.description!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  ticket.description ?? '',
                  style: theme.textTheme.titleSmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 4),

              // --- Location & Client ---
              Container(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      context,
                      Icons.location_on_outlined,
                      '${ticket.site} - ${ticket.building}, ${ticket.floor}',
                      theme.iconTheme.color!.withValues(alpha: 0.7),
                      theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    _buildInfoRow(
                      context,
                      Icons.business_outlined,
                      ticket.client ?? '',
                      theme.iconTheme.color!.withValues(alpha: 0.7),
                      theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // --- Chips: Priority & Category ---
              Row(
                children: [
                  _buildChip(
                    context,
                    ticket.priority ?? '',
                    Icons.flag_rounded,
                    provider.getPriorityColor(ticket.priority),
                  ),
                  const SizedBox(width: 8),
                  _buildChip(
                    context,
                    ticket.category ?? '',
                    Icons.category_outlined,
                    theme.iconTheme.color!,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildDateItem(
                    context,
                    Icons.calendar_today_outlined,
                    'Created',
                    _formatDate(ticket.ticketDate ?? ""),
                  ),
              // --- Footer: Dates ---
              // Row(
              //   children: [
              //
              //     if (ticket.targetClosureDate != null &&
              //         ticket.targetClosureDate!.isNotEmpty) ...[
              //       const SizedBox(width: 16),
              //       _buildDateItem(
              //         context,
              //         Icons.history_toggle_off_outlined,
              //         'Target',
              //         _formatDate(ticket.targetClosureDate ?? ""),
              //       ),
              //     ],
              //   ],
              // ),

              // --- Engineer Footer ---
              // if (ticket.assignedUser != null) ...[
              //   const SizedBox(height: 8),
              //   Container(
              //     width: double.infinity,
              //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              //     decoration: BoxDecoration(
              //       color: theme.primaryColor.withValues(alpha: 0.05),
              //       borderRadius: BorderRadius.circular(8),
              //     ),
              //     child: Row(
              //       children: [
              //         Icon(Icons.engineering_outlined,
              //             size: 15, color: theme.primaryColor),
              //         const SizedBox(width: 8),
              //         Text(
              //           'Task Owner:',
              //           style: theme.textTheme.labelLarge?.copyWith(
              //             color: theme.textTheme.titleMedium?.color?.withValues(alpha: 0.7),
              //             fontWeight: FontWeight.w500,
              //           ),
              //         ),
              //         const SizedBox(width: 4),
              //         Expanded(
              //           child: Text(
              //             ticket..assignedUser ?? '',
              //             style: theme.textTheme.labelLarge?.copyWith(
              //               fontWeight: FontWeight.bold,
              //             ),
              //             overflow: TextOverflow.ellipsis,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateItem(
      BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.iconTheme.color?.withValues(alpha:  0.6)),
        const SizedBox(width: 6),
        Text(
            '$label: ',
            style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)
        ),
        Text(
          value,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
      BuildContext context,
      IconData icon,
      String text,
      Color color,
      TextStyle? textStyle,
      ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: textStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date);
      return '${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}';
    } catch (e) {
      return date;
    }
  }
}

class ServiceDashBoardFilterBottomSheet extends StatelessWidget {
  final ServiceTasksListProvider serviceTasksListProvider; //  keep to call fetchDashboardData
  final ServiceTicketDashboardProvider dashboardProvider; //  keep to call fetchDashboardData

  const ServiceDashBoardFilterBottomSheet({
    super.key,
    required this.serviceTasksListProvider,
    required this.dashboardProvider
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseConsumer(
      provider: dashboardFilterProvider,
      builder: (context, provider, ref) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: theme.dialogTheme.backgroundColor ?? theme.cardColor,
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // ── HEADER ──────────────────────────────────────────
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 4),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.disabledColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Dashboard',
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () => GoRouter.of(context).pop(),
                          icon: Icon(Icons.close,
                              color: theme.iconTheme.color),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: theme.dividerColor),

                  // ── SCROLLABLE CONTENT ───────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: EdgeInsets.only(
                        left: 8,
                        right: 8,
                        top: 8,
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),

                          // Date Row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Text("Date From",
                                        style: theme.textTheme.titleMedium),
                                    const SizedBox(height: 8),
                                    CommonDatesPicker(
                                      onChange: (date) => provider
                                          .changeDateFromDashFilter(date),
                                      initialDate:
                                      provider.dateFromDashFilter,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text("Date To",
                                        style: theme.textTheme.titleMedium),
                                    const SizedBox(height: 8),
                                    CommonDatesPicker(
                                      onChange: (date) => provider
                                          .changeDateToDashFilter(date),
                                      initialDate: provider.dateToDashFilter,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Ticket No.
                          Text('Ticket No.',
                              style: theme.textTheme.titleMedium),
                          const SizedBox(height: 8),
                          TextField(
                            controller: provider.ticketController,
                            style: theme.textTheme.titleSmall,
                            decoration: InputDecoration(
                              hintText: 'Enter ticket number',
                              hintStyle: theme.textTheme.titleMedium
                                  ?.copyWith(color: theme.disabledColor),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                  BorderSide(color: theme.dividerColor)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                  BorderSide(color: theme.dividerColor)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: theme.primaryColor, width: 2)),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // City
                          _buildDropdownField(
                            context: context,
                            label: "City",
                            controller: provider.cityController,
                            hintText: "City",
                            isEmpty: provider.cityList.isEmpty,
                            onTap: () => _showCityDialog(context, provider),
                          ),
                          const SizedBox(height: 10),
                          // Priority
                          _buildDropdownField(
                            context: context,
                            label: "Priority",
                            controller: provider.priorityController,
                            hintText: "Priority",
                            isEmpty: provider.priorityList.isEmpty,
                            onTap: () =>
                                _showPriorityDialog(context, provider),
                          ),
                          const SizedBox(height: 10),

                          // Client
                          GestureDetector(
                            onTap: () => showClientMultiSelectDialog(
                              context,
                              clientList: provider.clientList,
                              initiallySelected:
                              provider.selDashFilterClientStr,
                              title: "Select Client",
                              onForward: (value) =>
                                  provider.selectDashFilterClient(value),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Client",
                                    style: theme.textTheme.titleMedium),
                                const SizedBox(height: 8),
                                TextFormField(
                                  style: theme.textTheme.titleSmall,
                                  decoration: InputDecoration(
                                    suffixIcon: const Icon(
                                        Icons.keyboard_arrow_down_outlined),
                                    suffixIconColor:
                                    provider.clientList.isNotEmpty
                                        ? theme.colorScheme.primary
                                        : null,
                                    hintText:
                                    provider.selDashFilterClientList.isEmpty
                                        ? "All Clients"
                                        : "Clients",
                                    enabled: false,
                                    hintStyle: theme.textTheme.titleMedium
                                        ?.copyWith(color: theme.disabledColor),
                                    labelStyle: theme.textTheme.titleMedium,
                                    disabledBorder: OutlineInputBorder(
                                        borderSide:
                                        const BorderSide(width: 0.54),
                                        borderRadius:
                                        BorderRadius.circular(10)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 0.54,
                                            color: theme.colorScheme.primary),
                                        borderRadius:
                                        BorderRadius.circular(10)),
                                    errorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 0.54,
                                            color: bayaInfraRedColor),
                                        borderRadius:
                                        BorderRadius.circular(10)),
                                    focusedErrorBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            width: 0.54,
                                            color: bayaInfraRedColor),
                                        borderRadius:
                                        BorderRadius.circular(10)),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 0.54,
                                            color: provider.clientList.isEmpty
                                                ? theme.disabledColor
                                                .withValues(alpha: 0.5)
                                                : theme.colorScheme.primary),
                                        borderRadius:
                                        BorderRadius.circular(10)),
                                  ),
                                ),
                                Visibility(
                                  visible:
                                  provider.selDashFilterClientList.isNotEmpty,
                                  child: SelectedClientGridFromUser(
                                    selectedClient:
                                    provider.selDashFilterClientList,
                                    showDelete: true,
                                    onRemove: (item) =>
                                        provider.removeDashFilterClient(item),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          _buildDropdownField(
                            context: context,
                            label: "Task Owner",
                            controller: provider.engineerController,
                            hintText: "Task Owner",
                            isEmpty: provider.engineerList.isEmpty,
                            onTap: () => _showEngineerDialog(context, provider),
                          ),
                          const SizedBox(height: 10),
                          // Reporter
                          _buildDropdownField(
                            context: context,
                            label: "Reviewer",
                            controller: provider.reporterController,
                            hintText: "Reviewer",
                            isEmpty: provider.reporterList.isEmpty,
                            onTap: () => _showReporterDialog(context, provider),
                          ),
                          const SizedBox(height: 10),
                          _buildDropdownField(
                            context: context,
                            label: "Coordinator",
                            controller: provider.coordinatorController,
                            hintText: "Coordinator",
                            isEmpty: provider.coordinatorList.isEmpty,
                            onTap: () => _showCoordinatorDialog(context, provider),
                          ),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),

                  // ── FIXED FOOTER ─────────────────────────────────────
                  Divider(height: 1, color: theme.dividerColor),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 8,
                      right: 8,
                      top: 10,
                      bottom: MediaQuery.of(context).padding.bottom + 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: BaseElevatedButton(
                            onPressed: () {
                              provider.clearFilters();
                              serviceTasksListProvider.loadTicketsFromGraph();
                              dashboardProvider.fetchDashboardData(filter: TaskDashBoardSummaryFilterModel(
                                  ticketNo: null,
                                  dateFrom: null,
                                  dateTo: null,
                                  priorityId: null,
                                  cityId: null,
                                  selDashFilterClientList: []));
                              GoRouter.of(context).pop();
                            },
                            text: 'Clear All',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: BaseElevatedButton(
                            onPressed: () {
                              serviceTasksListProvider.loadTicketsFromGraph();
                              dashboardProvider.fetchDashboardData(filter: TaskDashBoardSummaryFilterModel(
                                  ticketNo: provider.ticketController.text,
                                  dateFrom: provider.dateFromDashFilter == null
                                      ? null
                                      : DateFormat('dd-MM-yyyy').format(provider.dateFromDashFilter!),
                                  dateTo: provider.dateToDashFilter == null
                                      ? null
                                      : DateFormat('dd-MM-yyyy').format( provider.dateToDashFilter!),
                                  priorityId: provider.selectedPriority?.id,
                                  cityId: provider.selectedDashFilterCity?.id,
                                  selDashFilterClientList: provider.selDashFilterClientList));
                              Navigator.pop(context);
                            },
                            text: 'Apply Filters',
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ── END FIXED FOOTER ──────────────────────────────────
                ],
              ),
            );
          },
        );
      },
    );
  }
}
void _showPriorityDialog(
    BuildContext context, DashboardFilterProvider provider) {
  showSelectionDialog<CommonMasterModel>(
    context,
    items: provider.priorityList,
    getDisplayName: (priority) => priority.description,
    onSelect: (priority) {
      provider.setSelectedPriority(priority);
      GoRouter.of(context).pop();
    },
    title: "Select Priority",
    searchHint: "Search priority",
  );
}

void _showCityDialog(
    BuildContext context, DashboardFilterProvider provider) {
  showSelectionDialog<CommonMasterModel>(
    context,
    items: provider.cityList,
    getDisplayName: (city) => city.cityname,
    onSelect: (city) {
      provider.setSelectedDashFilterCity(city);
      GoRouter.of(context).pop();
    },
    title: "Select City",
    searchHint: "Search city",
  );
}
void _showEngineerDialog(
    BuildContext context, DashboardFilterProvider provider) {
  showSelectionDialog<CommonMasterModel>(
    context,
    items: provider.engineerList,
    getDisplayName: (item) => item.name , // adjust field
    onSelect: (value) {
      provider.setSelectedEngineer(value);
      GoRouter.of(context).pop();
    },
  );
}

void _showReporterDialog(
    BuildContext context, DashboardFilterProvider provider) {
  showSelectionDialog<CommonMasterModel>(
    context,
    items: provider.reporterList,
    getDisplayName: (item) => item.name ,
    onSelect: (value) {
      provider.setSelectedReporter(value);
      GoRouter.of(context).pop();
    },
  );
}

void _showCoordinatorDialog(
    BuildContext context, DashboardFilterProvider provider) {
  showSelectionDialog<CommonMasterModel>(
    context,
    items: provider.coordinatorList,
    getDisplayName: (item) => item.name ,
    onSelect: (value) {
      provider.setSelectedCoordinator(value);
      GoRouter.of(context).pop();
    },
  );
}

class SelectedClientGridFromUser extends StatelessWidget {
  final List<CommonMasterModel> selectedClient;
  final void Function(String name) onRemove;
  final bool showDelete;

  const SelectedClientGridFromUser({
    super.key,
    required this.selectedClient,
    required this.onRemove,
    required this.showDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height*0.1,
        width: MediaQuery.of(context).size.width,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: AlwaysScrollableScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: selectedClient.length,
          separatorBuilder: (_, __) => const SizedBox(width: 0),
          itemBuilder: (context, index) {
            final client = selectedClient[index];

            return Stack(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.22,
                  child: Card(
                    color: Theme.of(context).colorScheme.onTertiary,
                    elevation: 0.5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            ProfileImageDialog.show(context: context,
                              imageUrl: "Client",
                              userName:  client.clientname,);

                          },
                          child: CachedNetworkImageWidget(
                            imageUrl:  "",
                            size: 32,
                            userName: client.clientname,
                          ),
                        ),
                        const SizedBox(height: 4),

                        Text(
                          client.clientname,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall,
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: showDelete,
                  child: Positioned(
                    top: 8,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => onRemove(client.clientname),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.close,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class SelectedCityGridFromUser extends StatelessWidget {
  final List<CommonMasterModel> selectedCity;
  final void Function(String name) onRemove;
  final bool showDelete;

  const SelectedCityGridFromUser({
    super.key,
    required this.selectedCity,
    required this.onRemove,
    required this.showDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height*0.1,
        width: MediaQuery.of(context).size.width,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: AlwaysScrollableScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: selectedCity.length,
          separatorBuilder: (_, __) => const SizedBox(width: 0),
          itemBuilder: (context, index) {
            final city = selectedCity[index];

            return Stack(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.22,
                  child: Card(
                    color: Theme.of(context).colorScheme.onTertiary,
                    elevation: 0.5,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            ProfileImageDialog.show(context: context,
                              imageUrl: "Client",
                              userName:  city.cityname,);

                          },
                          child: CachedNetworkImageWidget(
                            imageUrl:  "",
                            size: 32,
                            userName: city.cityname,
                          ),
                        ),
                        const SizedBox(height: 4),

                        Text(
                          city.cityname,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall,
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: showDelete,
                  child: Positioned(
                    top: 8,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => onRemove(city.cityname),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.close,
                          size: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Widget _buildDropdownField({
  required BuildContext context,
  required String label,
  required TextEditingController controller,
  required String hintText,
  required bool isEmpty,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap ,
    child: AbsorbPointer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .titleMedium,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: controller,
            style: Theme.of(context).textTheme.titleMedium,
            decoration: InputDecoration(
              suffixIcon: const Icon(Icons.keyboard_arrow_down_outlined),
              hintText: hintText,
              hintStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).disabledColor,
              ),
              labelStyle: Theme.of(context).textTheme.titleMedium,
              disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 0.54,
                    color: Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      width: 0.54,
                      color: Theme.of(context).colorScheme.primary),
                  borderRadius: BorderRadius.circular(10)),
              errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      width: 0.54, color: bayaInfraRedColor),
                  borderRadius: BorderRadius.circular(10)),
              focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      width: 0.54, color: bayaInfraRedColor),
                  borderRadius: BorderRadius.circular(10)),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      width: 0.54,
                      color: isEmpty
                          ? Theme.of(context)
                          .disabledColor
                          .withValues(alpha: 0.5)
                          : Theme.of(context).colorScheme.primary),
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    ),
  );
}