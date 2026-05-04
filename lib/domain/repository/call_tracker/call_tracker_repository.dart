import 'package:base/data/repository/remote/base_repository.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/request/call_tracker/status_update_model.dart';
import 'package:interior_design/data/model/response/call_tracker/call_tracker_model.dart';
import 'package:interior_design/data/model/response/call_tracker/service_based_support_dashboard_model.dart';
import 'package:interior_design/data/model/response/call_tracker/task_model.dart';
import 'package:interior_design/data/model/response/call_tracker/tracking_details_dto.dart';
import 'package:interior_design/data/model/response/call_tracker/service_ticket_dashboard_model.dart';
import 'package:interior_design/data/model/response/close_observation/close_observation_model.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/model/response/common/site_response_model.dart';
import 'package:interior_design/data/model/response/project_schedule/project_schedule_dashboard_model.dart';
import 'package:interior_design/presentation/provider/call_tracker/dashboard_filter_provider.dart';
import 'package:interior_design/presentation/provider/call_tracker/service_ticket_dashboard_provider.dart';

 abstract class CallTrackerRepository extends BaseRepository{
  Future<void> fetchCallTrackerInfo(
      {required int start,
      required int limit,
      required String ticketNo,
      required String sitenames,
      required int refTableDataId,
      required int taskId,
      required List<StatusModel> statuses,
      required List<CommonMasterModel> clientList,
      required List<CommonMasterModel> priorityList,
      required List<CommonMasterModel> cities,
      required List<EngineerModel> engineers,
      required List<SiteModel> sitesList,
      required String type,
      required String dateFrom,
      required String dateTo,
      required Function(List<CallTicketModel>) onRequestSuccess,
      required Function(AppException) onRequestFailure});

  void fetchCallTrackerInfoFromGraphDashboard(
      {required int start,
        required int limit,
        required String ticketNo,
        required int userId,
        required int refTableDataId,
        required int serviceClientId,
        required String type,
        required String status,
        required String flag,
        required TaskDashBoardSummaryFilterModel taskDashBoardSummaryFilter,
        required int? engineerId,
        required int? coordinatorId,
        required int? reporterId,
        required Function(List<CallTicketModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure, });

  void fetchCallTrackerInfoFromDashboardGraph(
      {String? type,
        String? subType,
        String? ticketNo,
        String? dateFrom,
        String? dateTo,
        int? cityId,
        int? priorityId,
        int? serviceClientId,
        List<int>? clientIds,
        required Function(List<CallTicketModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure, });

  void fetchTasksByClientAndLocation(
      {required int clientId,
        required String siteName,
        required Function(List<TaskModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure, });

  void fetchTasksFromDashboard(
      {required int clientId,
        required int serviceUserId,
        required String type,
        required String subType,
        required Function(List<TaskModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure, });

  void fetchStatusTypes(
      {required Function(List<StatusModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure});
  void fetchDepartmentFilter(
      {required Function(List<EngineerModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure});

  void updateStatus(
      {
        required TicketStatusModel taskModel,
        required Function(String) onRequestSuccess,
        required Function(AppException exception) onRequestFailure});

  void fetchServiceBasedSupportDashboardData(
      {
        required int dataId,
        required Function(List<TicketSummaryModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure});

  void fetchGetTicketTracking(
      {required int ticketId,
        required Function(List<TicketDetailResultModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure});

  void addCommentServiceTask(
      {required int ticketId,
        required String comment,
        required Function() onRequestSuccess,
        required Function(AppException exception) onRequestFailure});

  void fetchServiceTicketDashboard(
      {required TaskDashBoardSummaryFilterModel taskDashBoardFilterModel,
        required Function(List<ServiceTicketDashboardData>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure});

  Future<void> cancelServiceTicket({
    required int ticketId,
    required String lastModDate,
    required String notifyClientYN,
    required Function() onRequestSuccess,
    required Function(AppException) onRequestFailure});

  Future<void> updateTaskClientDependency({
    required int taskId,
    required String clientDependencyYN,
    required String lastModDate,
    required Function() onRequestSuccess,
    required Function(AppException) onRequestFailure,
  });

  Future<void> updateTaskClosureDate({
    required int taskId,
    required String targetClosureDate,
    required String lastModDate,
    required Function() onRequestSuccess,
    required Function(AppException) onRequestFailure,
  });

  Future<void> fetchPriority(
      {required Function(List<CommonMasterModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure});
 }