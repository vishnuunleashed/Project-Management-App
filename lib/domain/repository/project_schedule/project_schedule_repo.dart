import 'package:base/data/repository/remote/base_repository.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/close_observation/read_status_update_dto.dart';
import 'package:interior_design/data/model/response/project_details/support_request_model.dart';
import 'package:interior_design/data/model/response/project_schedule/my_schedule_response_model.dart';
import 'package:interior_design/data/model/request/project_details/update_task_status_model.dart';
import 'package:interior_design/data/model/response/project_schedule/project_schedule_dto.dart';
import 'package:interior_design/data/model/response/project_schedule/schedule_project_details.dart';
import 'package:interior_design/data/model/response/project_schedule/schedule_summary.dart';
import 'package:interior_design/data/model/response/project_schedule/taskAgainstSupportListModel.dart';
import 'package:interior_design/data/model/response/project_schedule/task_attachment_response_model.dart';
import 'package:interior_design/data/model/response/project_schedule/task_status_drodown_model.dart';
import 'package:interior_design/data/model/response/project_schedule/task_type_dropdown_model.dart';
import 'package:interior_design/data/model/response/project_schedule/task_view_or_fill_dto.dart';
import 'package:interior_design/presentation/view/project_details/schedule_status_graphs_and_widgets/tasks_based_on_graph_screen.dart';
import 'package:interior_design/presentation/view/project_schedule/project_schedule_status_page.dart';

abstract class ProjectScheduleRepo extends BaseRepository {
  Future<void> fetchProjectScheduleData({required int projectId,
    required int userId,
    required Function(List<ResultObjectModel>?) onRequestSuccess,
    required Function(AppException) onRequestFailure});

  Future<void> fetchProjectScheduleSummaryData({required int projectId,
    required Function(List<SummaryModel>?) onRequestSuccess,
    required Function(AppException) onRequestFailure});
  Future<void> fetchProjectScheduleDataMyTask(
      {required int projectId,
        required String status,
        required int userId,
        required String scopeFlag,
        required Function(MyTaskBasedDto?) onRequestSuccess,
        required Function(AppException) onRequestFailure});

  Future<void> fetchMyScheduleData({required int projectId,
    required Function(List<
        MyScheduleModel>, ScheduleProjectDetails?) onRequestSuccess,
    required Function(AppException) onRequestFailure});

  Future<void> fetchTaskStatusDropdown(
      {required Function(List<TaskStatusDropdownDtlModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure});

  Future<void> fetchTaskTypeDropdown(
      {required Function(List<TaskTypeDropdownDtlModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure});

  Future<void> fetchProjectScheduleFillData({required int taskId,
    required Function(List<ProjectTaskDtlModel>?) onRequestSuccess,
    required Function(AppException) onRequestFailure});

  Future<void> updateTaskStatus({
    required ProjectScheduleHdr projectScheduleHdr,
    required Function({required String transNo}) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  });

  Future<void> getAttachedDocuments({
    required int taskId,
    required Function(List<TaskAttachmentModel>) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  });

  Future<void> fetchReportingToScheduleData({
    required int projectId,
    required Function(List<
        MyScheduleModel>, ScheduleProjectDetails?) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  });


  void fetchTaskAgainstSupportList({
    required TaskAgainstSupportListModel taskAgainstSupportListModel,
    required Function(List<SupportRequestDtlModel>) onRequestSuccess,
    required Function(AppException) onRequestFailure
  });

  void fetchProjectScheduleDataStatusBased({
    required int projectId,
    required ProjectStatus status,
    required List<int> criticalTaskIds,
    int? activityGroupId,
    String? type,
    required Function(List<ResultObjectModel> result) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  });

  void fetchProjectScheduleDataGraphBased(
      {required int projectId,
        required GraphList status,
        int? userId,
        String? label,
        required Function(List<ResultObjectModel> result) onRequestSuccess,
        required Function(AppException exception) onRequestFailure});

  Future<void> fetchProjectScheduleDataMyReporteesFromHome({
    required int projectId,
    required String status,
    required int userId,
    required String scopeFlag,
    required bool reporteesTasksFlag,
    required Function(MyTaskBasedDto?) onRequestSuccess,
    required Function(AppException) onRequestFailure,
  });



}