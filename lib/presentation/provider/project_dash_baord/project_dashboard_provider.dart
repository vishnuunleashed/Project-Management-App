import 'package:base/core/constants.dart';
import 'package:base/core/loader_value.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_design/data/model/response/project_dashboard/project_dashboard_model.dart';
import 'package:interior_design/data/model/response/project_dashboard/user_hierarchy_dto.dart';
import 'package:interior_design/domain/usecase/project_dashboard/project_dashboard_usecase.dart';
import 'package:interior_design/presentation/view/project_dash_board/_partials/call_tracker_dashboard/_partials/call_tracker_tile.dart';
import 'package:interior_design/presentation/view/project_dash_board/_partials/project_based_dashboard/_partials/_project_sub_dashboard.dart';
import 'package:interior_design/presentation/view/project_dash_board/_partials/project_based_dashboard/_partials/additional_material_tile.dart';
import 'package:interior_design/presentation/view/project_dash_board/_partials/schedule/_schedule_sub_dashboard.dart';
enum CategoryFlag {AGAINST,RAISED}
class ProjectDashboardProvider extends BaseProvider{
  List<UserDashboardData> dashBoardResult = [];
  ObservationCount? observationCount;
  SupportReqCount?  supportReqCount;
  ScheduleTaskCount? scheduleTaskCount;
  AdditionalMaterialCount? additionalMaterialCount;
  CallTrackSupportCount? callTrackSupportCount;
  CallTrackCount? callTrackCount;

  int userId = 0;
  int loggedInUserId = 0;
  String scopeFlag = "INDIVIDUAL";
  String loggedInUserName = "";
  String loggedInUserProfileImageUrl = "";

  List<UserHierarchyModel> userHierarchyModel = [];
  int currentUserId = 0;

  bool isExpandedObs = false;
  bool isExpandedSupport = false;
  bool isExpandedSchedule = false;
  bool isExpandedMaterial = false;
  bool isExpandedCallTrackSupport = false;
  bool isExpandedCallTrack = false;

  int obsCurrentPage = 0;
  int supportCurrentPage = 0;
  int materialCurrentPage = 0;
  int callTrackCurrentPage = 0;
  int callTrackSupportCurrentPage = 0;
  int scheduleCurrentPage = 0;


  void toggleObs() {
    if (isExpandedObs) {
      isExpandedObs = false;
    } else {
      isExpandedObs = true;
      isExpandedSupport = false;
      isExpandedSchedule = false;
      isExpandedMaterial = false;
      isExpandedCallTrackSupport = false;
      isExpandedCallTrack = false;
      isExpandedOpen = false;
      isExpandedDelayed = false;
    }
    obsCurrentPage = 0;
    notifyListeners();
  }

  void toggleSupport() {
    if (isExpandedSupport) {
      isExpandedSupport = false;
    } else {
      isExpandedObs = false;
      isExpandedSupport = true;
      isExpandedSchedule = false;
      isExpandedMaterial = false;
      isExpandedCallTrackSupport = false;
      isExpandedCallTrack = false;
      isExpandedOpen = false;
      isExpandedDelayed = false;
    }
    supportCurrentPage = 0;
    notifyListeners();
  }

  void toggleSchedule() {
    if (isExpandedSchedule) {
      isExpandedSchedule = false;
    } else {
      isExpandedObs = false;
      isExpandedSupport = false;
      isExpandedSchedule = true;
      isExpandedMaterial = false;
      isExpandedCallTrackSupport = false;
      isExpandedCallTrack = false;
      isExpandedOpen = false;
      isExpandedDelayed = false;
    }
    scheduleCurrentPage = 0;
    notifyListeners();
  }

  void toggleMaterial() {
    if (isExpandedMaterial) {
      isExpandedMaterial = false;
    } else {
      isExpandedObs = false;
      isExpandedSupport = false;
      isExpandedSchedule = false;
      isExpandedMaterial = true;
      isExpandedCallTrackSupport = false;
      isExpandedCallTrack = false;
      isExpandedOpen = false;
      isExpandedDelayed = false;
    }
    materialCurrentPage = 0;
    notifyListeners();
  }

  void toggleCallTrackSupport() {
    if (isExpandedCallTrackSupport) {
      isExpandedCallTrackSupport = false;
    } else {
      isExpandedObs = false;
      isExpandedSupport = false;
      isExpandedSchedule = false;
      isExpandedMaterial = false;
      isExpandedCallTrackSupport = true;
      isExpandedCallTrack = false;
      isExpandedOpen = false;
      isExpandedDelayed = false;
    }
    callTrackSupportCurrentPage = 0;
    notifyListeners();
  }

  void toggleCallTrack() {
    if (isExpandedCallTrack) {
      isExpandedCallTrack = false;
    } else {
      isExpandedObs = false;
      isExpandedSupport = false;
      isExpandedSchedule = false;
      isExpandedMaterial = false;
      isExpandedCallTrackSupport = false;
      isExpandedCallTrack = true;
      isExpandedOpen = false;
      isExpandedDelayed = false;
    }
    callTrackCurrentPage = 0;
    notifyListeners();
  }
  bool isProjectDepartment = false;
  bool isSuperUser = false;

  Future<void> initValue() async {
    isProjectDepartment = await BaseSecureStorage.getString(BaseConstants.departmentCode) == "PRJ";
    isSuperUser = await BaseSecureStorage.getBool(BaseConstants.superUserYN);
    selectedUser = null;
    dashBoardResult = [];
    userHierarchyModel = [];
    observationCount = null;
    supportReqCount = null;
    scheduleTaskCount = null;
    additionalMaterialCount = null;
    callTrackSupportCount = null;
    callTrackCount = null;

    userId = await BaseSecureStorage.getInt(BaseConstants.userID);
    loggedInUserId =  await BaseSecureStorage.getInt(BaseConstants.userID);
    loggedInUserName = await BaseSecureStorage.getString(BaseConstants.userName);
    loggedInUserProfileImageUrl = await BaseSecureStorage.getString(BaseConstants.loggedInUserProfileImageUrl);
    currentUserId = await BaseSecureStorage.getInt(BaseConstants.userID);
    scopeFlag = "INDIVIDUAL";

    isExpandedObs = false;
    isExpandedSupport = false;
    isExpandedSchedule = false;
    isExpandedMaterial = false;
    isExpandedCallTrackSupport = false;
    isExpandedCallTrack = false;
    isExpandedOpen = false;
    isExpandedDelayed = false;

    obsCurrentPage = 0;
    supportCurrentPage = 0;
    materialCurrentPage = 0;
    callTrackCurrentPage = 0;
    callTrackSupportCurrentPage = 0;
    scheduleCurrentPage = 0;

    categoryFlag = CategoryFlag.AGAINST;
    getUserHierarchy();
    fetchDashboard();

  }


  CategoryFlag categoryFlag = CategoryFlag.AGAINST;


  List<Project> observations = [];
  List<Project> supportRequests = [];
  List<ScheduleProject> schedules = [];
  List<MaterialProject> additionalMaterials = [];
  List<CallTrackSupportTicket> callTrackSupports = [];



  Future<void> fetchDashboard() async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ProjectDashBoardUseCase().fetchDashboard(
        userId: userId,
        scopeFlag: scopeFlag,
        categoryFlag: categoryFlag.name,
        onRequestSuccess: (result){
          if(result.isNotEmpty){
            dashBoardResult = result;
            observationCount = dashBoardResult.first.observationCount;
            supportReqCount = dashBoardResult.first.supportReqCount;
            scheduleTaskCount = dashBoardResult.first.scheduleTaskCount;
            additionalMaterialCount = dashBoardResult.first.additionalMaterialCount;
            callTrackSupportCount = dashBoardResult.first.callTrackSupportCount;
            callTrackCount = dashBoardResult.first.callTrackCount;
            // Convert provider data to UI models
            final prevObservations = observations;
            final prevSupportRequests = supportRequests;
            final prevAdditionalMaterials = additionalMaterials;
            final prevCallTrackSupports = callTrackSupports;

            observations = observationCount?.projectWise.map((pw) {
              final prev = prevObservations
                  .where((p) => p.id == (pw.projectId ?? 0))
                  .firstOrNull;
              return Project(
                id: pw.projectId ?? 0,
                name: pw.projectName ?? '',
                reportingToYN: pw.reportingToYN ?? '',
                open: pw.openCount ?? 0,
                delayed: pw.delayedCount ?? 0,
                openUnassigned: pw.openUnassignedCount ?? 0,
                openAssigned: pw.openAssignedCount ?? 0,
                openSubmitted: pw.openSubmitCount ?? 0,
                openRejected: pw.openRejectedCount ?? 0,
                delayedUnassigned: pw.delayedUnassignedCount ?? 0,
                delayedAssigned: pw.delayedAssignedCount ?? 0,
                delayedSubmitted: pw.delayedSubmitCount ?? 0,
                delayedRejected: pw.delayedRejectedCount ?? 0,
                total: (pw.openCount ?? 0) + (pw.delayedCount ?? 0),
                isExpandedOpen: prev?.isExpandedOpen ?? false,
                isExpandedDelayed: prev?.isExpandedDelayed ?? false,
              );
            }).toList() ?? [];

            supportRequests = supportReqCount?.projectWise.map((pw) {
              final prev = prevSupportRequests
                  .where((p) => p.id == (pw.projectId ?? 0))
                  .firstOrNull;
              return Project(
                id: pw.projectId ?? 0,
                reportingToYN: pw.reportingToYN ?? "N",
                name: pw.projectName ?? '',
                open: pw.openCount ?? 0,
                delayed: pw.delayedCount ?? 0,
                openAssigned: pw.openAssignedCount ?? 0,
                openForwarded: pw.openForwardedCount ?? 0,
                openSubmitted: pw.openSubmitCount ?? 0,
                openReassigned: pw.openReassignedCount ?? 0,
                delayedAssigned: pw.delayedAssignedCount ?? 0,
                delayedForwarded: pw.delayedForwardedCount ?? 0,
                delayedSubmitted: pw.delayedSubmitCount ?? 0,
                delayedReassigned: pw.delayedReassignedCount ?? 0,
                total: (pw.openCount ?? 0) + (pw.delayedCount ?? 0),
                isExpandedOpen: prev?.isExpandedOpen ?? false,
                isExpandedDelayed: prev?.isExpandedDelayed ?? false,
              );
            }).toList() ?? [];

            schedules = scheduleTaskCount?.projectWise.map((pw) {
              return ScheduleProject(
                name: pw.projectName ?? '',
                reportingToYN: pw.reportingToYN ?? '',
                projectId: pw.projectId ?? 0,
                totalTasksOpen: pw.onTrack ?? 0,
                delayedTasks: pw.delayed ?? 0,
                inProgressTasks: 0,
                supportRequestsToOvercomeDelay: 0,
                totalPending: pw.totalPending ?? 0,
                total: (pw.onTrack ?? 0) + (pw.delayed ?? 0) + (pw.totalPending ?? 0),
              );
            }).toList() ?? [];

            additionalMaterials = additionalMaterialCount?.projectWise.map((pw) {
              final prev = prevAdditionalMaterials
                  .where((p) => p.projectId == (pw.projectId ?? 0))
                  .firstOrNull;
              return MaterialProject(
                projectId: pw.projectId ?? 0,
                projectName: pw.projectName ?? '',
                approvalPending: pw.approvalPendingCount ?? 0,
                poUpdate: pw.poUpdateCount ?? 0,
                received: pw.receivedCount ?? 0,
                exceededReceived: pw.exceededReceivedCount ?? 0,
                sendBackCount: pw.sendBackCount ?? 0,
                total: (pw.approvalPendingCount ?? 0) +
                    (pw.poUpdateCount ?? 0) +
                    (pw.receivedCount ?? 0) +
                    (pw.exceededReceivedCount ?? 0) +
                    (pw.sendBackCount ?? 0),
                isExpandedOpen: prev?.isExpandedOpen ?? false,
                isExpandedDelayed: prev?.isExpandedDelayed ?? false,
              );
            }).toList() ?? [];

            callTrackSupports = callTrackSupportCount?.ticketWise.map((tw) {
              final prev = prevCallTrackSupports
                  .where((p) => p.ticketId == (tw.ticketId ?? 0))
                  .firstOrNull;
              return CallTrackSupportTicket(
                ticketId: tw.ticketId ?? 0,
                clientName: tw.clientName ?? '',
                siteName: tw.siteName,
                ticketNo: tw.ticketNo ?? '',
                isEngineerYN: tw.isEngineerYN ?? 'N',
                optionId: tw.optionId ?? 0,
                open: tw.openCount ?? 0,
                openSubmit: tw.openSubmitCount ?? 0,
                openAssigned: tw.openAssignedCount ?? 0,
                openReassigned: tw.openReassignedCount ?? 0,
                openForwarded: tw.openForwardedCount ?? 0,
                delayed: tw.delayedCount ?? 0,
                delayedSubmit: tw.delayedSubmitCount ?? 0,
                delayedAssigned: tw.delayedAssignedCount ?? 0,
                delayedReassigned: tw.delayedReassignedCount ?? 0,
                delayedForwarded: tw.delayedForwardedCount ?? 0,
                total: (tw.openCount ?? 0) + (tw.delayedCount ?? 0),
                ticketCount: tw.ticketCount ?? 0,
                isExpandedDelayed: prev?.isExpandedDelayed ?? false,
                isExpandedOpen: prev?.isExpandedOpen ?? false,
                clientid: tw.clientid??0
              );
            }).toList() ?? [];
          }
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception){
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error, exception: exception));
        });
  }


  void getUserHierarchy(){
    userHierarchyModel = [];
    ProjectDashBoardUseCase().getUserHierarchy(
        onRequestSuccess: (result){
          if(result.isNotEmpty){
            userHierarchyModel = result;
            userHierarchyModel.add(UserHierarchyModel(
                userName: loggedInUserName,
                userId: loggedInUserId,
                userProfileImageUrl:loggedInUserProfileImageUrl));

            notifyListeners();
          }
        },
        onRequestFailure: (exception){
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error, exception: exception));
        });
  }



  UserHierarchyModel? selectedUser;

  void updateSelectedUser({required UserHierarchyModel user, required String scopeFlag}) {
    userId = user.userId??loggedInUserId;
    scopeFlag = scopeFlag;
    selectedUser = _getSelectedUser();
    isExpandedObs = false;
    isExpandedSupport = false;
    isExpandedSchedule = false;
    isExpandedMaterial = false;
    isExpandedCallTrackSupport = false;
    isExpandedCallTrack = false;
    isExpandedOpen = false;
    isExpandedDelayed = false;
    notifyListeners();
    fetchDashboard();

  }

  UserHierarchyModel? _getSelectedUser() {
    if (userHierarchyModel.isEmpty) return null;

    try {
      return userHierarchyModel.firstWhere(
            (user) => user.userId == userId,
        orElse: () => userHierarchyModel.first,
      );
    } catch (e) {
      return userHierarchyModel.isNotEmpty
          ? userHierarchyModel.first
          : null;
    }
  }

  void changeScopeFlag({required String scopeFlag}) {
    this.scopeFlag = scopeFlag;
    isExpandedObs = false;
    isExpandedSupport = false;
    isExpandedSchedule = false;
    isExpandedMaterial = false;
    isExpandedCallTrackSupport = false;
    isExpandedCallTrack = false;
    isExpandedOpen = false;
    isExpandedDelayed = false;
    fetchDashboard();

  }
  void changeCategoryFlag({required CategoryFlag categoryFlag}) {
    this.categoryFlag = categoryFlag;
    isExpandedObs = false;
    isExpandedSupport = false;
    isExpandedSchedule = false;
    isExpandedMaterial = false;
    isExpandedCallTrackSupport = false;
    isExpandedCallTrack = false;
    isExpandedOpen = false;
    isExpandedDelayed = false;
    fetchDashboard();

  }



  bool isExpandedOpen = false;
  bool isExpandedDelayed = false;

  int currentIndex = 0;

  void toggleTicketExpandedOpen(int index) {
    currentIndex = index;
    callTrackSupports[index] = callTrackSupports[index].copyWith(
          isExpandedOpen: !callTrackSupports[index].isExpandedOpen,
          isExpandedDelayed: false,
    );
    notifyListeners();
  }

  void toggleTicketExpandedDelayed(int index) {
    currentIndex = index;
    callTrackSupports[index] = callTrackSupports[index].copyWith(
          isExpandedDelayed: !callTrackSupports[index].isExpandedDelayed,
          isExpandedOpen: false,
    );
    notifyListeners();
  }

  void toggleObsExpandedOpen(int index) {
    observations[index] = observations[index].copyWith(
      isExpandedOpen: !observations[index].isExpandedOpen,
      isExpandedDelayed: false,
    );
    notifyListeners();
  }

  void toggleObsExpandedDelayed(int index) {
    observations[index] = observations[index].copyWith(
      isExpandedDelayed: !observations[index].isExpandedDelayed,
      isExpandedOpen: false,
    );
    notifyListeners();
  }

  void toggleSupportExpandedOpen(int index) {
    supportRequests[index] = supportRequests[index].copyWith(
      isExpandedOpen: !supportRequests[index].isExpandedOpen,
      isExpandedDelayed: false,
    );
    notifyListeners();
  }

  void toggleSupportExpandedDelayed(int index) {
    supportRequests[index] = supportRequests[index].copyWith(
      isExpandedDelayed: !supportRequests[index].isExpandedDelayed,
      isExpandedOpen: false,
    );
    notifyListeners();
  }

  void toggleMaterialExpandedOpen(int index) {
    additionalMaterials[index] = additionalMaterials[index].copyWith(
      isExpandedOpen: !additionalMaterials[index].isExpandedOpen,
      isExpandedDelayed: false,
    );
    notifyListeners();
  }

  void toggleMaterialExpandedDelayed(int index) {
    additionalMaterials[index] = additionalMaterials[index].copyWith(
      isExpandedDelayed: !additionalMaterials[index].isExpandedDelayed,
      isExpandedOpen: false,
    );
    notifyListeners();
  }

  void changeOpenedExpansionFlag(){
    isExpandedDelayed = false;
    isExpandedOpen = !isExpandedOpen;
    notifyListeners();
  }

  void closeExpansionFlag(){
    isExpandedOpen = false;
    isExpandedDelayed = false;
    notifyListeners();
  }

  void changeDelayedExpansionFlag(){
    isExpandedOpen = false;
    isExpandedDelayed = !isExpandedDelayed;
    notifyListeners();
  }

  void changeHierarchyUsersExpansion(int userId) {
    int index = userHierarchyModel
        .indexWhere((item) => item.userId == userId);

    if (index == -1) return;

    userHierarchyModel[index] =
        userHierarchyModel[index]
            .copyWith(isExpanded: !(userHierarchyModel[index].isExpanded));

    notifyListeners();
  }

  void collapseAllHierarchyUsers() {
    userHierarchyModel = userHierarchyModel
        .map((user) => user.copyWith(isExpanded: false))
        .toList();
    notifyListeners();
  }

  void expandAllHierarchyUsers() {
    userHierarchyModel = userHierarchyModel
        .map((user) => user.copyWith(isExpanded: true))
        .toList();
    notifyListeners();
  }

  bool get isAllExpanded {
    final hierarchyUsers = userHierarchyModel
        .where((user) => user.userId != loggedInUserId)
        .toList();

    if (hierarchyUsers.isEmpty) return false;
    return hierarchyUsers.every((user) => user.isExpanded == true);
  }

  void updateSchedulePage(int page) {
    scheduleCurrentPage = page;
  }
  void updateObsPage(int page) {
    obsCurrentPage = page;
    notifyListeners();
  }

  void updateSupportPage(int page) {
    supportCurrentPage = page;
    notifyListeners();
  }

  void updateMaterialPage(int page) {
    materialCurrentPage = page;
    notifyListeners();
  }

  void updateCallTrackPage(int page) {
    callTrackCurrentPage = page;
    notifyListeners();
  }

  void updateCallTrackSupportPage(int page) {
    callTrackSupportCurrentPage = page;
    notifyListeners();
  }
}