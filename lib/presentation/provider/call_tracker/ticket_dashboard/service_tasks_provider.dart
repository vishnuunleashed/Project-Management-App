import 'package:base/core/constants.dart';
import 'package:base/core/loader_value.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_design/data/model/response/call_tracker/call_tracker_model.dart';
import 'package:interior_design/domain/usecase/call_tracker/call_tracker_usercase.dart';
import 'package:interior_design/presentation/provider/call_tracker/dashboard_filter_provider.dart';
import 'package:interior_design/presentation/provider/call_tracker/service_ticket_dashboard_provider.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:intl/intl.dart';

class ServiceTasksListProvider extends BaseProvider{
  int _start = 0;
  int _limit = 10;
  int _totalRecords = 0;
  bool _isLoadingMore = false;
  String _ticketNoFilter = '';
  String get ticketNoFilter => _ticketNoFilter;
  int get totalRecords => _totalRecords;
  List<CallTicketModel> _serviceTasks = [];
  List<CallTicketModel> get serviceTasks => _serviceTasks;
  String flag = '';
  String statusFromGraph = '';
  int serviceClientId = 0;
  int userId = 0;
  int loggedInUserId = 0;
  int? cityId;
  int? priorityId;
  DateTime? dateFrom;
  DateTime? dateTo;

  String? type;
  String? subType;
  String? serviceTrackerHeader;
  String? serviceTrackerSubHeader;

  DashboardFilterProvider? filterProvider;
  void initValues(Map<String, dynamic>? extra , DashboardFilterProvider filter) async {
    loggedInUserId = await BaseSecureStorage.getInt(BaseConstants.userID);

    filterProvider = filter;
    type = extra!['type']??"";
    subType = extra['subtype']??"";
    serviceClientId = extra['clientId']??0;
    serviceTrackerHeader = extra['header'];
    serviceTrackerSubHeader = extra['subHeader'];
    // //  NEW VALUES
    // cityId = extra['cityId'];
    // priorityId = extra['priorityId'];
    // dateFrom = extra['dateFrom'];
    // dateTo = extra['dateTo'];
    // _ticketNoFilter = extra['ticketNo'] ?? '';
    loadTicketFromDashboardGraph();
    _setupScrollListener();

  }

  Future<void> refreshTickets() async {
    loadTicketsFromGraph();
    }

  ScrollController scrollController = ScrollController();

  void _setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent)  {
        _loadMoreTicketsFromGraph();
      }
    });
  }

  bool get hasMore => _serviceTasks.length < _totalRecords;

  void _loadMoreTicketsFromGraph() {
    // Prevent multiple simultaneous loads
    if (_isLoadingMore || !hasMore) return;

    _isLoadingMore = true;
    _start += _limit;

    loadTicketsFromGraph(changeStart: false).then((_) {
      _isLoadingMore = false;
      notifyListeners();
    });
  }


  Future<void> loadTicketsFromGraph({bool changeStart = false}) async {
    if(changeStart){
      changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
      _serviceTasks = [];
      _start = 0;
      _totalRecords = 0; // Reset total records too
    }


    CallTrackerUseCase().fetchCallTrackerInfoFromGraphDashboard(
        start: _start,
        limit: _limit,
        ticketNo: _ticketNoFilter,
        refTableDataId: 0,
        status: statusFromGraph,
        userId: userId,
        serviceClientId: serviceClientId ?? 0,
        flag:flag,
        taskDashBoardSummaryFilter: (filterProvider?.currentFilter) ?? TaskDashBoardSummaryFilterModel(ticketNo: null, dateFrom: null, dateTo: null, priorityId: null, cityId: null, selDashFilterClientList: []),
        engineerId: filterProvider?.selectedEngineer?.id,
        reporterId: filterProvider?.selectedReporter?.id,
        coordinatorId: filterProvider?.selectedCoordinator?.id,
        onRequestSuccess: (result){
          if(_start == 0) {
            _serviceTasks = result;
          } else {
            _serviceTasks.addAll(result); // Use addAll instead of +=
          }

          // Update total records from response
          _totalRecords = result.isNotEmpty
              ? (result.first.totalRecords ?? 0)
              : _totalRecords;

          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
          notifyListeners();
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error, exception: exception));
          notifyListeners();
        });
  }

  void loadTicketFromDashboardGraph(){
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    CallTrackerUseCase().fetchCallTrackerInfoFromDashboardGraph(
      type: type,
      subType: subType,
      ticketNo: filterProvider?.ticketController.text,
      cityId: filterProvider?.selectedDashFilterCity?.id,
      clientIds: filterProvider?.selDashFilterClientList.map((e) => e.id).toList() ,
      dateFrom: filterProvider?.dateFromDashFilter != null
          ? DateFormat('yyyy-MM-dd').format(filterProvider!.dateFromDashFilter!)
          : null,
      dateTo: filterProvider?.dateToDashFilter != null
          ? DateFormat('yyyy-MM-dd').format(filterProvider!.dateToDashFilter!)
          : null,
      priorityId: filterProvider?.selectedPriority?.id,
      serviceClientId: serviceClientId,
      onRequestSuccess: (result){
        _serviceTasks = result;
        changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
        notifyListeners();

      },
      onRequestFailure: (exception){
        changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error));
      }
    );
  }

// Get status color
  Color getStatusColor(String? statusCode) {
    if (statusCode == null) return Colors.grey;

    switch (statusCode) {
      case 'ASGN_PENDING':
        return bayaInfraPaleOrange;
      case 'ASSIGNED':
        return bayaInfraBlue600!;
      case 'IN_PROGRESS':
        return bayaInfraBlue100;
      case 'CLOSE_PENDING':
        return bayaInfraAmber;
      case 'REVIEWED':
        return bayaInfraRed;
      case 'CLOSED':
        return bayaInfraGreen;
      case 'REJECTED':
        return bayaInfraLightRedColor;
      default:
        return Colors.grey;
    }
  }

  // Get priority color
  Color getPriorityColor(String? priority) {
    if (priority == null) return Colors.grey;

    if (priority.contains('1')) {
      return Colors.red;
    } else if (priority.contains('2')) {
      return Colors.orange;
    } else if (priority.contains('3')) {
      return bayaInfraPaleGreen;
    } else {
      return Colors.green;
    }
  }
}