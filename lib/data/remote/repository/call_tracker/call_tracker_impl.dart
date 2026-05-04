import 'package:base/data/models/request/json_builder.dart';
import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/request/call_tracker/status_update_model.dart';
import 'package:interior_design/data/model/response/call_tracker/call_tracker_model.dart';
import 'package:interior_design/data/model/response/call_tracker/service_based_support_dashboard_model.dart';
import 'package:interior_design/data/model/response/call_tracker/service_ticket_dashboard_model.dart';
import 'package:interior_design/data/model/response/call_tracker/task_model.dart';
import 'package:interior_design/data/model/response/call_tracker/tracking_details_dto.dart';
import 'package:interior_design/data/model/response/close_observation/close_observation_model.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/model/response/common/site_response_model.dart';
import 'package:interior_design/domain/repository/call_tracker/call_tracker_repository.dart';
import 'package:interior_design/presentation/provider/call_tracker/dashboard_filter_provider.dart';

class CallTrackerImpl extends CallTrackerRepository {
  factory CallTrackerImpl() => _instance;
  static final CallTrackerImpl _instance = CallTrackerImpl._internal();
  CallTrackerImpl._internal();

  @override
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
        required String dateFrom,
        required String dateTo,
        required String type,
        required Function(List<CallTicketModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}) async {
    const String urlExtension = "ServiceCallTracker/list";
    final Map<String, dynamic> rawData = {};
    rawData["start"] = start;
    rawData["size"] = limit;
    if (ticketNo != "") {
      rawData["ticketNo"] = ticketNo;
    }
    if (refTableDataId != 0 && taskId == 0) {
      rawData["ticketId"] = refTableDataId;
    }
    if (taskId != 0){
      rawData["taskId"] = taskId;
    }
    if (engineers.isNotEmpty) {
      rawData["engineerIds"] = engineers.map((e) => e.id).join(",");
    }
    if (statuses.isNotEmpty) {
      rawData["statusIds"] = statuses.map((s) => s.id).join(",");
    }
    if (clientList.isNotEmpty) {
      rawData["clientIds"] = clientList.map((c) => c.id).join(",");
    }
    if (priorityList.isNotEmpty) {
      rawData["priorityIds"] = priorityList.map((c) => c.id).join(",");
    }
    if (cities.isNotEmpty) {
      rawData["cityIds"] = cities.map((c) => c.id).join(",");
    }
    if (sitesList.isNotEmpty){
      rawData['sitenames'] = sitesList.map((c) => c.siteName).join(",");
    }
    if (sitenames.isNotEmpty){
      rawData['sitenames'] = sitenames;
    }
    if (type != "") {
      rawData["type"] = type;
    }
    if (dateFrom != "") {
      rawData["dateFrom"] = dateFrom;
    }
    if (dateTo != "") {
      rawData["dateTo"] = dateTo;
    }
    performGetRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          CallTrackerTicketsHdrModel response =
          CallTrackerTicketsHdrModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.tickets);
          } else {
            onRequestFailure(AppException(response.statusMessage ?? ""));
          }
        },
        onRequestFailure: onRequestFailure);
  }
  @override
  Future<void> fetchCallTrackerInfoFromGraphDashboard(
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
      required Function(AppException) onRequestFailure, }) async {
    String urlExtension = "ServiceCallTracker/GetDashboardDataList";

    final builder = DataStructureBuilder()
        .addColumn("Flag", flag)
        .addColumn("Status", status)
        .addColumn("Start", start)
        .addColumn("Limit", limit);

    if(flag == "SERVICE_CLIENTWISE_DELAY"){
      builder.addColumn("ServiceClientId", serviceClientId);
    }
    if(flag == "SERVICE_USERWISE_DELAY"){
      builder.addColumn("UserId", userId);
    }

    if (taskDashBoardSummaryFilter.ticketNo != null &&
        taskDashBoardSummaryFilter.ticketNo!.isNotEmpty) {

      builder.addColumn("TicketNo", "%${taskDashBoardSummaryFilter.ticketNo}%");
    }

    if (taskDashBoardSummaryFilter.dateFrom != null) {
      builder.addColumn("DateFrom", taskDashBoardSummaryFilter.dateFrom);
    }

    if (taskDashBoardSummaryFilter.dateTo != null) {
      builder.addColumn("DateTo", taskDashBoardSummaryFilter.dateTo);
    }

    if (taskDashBoardSummaryFilter.cityId != null) {
      builder.addColumn("CityId", taskDashBoardSummaryFilter.cityId);
    }

    if (taskDashBoardSummaryFilter.priorityId != null) {
      builder.addColumn("PriorityId", taskDashBoardSummaryFilter.priorityId);
    }

    if (taskDashBoardSummaryFilter.selDashFilterClientList.isNotEmpty) {
      builder.addColumn(
        "ClientIdString",
        taskDashBoardSummaryFilter.selDashFilterClientList
            .map((e) => e.id)
            .join(','),
      );
    }

    // 👇 ADD HERE

    if (engineerId != null) {
      builder.addColumn("EngineerIdSrch", engineerId);
    }

    if (coordinatorId != null) {
      builder.addColumn("CoordinatorIdSrch", coordinatorId);
    }

    if (reporterId != null) {
      builder.addColumn("ReportingManagerIdSrch", reporterId);
    }



    final rawData = builder.build();
    performRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          CallTrackerTicketsHdrModel response =
              CallTrackerTicketsHdrModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.tickets);
          } else {
            onRequestFailure(AppException(response.statusMessage ?? ""));
          }
        },
        onRequestFailure: onRequestFailure);
  }


  @override
  Future<void> fetchCallTrackerInfoFromDashboardGraph(
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
        required Function(AppException) onRequestFailure, }) async {
    String urlExtension = "ServiceCallTracker/getTicketDetailsByFilters?";
    final Map<String, dynamic> rawData = {};

    if (type != null) {
      rawData["type"] = type;
    }

    if (subType != null) {
      rawData["subType"] = subType;
    }

    if (ticketNo != null && ticketNo.isNotEmpty) {
      rawData["ticketNo"] = ticketNo;
    }

    if (dateFrom != null && dateFrom.isNotEmpty) {
      rawData["dateFrom"] = dateFrom;
    }

    if (dateTo != null && dateTo.isNotEmpty) {
      rawData["dateTo"] = dateTo;
    }

    if (cityId != null) {
      rawData["cityId"] = cityId;
    }

    if (priorityId != null) {
      rawData["priorityId"] = priorityId;
    }

    if (serviceClientId != null) {
      rawData["serviceClientId"] = serviceClientId;
    }

    if (clientIds != null && clientIds.isNotEmpty) {
      rawData["clientIds"] = clientIds.join(",");
    }

    performGetRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          CallTrackerTicketsHdrModel response =
          CallTrackerTicketsHdrModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.tickets);
          } else {
            onRequestFailure(AppException(response.statusMessage ?? ""));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  Future<void> fetchTasksByClientAndLocation(
      {required int clientId,
        required String siteName,
        required Function(List<TaskModel>) onRequestSuccess,
      required Function(AppException) onRequestFailure, }) async {
    String urlExtension = "ServiceCallTracker/getTaskDetailsByClientLocation";

    // clientId=56&locationId=80
    final Map<String, dynamic> rawData = {};
    rawData["clientId"] = clientId;
    rawData["sitename"] = siteName;


    performGetRequest(
        rawData: rawData,

        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          TicketTaskListHdrModel response =
          TicketTaskListHdrModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.tasks);
          } else {
            onRequestFailure(AppException(response.statusMessage ?? ""));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  Future<void> fetchTasksFromDashboard(
      {required int clientId,
        required int serviceUserId,
        required String type,
        required String subType,
        required Function(List<TaskModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure, }) async {
    String urlExtension = "ServiceCallTracker/getTaskDetailsByFilters?";

    final Map<String, dynamic> rawData = {};
    rawData["type"] = type;
    rawData["subtype"] = subType;
    if(clientId != 0){
      rawData["serviceClientId"] = clientId;
    }
    if(serviceUserId != 0){
      rawData["serviceUserId"] = serviceUserId;
    }

    performGetRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          TicketTaskListHdrModel response =
          TicketTaskListHdrModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.tasks);
          } else {
            onRequestFailure(AppException(response.statusMessage ?? ""));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  void fetchStatusTypes(
      {required Function(List<StatusModel>) onRequestSuccess,
      required Function(AppException exception) onRequestFailure}) {
    String urlExtension = "Lookup/GetCommonMasterByType";

    Map<String, dynamic> rawData = {};
    rawData["type"] = "SERV_TKT_STATUS";

    performGetRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (result) {
          try {
            StatusModelResponse response = StatusModelResponse.fromJson(result);
            onRequestSuccess(response.statusResponse);
          } catch (e) {
            onRequestFailure(AppException(
              "Error parsing user data: ${e.toString()}",
            ));
          }
        },
        onRequestFailure: onRequestFailure);
  }
  @override
  Future<void> fetchPriority(
      {required Function(List<CommonMasterModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}) async{
    String urlExtension = "Lookup/GetCommonMasterByType";

    Map<String, dynamic> rawData = {};
    rawData["type"] = "SERV_PRIORITY";

    performGetRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (result) {
          try {
            CommonMasterResponseModel response = CommonMasterResponseModel.fromJson(result);
            onRequestSuccess(response.resultObject);
          } catch (e) {
            onRequestFailure(AppException(
              "Error parsing user data: ${e.toString()}",
            ));
          }
        },
        onRequestFailure: onRequestFailure);
  }
  @override
  void fetchDepartmentFilter(
      {required Function(List<EngineerModel>) onRequestSuccess,
      required Function(AppException exception) onRequestFailure}) {
    String urlExtension = "lookup/GetUsersByDepartment";

    Map<String, dynamic> rawData = {};
    rawData["departmentCode"] = "PRJ";

    performGetRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (result) {
          try {
            EngineersHdrModel response = EngineersHdrModel.fromJson(result);
            onRequestSuccess(response.engineers);
          } catch (e) {
            onRequestFailure(AppException(
              "Error parsing user data: ${e.toString()}",
            ));
          }
        },
        onRequestFailure: onRequestFailure);
  }


  @override
  void updateStatus({
    required TicketStatusModel taskModel,
    required Function(String) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  }) {
    String urlExtension = "ServiceCallTracker/updateStatus";

    Map<String, dynamic> rawData = {};
    rawData["Id"] = taskModel.id ;
    rawData["StatusType"] = taskModel.statusType; // TASK or TICKET
    rawData["Lastmoddate"] = taskModel.lastmoddate ?? "";
    rawData["Statuscode"] = taskModel.statuscode ;

    if (taskModel.remarks != null && taskModel.remarks!.isNotEmpty) {
      if (taskModel.statusType == "TICKET") {
        rawData["Reviewremarks"] = taskModel.remarks ?? "";
      } else {
        rawData["Remarks"] = taskModel.remarks ?? "";
      }
    }

    if (taskModel.notifyClientYN != null) {
      rawData["Notifyclientyn"] = taskModel.notifyClientYN ?? "N";
    }

    if (taskModel.workStatusOptionId != null) {
      rawData["Workstatusid"] = taskModel.workStatusOptionId;
    }

    if (taskModel.taskliststatusupdation != null) {
      rawData["taskliststatusupdation"] = taskModel.taskliststatusupdation!
          .map((t) => {
                "Id": t.id,
                "StatusType": t.statusType,
                "Statuscode": t.statuscode,
                "Lastmoddate": t.lastmoddate ?? "",
              })
          .toList();
    }

    if (taskModel.attachmentList.isNotEmpty) {
      rawData["docAttachments"] = [
        {
          "id": taskModel.docAttachID ?? 0,
          "seriesno": taskModel.seriesNo ?? "",
          "attachmentDtls": taskModel.attachmentList.map((dtl) {
            return {
              "filename": dtl.fileName ?? "",
              "physicalfilename": dtl.filePhysicalName ?? "",
            };
          }).toList(),
        }
      ];
    }

    performRequest(
      urlExtension: urlExtension,
      rawData: rawData,
      onRequestSuccess: (result) {
        try {
          if (result["statusCode"] == 0) {
            onRequestFailure(AppException(result["statusMessage"]));
          } else {
            onRequestSuccess(result["statusMessage"]);
          }
        } catch (e) {
          onRequestFailure(AppException(e.toString()));
        }
      },
      onRequestFailure: onRequestFailure,
    );
  }

  @override
  void fetchServiceBasedSupportDashboardData(
      {required int dataId,
      required Function(List<TicketSummaryModel>) onRequestSuccess,
      required Function(AppException exception) onRequestFailure}) {
    String urlExtension = "SupportRequest/GetDashboardOptionWise";

    Map<String, dynamic> rawData = {};
    rawData["optionCode"] = "CALL_TRACKER";
    rawData["dataId"] = dataId;

    performGetRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (result) {
          try {
            TicketSummaryResponseModel dashboardData =
                TicketSummaryResponseModel.fromJson(result);
            onRequestSuccess(dashboardData.resultObject);
          } catch (e) {
            onRequestFailure(AppException(
              "Error parsing user data: ${e.toString()}",
            ));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  void fetchGetTicketTracking(
      {required int ticketId,
      required Function(List<TicketDetailResultModel>) onRequestSuccess,
      required Function(AppException exception) onRequestFailure}) {
    String urlExtension = "ServiceCallTracker/getTicketTracking?";

    Map<String, dynamic> rawData = {};
    rawData["ticketId"] = ticketId;

    performGetRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (result) {
          try {
            TicketDetailResponseModel data =
                TicketDetailResponseModel.fromJson(result);
            onRequestSuccess(data.resultObject);
          } catch (e) {
            onRequestFailure(AppException(
              "Error parsing user data: ${e.toString()}",
            ));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  void addCommentServiceTask(
      {required int ticketId,
      required String comment,
      required Function() onRequestSuccess,
      required Function(AppException exception) onRequestFailure}) {
    String urlExtension =
        "ServiceCallTracker/addComment?ticketId=$ticketId&comment=$comment";

    performRequest(
        urlExtension: urlExtension,
        rawData: {},
        onRequestSuccess: (result) {
          try {

            onRequestSuccess();
          } catch (e) {
            onRequestFailure(AppException(
              "Error parsing user data: ${e.toString()}",
            ));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  void fetchServiceTicketDashboard(
      {required TaskDashBoardSummaryFilterModel taskDashBoardFilterModel,
        required Function(List<ServiceTicketDashboardData>) onRequestSuccess,
      required Function(AppException exception) onRequestFailure}) {
    String urlExtension = "ServiceCallTracker/GetDashboardDataList";

    final builder = DataStructureBuilder()
        .addColumn("Flag", "SUMMARY");

    if (taskDashBoardFilterModel.ticketNo != null &&
        taskDashBoardFilterModel.ticketNo!.isNotEmpty) {

      builder.addColumn("TicketNo", "%${taskDashBoardFilterModel.ticketNo}%");
    }

    if (taskDashBoardFilterModel.dateFrom != null) {
      builder.addColumn("DateFrom", taskDashBoardFilterModel.dateFrom);
    }

    if (taskDashBoardFilterModel.dateTo != null) {
      builder.addColumn("DateTo", taskDashBoardFilterModel.dateTo);
    }

    if (taskDashBoardFilterModel.cityId != null) {
      builder.addColumn("CityId", taskDashBoardFilterModel.cityId);
    }

    if (taskDashBoardFilterModel.priorityId != null) {
      builder.addColumn("PriorityId", taskDashBoardFilterModel.priorityId);
    }

    if (taskDashBoardFilterModel.selDashFilterClientList.isNotEmpty) {
      builder.addColumn(
        "ClientIdString",
        taskDashBoardFilterModel.selDashFilterClientList
            .map((e) => e.id)
            .join(','),
      );
    }

    final rawData = builder.build();

    performRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (result) {
          try {
            ServiceTicketDashboardDto response =
                ServiceTicketDashboardDto.fromJson(result);
            onRequestSuccess(response.resultObject);
          } catch (e) {
            onRequestFailure(AppException(
              "Error parsing dashboard data: ${e.toString()}",
            ));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  Future<void> cancelServiceTicket({
    required int ticketId,
    required String lastModDate,
    required String notifyClientYN,
    required Function() onRequestSuccess,
    required Function(AppException) onRequestFailure}) async{
    String urlExtension = "ServiceCallTracker/updateStatus";
    Map<String, dynamic> rawData = {};

    rawData["Id"] = ticketId;
    rawData["Notifyclientyn"] = notifyClientYN;
    rawData["Lastmoddate"] = lastModDate;
    rawData["StatusType"] = "TICKET";
    rawData["Statuscode"] = "CANCELLED";
    rawData["Reviewremarks"] = "";

    performRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (result) {
          BaseResponseModel responseModel = BaseResponseModel.fromJson(result);
          if(responseModel.statusCode == 1){
            onRequestSuccess();
          }
          else{
            onRequestFailure(AppException(responseModel.statusMessage ?? ""));
          }

        },
        onRequestFailure: onRequestFailure);
  }

  @override
  Future<void> updateTaskClientDependency({
    required int taskId,
    required String clientDependencyYN,
    required String lastModDate,
    required Function() onRequestSuccess,
    required Function(AppException) onRequestFailure,
  }) async {
    String urlExtension = "ServiceCallTracker/updateClientDependency";
    Map<String, dynamic> rawData = {
      "id": taskId,
      "clientdependencyyn": clientDependencyYN,
      "Lastmoddate": lastModDate,
    };

    performRequest(
      urlExtension: urlExtension,
      rawData: rawData,
      onRequestSuccess: (result) {
        if (result["statusCode"] == 1) {
          onRequestSuccess();
        } else {
          onRequestFailure(AppException(result['statusMessage']));
        }
      },
      onRequestFailure: onRequestFailure,
    );
  }

  @override
  Future<void> updateTaskClosureDate({
    required int taskId,
    required String targetClosureDate,
    required String lastModDate,
    required Function() onRequestSuccess,
    required Function(AppException) onRequestFailure,
  }) async {
    String urlExtension = "ServiceCallTracker/updateTargetClosureDate";
    Map<String, dynamic> rawData = {
      "Id": taskId,
      "Targetclosuredate": targetClosureDate,
      "Lastmoddate": lastModDate,
    };

    performRequest(
      urlExtension: urlExtension,
      rawData: rawData,
      onRequestSuccess: (result) {
        if (result["statusCode"] == 1) {
          onRequestSuccess();
        } else {
          onRequestFailure(AppException(result['statusMessage']));
        }
      },
      onRequestFailure: onRequestFailure,
    );
  }
}
