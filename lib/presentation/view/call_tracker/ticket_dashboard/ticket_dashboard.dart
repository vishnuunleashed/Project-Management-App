import 'package:base/presentation/base/base_consumer.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/customer_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/presentation/provider/call_tracker/dashboard_filter_provider.dart';
import 'package:interior_design/presentation/provider/call_tracker/service_ticket_dashboard_provider.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/common/cached_image_view.dart';
import 'package:interior_design/presentation/view/common/client_multi_select.dart';
import 'package:interior_design/presentation/view/common/common_date_picker.dart';
import 'package:interior_design/presentation/view/common/common_selection_dialog.dart';
import 'package:interior_design/presentation/view/common/view_profile_image.dart';
import 'package:interior_design/presentation/view/project_details/partials/empty_list_view.dart';
import 'package:interior_design/presentation/view/project_details/schedule_status_graphs_and_widgets/generalized_graph/general_pie_chart_widget.dart';
import 'package:interior_design/presentation/view/project_details/schedule_status_graphs_and_widgets/generalized_graph/generalized_horizontal_graph.dart';
import 'package:interior_design/utils/routes.dart';
import 'package:intl/intl.dart';


class ServiceTicketDashboardScreen extends ConsumerStatefulWidget {
  const ServiceTicketDashboardScreen({super.key});

  @override
  ConsumerState createState() => _ServiceTicketDashboardScreenState();
}

class _ServiceTicketDashboardScreenState
    extends ConsumerState<ServiceTicketDashboardScreen> with RouteAware{

  @override
  void didPopNext()  {
    Future.microtask(() async {
      var provider = ref.watch(serviceTicketDashboardProvider);
      var filterProvider = ref.watch(dashboardFilterProvider);
      provider.fetchDashboardData(filter: TaskDashBoardSummaryFilterModel(
          ticketNo: filterProvider.ticketController.text,
          dateFrom: filterProvider.dateFromDashFilter == null
              ? null
              : DateFormat('dd-MM-yyyy').format(filterProvider.dateFromDashFilter!),
          dateTo: filterProvider.dateToDashFilter == null
              ? null
              : DateFormat('dd-MM-yyyy').format( filterProvider.dateToDashFilter!),
          priorityId: filterProvider.selectedPriority?.id,
          cityId: filterProvider.selectedDashFilterCity?.id,
          selDashFilterClientList: filterProvider.selDashFilterClientList));
    });
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

  // ── Color palette ───────────────────────────────────────────────────────
  final Color _onTrackColor  = const Color(0xff91C483); // Greenish (Closed/Completed)
  final Color _delayColor    = const Color(0xffFF6464); // Reddish (Delayed)
  final Color _futureColor   = Color(0xFF848484); // Yellowish (Pending/Opened)
  final Color _targetColor   = const Color(0xFFF2B35C); // Keep blue for targets

  Color _statusColor(String? code, {bool isFromStatusGraph = false}) {
    switch (code?.toUpperCase()) {
      case 'ON_TRACK':      return isFromStatusGraph ? Color(0xFF3A7BDA) : _onTrackColor  ;
      case 'DELAY':         return _delayColor;
      case 'FUTURE_TASK':   return _futureColor;
      case 'TARGET_ISSUE':  return _targetColor;
      default:              return _delayColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BaseView<ServiceTicketDashboardProvider>(
      provider: serviceTicketDashboardProvider,
      initState: (context, provider, ref) {
        final filter = ref.read(dashboardFilterProvider);
        provider.init(filter);
        provider.fetchDashboardData(filter: TaskDashBoardSummaryFilterModel(ticketNo: null, dateFrom: null, dateTo: null, priorityId: null, cityId: null, selDashFilterClientList: []));
        filter.fetchServicePriority();
        filter.fetchCityLists();
        filter.fetchClientLists();
        filter.fetchEngineers();
        filter.fetchCoordinator();
        filter.fetchReporters();
      },
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: Text("Service Dashboard"),
      ),
      virtualFloatingActionButton: BaseConsumer(
        provider: serviceTicketDashboardProvider,
        builder: (context, provider, ref) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 56),
            child: Row(
              children: [
                FloatingActionButton(
                    backgroundColor: Theme.of(context).primaryColor,
                    heroTag: "Filter",
                    child: Icon(Icons.filter_list,color: bayaInfraWhiteColor,),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) =>  ServiceDashBoardFilterBottomSheet(dashboardProvider: provider),
                      );
                    }
                ),
              ],
            ),
          );
        }
      ),
        builder: (context, provider, ref) {
          if (provider.allGraphsEmpty) {
            return const Center(
              child: EmptyListView(
                emptyText: "No data found",
              ),
            );
          }

          return ListView(
            physics: const ClampingScrollPhysics(),
            children: [
              _buildTaskStatusGraph(provider),
              _buildDaysDelayGraph(provider),
              _buildClientDelayGraph(provider),
              _buildMemberDelayGraph(provider),
              _buildTeamDelayGraph(provider),
            ],
          );
        }
    );
  }

  // ── Chart 1: Service Tasks Status ──────────────────────────────────────
  Widget _buildTaskStatusGraph(ServiceTicketDashboardProvider provider) {
    if (provider.taskStatusJson.isEmpty) return const SizedBox.shrink();

    return GeneralPieChart(
      data: _buildTaskStatusData(provider),
      onSectionTap: (data, index) {
        GoRouter.of(context)
            .pushNamed(AppRoutes.serviceTaskListsFromHome,
            extra: {
              "clientId": data['clientId'],
              "isFromDashboard" : true,
              "dashboardType":"SERVICE_STATUS",
              "dashboardSubType": data['statusCategoryCode'],
              "header" : data['label'],
            });
      },
    );
  }

  List<Map<String, Object>> _buildTaskStatusData(
      ServiceTicketDashboardProvider provider) {
    final list = <Map<String, Object>>[];
    for (final e in provider.taskStatusJson) {
      if ((e.serviceCount ?? 0) != 0) {
        list.add({
          'title': 'Service Tasks Status',
          'label':  e.statusCategory ?? "",
          'statusCategoryCode': e.statusCategoryCode ?? '',
          'value': (e.serviceCount ?? 0).toDouble(),
          'color': _statusColor(e.statusCategoryCode, isFromStatusGraph: true),
        });
      }
    }
    return list;
  }

  // ── Chart 2: Number of Tasks × Days Delay ──────────────────────────────
  Widget _buildDaysDelayGraph(ServiceTicketDashboardProvider provider) {
    if (provider.taskDelayByDaysJson.isEmpty) return const SizedBox.shrink();

    return HorizontalBarChart(
      data: _buildDaysDelayData(provider),
      onBarTap: (data, index) {
        GoRouter.of(context)
            .pushNamed(AppRoutes.serviceTaskListsFromHome,
            extra: {
              "clientId": data['clientId'],
              "isFromDashboard" : true,
              "dashboardType":"SERVICE_TASK_DELAY",
              "dashboardSubType": data['delayCategoryCode'],
              "header" : "Delay",
              "subHeader" : data['delaycategory'],
            });
      },
    );
  }

  List<Map<String, Object>> _buildDaysDelayData(
      ServiceTicketDashboardProvider provider) {
    final list = <Map<String, Object>>[];
    for (final e in provider.taskDelayByDaysJson) {
      if ((e.taskCount ?? 0) != 0) {
        list.add({
          'title': 'Number of Tasks x Days Delay',
          'label': e.delayCategory ?? '',
          'delayCategoryCode': e.delayCategoryCode ?? '',
          'value': (e.taskCount ?? 0).toDouble(),
          'color': _delayColor,
          'delaycategory' : e.delayCategory ?? ""
        });
      }
    }
    return list;
  }

  List<Map<String, Object>> _buildTeamDelayData(
      ServiceTicketDashboardProvider provider) {
    final list = <Map<String, Object>>[];
    for (final e in provider.teamTicketDelayJson) {
      if ((e.delayedCount ?? 0) != 0 || (e.onTrackCount ?? 0) != 0) {
        list.add({
          'title': 'Client x Service Tickets',
          'label': e.category ?? '',
          'categoryCode': e.categoryCode ?? '',
          'clientId': e.clientId ?? 0,
          'onTrackValue': e.onTrackCount ?? 0,          // rod 0 → opened
          'onTrackColor': _onTrackColor,    // color for opened rod
          'delayedValue': e.delayedCount ?? 0,  // rod 1 → delayed
          'delayedColor': _delayColor,
        });
      }
    }
    return list;
  }

  // ── Chart 3: Client × Delayed Service Requests ────────────────────────
  Widget _buildClientDelayGraph(ServiceTicketDashboardProvider provider) {
    if (provider.clientDelayJson.isEmpty) return const SizedBox.shrink();

    return HorizontalBarChart(
      data: _buildClientDelayData(provider),
      valueKey: 'onTrackValue',
      colorKey: 'onTrackColor',
      secondValueKey: 'delayedValue',
      secondColorKey: 'delayedColor',
      firstLegendLabel: 'Opened',
      secondLegendLabel: 'Delayed',

      // Tapping the green (on-track) rod
      onOpenTap: (data, index) {
        GoRouter.of(context).pushNamed(
          AppRoutes.serviceTaskListsFromHome,
          extra: {
            'clientId': data['clientId'],
            "isFromDashboard" : true,
            "dashboardType":"SERVICE_CLIENTWISE_DELAY",
            "dashboardSubType": "ON_TRACK",
            "header" : data['clientName'],
            "subHeader" : "Opened",
          },
        );
      },

      // Tapping the red (delayed) rod
      onDelayTap: (data, index) {
        GoRouter.of(context).pushNamed(
          AppRoutes.serviceTaskListsFromHome,
          extra: {
            'clientId': data['clientId'],
            "isFromDashboard" : true,
            "dashboardType":"SERVICE_CLIENTWISE_DELAY",
            "dashboardSubType": "DELAY",
            "header" : data['clientName'],
            "subHeader" : "Delayed",
          },
        );
      },
    );
  }

  List<Map<String, Object>> _buildClientDelayData(
      ServiceTicketDashboardProvider provider) {
    final list = <Map<String, Object>>[];
    for (final e in provider.clientDelayJson) {
      if ((e.delayedCount ?? 0) != 0 || e.onTrackCount != 0) {
        list.add({
          'title': 'Client x Service Tasks',
          'label': e.clientName ?? '',
          'categoryCode': e.categorycode ?? '',
          'clientId': e.clientId ?? 0,
          'onTrackValue': e.onTrackCount ?? 0,          // rod 0 → opened
          'onTrackColor': _onTrackColor,    // color for opened rod
          'delayedValue': e.delayedCount ?? 0,  // rod 1 → delayed
          'delayedColor': _delayColor,
          'clientName' : e.clientName ?? ""
        });
      }
    }
    return list;
  }

  // ── Chart 4: Team Member × Delayed Service Requests ───────────────────
  Widget _buildMemberDelayGraph(ServiceTicketDashboardProvider provider) {
    if (provider.memberDelayJson.isEmpty) return const SizedBox.shrink(); /// next is this


    return HorizontalBarChart(
      data: _buildMemberDelayData(provider),

      valueKey: 'onTrackValue',
      colorKey: 'onTrackColor',
      secondValueKey: 'delayedValue',
      secondColorKey: 'delayedColor',
      firstLegendLabel: 'Opened',
      secondLegendLabel: 'Delayed',

      // Tapping the green (on-track) rod
      onOpenTap: (data, index) {
        GoRouter.of(context)
            .pushNamed(AppRoutes.serviceTaskListsFromHome,
            extra: {
              "isFromDashboard" : true,
              "dashboardType":"SERVICE_USERWISE_DELAY",
              "dashboardSubType": "ON_TRACK",
              "serviceUserId": data['memberId'],
              "header" : data['label'],
              "subHeader" : "Opened",
            });
      },

      // Tapping the red (delayed) rod
      onDelayTap: (data, index) {
        GoRouter.of(context)
            .pushNamed(AppRoutes.serviceTaskListsFromHome,
            extra: {
              "isFromDashboard" : true,
              "dashboardType":"SERVICE_USERWISE_DELAY",
              "dashboardSubType": "DELAY",
              "serviceUserId": data['memberId'],
              "header" : data['label'],
              "subHeader" : "Delayed",
            });
      },
    );
  }

  List<Map<String, Object>> _buildMemberDelayData( // next is here
      ServiceTicketDashboardProvider provider) {
    final list = <Map<String, Object>>[];
    for (final e in provider.memberDelayJson) {
      if ((e.delayedCount ?? 0) != 0 || (e.onTrackCount ?? 0) != 0) {
        list.add({
          'title': 'Team Member x Service Tasks',
          'label': e.memberName ?? '',
          'memberId': e.memberId ?? 0,
          'categoryCode': e.categorycode ?? '',
          'onTrackValue': e.onTrackCount ?? 0,          // rod 0 → opened
          'onTrackColor': _onTrackColor,    // color for opened rod
          'delayedValue': e.delayedCount ?? 0,  // rod 1 → delayed
          'delayedColor': _delayColor,
        });
      }
    }
    return list;
  }

  Widget _buildTeamDelayGraph(ServiceTicketDashboardProvider provider) {
    if (provider.teamTicketDelayJson.isEmpty) return const SizedBox.shrink();

    return HorizontalBarChart(
      data: _buildTeamDelayData(provider),
      valueKey: 'onTrackValue',
      colorKey: 'onTrackColor',
      secondValueKey: 'delayedValue',
      secondColorKey: 'delayedColor',
      firstLegendLabel: 'Opened',
      secondLegendLabel: 'Delayed',
      // Tapping the green (on-track) rod
      onOpenTap: (data, index) {
        GoRouter.of(context)
            .pushNamed(AppRoutes.serviceTaskLists,
            extra: {
              "type" : "SERVICE_CLIENTWISE_TICKETS" ,
              "subtype" : "ON_TRACK",
              "clientId": data['clientId'],
              "header" : data['label'],
              "subHeader" : "Opened",
            });
      },
      // Tapping the red (delayed) rod
      onDelayTap: (data, index) {
        GoRouter.of(context)
            .pushNamed(AppRoutes.serviceTaskLists,
            extra: {
              "type" : "SERVICE_CLIENTWISE_TICKETS" ,
              "subtype" : "DELAY",
              "clientId": data['clientId'],
              "header" : data['label'],
              "subHeader" : "Delayed",
            });
      },
    );
  }
}


class ServiceDashBoardFilterBottomSheet extends StatelessWidget {
  final ServiceTicketDashboardProvider dashboardProvider; //  keep to call fetchDashboardData

  const ServiceDashBoardFilterBottomSheet({
    super.key,
    required this.dashboardProvider,
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
