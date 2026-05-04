import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';

/// Response wrapper for the service ticket dashboard API.
class ServiceTicketDashboardDto extends BaseResponseModel {
  List<ServiceTicketDashboardData> resultObject = [];

  ServiceTicketDashboardDto.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    resultObject = BaseJsonParser.goodList(json, 'resultObject')
        .map((e) => ServiceTicketDashboardData.fromJson(e))
        .toList();
  }
}

/// Top-level dashboard data containing all 4 chart data lists.
class ServiceTicketDashboardData {
  List<ServiceTaskStatus> taskStatusJson = [];
  List<ServiceTaskDelayByDays> taskDelayByDaysJson = [];
  List<ServiceClientDelay> clientDelayJson = [];
  List<ServiceMemberDelay> memberDelayJson = [];
  List<TeamTicketDelay> teamDelayTicketJson = [];


  ServiceTicketDashboardData({
    this.taskStatusJson = const [],
    this.taskDelayByDaysJson = const [],
    this.clientDelayJson = const [],
    this.memberDelayJson = const [],
    this.teamDelayTicketJson = const []
  });

  ServiceTicketDashboardData.fromJson(Map<String, dynamic> json) {
    // JSON key: "servicestatusjson"
    taskStatusJson = BaseJsonParser.goodList(json, 'servicestatusjson')
        .map((e) => ServiceTaskStatus.fromJson(e))
        .toList();

    // JSON key: "servicetaskdelayjson"
    taskDelayByDaysJson = BaseJsonParser.goodList(json, 'servicetaskdelayjson')
        .map((e) => ServiceTaskDelayByDays.fromJson(e))
        .toList();

    // JSON key: "tclientdelayedjson"
    clientDelayJson = BaseJsonParser.goodList(json, 'tclientdelayedjson')
        .map((e) => ServiceClientDelay.fromJson(e))
        .toList();

    // JSON key: "teamdelayjson"
    memberDelayJson = BaseJsonParser.goodList(json, 'teamdelayjson')
        .map((e) => ServiceMemberDelay.fromJson(e))
        .toList();
    teamDelayTicketJson = BaseJsonParser.goodList(json, "teamdelaytktjson")
        .map((e) => TeamTicketDelay.fromJson(e))
        .toList();
  }
}

/// Chart 1: Service Status (On Track, Delay, Future Task, Target Issue)
class ServiceTaskStatus {
  String? statusCategory;
  String? statusCategoryCode;
  int? serviceCount;

  ServiceTaskStatus({this.statusCategory, this.statusCategoryCode, this.serviceCount});

  ServiceTaskStatus.fromJson(Map<String, dynamic> json) {
    // JSON keys: "servicecategory", "servicecategorycode", "servicecount"
    statusCategory = BaseJsonParser.goodString(json, 'servicecategory');
    statusCategoryCode = BaseJsonParser.goodString(json, 'servicecategorycode');
    serviceCount = BaseJsonParser.goodInt(json, 'servicecount') ?? 0;
  }
}

/// Chart 2: Number of Tasks × Days Delay (This Week, >7, >15, >30, >45)
class ServiceTaskDelayByDays {
  String? delayCategory;
  String? delayCategoryCode;
  int? taskCount;

  ServiceTaskDelayByDays({this.delayCategory, this.delayCategoryCode, this.taskCount});

  ServiceTaskDelayByDays.fromJson(Map<String, dynamic> json) {
    // JSON keys: "delaycategory", "delaycategorycode", "taskcount"
    delayCategory = BaseJsonParser.goodString(json, 'delaycategory');
    delayCategoryCode = BaseJsonParser.goodString(json, 'delaycategorycode');
    taskCount = BaseJsonParser.goodInt(json, 'taskcount') ?? 0;
  }
}

/// Chart 3: Client × Delayed Service Requests
class ServiceClientDelay {
  String? clientName;
  String? categorycode;
  int? clientId;
  int? requestCount;
  int? delayedCount;
  int? onTrackCount;

  ServiceClientDelay({this.clientName, this.clientId, this.requestCount});

  ServiceClientDelay.fromJson(Map<String, dynamic> json) {
    // JSON keys: "category" (client name), "clientid", "requestcount"
    clientName = BaseJsonParser.goodString(json, 'category');
    categorycode = BaseJsonParser.goodString(json, 'categorycode');
    clientId = BaseJsonParser.goodInt(json, 'clientid');
    requestCount = BaseJsonParser.goodInt(json, 'requestcount') ?? 0;
    delayedCount = BaseJsonParser.goodInt(json, 'delayedcount');
    onTrackCount = BaseJsonParser.goodInt(json, 'ontrackcount');
  }
}

/// Chart 4: Team Member × Delayed Service Requests
class ServiceMemberDelay {
  String? memberName;
  int? memberId;
  int? requestCount;
  int? onTrackCount;
  int? delayedCount;
  String? categorycode;

  ServiceMemberDelay({this.memberName, this.memberId, this.requestCount});

  ServiceMemberDelay.fromJson(Map<String, dynamic> json) {
    // JSON keys: "category" (member name), "userid", "requestcount"
    memberName = BaseJsonParser.goodString(json, 'category');
    memberId = BaseJsonParser.goodInt(json, 'userid');
    requestCount = BaseJsonParser.goodInt(json, 'requestcount') ?? 0;
    categorycode = BaseJsonParser.goodString(json, 'categorycode');
    onTrackCount = BaseJsonParser.goodInt(json, 'ontrackcount') ?? 0;
    delayedCount = BaseJsonParser.goodInt(json, 'delayedcount') ?? 0;
  }
}

class TeamTicketDelay {
  int? clientId;
  String? category;
  String? categoryCode;
  int? delayedCount;
  int? onTrackCount;

  TeamTicketDelay({this.clientId, this.category, this.categoryCode, this.delayedCount});

  TeamTicketDelay.fromJson(Map<String, dynamic> json) {
    clientId = BaseJsonParser.goodInt(json, 'clientid');
    category = BaseJsonParser.goodString(json, 'category');
    categoryCode = BaseJsonParser.goodString(json, 'categorycode');
    delayedCount = BaseJsonParser.goodInt(json, 'delayedcount');
    onTrackCount = BaseJsonParser.goodInt(json, 'ontrackcount');
  }
}