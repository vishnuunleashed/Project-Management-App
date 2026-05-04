import 'dart:async';
import 'dart:io';

import 'package:base/core/constants.dart';
import 'package:base/core/loader_value.dart';
import 'package:base/data/models/response/image_upload_response.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:eraser/eraser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_design/data/model/response/check_list/check_list_response_model.dart';
import 'package:interior_design/data/model/response/close_observation/close_observation_model.dart';
import 'package:interior_design/data/model/response/close_observation/read_status_update_dto.dart';
import 'package:interior_design/data/model/response/home/home_projectlist_model.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';
import 'package:interior_design/data/model/response/project_details/project_details_model.dart';
import 'package:interior_design/data/model/response/project_details/support_request_model.dart';
import 'package:interior_design/data/model/response/project_schedule/my_schedule_response_model.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_dialog.dart';
import 'package:base/presentation/utility/navigator_key.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/request/project_details/update_task_status_model.dart';
import 'package:interior_design/data/model/response/project_details/observation_model.dart';
import 'package:interior_design/data/model/response/project_schedule/project_schedule_dto.dart';
import 'package:interior_design/data/model/response/project_schedule/schedule_project_details.dart';
import 'package:interior_design/data/model/response/project_schedule/schedule_summary.dart';
import 'package:interior_design/data/model/response/project_schedule/taskAgainstSupportListModel.dart';
import 'package:interior_design/data/model/response/project_schedule/task_attachment_response_model.dart';
import 'package:interior_design/data/model/response/project_schedule/task_status_drodown_model.dart';
import 'package:interior_design/data/model/response/project_schedule/task_view_or_fill_dto.dart';
import 'package:interior_design/domain/usecase/add_observation/add_observation_usecase.dart';
import 'package:interior_design/domain/usecase/call_tracker/call_tracker_usercase.dart';
import 'package:interior_design/domain/usecase/project_details/project_details_usecase.dart';
import 'package:interior_design/domain/usecase/project_schedule/project_schedule_usecase.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/check_list/check_list_provider.dart';

import 'package:intl/intl.dart';

class ProjectScheduleProvider extends CheckListProvider {
  double progressValue = 0.0;
  late PageController pageController = PageController(initialPage: 0);
  int selectedTab = 0;
  bool viewAllTaskYN = false;
  bool masterExpanded = true;
  TaskStatusDropdownDtlModel? selectedStatus;

  final List<Map<String, dynamic>> tabs = [
    {'label': 'My Task', 'value': 0},
    {'label': 'My Reportees Task', 'value': 1},
    {'label': 'All Tasks', 'value': 2},
  ];

  static const String _slotMyTask = 'myTask';
  static const String _slotAllTask = 'allTask';
  static const String _slotReportees = 'reportees';
  static const String _slotFillData = 'fillData';

  void projectDetailInitValues() {
    selectedStatus = null;
    images = [];
    checkLists = [];
    attachmentUrl = [];
    completionPerc = 0.0;
    progressValue = 0.0;
    attachmentSeriesNo = "";
    scheduleProjectDetails = null;
    notifyListeners();
  }

  String userName = "";
  Future<void> getUserDetails() async {
    userName = await BaseSecureStorage.getString(BaseConstants.userName);
    notifyListeners();
  }

  void projectScheduleInitValues() {
    tasks = [];
    myScheduleTasks = [];
    reportingToTaskList = [];
    searchResultsOfMyTask = [];
    searchResultOfReportingToTask = [];
    selectedTab = 0;
    taskId = 0;
    taskAttachmentList = [];
    searchStarted = false;
    scheduleProjectDetails = null;
    _expansionStatesMyTask = {}; // Clear expansion states
    _expansionStatesAllTask = {}; // Clear expansion states
    notifyListeners();
  }

  void setBaseConstantValues() async {
    viewAllTaskYN =
        await BaseSecureStorage.getBool(BaseConstants.viewAllTaskYN);
    notifyListeners();
  }

  void goToPageWithOutApi({required int index}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!pageController.hasClients) return;
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void goToPage({required int index, bool isFromButtonClick = false}) {
    if (isFromButtonClick) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!pageController.hasClients) return;
        pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
    if (index == 0 && selectedTab != index) {
      fetchProjectScheduleDataMyTask();
      clearSearch();
    } else if (index == 1 && selectedTab != index) {
      fetchReportingToScheduleData();
      clearSearch();
    } else if (index == 2 && selectedTab != index) {
      fetchProjectScheduleData();
      clearSearch();
    }

    selectedTab = index;
    notifyListeners();
  }

  void onPageChanged(int index) {
    selectedTab = index;
    if (selectedTab == 0) {
      fetchProjectScheduleDataMyTask();
      clearSearch();
    } else if (selectedTab == 1) {
      fetchReportingToScheduleData();
      clearSearch();
    } else {
      fetchProjectScheduleData();
      clearSearch();
    }
    notifyListeners();
  }

  void updateProgress(double newValue) {
    print("Entering123");
    progressValue = newValue.clamp(0.0, 1.0);
    if (taskStatusDropdownList.isNotEmpty) {
      if (progressValue == 1) {
        if (taskStatusDropdownList
            .any((e) => e.taskStatusCode == "COMPLETED")) {
          selectedStatus = taskStatusDropdownList.firstWhere(
            (e) => e.taskStatusCode == "COMPLETED",
          );
        }
      } else if (progressValue == 0) {
        if (taskStatusDropdownList.any((e) => e.taskStatusCode == "PENDING")) {
          selectedStatus = taskStatusDropdownList
              .firstWhere((element) => element.taskStatusCode == "PENDING");
        }
      } else {
        if (taskStatusDropdownList
            .any((e) => e.taskStatusCode == "IN_PROGRESS")) {
          selectedStatus = taskStatusDropdownList
              .firstWhere((element) => element.taskStatusCode == "IN_PROGRESS");
        }
      }
    }
    notifyListeners();
  }

  void updateProgressPercent(double newValue, int statusId) {
    const double epsilon = 0.0001;

    // Convert 0–100 range input into 0–1 range for storage
    progressValue = (newValue / 100).clamp(0.0, 1.0);

    if (taskStatusDropdownList.isNotEmpty) {
      if ((progressValue - 1.0).abs() < epsilon) {
        selectedStatus = taskStatusDropdownList.firstWhere(
          (e) => e.taskStatusCode == "COMPLETED",
          orElse: () => taskStatusDropdownList.first,
        );
      } else if ((progressValue - 0.0).abs() < epsilon) {
        selectedStatus = taskStatusDropdownList.firstWhere(
          (e) => e.taskStatusCode == "PENDING",
          orElse: () => taskStatusDropdownList.first,
        );
      } else {
        selectedStatus = taskStatusDropdownList.firstWhere(
          (e) => e.taskStatusId == statusId,
          orElse: () => taskStatusDropdownList.first,
        );
      }
    }

    notifyListeners();
  }

  int projectId = 0;
  bool isFromMyTask = true;

  String statusMyTask = "None";
  String statusReporteesTask = "None";
  String selectedFilter = "All";
  Map<String, dynamic>? extra;

  bool reporteesTasksFlag = false;
  bool isReporteeUser = false;
  int userIdFilter = 0;
  int userIdReporteesFilter = 0;


  String scopeFlag = "INDIVIDUAL";
  void setParameter(Map<String, dynamic>? extra, bool isFromMyTask,
      bool isForAllTask, WidgetRef ref) {

    reporteesTasksFlag = false;
    scopeFlag = "INDIVIDUAL";
    this.extra = extra;
    print("extra___ $extra");

    reporteesTasksFlag= extra!["reporteesTasksFlag"] != null && extra["reporteesTasksFlag"] == true;
    isReporteeUser= extra!["isReporteeUser"] != null && extra["isReporteeUser"] == true;
    scopeFlag =  extra["scopeFlag"] ?? "INDIVIDUAL";

    if (extra != null && extra["projectId"] != null) {
      projectId = int.parse(extra["projectId"].toString());
    } else if (extra != null && extra["transid"] != null) {
      projectId = int.parse(extra["transid"].toString());
    }
    fetchProjectDetails(projectId: projectId);





    if (statusMyTask == "None") {
      selectedFilter = "All";
    } else if (statusMyTask == "ON_TRACK") {
      selectedFilter = "On Track";
    } else if (statusMyTask == "DELAYED") {
      selectedFilter = "Delayed";
    } else if (statusMyTask == "PENDING") {
      selectedFilter = "Total Pending";
    }




    fetchProjectScheduleData(); // for getting summary

    this.isFromMyTask = isFromMyTask;
    if (isForAllTask) {
      print("entered__2_");
      selectedTab = 2;
    } else if (isFromMyTask && !isReporteeUser) {
      userIdFilter = extra["userId"] ?? 0;
      statusMyTask = extra["status"] ?? "None";
      fetchProjectScheduleDataMyTask();
      selectedTab = 0;
    } else {
      userIdReporteesFilter = extra["userId"] ?? 0;
      statusReporteesTask = extra["status"] ?? "None";
      fetchReportingToScheduleData();
      selectedTab = 1;
    }
    goToPageWithOutApi(index: selectedTab);
    notifyListeners();
  }

  void changeRadioButtonStatus(String value) {
    selectedFilter = value;
    if (selectedFilter == "All") {
      statusMyTask = "None";
    } else if (selectedFilter == "On Track") {
      statusMyTask = "ON_TRACK";
    } else if (selectedFilter == "Delayed") {
      statusMyTask = "DELAYED";
    } else if (selectedFilter == "Total Pending") {
      statusMyTask = "PENDING";
    }
    notifyListeners();
  }

  void updateReporteeTasksStatus(bool flag) {
    reporteesTasksFlag = flag;
    notifyListeners();
  }

  int taskId = 0;
  bool isFromSupport = false;
  bool isFromOtherUser = true; // not logged in user
  bool isSuperUser = false;
  bool isFromReporteeTask = false;
  ProjectTaskPredecessorModel? predecessorDataFromOverride;
  int loggedInId = 0;
  String loggedUserName = "";
  void setParameterDetailPage(Map<String, dynamic>? extra) async {
    if (extra != null) {
      taskId = extra["taskId"] ?? extra["transid"];
      if (extra["projectId"] != null) {
        projectId = extra["projectId"];
      }
      isFromSupport = extra["isFromSupport"] ?? false;
      isFromOtherUser = extra["isFromLoggedInUser"] ?? true;
      isProjectLocked = extra["isProjectLocked"] ?? true;
      if (extra.containsKey("isFromReporteeTask")) {
        isFromReporteeTask = extra["isFromReporteeTask"] == true;
      } else {
        isFromReporteeTask = extra["tabName"] == "reporting_to";
      }
      print("isFromReporteeTask__ " + isFromReporteeTask.toString());
      predecessorDataFromOverride = extra["predecessorData"];
      notifyListeners();
      fetchProjectScheduleFillData();
    }
    isSuperUser = await BaseSecureStorage.getBool(BaseConstants.superUserYN);
    loggedInId = await BaseSecureStorage.getInt(BaseConstants.userID);
    loggedUserName = await BaseSecureStorage.getString(BaseConstants.userName);
  }

  void clearValues() {
    progressValue = 0.0;
    if (taskStatusDropdownList.isNotEmpty) {
      selectedStatus = taskStatusDropdownList
          .firstWhere((element) => element.taskStatusCode == "PENDING");
    }
    // selectedStatus = 'Not Started';
    notifyListeners();
  }

  void changeStatus(TaskStatusDropdownDtlModel? newValue) {
    if (newValue?.taskStatusCode == "COMPLETED") {
      progressValue = 1;
    } else if (newValue?.taskStatusCode == 'PENDING') {
      progressValue = 0.0;
    }
    selectedStatus = newValue!;
    notifyListeners();
  }

  bool isProjectLocked = false;
  List<TaskModel> tasks = [];
  List<TaskModel> myScheduleTasks = [];
  ScheduleHealthModel? summaryHealth;

  // Add this map to store expansion states
  Map<int, bool> _expansionStatesMyTask = {};
  Map<int, bool> _expansionStatesReporteesTask = {};
  Map<int, bool> _expansionStatesAllTask = {};

  void fetchProjectScheduleData() {
    _saveExpansionStates(tasks, _expansionStatesAllTask);

    final token = beginLoading(_slotAllTask);

    if (selectedTab == 2) {
      changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    }

    ProjectScheduleUseCase().fetchProjectScheduleData(
        projectId: projectId,
        userId: userIdFilter,
        onRequestSuccess: (
          result,
        ) {
          if (result != null && result.first.tasks.isNotEmpty) {
            tasks = result.first.tasks;
            tasks.first.isExpanded = true;
            _restoreExpansionStates(tasks, _expansionStatesAllTask);
          }
          summaryHealth = result?.first.scheduleHealth;
          isProjectLocked = result?.first.isProjectLocked ?? false;
          changeLoadingStatusIfActive(
            token: token,
            slot: _slotAllTask,
            loadingStatus: LoadingStatus(loader: Loader.success),
          );
        },
        onRequestFailure: (exception) {
          changeLoadingStatusIfActive(
              token: token,
              slot: _slotAllTask,
              loadingStatus:
                  LoadingStatus(loader: Loader.error, exception: exception));
        });
  }

  void setTreeExpansion({
    required List<TaskModel> tasks,
    required bool isExpanded,
  }) {
    for (final task in tasks) {
      task.isExpanded = isExpanded;

      if (task.children.isNotEmpty) {
        setTreeExpansion(
          tasks: task.children,
          isExpanded: isExpanded,
        );
      }
    }
  }

  bool _isTreeExpanded = true;
  bool get isTreeExpanded => _isTreeExpanded;

  bool isTreeToggling = false;

  void toggleTreeExpansion(List<TaskModel> tasks) {
    _isTreeExpanded = !_isTreeExpanded;
    isTreeToggling = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setExpansion(tasks, _isTreeExpanded);
      isTreeToggling = false;
      notifyListeners();
    });

    notifyListeners();
  }

  void _setExpansion(List<TaskModel> tasks, bool expanded) {
    for (final task in tasks) {
      task.isExpanded = expanded;
      if (task.children.isNotEmpty) {
        _setExpansion(task.children, expanded);
      }
    }
  }

  void fetchProjectScheduleDataMyTask({String? status}) {
    if (status != null) {
      myScheduleTasks = [];
      statusMyTask = status;
    }
    _saveExpansionStates(myScheduleTasks, _expansionStatesMyTask);
    final token = beginLoading(_slotMyTask);
    if (selectedTab == 0) {
      changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    }

    ProjectScheduleUseCase().fetchProjectScheduleDataMyTask(
        projectId: projectId,
        status: statusMyTask,
        userId: userIdFilter,
        scopeFlag: scopeFlag,
        onRequestSuccess: (result) {
          if (result != null && result.schedule.isNotEmpty) {
            myScheduleTasks = result.schedule ?? [];
            for (TaskModel task in myScheduleTasks) {
              task.isExpanded = true;
              for (var child in task.children) {
                child.isExpanded = true;
                for (var element in child.children) {
                  element.isExpanded = true;
                  for (var element in element.children) {
                    element.isExpanded = true;
                  }
                }
              }
            }

            _restoreExpansionStates(myScheduleTasks, _expansionStatesMyTask);
          }
          scheduleProjectDetails = result?.scheduleProjectDetails;
          isProjectLocked = result?.isProjectLocked ?? false;

          changeLoadingStatusIfActive(
            token: token,
            slot: _slotMyTask,
            loadingStatus: LoadingStatus(loader: Loader.success),
          );
        },
        onRequestFailure: (exception) {
          changeLoadingStatusIfActive(
            token: token,
            slot: _slotMyTask,
            loadingStatus:
                LoadingStatus(loader: Loader.error, exception: exception),
          );
        });
  }

  List<SummaryModel> summaryData = [];

  void fetchProjectScheduleSummaryData() {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ProjectScheduleUseCase().fetchProjectScheduleSummaryData(
        projectId: projectId,
        onRequestSuccess: (result) {
          summaryData = result ?? [];
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus:
                  LoadingStatus(loader: Loader.error, exception: exception));
        });
  }

  void fetchReportingToScheduleData({String? status}) {
    if (status != null) {
      reportingToTaskList = [];
      statusMyTask = status;
    }
    final token = beginLoading(_slotReportees);

    if (selectedTab == 1) {
      changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    }
    _saveExpansionStates(reportingToTaskList, _expansionStatesReporteesTask);

    ProjectScheduleUseCase().fetchProjectScheduleDataMyReporteesFromHome(
        projectId: projectId,
        status: statusReporteesTask,
        userId: userIdReporteesFilter,
        scopeFlag:scopeFlag,
        reporteesTasksFlag:reporteesTasksFlag,
        onRequestSuccess: (result) {
          if (result != null && result.schedule.isNotEmpty) {
            reportingToTaskList = result.schedule ?? [];
            for (TaskModel task in reportingToTaskList) {
              task.isExpanded = true;
              for (var child in task.children) {
                child.isExpanded = true;
                for (var element in child.children) {
                  element.isExpanded = true;
                  for (var element in element.children) {
                    element.isExpanded = true;
                  }
                }
              }
            }

            _restoreExpansionStates(myScheduleTasks, _expansionStatesMyTask);
          }

          changeLoadingStatusIfActive(
              token: token,
              slot: _slotReportees,
              loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception) {
          changeLoadingStatusIfActive(
            token: token,
            slot: _slotReportees,
            loadingStatus:
            LoadingStatus(loader: Loader.error, exception: exception),
          );
        });

  }


  void expandAndCollapseTaskByTab({required TaskModel task}) {
    if (selectedTab == 0) {
      _toggleExpansion(myScheduleTasks, task.id!);
      // Save state immediately after toggling
      _saveExpansionStates(myScheduleTasks, _expansionStatesMyTask);
    } else if (selectedTab == 2) {
      _toggleExpansion(tasks, task.id!);
      // Save state immediately after toggling
      _saveExpansionStates(tasks, _expansionStatesAllTask);
    }
    notifyListeners();
  }

  bool _toggleExpansion(List<TaskModel> list, int taskId) {
    for (final item in list) {
      if (item.id == taskId) {
        item.isExpanded = !item.isExpanded;
        return true; // found the task
      }

      // Only recurse if children exist and are not empty
      if (item.children.isNotEmpty) {
        final found = _toggleExpansion(item.children, taskId);
        if (found) return true;
      }
    }
    return false; // not found in this branch
  }

  void _saveExpansionStates(List<TaskModel> taskList, Map<int, bool> stateMap) {
    for (var task in taskList) {
      if (task.id != null) {
        stateMap[task.id!] = task.isExpanded;
      }
      // Only recurse if children exist and are not empty
      if (task.children.isNotEmpty) {
        _saveExpansionStates(task.children, stateMap);
      }
    }
  }

  void _restoreExpansionStates(
      List<TaskModel> taskList, Map<int, bool> stateMap) {
    for (var task in taskList) {
      if (task.id != null && stateMap.containsKey(task.id!)) {
        task.isExpanded = stateMap[task.id!]!;
      }
      // Only recurse if children exist and are not empty
      if (task.children.isNotEmpty) {
        _restoreExpansionStates(task.children, stateMap);
      }
    }
  }

  // List<MyScheduleModel> myTaskList = [];
  List<TaskModel> reportingToTaskList = [];
  ScheduleProjectDetails? scheduleProjectDetails;

  bool isExpanded = false;

  void expandAndCollapseTask({
    required TaskModel task,
  }) {
    _toggleExpansion(tasks, task.id!);
    notifyListeners();
  }

  void expandAndCollapseMyTask({
    required TaskModel task,
  }) {
    _toggleExpansion(myScheduleTasks, task.id!);
    notifyListeners();
  }

// For tooltip management
  OverlayEntry? _currentTooltipOverlay;

  void showTaskTooltip({
    required BuildContext context,
    required String statusText,
    required Offset position,
    required Size size,
  }) {
    hideTaskTooltip();

    final screenSize = MediaQuery.of(context).size;
    double tooltipWidth =
        screenSize.width - 100; // You can tweak this if needed
    const margin = 10.0;

    // Compute ideal position
    double left = position.dx - tooltipWidth - margin;
    double top = position.dy + size.height + 5;

    // Prevent tooltip from going off-screen horizontally
    if (left < margin) {
      left = margin;
    } else if (left + tooltipWidth > screenSize.width - margin) {
      left = screenSize.width - tooltipWidth - margin;
    }

    // Prevent tooltip from going off bottom edge
    if (top + 60 > screenSize.height) {
      top = position.dy - 50; // show above if not enough space below
    }

    _currentTooltipOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: left,
        top: top,
        width: tooltipWidth,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              statusText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ),
      ),
    );

    //  Use Overlay.of(context).insert instead of RenderBox
    final overlay = Overlay.of(context);
    if (overlay != null) {
      overlay.insert(_currentTooltipOverlay!);
    }

    notifyListeners();
  }

  void hideTaskTooltip() {
    _currentTooltipOverlay?.remove();
    _currentTooltipOverlay = null;
  }

  @override
  void dispose() {
    hideTaskTooltip();
    pageController.dispose();
    super.dispose();
  }
  // void fetchMyScheduleData(){
  //   changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
  //   ProjectScheduleUseCase().fetchMyScheduleData(
  //       projectId: projectId,
  //       onRequestSuccess: (result,scheduleProjectDetails){
  //         if(result.isNotEmpty){
  //           myTaskList = result;
  //         }
  //         this.scheduleProjectDetails = scheduleProjectDetails;
  //         notifyListeners();
  //         changeLoadingStatus(
  //             loadingStatus: LoadingStatus(loader: Loader.success));
  //       },
  //       onRequestFailure: (exception) {
  //         changeLoadingStatus(
  //             loadingStatus: LoadingStatus(loader: Loader.error, exception: exception));
  //       });
  // }

  List<TaskStatusDropdownDtlModel> taskStatusDropdownList = [];

  void fetchTaskStatusDropdown() {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ProjectScheduleUseCase().fetchTaskStatusDropdown(
        onRequestSuccess: (result) {
      taskStatusDropdownList = result;
      selectedStatus = taskStatusDropdownList.firstWhere(
          (e) => e.taskStatusCode == projectTaskFillData.first.statusCode);
      // (projectTaskFillData.first.completionPerc?.toInt() == 0) ?
      //   taskStatusDropdownList.firstWhere((element) => element.taskStatusCode == "PENDING" ) :
      //     (projectTaskFillData.first.completionPerc?.toInt() == 100) ?
      //       taskStatusDropdownList.firstWhere((element) => element.taskStatusCode == "COMPLETED" ) :
      //       taskStatusDropdownList.firstWhere((element) => element.taskStatusCode == "IN_PROGRESS" ) ;
      if (projectTaskFillData.first.completionPerc == 0.0 &&
          projectTaskFillData.first.statusCode != "IN_PROGRESS") {
        taskStatusDropdownList
            .removeWhere((e) => e.taskStatusCode == "COMPLETED");
      } else {
        taskStatusDropdownList
            .removeWhere((e) => e.taskStatusCode == "PENDING");
      }
      if (projectTaskFillData.first.statusCode == "HOLD") {
        taskStatusDropdownList.removeWhere((e) =>
            e.taskStatusCode == "PENDING" || e.taskStatusCode == "COMPLETED");
      }
      if (projectTaskFillData.first.completionPerc?.toInt() == 100) {
        taskStatusDropdownList.removeWhere(
            (e) => e.taskStatusCode == "PENDING" || e.taskStatusCode == "HOLD");
      }

      notifyListeners();
      changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
    }, onRequestFailure: (exception) {
      changeLoadingStatus(
          loadingStatus:
              LoadingStatus(loader: Loader.error, exception: exception));
    });
  }

  List<ProjectTaskDtlModel> projectTaskFillData = [];
  List<ProjectTaskPredecessorModel> projectTaskPredecessorData = [];
  double completionPerc = 0.0;

  void fetchProjectScheduleFillData() {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    projectTaskFillData = [];
    projectTaskPredecessorData = [];
    ProjectScheduleUseCase().fetchProjectScheduleFillData(
        taskId: taskId,
        onRequestSuccess: (result) {
          if (result != null && result.isNotEmpty) {
            projectTaskFillData = result ?? [];
            if (projectTaskFillData.first.projectId != null) {
              projectId = projectTaskFillData.first.projectId ?? 0;
              fetchProjectDetails(projectId: projectId);
            }
            completionPerc = projectTaskFillData.first.completionPerc ?? 0.0;

            updateProgressPercent(
                projectTaskFillData.first.completionPerc ?? 0.0,
                projectTaskFillData.first.statusId ?? 0);
            if (projectTaskFillData.first.predecessorList.isNotEmpty) {
              projectTaskPredecessorData =
                  projectTaskFillData.first.predecessorList;
            }
            fetchTaskStatusDropdown();
            getAttachedDocuments(taskId: taskId);
            fetchCheckList(refId: projectTaskFillData.first.id ?? 0, refTableId: projectTaskFillData.first.tableId ?? 0);

            notifyListeners();
          }
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus:
                  LoadingStatus(loader: Loader.error, exception: exception));
        });
  }





  void updateTaskStatus({List<CheckListModel>? selectedCheckLists}) {
    final checkLists = selectedCheckLists ?? [];
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    final plannedStartDate =
        projectTaskFillData.first.plannedStartDate ?? DateTime.now().toString();
    final plannedStartDateParsed =
        DateFormat('dd-MM-yyyy hh:mm:ss a').parse(plannedStartDate);
    final plannedStartDateIso = plannedStartDateParsed.toIso8601String();
    final plannedEndDate =
        projectTaskFillData.first.plannedEndDate ?? DateTime.now().toString();
    final plannedEndDateParsed =
        DateFormat('dd-MM-yyyy hh:mm:ss a').parse(plannedEndDate);
    final plannedEndDateIso = plannedEndDateParsed.toIso8601String();
    print("Trans_id --- $taskId");

    ProjectScheduleHdr projectScheduleHdr = ProjectScheduleHdr(
      id: taskId,
      statusid: selectedStatus?.taskStatusId ?? 0,
      completionperc: (progressValue * 100).toInt(),
      taskuserid: projectTaskFillData.first.taskUserId ?? 0,
      plannedstartdate: plannedStartDateIso,
      plannedenddate: plannedEndDateIso,
      seriesNo: attachmentSeriesNo,
      imagesDtl: images,
      lastmoddate: projectTaskFillData.first.lastmoddate ?? "",
      checkListData:checkLists
    );
    ProjectScheduleUseCase().updateTaskStatus(
        projectScheduleHdr: projectScheduleHdr,
        onRequestSuccess: ({required String transNo}) {
          changeLoadingStatus(
              loadingStatus: LoadingStatus(
                  loader: Loader.success,
                  message: "Task updated successfully"));
          return BaseDialog.show(
              context: NavigatorKey.navKey.currentContext!,
              title: "Success",
              message: "Task updated successfully",
              icon: Icon(
                Icons.check_circle_outline,
                color: bayaInfraGreen,
                size: 36,
              ),
              actions: [
                BaseElevatedButton(
                  borderRadius: 24,
                  onPressed: () {
                    projectDetailInitValues();
                    GoRouter.of(NavigatorKey.navKey.currentContext!).pop();
                    GoRouter.of(NavigatorKey.navKey.currentContext!).pop();
                  },
                  backgroundColor:Theme.of(NavigatorKey.navKey.currentState!.context).primaryColor,
                  text: "Ok",
                ),
              ]);
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus:
                  LoadingStatus(loader: Loader.error, exception: exception));
        });
  }

  // Search functionality
  bool isSearching = false;
  String searchQuery = '';

  List<MyScheduleModel> searchResultsOfMyTask = [];
  List<MyScheduleModel> searchResultOfReportingToTask = [];
  List<MyScheduleModel> searchResultOfAllTask = []; // ⬅ CHANGED HERE

  bool searchStarted = false;

  // Toggle search mode
  void toggleSearch() {
    isSearching = !isSearching;
    if (!isSearching) {
      clearSearch();
    }
    notifyListeners();
  }

  // Update search query and perform search
  void updateSearchQuery(String query) {
    searchQuery = query;
    if (query.isEmpty) {
      searchResultsOfMyTask = [];
      searchResultOfAllTask = [];
      searchStarted = false;
    } else {
      searchStarted = true;
      _performSearch(query);
    }

    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    searchQuery = '';
    isSearching = false;
    searchStarted = false;
    searchResultOfAllTask = [];
    searchResultsOfMyTask = [];
    notifyListeners();
  }

  // Convert TaskModel → MyScheduleModel
  MyScheduleModel _convertTaskToMySchedule(TaskModel task) {
    return MyScheduleModel(
      id: task.id,
      name: task.name,
      color: task.color,
    );
  }

  List<MyScheduleModel> _flattenTasks(List<TaskModel> tasks) {
    List<MyScheduleModel> result = [];
    void extract(TaskModel task) {
      if (task.children.isEmpty) {
        // Leaf node
        result.add(_convertTaskToMySchedule(task));
      } else {
        // Continue recursively
        for (var child in task.children) {
          extract(child);
        }
      }
    }

    for (var task in tasks) {
      extract(task);
    }

    return result;
  }

  // Perform search based on current tab
  void _performSearch(String query) {
    final lowerQuery = query.toLowerCase();

    if (selectedTab == 0) {
      print("entering___");
      final flatTasks = _flattenTasks(myScheduleTasks);
      searchResultsOfMyTask = flatTasks.where((task) {
        final taskName = task.name?.toLowerCase() ?? '';
        return taskName.contains(lowerQuery);
      }).toList();
    } else if (selectedTab == 1) {
      final flatTasks = _flattenTasks(reportingToTaskList);
      searchResultsOfMyTask = flatTasks.where((task) {
        final taskName = task.name?.toLowerCase() ?? '';
        return taskName.contains(lowerQuery);
      }).toList();
    } else {
      // Search in All Tasks (now MyScheduleModel list)
      final flatTasks = _flattenTasks(tasks); // MyScheduleModel list

      searchResultOfAllTask = flatTasks.where((task) {
        final taskName = task.name?.toLowerCase() ?? '';
        return taskName.contains(lowerQuery);
      }).toList();
    }
  }

  //Upload image section
  String attachmentSeriesNo = "";
  List<UploadResponse> images = [];
  List<AttachmentModel> attachmentUrl = [];

  List<ProjectDetailsModel> projectDetailList = [];

  Future<void> fetchProjectDetails({required int projectId}) async {
    ProjectScheduleUseCase().fetchProjectDetails(
        projectId: projectId,
        onRequestSuccess: (result) {
          projectDetailList = result;
          notifyListeners();
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.error));
        });
    notifyListeners();
  }

  Future<void> fetchAttachmentsDetail({
    required List<UploadResponse> attachmentList,
  }) {
    final completer = Completer<void>();

    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));

    ProjectScheduleUseCase().fetchAttachmentsDetail(
      attachmentList: attachmentList,
      onRequestSuccess: (result) {
        attachmentUrl.addAll(result.attachmentUrl);
        changeLoadingStatus(
            loadingStatus: LoadingStatus(loader: Loader.success));
        completer.complete();
      },
      onRequestFailure: (exception) {
        changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error));
        completer.completeError(exception);
      },
    );

    return completer.future;
  }

  void addImage(List<UploadResponse> file) {
    images.addAll(file);
    attachmentUrl
        .addAll(file.map((e) => AttachmentModel(url: e.url ?? "")).toList());
    notifyListeners();
  }

  void uploadImageFile(List<File> file) async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    await ProjectScheduleUseCase().uploadImageFile(
        file: file,
        uploadProgress: (progress) {
          loadingProgress = progress;
          notifyListeners();
        },
        attachmentSerialNo: attachmentSeriesNo,
        onRequestSuccess: (response) {
          addImage(response);
          attachmentSeriesNo = response.last.serialno ?? "";
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus:
                  LoadingStatus(loader: Loader.error, exception: exception));
        });
  }

  List<TaskAttachmentModel> taskAttachmentList = [];

  PageController? pageControllerHeaderCard = PageController();

  void getAttachedDocuments({required int taskId}) {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ProjectScheduleUseCase().getAttachedDocuments(
        taskId: taskId,
        onRequestSuccess: (result) {
          taskAttachmentList = result;
          List<UploadResponse> attachmentList = [];
          if (taskAttachmentList.isNotEmpty) {
            attachmentList = taskAttachmentList
                .map(
                    (e) => UploadResponse(physicalfilename: e.filePhysicalName))
                .toList();
          }
          if (taskAttachmentList.isNotEmpty) {
            fetchAttachmentsDetail(attachmentList: attachmentList);
          }
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus:
                  LoadingStatus(loader: Loader.error, exception: exception));
        });
  }


  List<SupportRequestDtlModel> itemAgainstSupportRequestList = [];
  int taskSupTotalRecords = 0;
  int taskSupStart = 0;
  int taskSupLimit = 10;
  bool taskSupportFetched = false;
  ScrollController taskAgainstSupportController = ScrollController();

  void taskAgainstSupportInitValues() {
    taskId = 0;
    transNoController = TextEditingController(text: "");
    taskAgainstSupportController = ScrollController();
    closureDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
    closureDateTo = DateTime.now();
    tempClosureDateFrom = null;
    tempClosureDateTo = null;
    isShowAllTaskSupport = true;
    tempIsShowAllTaskSupport = null;
    filterTempSelectedStatus = null;
    filterSelectedStatus = filterStatusList.first;
    itemAgainstSupportRequestList = [];
    taskSupportFetched = false;
    taskSupStart = 0;
    paginationController();
    notifyListeners();
  }

  List<FilterStatusModel> filterStatusList = [
    FilterStatusModel(statusName: 'All', statusCode: 'ALL'),
    FilterStatusModel(statusName: 'Closed', statusCode: 'CLOSED'),
    FilterStatusModel(statusName: 'Pending', statusCode: 'PENDING'),
  ];

  void fetchTaskAgainstSupportList({bool changeStart = false}) {
    taskSupportFetched = false;
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    if (changeStart) {
      itemAgainstSupportRequestList = [];
      taskSupStart = 0;
    }
    ProjectScheduleUseCase().fetchTaskAgainstSupportList(
        taskAgainstSupportListModel: TaskAgainstSupportListModel(
            projectId: projectId,
            taskId: taskId,
            materialItemId: materialItemId,
            status: filterSelectedStatus?.statusCode ?? "",
            transNo: transNoController.text,
            start: taskSupStart,
            limit: taskSupLimit,
            dateFrom: DateFormat('yyyy-MM-dd').format(closureDateFrom),
            dateTo: DateFormat('yyyy-MM-dd').format(closureDateTo),
            isShowAllTaskSupport: isShowAllTaskSupport,
            isFromAdditionalMaterial: isFromAdditionalMaterial,
            action: isFromAdditionalMaterial ? "ADD_MATERIAL_CHART" : ""),
        onRequestSuccess: (result) {
          if (taskSupStart == 0) {
            itemAgainstSupportRequestList = result;
            taskSupTotalRecords =
                (result.isNotEmpty) ? result.first.totalRecords ?? 0 : 0;
          } else {
            itemAgainstSupportRequestList += result;
            taskSupTotalRecords =
                (result.isNotEmpty) ? result.first.totalRecords ?? 0 : 0;
          }
          taskSupportFetched = true;
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

  int materialItemId = 0;
  bool isFromAdditionalMaterial = false;
  void setTaskAgainstSupportParameter(Map<String, dynamic>? extra) {
    if (extra != null) {
      taskId = extra['taskId'] ?? 0;
      if (extra['materialItemId'] != null) {
        isFromAdditionalMaterial = true;
        materialItemId = extra['materialItemId'] ?? 0;
        projectId = extra['projectId'] ?? 0;
      }
    }
    fetchTaskAgainstSupportList();
    notifyListeners();
  }

  void paginationController() {
    taskAgainstSupportController.addListener(() {
      if (taskAgainstSupportController.position.pixels ==
              taskAgainstSupportController.position.maxScrollExtent &&
          (itemAgainstSupportRequestList.first.totalRecords ?? 0) >
              ((taskSupStart == 0)
                  ? taskSupLimit
                  : taskSupStart + taskSupLimit)) {
        taskSupStart += taskSupLimit;
        fetchTaskAgainstSupportList();
      }
    });
  }

  //Filter
  DateTime closureDateFrom =
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime closureDateTo = DateTime.now();
  DateTime? tempClosureDateFrom;
  DateTime? tempClosureDateTo;
  bool isShowAllTaskSupport = true;
  bool? tempIsShowAllTaskSupport;
  FilterStatusModel? filterTempSelectedStatus;
  FilterStatusModel? filterSelectedStatus;
  TextEditingController transNoController = TextEditingController();
  void clearSupportReqFilter({required bool isFromClearButton}) {
    if (isFromClearButton) {
      closureDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
      closureDateTo = DateTime.now();
      filterSelectedStatus = null;
      filterTempSelectedStatus = null;
      tempClosureDateFrom = null;
      tempClosureDateTo = null;
      isShowAllTaskSupport = true;
      tempIsShowAllTaskSupport = null;
      transNoController.clear();
    } else {
      tempClosureDateFrom = null;
      tempClosureDateTo = null;
      filterTempSelectedStatus = null;
      tempIsShowAllTaskSupport = null;
    }
    notifyListeners();
  }

  void changeFilterStatus(FilterStatusModel status) {
    filterTempSelectedStatus = status;
    notifyListeners();
  }

  void setSelectedFilterStatus() {
    if (filterTempSelectedStatus != null) {
      filterSelectedStatus = filterTempSelectedStatus;
    }
    notifyListeners();
  }

  void changeIsShowAllSupport(bool value) {
    tempIsShowAllTaskSupport = value;
    closureDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
    closureDateTo = DateTime.now();
    notifyListeners();
  }

  void changeClosureDateFrom(DateTime date) {
    tempClosureDateFrom = date;
    notifyListeners();
  }

  void changeClosureDateTo(DateTime date) {
    tempClosureDateTo = date;
    notifyListeners();
  }

  void setIsShowAllSupport() {
    isShowAllTaskSupport = tempIsShowAllTaskSupport ?? true;
    notifyListeners();
  }

  void setSptFilterDateField() {
    if (tempClosureDateFrom != null) {
      closureDateFrom = tempClosureDateFrom ??
          DateTime(DateTime.now().year, DateTime.now().month, 1);
    }
    if (tempClosureDateTo != null) {
      closureDateTo = tempClosureDateTo ?? DateTime.now();
    }
    notifyListeners();
  }

  void applyFilter() {
    myScheduleTasks = [];
    fetchProjectScheduleDataMyTask();
    clearSearch();
  }

  void clearFilter() {
    statusMyTask = extra!["status"] ?? "None";
    if (statusMyTask == "None") {
      selectedFilter = "All";
    } else if (statusMyTask == "ON_TRACK") {
      selectedFilter = "On Track";
    } else if (statusMyTask == "DELAYED") {
      selectedFilter = "Delayed";
    } else if (statusMyTask == "PENDING") {
      selectedFilter = "Total Pending";
    }
    if (extra!["reporteesTasksFlag"] != null) {
      updateReporteeTasksStatus(extra!["reporteesTasksFlag"] ?? false);
    }
    notifyListeners();
  }



}

class FilterStatusModel {
  String statusName;
  String statusCode;
  FilterStatusModel({required this.statusName, required this.statusCode});
}
