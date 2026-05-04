import 'dart:io';

import 'package:base/data/models/response/image_upload_response.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/check_list/check_list_response_model.dart';
import 'package:interior_design/data/model/response/close_observation/read_status_update_dto.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';
import 'package:interior_design/data/model/response/project_details/project_details_model.dart';
import 'package:interior_design/data/model/response/project_details/support_request_model.dart';
import 'package:interior_design/data/model/response/project_schedule/my_schedule_response_model.dart';
import 'package:interior_design/data/model/request/project_details/update_task_status_model.dart';
import 'package:interior_design/data/model/response/project_schedule/project_schedule_dto.dart';
import 'package:interior_design/data/model/response/project_schedule/schedule_project_details.dart';
import 'package:interior_design/data/model/response/project_schedule/schedule_summary.dart';
import 'package:interior_design/data/model/response/project_schedule/taskAgainstSupportListModel.dart';
import 'package:interior_design/data/model/response/project_schedule/task_attachment_response_model.dart';
import 'package:interior_design/data/model/response/project_schedule/task_status_drodown_model.dart';
import 'package:interior_design/data/model/response/project_schedule/task_view_or_fill_dto.dart';
import 'package:interior_design/data/remote/repository/add_observation/add_observation_repository_impl.dart';
import 'package:interior_design/data/remote/repository/check_list/check_list_repository_impl.dart';
import 'package:interior_design/data/remote/repository/close_support_request/close_support_request_repository_impl.dart';
import 'package:interior_design/data/remote/repository/project_details/project_details_repository_impl.dart';
import 'package:interior_design/data/remote/repository/project_schedule/project_schedule_impl.dart';
import 'package:interior_design/presentation/view/project_details/schedule_status_graphs_and_widgets/tasks_based_on_graph_screen.dart';
import 'package:interior_design/presentation/view/project_schedule/project_schedule_status_page.dart';

class ProjectScheduleUseCase{
  void fetchProjectScheduleData({required int projectId,
  required int userId,
    required Function(List<ResultObjectModel>?) onRequestSuccess,
    required Function(AppException) onRequestFailure, }){
  ProjectScheduleImpl().fetchProjectScheduleData(
      projectId: projectId,
      userId:userId,
      onRequestSuccess: onRequestSuccess,
      onRequestFailure: onRequestFailure);
  }
  void fetchProjectScheduleDataMyTask({required int projectId,
  required String status,
    required String scopeFlag,
    required int userId,
    required Function(MyTaskBasedDto?) onRequestSuccess,
    required Function(AppException) onRequestFailure,
  }){
  ProjectScheduleImpl().fetchProjectScheduleDataMyTask(
      projectId: projectId,
      status:status,
      userId:userId,
      scopeFlag: scopeFlag,
      onRequestSuccess: onRequestSuccess,
      onRequestFailure: onRequestFailure);
  }

  void fetchProjectScheduleDataMyReporteesFromHome({required int projectId,

    required String status,
    required int userId,
    required Function(MyTaskBasedDto?) onRequestSuccess,
    required Function(AppException) onRequestFailure,
    required String scopeFlag, required bool reporteesTasksFlag,  }){
  ProjectScheduleImpl().fetchProjectScheduleDataMyReporteesFromHome(
      projectId: projectId,
      status:status,
      userId:userId,
      reporteesTasksFlag:reporteesTasksFlag,
      scopeFlag:scopeFlag,
      onRequestSuccess: onRequestSuccess,
      onRequestFailure: onRequestFailure);
  }
  void fetchProjectScheduleSummaryData({required int projectId,
    required Function(List<SummaryModel>?) onRequestSuccess,
    required Function(AppException) onRequestFailure}){
  ProjectScheduleImpl().fetchProjectScheduleSummaryData(
      projectId: projectId,
      onRequestSuccess: onRequestSuccess,
      onRequestFailure: onRequestFailure);
  }

  void fetchMyScheduleData({required int projectId,
    required Function(List<MyScheduleModel>,ScheduleProjectDetails?) onRequestSuccess,
    required Function(AppException) onRequestFailure}){
    ProjectScheduleImpl().fetchMyScheduleData(
        projectId: projectId,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void fetchTaskStatusDropdown(
      {required Function(List<TaskStatusDropdownDtlModel>) onRequestSuccess,
      required Function(AppException) onRequestFailure}){
    ProjectScheduleImpl().fetchTaskStatusDropdown(
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);

  }

  void fetchProjectScheduleFillData(
      {required int taskId,
        required Function(List<ProjectTaskDtlModel>?) onRequestSuccess,
        required Function(AppException) onRequestFailure}){
    ProjectScheduleImpl().fetchProjectScheduleFillData(
        taskId: taskId,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);

  }
  void updateTaskStatus({
    required ProjectScheduleHdr  projectScheduleHdr ,
    required Function({required String transNo}) onRequestSuccess,
    required Function(AppException) onRequestFailure
  }){
    ProjectScheduleImpl().updateTaskStatus(
        projectScheduleHdr: projectScheduleHdr,
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

  Future<void> fetchAttachmentsDetail(
      {required List<UploadResponse> attachmentList,
        required Function(AttachmentResponseModel) onRequestSuccess,
        required Function(AppException) onRequestFailure}
      )async{
    AddObservationRepositoryImpl().fetchAttachmentsDetail(
        attachmentList: attachmentList,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  Future<void> getAttachedDocuments(
      {required int taskId,
        required Function(List<TaskAttachmentModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}
      )async{
    ProjectScheduleImpl().getAttachedDocuments(
        taskId: taskId,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void fetchReportingToScheduleData({required int projectId,
    required Function(List<MyScheduleModel>,ScheduleProjectDetails?) onRequestSuccess,
    required Function(AppException) onRequestFailure}){
    ProjectScheduleImpl().fetchReportingToScheduleData(
        projectId: projectId,
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
  void fetchTaskAgainstSupportList({
    required TaskAgainstSupportListModel taskAgainstSupportListModel,
    required Function(List<SupportRequestDtlModel>) onRequestSuccess,
    required Function(AppException) onRequestFailure
  }){
    ProjectScheduleImpl().fetchTaskAgainstSupportList(
        taskAgainstSupportListModel: taskAgainstSupportListModel,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void fetchProjectScheduleDataStatusBased({
    required int projectId,
    required ProjectStatus status,
    required List<int> criticalTaskIds,
    int? activityGroupId,
    String? type,
    required Function(List<ResultObjectModel> result) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  }) {
    ProjectScheduleImpl().fetchProjectScheduleDataStatusBased(
        projectId: projectId,
        status: status,
        criticalTaskIds: criticalTaskIds,
        activityGroupId: activityGroupId,
        type: type,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }
  void fetchProjectScheduleDataGraphBased(
      {required int projectId,
        required GraphList status,
        int? userId,
        required  Function(List<ResultObjectModel> result) onRequestSuccess,
        required  Function(AppException exception) onRequestFailure,
        String? label}) {

    ProjectScheduleImpl().fetchProjectScheduleDataGraphBased(
        projectId: projectId,
        userId: userId,
        status: status,
        label:label,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  Future<void> fetchGraphBasedSupportRequestList(
      {required String supportType,
        int? userId,
        required int projectId,
        required int start,
        required int limit,
        required Function(List<SupportRequestDtlModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure,
        required bool isCritical,
        required bool isAllSupport,
      }) async {
    ProjectScheduleImpl().fetchGraphBasedSupportRequestList(
        doPassAppType: true,
        start: start,
        supportType: supportType,
        isCritical:isCritical,
        limit: limit,
        projectId: projectId,
        isAllSupport: isAllSupport,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  Future<void> fetchProjectDetails(
      {required int projectId,
        required Function(List<ProjectDetailsModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}) async {
    ProjectDetailsRepositoryImpl().fetchProjectDetails(
        projectId: projectId,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void fetchCheckList(
      {required int refId,
        required int refTableId,
        required Function(List<CheckListModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}) {
    CheckListRepositoryImpl().fetchCheckList(
        id: refId,
        tableId: refTableId,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }


}