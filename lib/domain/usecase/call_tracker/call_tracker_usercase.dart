import 'dart:io';
import 'package:base/data/models/response/image_upload_response.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/request/call_tracker/status_update_model.dart';
import 'package:interior_design/data/model/response/call_tracker/call_tracker_model.dart';
import 'package:interior_design/data/model/response/call_tracker/service_based_support_dashboard_model.dart';
import 'package:interior_design/data/model/response/call_tracker/service_ticket_dashboard_model.dart';
import 'package:interior_design/data/model/response/call_tracker/task_model.dart';
import 'package:interior_design/data/model/response/call_tracker/tracking_details_dto.dart';
import 'package:interior_design/data/model/response/close_observation/close_observation_model.dart';
import 'package:interior_design/data/model/response/close_observation/read_status_update_dto.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/model/response/common/site_response_model.dart';
import 'package:interior_design/data/model/response/project_schedule/project_schedule_dashboard_model.dart';
import 'package:interior_design/data/remote/repository/add_observation/add_observation_repository_impl.dart';
import 'package:interior_design/data/remote/repository/call_tracker/add_service_request_impl.dart';
import 'package:interior_design/data/remote/repository/call_tracker/call_tracker_impl.dart';
import 'package:interior_design/data/remote/repository/close_support_request/close_support_request_repository_impl.dart';
import 'package:interior_design/presentation/provider/call_tracker/dashboard_filter_provider.dart';
import 'package:interior_design/presentation/provider/call_tracker/service_ticket_dashboard_provider.dart';
import 'package:intl/intl.dart';

class CallTrackerUseCase{
  void fetchCallTrackerInfo(
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
        required String dateFrom,
        required String dateTo,
        required String type,
        required Function(List<CallTicketModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}){
    CallTrackerImpl().fetchCallTrackerInfo(
        start: start,
        limit: limit,
        sitenames: sitenames,
        ticketNo: ticketNo,
        refTableDataId: refTableDataId,
        taskId: taskId,
        engineers: engineers,
        statuses: statuses,
        cities: cities,
        clientList: clientList,
        dateFrom: dateFrom,
        dateTo: dateTo,
        priorityList: priorityList,
        sitesList: sitesList,
        type: type,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void fetchCallTrackerInfoFromGraphDashboard(
      {required int start,
        required int limit,
        required String ticketNo,
        required int userId,
        required int refTableDataId,
        required int serviceClientId,
        String? type,
        required String status,
        required String flag,
        required TaskDashBoardSummaryFilterModel taskDashBoardSummaryFilter,
        required int? engineerId,
        required int? coordinatorId,
        required int? reporterId,
        required Function(List<CallTicketModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure, }){
    CallTrackerImpl().fetchCallTrackerInfoFromGraphDashboard(
        start: start,
        limit: limit,
        ticketNo: ticketNo,
        userId: userId,
        refTableDataId: refTableDataId,
        serviceClientId: serviceClientId,
        type: type??'',
        status: status,
        flag:flag,
        taskDashBoardSummaryFilter: taskDashBoardSummaryFilter,
        coordinatorId: coordinatorId,
        engineerId: engineerId,
        reporterId: reporterId,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }
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
        required Function(AppException) onRequestFailure, }){
    CallTrackerImpl().fetchCallTrackerInfoFromDashboardGraph(
        type: type,
        subType: subType,
        cityId: cityId,
        clientIds: clientIds,
        dateFrom: dateFrom,
        dateTo: dateTo,
        priorityId: priorityId,
        serviceClientId: serviceClientId,
        ticketNo: ticketNo,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void fetchTasksByClientAndLocation(
      {required int clientId,
        required  String siteName,
        required Function(List<TaskModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure, }){
    CallTrackerImpl().fetchTasksByClientAndLocation(
        clientId: clientId,
        siteName: siteName,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);

  }

  void fetchTasksFromDashboard(
    {required int clientId,
      required int serviceUserId,
      required String type,
      required String subType,
      required Function(List<TaskModel>) onRequestSuccess,
      required Function(AppException) onRequestFailure} ){
    CallTrackerImpl().fetchTasksFromDashboard(
      clientId: clientId,
        serviceUserId: serviceUserId,
        type: type,
        subType: subType,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);

  }

  void fetchStatusTypes(
      {required Function(List<StatusModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}){
    CallTrackerImpl().fetchStatusTypes(
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void fetchPriority(
      {required Function(List<CommonMasterModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}){
    CallTrackerImpl().fetchPriority(
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void fetchDepartmentFilter(
      {required Function(List<EngineerModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}){
    CallTrackerImpl().fetchDepartmentFilter(
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void updateStatus(
      {required TicketStatusModel taskModel,
        required Function(String) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}){
    CallTrackerImpl().updateStatus(
        taskModel: taskModel,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void fetchServiceBasedSupportDashboardData(
      {required int dataId,
        required Function(List<TicketSummaryModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}){
    CallTrackerImpl().fetchServiceBasedSupportDashboardData(
        dataId: dataId,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void updateNotificationStatus(
      {
        required int notificationId,
        required Function(int) onRequestSuccess,
        required Function(AppException) onRequestFailure}
      ){
    CloseSupportRequestRepositoryImpl().updateNotificationStatus(
        notificationId: notificationId,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);


  }

  //For uploading image
  Future<void> uploadImageFile(
      {required List<File> file,
        required String attachmentSerialNo,
        required Function(double progress) uploadProgress,
        required Function(List<UploadResponse> uploadResponse) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}){
    return AddObservationRepositoryImpl().uploadImageFile(
        images: file,
        attachmentSerialNo: attachmentSerialNo,
        onRequestSuccess: onRequestSuccess,
        uploadProgress: uploadProgress,
        onRequestFailure: onRequestFailure);
  }

  void addCommentServiceTask(
      {required int ticketId,
        required String comment,
        required Function() onRequestSuccess,
        required Function(AppException exception) onRequestFailure}){
    CallTrackerImpl().addCommentServiceTask(
        ticketId: ticketId,
        comment: comment,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void fetchGetTicketTracking(
      {required int ticketId,
        required Function(List<TicketDetailResultModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}){
   CallTrackerImpl().fetchGetTicketTracking(
       ticketId: ticketId,
       onRequestSuccess: onRequestSuccess,
       onRequestFailure: onRequestFailure);
  }

  void fetchServiceTicketDashboard(
      {required TaskDashBoardSummaryFilterModel taskDashBoardFilterModel,
        required Function(List<ServiceTicketDashboardData>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}){
    CallTrackerImpl().fetchServiceTicketDashboard(
      taskDashBoardFilterModel: taskDashBoardFilterModel,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void fetchClientLists(
      {required Function(List<CommonMasterModel>) onRequestSuccess,
      required Function(AppException exception) onRequestFailure}) {
    AddServiceRequestImpl().fetchClientLists(
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void fetchCityLists(
      {required Function(List<CommonMasterModel>) onRequestSuccess,
      required Function(AppException exception) onRequestFailure}) {
    AddServiceRequestImpl().fetchCityLists(
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void fetchSiteLists(
      {required List<CommonMasterModel> clientList,
      required Function(List<SiteModel>) onRequestSuccess,
      required Function(AppException exception) onRequestFailure}) {
    AddServiceRequestImpl().fetchSiteLists(
        clientList: clientList,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  Future<void> cancelServiceTicket({
    required int ticketId,
    required String lastModDate,
    required String notifyClientYN,
    required Function() onRequestSuccess,
    required Function(AppException) onRequestFailure}) async{
    CallTrackerImpl().cancelServiceTicket(
        ticketId: ticketId,
        lastModDate: lastModDate,
        notifyClientYN: notifyClientYN,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  Future<void> updateTaskClientDependency({
    required int taskId,
    required String clientDependencyYN,
    required String lastModDate,
    required Function() onRequestSuccess,
    required Function(AppException) onRequestFailure,
  }) async {
    return CallTrackerImpl().updateTaskClientDependency(
      taskId: taskId,
      clientDependencyYN: clientDependencyYN,
      lastModDate: lastModDate,
      onRequestSuccess: onRequestSuccess,
      onRequestFailure: onRequestFailure,
    );
  }

  Future<void> updateTaskClosureDate({
    required int taskId,
    required String targetClosureDate,
    required String lastModDate,
    required Function() onRequestSuccess,
    required Function(AppException) onRequestFailure,
  }) async {
    return CallTrackerImpl().updateTaskClosureDate(
      taskId: taskId,
      targetClosureDate: targetClosureDate,
      lastModDate: lastModDate,
      onRequestSuccess: onRequestSuccess,
      onRequestFailure: onRequestFailure,
    );
  }
}