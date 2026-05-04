/*------------------------------------------------------------------------------
AUTHOR          :
CREATED DATE    : 27/02/2026
PURPOSE         : Provider for Service Request Dashboard Screen
MODULE/TOPIC    : Call Tracker / Service Request
REMARKS         : Extends BaseServiceTicketProvider directly.
                  Tasks are managed separately via ServiceTasksProvider.
------------------------------------------------------------------------------*/

import 'dart:convert';
import 'dart:io';
import 'package:base/core/constants.dart';
import 'package:base/core/loader_value.dart';
import 'package:base/data/models/response/image_upload_response.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_design/data/model/request/call_tracker/status_update_model.dart';
import 'package:interior_design/data/model/response/call_tracker/call_tracker_model.dart';
import 'package:interior_design/data/model/response/call_tracker/service_based_support_dashboard_model.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';
import 'package:interior_design/data/model/response/project_schedule/project_schedule_dto.dart';
import 'package:interior_design/domain/usecase/call_tracker/call_tracker_usercase.dart';
import 'package:interior_design/presentation/provider/call_tracker/providers/service_tasks_provider.dart';
import 'package:interior_design/presentation/provider/call_tracker/service_tasks_provider.dart';
import 'package:interior_design/presentation/view/call_tracker/detail_view/_partials/_partials/task_filter_tab.dart';
import 'package:interior_design/utils/firebase_tap_config.dart';
import 'package:intl/intl.dart';

import 'base_service_ticket_provider.dart';

class ServiceRequestDashboardProvider extends ServiceTasksProvider {
  final TextEditingController remarksController = TextEditingController();

  int loggedInUserID = 0;
  bool isSuperUser = false;

  int _desiredInnerTabIndex = -1;
  int get desiredInnerTabIndex => _desiredInnerTabIndex;

  void jumpToTaskStatus(TaskFilter filter) {
    selectedTaskFilter = filter;
    _desiredInnerTabIndex = 1; // Switch to Tasks tab
    notifyListeners();
  }

  void resetDesiredTab() {
    _desiredInnerTabIndex = -1;
  }

  List<Map<String, dynamic>> _parseRoutePaths(dynamic rawRoutePath) {
    try {
      List<dynamic> parsed = [];

      if (rawRoutePath is List) {
        // Android: already a List (existing working case — untouched)
        parsed = rawRoutePath;
      } else if (rawRoutePath is String) {
        final trimmed = rawRoutePath.trim();
        if (trimmed.startsWith('[')) {
          // iOS: route_path is a JSON-encoded String — decode it
          parsed = jsonDecode(trimmed) as List<dynamic>;
        } else {
          // Plain route string like "/home" — return empty to trigger fallback
          return [];
        }
      } else {
        return [];
      }

      final routes = parsed
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      // FIXED: Safe int parsing — handles both "1" (iOS String) and 1 (Android int)
      routes.sort((a, b) {
        final aOrder = int.tryParse(a['order'].toString()) ?? 0;
        final bOrder = int.tryParse(b['order'].toString()) ?? 0;
        return aOrder.compareTo(bOrder);
      });

      return routes;

    } catch (e) {
      print("Error parsing route_path: $e");
      return []; // Safe fallback — triggers home navigation
    }
  }


  // Initialize - for now just sets up hardcoded data
  Future<void> initState({Map<String, dynamic>? extra}) async {
    currentTaskId = 0;
    showLoaderForClose = false;
    loggedInUserID = await BaseSecureStorage.getInt(BaseConstants.userID);
    isSuperUser = await BaseSecureStorage.getBool(BaseConstants.superUserYN);


    if (extra != null && extra['transid'] != null) {
      currentTicketId = int.parse(extra['transid'].toString() ?? "0");
      print("currentTicketId  == $currentTicketId");
      selectedTaskFilter = extra["selectedTaskFilter"]??TaskFilter.all;
      final rawRoutePath = extra['route_path'];
      final List<Map<String, dynamic>> routes = _parseRoutePaths(rawRoutePath);
      String routePath = "";

      final List<String> routeNames = routes
          .map((e) => (e['routepath'] as String?) ?? "")
          .where((r) => r.isNotEmpty)
          .toList();



      if(routeNames.contains("/home/serviceTaskScreenDirect") ||
          routeNames.contains("serviceTaskScreenDirect")){
        currentTaskId = int.parse(extra['transid'].toString());

        fetchCallTrackerInfo(taskId: currentTaskId);
        jumpToTaskStatus(TaskFilter.task_notification);
      }
      else{
        fetchCallTrackerInfo();
      }

      fetchServiceBasedSupportDashboardData();

    }

    notifyListeners();
  }

  List<CallTicketModel> tickets = [];




  Future<void> fetchCallTrackerInfo({int taskId = 0}) async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    CallTrackerUseCase().fetchCallTrackerInfo(
        start: 0,
        limit: 10,
        ticketNo: "",
        refTableDataId: currentTicketId,
        engineers:[],
        statuses: [],
        clientList: [],
        cities: [],
        sitesList: [],
        priorityList: [],
        dateTo: "",
        dateFrom: "",
        type: "",
        sitenames: "",
        taskId: taskId,
        onRequestSuccess: (result) {
          print("data called--");
          if (result.isNotEmpty) {
            tickets = result;

            currentTicket = result.first;
            taskStatusCode = tickets.first.statusCode ?? "PENDING";
            serviceReportUserId = tickets.first.serviceReportUserId ?? 0;
            tasks = tickets.first.newTaskLists ?? [];
            // fetchTaskDetails(ticketId: currentTicketId);
          }
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus:
              LoadingStatus(loader: Loader.error, exception: exception));
        });
    notifyListeners();
  }


  int? notificationId;
  void setNotificationId(int id){
    notificationId =  id;
    updateNotificationStatus();
  }

  void updateNotificationStatus() {
    if(notificationId == null || notificationId == 0){
      return;
    }
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));

    CallTrackerUseCase().updateNotificationStatus(
        notificationId: notificationId??0,
        onRequestSuccess: (notificationId) {
          removeNotificationUsingIdList(notificationId);

          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus:
              LoadingStatus(loader: Loader.error, exception: exception));
        });
  }

  List<TicketSummaryModel> dashboardSupport = [];

  Future<void> fetchServiceBasedSupportDashboardData() async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    CallTrackerUseCase().fetchServiceBasedSupportDashboardData(
        dataId: currentTicketId,
        onRequestSuccess: (result) {
          dashboardSupport = result;
          notifyListeners();
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus:
              LoadingStatus(loader: Loader.error, exception: exception));
        });
  }

  bool showLoaderForClose = true;

  void updateLoaderForClose(bool mode){
    showLoaderForClose = mode;
    notifyListeners();
  }
  // antigravity check --?
  Future<void> updateStatus({
    required String statusCode,
    required ServiceTaskModel task,
    required String statusType,
    required Function(String) onSuccess,
    required Function(AppException? exception) onFailure,
    bool? notifyClient,
  }) async {

    print("newTaskAttachments attachment lenght 5 --${newTaskAttachments.length}");
    changeLoadingStatusIfActive(
      loadingStatus: LoadingStatus(loader: Loader.loading),
      token: "Close"
    );
    if(statusCode == "CLOSED"){
      showLoaderForClose = true;
    }


    TicketStatusModel taskModel = TicketStatusModel(
      id: (statusType == "TICKET")
          ? currentTicket?.id ?? 0
          : task.id ?? 0,
      lastmoddate: (statusType == "TICKET")
          ? currentTicket?.lastModDate
          : task.lastModDate,
      remarks: (statusCode == "SUBMITTED") || (statusCode == "SEND_BACK") || (statusCode == "REJECTED") || (statusCode == "REOPENED") ? remarkCtrl.text :"",
      statuscode: statusCode,
      statusType: statusType,
      docAttachID: (statusCode == "PENDING") ? docAttachId : null,
      seriesNo: attachmentSeriesNo,
      attachmentList:
      (statusCode == "SUBMITTED")
          ? newTaskAttachments
          : [],
      createdUserID:
      (statusCode == "PENDING") ? createdUserId : null,
      workStatusOptionId: selectedWorkStatusOption?.id,
      notifyClientYN: notifyClient == null ? null : (notifyClient == true ? "Y" : "N"),
    );

    print("newTaskAttachments attachment lenght 5 --${taskModel.lastmoddate}");

    CallTrackerUseCase().updateStatus(
      taskModel: taskModel,
      onRequestSuccess: (message) {
        selectedWorkStatusOption = null;
        newTaskAttachments = [];
        remarkCtrl.clear();
        sendBackRemarkCtrl.clear();
        showLoaderForClose = false;
        onSuccess(message);
      },
      onRequestFailure: (exception) {
        showLoaderForClose = false;
        changeLoadingStatus(
          loadingStatus:
          LoadingStatus(loader: Loader.error, exception: exception),
        );
        onFailure(exception);
      },
    );
  }

  /// ── Accept Assignment ──────────────────────────────────────────────
  /// Moves Ticket to IN_PROGRESS and assigned tasks to ACCEPTED
  Future<void> acceptAssignment({
    required Function(String) onSuccess,
    required Function(AppException) onFailure,
  }) async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));

    print("assignedUserId_____ "+tasks.length.toString());
    final taskList = tasks
        .where((t) =>
            (t.assignedUserId == loggedInUserID || isSuperUser) &&
            t.statusCode == "ASSIGNED")
        .map((t) => TaskStatusUpdate(
              id: t.id ?? 0,
              statusType: 'TASK',
              statuscode: 'ACCEPTED',
              lastmoddate: t.lastModDate,
            ))
        .toList();

    TicketStatusModel payload = TicketStatusModel(
      id: currentTicketId,
      statuscode: 'IN_PROGRESS',
      statusType: 'TICKET',
      lastmoddate: currentTicket?.lastModDate,
      seriesNo: null,
      attachmentList: [],
      docAttachID: null,
      createdUserID: loggedInUserID,
      workStatusOptionId: null,
      taskliststatusupdation: taskList,
    );

    CallTrackerUseCase().updateStatus(
      taskModel: payload,
      onRequestSuccess: (msg) {
        fetchCallTrackerInfo();
        changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
        onSuccess(msg);
      },
      onRequestFailure: (err) {
        changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error, exception: err));
        onFailure(err);
      },
    );
  }

  /// ── Accept Specific Task ───────────────────────────────────────────
  /// Wraps a single task acceptance in a TICKET level IN_PROGRESS update
  Future<void> acceptTask({
    required ServiceTaskModel task,
    required Function(String) onSuccess,
    required Function(AppException) onFailure,
  }) async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));

    final taskUpdate = TaskStatusUpdate(
      id: task.id ?? 0,
      statusType: 'TASK',
      statuscode: 'ACCEPTED',
      lastmoddate: task.lastModDate,
    );

    TicketStatusModel payload = TicketStatusModel(
      id: currentTicketId,
      statuscode: 'IN_PROGRESS',
      statusType: 'TICKET',
      lastmoddate: currentTicket?.lastModDate,
      seriesNo: null,
      attachmentList: [],
      docAttachID: null,
      createdUserID: loggedInUserID,
      workStatusOptionId: null,
      taskliststatusupdation: [taskUpdate],
    );

    CallTrackerUseCase().updateStatus(
      taskModel: payload,
      onRequestSuccess: (msg) {
        fetchCallTrackerInfo();
        changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
        onSuccess(msg);
      },
      onRequestFailure: (err) {
        changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error, exception: err));
        onFailure(err);
      },
    );
  }

  /// ── Cancel Ticket ──────────────────────────────────────────────────
  Future<void> cancelServiceTicket({
    required bool notifyClient,
    required Function() onSuccess,
    required Function(AppException) onFailure,
  }) async {

    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
     CallTrackerUseCase().cancelServiceTicket(
      ticketId: currentTicketId,
      lastModDate: currentTicket?.lastModDate ?? "",
      notifyClientYN: notifyClient ? "Y" : "N",
      onRequestSuccess: () {
        fetchCallTrackerInfo();
        changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
        onSuccess();
      },
      onRequestFailure: (err) {
        changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error, exception: err));
        onFailure(err);
      },
    );
  }

  /// ── Close Ticket ───────────────────────────────────────────────────
  Future<void> closeServiceTicket({
    required bool notifyClient,
    required Function(String) onSuccess,
    required Function(AppException) onFailure,
  }) async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));

    TicketStatusModel payload = TicketStatusModel(
      id: currentTicketId,
      statuscode: 'CLOSED',
      statusType: 'TICKET',
      lastmoddate: currentTicket?.lastModDate,
      seriesNo: null,
      attachmentList: [],
      docAttachID: null,
      createdUserID: loggedInUserID,
      workStatusOptionId: null,
      notifyClientYN: notifyClient ? "Y" : "N",
    );

    CallTrackerUseCase().updateStatus(
      taskModel: payload,
      onRequestSuccess: (msg) {
        fetchCallTrackerInfo();
        onSuccess(msg);
      },
      onRequestFailure: (err) {
        changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error, exception: err));
        onFailure(err);
      },
    );
  }

  void disposeVariables() {
    print("Worked -- ");
    dashboardSupport = [];
    tickets = [];
  }



  // ── Expansion state ─────────────────────────────────────────────────────────
  bool _isExpandedDescription = true;
  bool _isExpandedLocation = true;
  bool _isExpandedServiceInfo = true;
  bool _isExpandedTimeline = true;
  bool _isExpandedAssignment = true;

  bool get isExpandedDescription => _isExpandedDescription;
  bool get isExpandedLocation => _isExpandedLocation;
  bool get isExpandedServiceInfo => _isExpandedServiceInfo;
  bool get isExpandedTimeline => _isExpandedTimeline;
  bool get isExpandedAssignment => _isExpandedAssignment;

  void toggleDescriptionExpansion(bool value) {
    _isExpandedDescription = value;
    notifyListeners();
  }

  void toggleLocationExpansion(bool value) {
    _isExpandedLocation = value;
    notifyListeners();
  }

  void toggleServiceInfoExpansion(bool value) {
    _isExpandedServiceInfo = value;
    notifyListeners();
  }

  void toggleTimelineExpansion(bool value) {
    _isExpandedTimeline = value;
    notifyListeners();
  }

  void toggleAssignmentExpansion(bool value) {
    _isExpandedAssignment = value;
    notifyListeners();
  }

  void collapseAllSections() {
    _isExpandedDescription = false;
    _isExpandedLocation = false;
    _isExpandedServiceInfo = false;
    _isExpandedTimeline = false;
    _isExpandedAssignment = false;
    notifyListeners();
  }

  void expandAllSections() {
    _isExpandedDescription = true;
    _isExpandedLocation = true;
    _isExpandedServiceInfo = true;
    _isExpandedTimeline = true;
    _isExpandedAssignment = true;
    notifyListeners();
  }

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

  Future<void> updateTaskClientDependency({
    required int taskId,
    required String clientDependencyYN,
    required String lastModDate,
    required Function() onSuccess,
    required Function(AppException) onFailure,
  }) async {
    CallTrackerUseCase().updateTaskClientDependency(
      taskId: taskId,
      clientDependencyYN: clientDependencyYN,
      lastModDate: lastModDate,
      onRequestSuccess: () {
        fetchCallTrackerInfo();
        onSuccess();
      },
      onRequestFailure: onFailure,
    );
  }

  Future<void> updateTaskClosureDate({
    required int taskId,
    required String targetClosureDate,
    required String lastModDate,
    required Function() onSuccess,
    required Function(AppException) onFailure,
  }) async {
    CallTrackerUseCase().updateTaskClosureDate(
      taskId: taskId,
      targetClosureDate: targetClosureDate,
      lastModDate: lastModDate,
      onRequestSuccess: () {
        fetchCallTrackerInfo();
        onSuccess();
      },
      onRequestFailure: onFailure,
    );
  }



}