import 'package:base/core/loader_value.dart' show LoadingStatus, Loader;
import 'package:base/presentation/provider/base_provider.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/data/model/response/call_tracker/service_ticket_dashboard_model.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/domain/usecase/call_tracker/add_service_request_usecase.dart';
import 'package:interior_design/domain/usecase/call_tracker/call_tracker_usercase.dart';
import 'package:interior_design/presentation/provider/call_tracker/call_tracker_provider.dart';
import 'package:intl/intl.dart';

import 'dashboard_filter_provider.dart';

class ServiceTicketDashboardProvider extends BaseProvider {

  List<ServiceTaskStatus> taskStatusJson = [];
  List<ServiceTaskDelayByDays> taskDelayByDaysJson = [];
  List<ServiceClientDelay> clientDelayJson = [];
  List<ServiceMemberDelay> memberDelayJson = [];
  List<TeamTicketDelay> teamTicketDelayJson = [];

  bool allGraphsEmpty = false;
  DashboardFilterProvider? filterProvider;

  void init(DashboardFilterProvider filter) {
    filterProvider = filter;
    filterProvider?.clearDetailFilter();
    filterProvider?.clearFilters();
  }

  ///antigravity: for the time being let the commented code be there i will use it once i get the api.
  /// can you put a dummy json for the time being so that i can work on the ui part.
  ///
  void fetchDashboardData({required TaskDashBoardSummaryFilterModel filter}) {
    changeLoadingStatus(
        loadingStatus: LoadingStatus(loader: Loader.loading));
    CallTrackerUseCase().fetchServiceTicketDashboard(
      taskDashBoardFilterModel: filter,
        onRequestSuccess: (result) {
          if (result.isNotEmpty) {
            final data = result.first;
            taskStatusJson = data.taskStatusJson;
            taskDelayByDaysJson = data.taskDelayByDaysJson;
            clientDelayJson = data.clientDelayJson;
            memberDelayJson = data.memberDelayJson;
            teamTicketDelayJson = data.teamDelayTicketJson;
          }

        allGraphsEmpty =
            taskStatusJson.first.serviceCount == 0 &&
                taskDelayByDaysJson.first.taskCount == 0 &&
                clientDelayJson.isEmpty &&
                memberDelayJson.isEmpty && teamTicketDelayJson.isEmpty;
        notifyListeners();

          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.error, exception: exception));
        });
  }

  /// Dummy data for UI development — remove once real API is wired.
  // void fetchDashboardData() {
  //   changeLoadingStatus(
  //       loadingStatus: LoadingStatus(loader: Loader.loading));
  //
  //   // Chart 1: Service Tasks Status
  //   taskStatusJson = [
  //     ServiceTaskStatus(statusCategory: 'On Track', statusCategoryCode: 'ON_TRACK', taskCount: 9),
  //     ServiceTaskStatus(statusCategory: 'Delay', statusCategoryCode: 'DELAY', taskCount: 22),
  //     ServiceTaskStatus(statusCategory: 'Future Task', statusCategoryCode: 'FUTURE_TASK', taskCount: 18),
  //     ServiceTaskStatus(statusCategory: 'Target Issue', statusCategoryCode: 'TARGET_ISSUE', taskCount: 15),
  //   ];
  //
  //   // Chart 2: Number of Tasks × Days Delay
  //   taskDelayByDaysJson = [
  //     ServiceTaskDelayByDays(delayCategory: 'This Week', delayCategoryCode: 'THIS_WEEK', taskCount: 0),
  //     ServiceTaskDelayByDays(delayCategory: '> 7 Days', delayCategoryCode: 'GT_7', taskCount: 0),
  //     ServiceTaskDelayByDays(delayCategory: '> 15 Days', delayCategoryCode: 'GT_15', taskCount: 0),
  //     ServiceTaskDelayByDays(delayCategory: '> 30 Days', delayCategoryCode: 'GT_30', taskCount: 7),
  //     ServiceTaskDelayByDays(delayCategory: '> 45 Days', delayCategoryCode: 'GT_45', taskCount: 15),
  //   ];
  //
  //   // Chart 3: Client × Delayed Service Requests
  //   clientDelayJson = [
  //     ServiceClientDelay(clientName: 'Unassigned', clientId: 0, delayedCount: 0),
  //     ServiceClientDelay(clientName: 'VWRIT', clientId: 1, delayedCount: 0),
  //     ServiceClientDelay(clientName: 'Trane', clientId: 2, delayedCount: 0),
  //     ServiceClientDelay(clientName: 'SKCL Prime', clientId: 3, delayedCount: 0),
  //     ServiceClientDelay(clientName: 'Wallow', clientId: 4, delayedCount: 0),
  //     ServiceClientDelay(clientName: 'SKCL Harmony Sq...', clientId: 5, delayedCount: 1),
  //   ];
  //
  //   // Chart 4: Team Member × Delayed Service Requests
  //   memberDelayJson = [
  //     ServiceMemberDelay(memberName: 'Unassigned', memberId: 0, delayedCount: 5),
  //     ServiceMemberDelay(memberName: 'DURAIVELU', memberId: 1, delayedCount: 16),
  //     ServiceMemberDelay(memberName: 'AVINESH', memberId: 2, delayedCount: 0),
  //     ServiceMemberDelay(memberName: 'RAMKI', memberId: 3, delayedCount: 1),
  //     ServiceMemberDelay(memberName: 'ARUN', memberId: 4, delayedCount: 0),
  //     ServiceMemberDelay(memberName: 'SUMESH', memberId: 5, delayedCount: 0),
  //     ServiceMemberDelay(memberName: 'MANI', memberId: 6, delayedCount: 10),
  //     ServiceMemberDelay(memberName: 'SELVAN', memberId: 7, delayedCount: 0),
  //   ];
  //
  //   allGraphsEmpty = false;
  //
  //   changeLoadingStatus(
  //       loadingStatus: LoadingStatus(loader: Loader.success));
  // }

}
