import 'package:base/core/constants.dart';
import 'package:base/data/models/request/json_builder.dart';
import 'package:base/data/models/response/image_upload_response.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/check_list/check_list_response_model.dart';
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
import 'package:interior_design/domain/repository/project_schedule/project_schedule_repo.dart';
import 'package:interior_design/presentation/view/project_details/schedule_status_graphs_and_widgets/tasks_based_on_graph_screen.dart';
import 'package:interior_design/presentation/view/project_schedule/project_schedule_status_page.dart';

class ProjectScheduleImpl extends ProjectScheduleRepo {
  factory ProjectScheduleImpl() => _instance;
  static final ProjectScheduleImpl _instance = ProjectScheduleImpl._internal();
  ProjectScheduleImpl._internal();
  @override
  Future<void> fetchProjectScheduleData({
    required int projectId,
    required int userId,
    required Function(
      List<ResultObjectModel>?,
    ) onRequestSuccess,
    required Function(AppException) onRequestFailure,
  }) async {
    const String urlExtension = "Schedule/loadeschedule";
    final Map<String, dynamic> rawData = {};
    rawData["projectId"] = projectId;
    if (userId != 0) {
      rawData["UserId"] = userId;
    }

    performGetRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          ProjectStatusHdrModel response =
              ProjectStatusHdrModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.resultObject);
          } else {
            onRequestFailure(AppException(response.statusMessage ?? ""));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  Future<void> fetchProjectScheduleDataMyTask({
    required int projectId,
    required String status,
    required String scopeFlag,
    required int userId,
    required Function(MyTaskBasedDto?) onRequestSuccess,
    required Function(AppException) onRequestFailure,
  }) async {
    String urlExtension = "";
    if (scopeFlag == "TEAM") {
      urlExtension = "Schedule/loadMyAndReporteesSchedule";
    } else {
      urlExtension = "Schedule/loadmyschedule";
    }


    final Map<String, dynamic> rawData = {};
    rawData["projectId"] = projectId;
    if (status != "None") {
      rawData["status"] = status;
    }
    if (userId != 0) {
      rawData["UserId"] = userId;
    }

    performGetRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          ProjectStatusHdrModelMyTaskBased response =
              ProjectStatusHdrModelMyTaskBased.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.resultObject);
          } else {
            onRequestFailure(AppException(response.statusMessage ?? ""));
          }
        },
        onRequestFailure: onRequestFailure);
  }


  @override
  Future<void> fetchProjectScheduleDataMyReporteesFromHome({
    required int projectId,
    required String status,
    required int userId,
    required Function(MyTaskBasedDto?) onRequestSuccess,
    required Function(AppException) onRequestFailure,
    required String scopeFlag,
    required bool reporteesTasksFlag,
  }) async {

    String urlExtension = "";
    if(reporteesTasksFlag){
      if (scopeFlag == "TEAM") {
        urlExtension = "Schedule/loadMyAndReporteesSchedule";
      } else {
        urlExtension = "Schedule/loadmyschedule";
      }
    }else{
      urlExtension = "Schedule/loadMyReporteesSchedule";
    }


    final Map<String, dynamic> rawData = {};
    rawData["projectId"] = projectId;
    if(reporteesTasksFlag){

      if (status != "None") {
        rawData["status"] = status;
      }
      if (userId != 0) {
        rawData["UserId"] = userId;
      }
    }else{
      rawData["status="] = "";
      rawData["userid"] = 0;

    }
    http://192.168.10.50:5002/api/Schedule/loadMyReporteesSchedule?projectId=9&status=&userid=0
    http://192.168.10.50:5002/api/Schedule/loadMyReporteesSchedule?projectId=9&status&userid=0
    performGetRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        doPassAppType: false,
        onRequestSuccess: (result) {
          ProjectStatusHdrModelMyTaskBased response =
          ProjectStatusHdrModelMyTaskBased.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.resultObject);
          } else {
            onRequestFailure(AppException(response.statusMessage ?? ""));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  void fetchProjectScheduleDataStatusBased({
    required int projectId,
    required ProjectStatus status,
    required List<int> criticalTaskIds,
    int? activityGroupId,
    String? type,
    required Function(List<ResultObjectModel> result) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  }) {
    const String urlExtension = "Schedule/loadeschedulebystatus";
    final Map<String, dynamic> rawData = {
      "projectId": projectId,
      "status": status.name,
      "type": type ?? "Project",
      "criticalTaskIds": criticalTaskIds,
    };

    if (activityGroupId != null && activityGroupId != 0) {
      rawData["activityGroupId"] = activityGroupId;
    }

    performGetRequestWithListSupport(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          ProjectStatusHdrModel response =
              ProjectStatusHdrModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.resultObject);
          } else {
            onRequestFailure(AppException(response.statusMessage ?? ""));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  void fetchProjectScheduleDataGraphBased({
    required int projectId,
    required GraphList status,
    int? userId,
    String? label,
    required Function(List<ResultObjectModel> result) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  }) {
    const String urlExtension = "Schedule/dashboardDrilldownDetails";
    Map<String, dynamic> rawData = {};

    if (status == GraphList.DaysDelayGraph) {
      rawData = {
        "projectId": projectId,
        "status": label?.toUpperCase(),
        "Flag": "DELAYED_TASKS_DAYS",
      };
    }
    if (status == GraphList.UserDelayGraph) {
      rawData = {
        "projectId": projectId,
        "status": "DELAYED",
        "Flag": "DELAYED_TASKS_USR",
        "userId": userId ?? "",
      };
    }
    if (status == GraphList.UserCompleteGraph) {
      rawData = {
        "projectId": projectId,
        "status": "COMPLETED",
        "Flag": "COMPLETED_TASKS_USR",
        "userId": userId ?? "",
      };
    }
    if (status == GraphList.ProgressGraph) {
      rawData = {
        "projectId": projectId,
        "status": label?.toUpperCase(),
        "Flag": "PROJECT_PROGRESS",
      };
    }

    performGetRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          ProjectStatusHdrModel response =
              ProjectStatusHdrModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.resultObject);
          } else {
            onRequestFailure(AppException(response.statusMessage ?? ""));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  Future<void> fetchProjectScheduleSummaryData(
      {required int projectId,
      required Function(List<SummaryModel>?) onRequestSuccess,
      required Function(AppException) onRequestFailure}) async {
    const String urlExtension = "Schedule/loadCalculatedScheduleSummary";
    final Map<String, dynamic> rawData = {};
    rawData["projectId"] = projectId;
    rawData["type"] = "projectId";

    performGetRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          ProjectScheduleSummaryModel response =
              ProjectScheduleSummaryModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.resultObject);
          } else {
            onRequestFailure(AppException(response.statusMessage ?? ""));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  Future<void> fetchMyScheduleData(
      {required int projectId,
      required Function(List<MyScheduleModel>, ScheduleProjectDetails?)
          onRequestSuccess,
      required Function(AppException) onRequestFailure}) async {
    const String urlExtension = "Schedule/loadescheduleforuser";
    final Map<String, dynamic> rawData = {};
    rawData["projectId"] = projectId;

    performGetRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          MyScheduleResponseModel response =
              MyScheduleResponseModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(
                response.myScheduleList, response.scheduleProjectDetails);
          } else {
            onRequestFailure(AppException(response.statusMessage ?? ""));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  Future<void> fetchProjectScheduleFillData(
      {required int taskId,
      required Function(List<ProjectTaskDtlModel>?) onRequestSuccess,
      required Function(AppException) onRequestFailure}) async {
    const String urlExtension = "Schedule/getschedulelist";
    final Map<String, dynamic> rawData = {};
    rawData["taskId"] = taskId;
    performGetRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          ProjectTaskListModel response = ProjectTaskListModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.projectTaskList);
          } else {
            onRequestFailure(AppException(response.statusMessage ?? ""));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  Future<void> fetchTaskStatusDropdown(
      {required Function(List<TaskStatusDropdownDtlModel>) onRequestSuccess,
      required Function(AppException) onRequestFailure}) async {
    const String urlExtension = "Lookup/GetCommonMasterByType";
    final Map<String, dynamic> rawData = {};
    rawData["type"] = 'SCH_TASK_STATUS';
    performGetRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          TaskStatusDropdownModel response =
              TaskStatusDropdownModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.taskStatusDropdownList);
          } else {
            onRequestFailure(AppException(response.statusMessage ?? ""));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  Future<void> fetchTaskTypeDropdown(
      {required Function(List<TaskTypeDropdownDtlModel>) onRequestSuccess,
      required Function(AppException p1) onRequestFailure}) async {
    const String urlExtension = "Lookup/GetCommonMasterByType";
    final Map<String, dynamic> rawData = {};
    rawData["type"] = 'SUPPORT_TYPE';

    performGetRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          TaskTypeDropdownModel response =
              TaskTypeDropdownModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.taskTypeDropdownList);
          } else {
            onRequestFailure(AppException(response.statusMessage ?? ""));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  //Save
  @override
  Future<void> updateTaskStatus({
    required ProjectScheduleHdr projectScheduleHdr,
    required Function({required String transNo}) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  }) async {
    const String urlExtension = "Schedule/update";
    final Map<String, dynamic> rawData = {};

    rawData['projectScheduleHdr'] = [
      {
        'id': projectScheduleHdr.id,
        'statusid': projectScheduleHdr.statusid,
        'completionperc': projectScheduleHdr.completionperc,
        'taskuserid': projectScheduleHdr.taskuserid,
        'plannedstartdate': projectScheduleHdr.plannedstartdate,
        'plannedenddate': projectScheduleHdr.plannedenddate,
        'lastmoddate': projectScheduleHdr.lastmoddate,

        'Checklistmappingdetail': projectScheduleHdr.checkListData.isEmpty
            ? []
            : _buildChecklistMapping(projectScheduleHdr.checkListData),
        'docAttachments': projectScheduleHdr.imagesDtl.isEmpty
            ? []
            : [
                {
                  "id": 0,
                  "seriesno": projectScheduleHdr.seriesNo,
                  "attachmentDtls":
                      _buildAttachmentDtls(projectScheduleHdr.imagesDtl),
                }
              ]
      },
    ];

    performRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (response) {
          try {
            final resultObject = response['resultObject'];
            final transNo = resultObject.first['transactionNo'];
            onRequestSuccess(transNo: transNo);
          } catch (e) {
            onRequestFailure(AppException(
                'Add Support Request submit failed: ${e.toString()}'));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  List<Map<String, dynamic>> _buildAttachmentDtls(
      List<UploadResponse> imagesDtl) {
    return imagesDtl
        .map((img) => {
              "filename": img.filename ?? "",
              "physicalfilename": img.physicalfilename ?? "",
            })
        .toList();
  }

  List<Map<String, dynamic>> _buildChecklistMapping(
      List<CheckListModel> list) {
    return list.map((e) {
      return {
        "id":  e.logId,
        "checklistid": e.checklistId ?? 0,
        "name": e.name ?? "",
        "isactive": e.isActive ? "Y" : "N",
        "ischecked": e.isChecked ? "Y" : "N", //  IMPORTANT
        "reftabledataid": e.refTableDataId ?? 0,
        "reftableid": e.refTableId ?? 0,
        "mandatoryyn": e.isMandatory ? "Y" : "N",
      };
    }).toList();
  }

  @override
  Future<void> getAttachedDocuments(
      {required int taskId,
      required Function(List<TaskAttachmentModel>) onRequestSuccess,
      required Function(AppException exception) onRequestFailure}) async {
    const String urlExtension = "Schedule/getAttachedDocuments";
    final Map<String, dynamic> rawData = {};
    rawData["taskId"] = taskId;

    performGetRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          TaskAttachmentResponseModel taskAttachmentResponseModel =
              TaskAttachmentResponseModel.fromJson(result);
          if (taskAttachmentResponseModel.statusCode == 1) {
            onRequestSuccess(
                taskAttachmentResponseModel.taskAttachmentList );
          } else {
            onRequestFailure(
                AppException(taskAttachmentResponseModel.statusMessage ?? ""));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  Future<void> fetchReportingToScheduleData(
      {required int projectId,
      required Function(List<MyScheduleModel>, ScheduleProjectDetails?)
          onRequestSuccess,
      required Function(AppException exception) onRequestFailure}) async {
    const String urlExtension = "Schedule/LoadSchedulerTaskListByLoginUser";
    final Map<String, dynamic> rawData = {};
    rawData["projectId"] = projectId;

    performGetRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          MyScheduleResponseModel response =
              MyScheduleResponseModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(
                response.myScheduleList, response.scheduleProjectDetails);
          } else {
            onRequestFailure(AppException(response.statusMessage ?? ""));
          }
        },
        onRequestFailure: onRequestFailure);
  }



  @override
  void fetchTaskAgainstSupportList(
      {required TaskAgainstSupportListModel taskAgainstSupportListModel,
      required Function(List<SupportRequestDtlModel>) onRequestSuccess,
      required Function(AppException) onRequestFailure}) {
    const String urlExtension = "SupportRequest/GetSupportReqListView";
    Map<String, dynamic> rawData = {};
    final builder = DataStructureBuilder()
        .addColumn("Start", taskAgainstSupportListModel.start)
        .addColumn("Limit", taskAgainstSupportListModel.limit)
        .addColumn("ProjectId", taskAgainstSupportListModel.projectId)
        .addColumn("Status", taskAgainstSupportListModel.status);

    if (!taskAgainstSupportListModel.isShowAllTaskSupport) {
      builder
          .addColumn('DateFrom', taskAgainstSupportListModel.dateFrom)
          .addColumn('DateTo', taskAgainstSupportListModel.dateTo);
    }
    if (taskAgainstSupportListModel.transNo != "") {
      builder.addColumn('TransNo', taskAgainstSupportListModel.transNo);
    }
    if (taskAgainstSupportListModel.isFromAdditionalMaterial) {
      builder.addColumn('Id', taskAgainstSupportListModel.materialItemId);
      builder.addColumn('projectId', taskAgainstSupportListModel.projectId);
      rawData = {
        "action": taskAgainstSupportListModel.action,
        ...builder.build(),
      };
    } else {
      builder.addColumn("Id", taskAgainstSupportListModel.taskId);
      rawData = builder.build();
    }

    performRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          SupportRequestModel response = SupportRequestModel.fromJson(result);
          if (response.supportRequestList.isNotEmpty) {
            onRequestSuccess(response.supportRequestList);
          } else {
            onRequestSuccess(response.supportRequestList);
          }
        },
        onRequestFailure: onRequestFailure);
  }

  Future<void> fetchGraphBasedSupportRequestList(
      {required String supportType,
      bool doPassAppType = false,
      required int projectId,
      required int start,
      required int limit,
      required Function(List<SupportRequestDtlModel>) onRequestSuccess,
      required Function(AppException) onRequestFailure,
      required bool isCritical,
      required bool isAllSupport}) async {
    final builder = DataStructureBuilder()
        .addColumn("Flag", "SUP_REQ_LIST")
        .addColumn("Start", start)
        .addColumn("Limit", limit);

    builder.addColumn("SupportType", supportType);

    builder.addColumn("ProjectId", projectId);

    final rawData = builder.build();
    const String urlExtension = "project/GetDashboardChartsDetails";

    performRequest(
        doPassAppType: false,
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          SupportRequestModel response = SupportRequestModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.supportRequestList);
          } else {
            onRequestFailure(AppException(response.statusMessage ?? ""));
          }
        },
        onRequestFailure: (e) {
          onRequestFailure(e);
        });
  }
}
