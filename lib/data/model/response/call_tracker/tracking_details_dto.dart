import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';

class TicketDetailResponseModel extends BaseResponseModel {
  List<TicketDetailResultModel> resultObject = [];

  TicketDetailResponseModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    json['resultObject'] != null
        ? resultObject.add(TicketDetailResultModel.fromJson(json['resultObject']))
        : resultObject = [];
  }
}

class TicketDetailResultModel {
  TicketDetailSummaryModel? summary;

  List<TicketLogModel> ticketLogs = [];
  List<TicketTaskModel> tasks = [];
  List<TicketCommentModel> comments = [];
  List<MembersListModel> membersList = [];

  TicketDetailResultModel.fromJson(Map<String, dynamic> json) {
    summary = json['summary'] != null
        ? TicketDetailSummaryModel.fromJson(json['summary'])
        : null;

    ticketLogs = BaseJsonParser.goodList(json, 'ticketLogs')
        .map((e) => TicketLogModel.fromJson(e))
        .toList();

    tasks = BaseJsonParser.goodList(json, 'tasks')
        .map((e) => TicketTaskModel.fromJson(e))
        .toList();

    comments = BaseJsonParser.goodList(json, 'comments')
        .map((e) => TicketCommentModel.fromJson(e))
        .toList();
    membersList = BaseJsonParser.goodList(json, 'memberslist')
        .map((e) => MembersListModel.fromJson(e))
        .toList();
  }
}

class TicketDetailSummaryModel {
  int id = 0;
  String? ticketno;
  String? ticketdate;
  String? description;
  String? lastmoddate;

  String? statusCode;
  String? status;
  String? category;
  String? priority;

  String? targetclosuredate;
  String? actualclosuredate;

  String? assignedUser;
  String? assignedUserProfileKey;

  String? coordinateUser;
  String? coordinateUserProfileKey;

  String? serviceReportUser;
  String? serviceReportUserProfileKey;

  TicketDetailSummaryModel.fromJson(Map<String, dynamic> json) {
    id = BaseJsonParser.goodInt(json, 'id') ?? 0;
    ticketno = BaseJsonParser.goodString(json, 'ticketno');
    ticketdate = BaseJsonParser.goodString(json, 'ticketdate');
    description = BaseJsonParser.goodString(json, 'description');
    lastmoddate = BaseJsonParser.goodString(json, 'lastmoddate');

    statusCode = BaseJsonParser.goodString(json, 'statusCode');
    status = BaseJsonParser.goodString(json, 'status');
    category = BaseJsonParser.goodString(json, 'category');
    priority = BaseJsonParser.goodString(json, 'priority');

    targetclosuredate =
        BaseJsonParser.goodString(json, 'targetclosuredate');
    actualclosuredate =
        BaseJsonParser.goodString(json, 'actualclosuredate');

    assignedUser = BaseJsonParser.goodString(json, 'assignedUser');
    assignedUserProfileKey =
        BaseJsonParser.goodString(json, 'assignedUserProfileKey');

    coordinateUser = BaseJsonParser.goodString(json, 'coordinateUser');
    coordinateUserProfileKey =
        BaseJsonParser.goodString(json, 'coordinateUserProfileKey');

    serviceReportUser =
        BaseJsonParser.goodString(json, 'serviceReportUser');
    serviceReportUserProfileKey =
        BaseJsonParser.goodString(json, 'serviceReportUserProfileKey');
  }
}
// {id: 2338,
// actionTypeCode: STATUS_UPDATE,
// actionType: Staus Update,
// statusCode: IN_PROGRESS,
// status: In Progress,
// statusdate: 2026-04-24T18:25:36.811855,
// fromUserId: 31,
// fromUser: Ajith Sudhakaran,
// fromUserProfileKey: null,
// toUserId: null,
// toUser: null,
// toUserProfileKey: null,
// remarks: null,
// workstatusName: null,
// workstatusCode: null}
class TicketLogModel {
  int id = 0;
  String actionType = '';
  String statusCode = '';
  String status = '';
  String statusdate = '';
  String fromUser = '';
  String fromUserProfileKey = '';
  String toUser = '';
  String toUserProfileKey = '';
  String remarks = '';
  String description = '';
  String workStatusCode = '';
  String workStatusName = '';

  TicketLogModel.fromJson(Map<String, dynamic> json) {
    id = BaseJsonParser.goodInt(json, 'id') ?? 0;
    actionType = BaseJsonParser.goodString(json, 'actionType')??"";
    statusCode = BaseJsonParser.goodString(json, 'statusCode')??'';
    status = BaseJsonParser.goodString(json, 'status')??'';
    statusdate = BaseJsonParser.goodString(json, 'statusdate')??'';
    description = BaseJsonParser.goodString(json, 'description')??'';

    fromUser = BaseJsonParser.goodString(json, 'fromUser')??'';
    fromUserProfileKey =
        BaseJsonParser.goodString(json, 'fromUserProfileKey')??'';

    toUser = BaseJsonParser.goodString(json, 'toUser')??'';
    toUserProfileKey =
        BaseJsonParser.goodString(json, 'toUserProfileKey')??'';

    remarks = BaseJsonParser.goodString(json, 'remarks')??'';
    workStatusCode = BaseJsonParser.goodString(json, 'workstatusCode') ?? "";
    workStatusName = BaseJsonParser.goodString(json, 'workstatusName') ?? "";
  }
}

class TicketTaskModel {
  int id = 0;
  int slno = 0;

  String? description;
  String? statusCode;
  String? status;
  String? lastmoddate;

  List<TicketLogModel> logs = [];

  TicketTaskModel.fromJson(Map<String, dynamic> json) {
    id = BaseJsonParser.goodInt(json, 'id') ?? 0;
    slno = BaseJsonParser.goodInt(json, 'slno') ?? 0;

    description = BaseJsonParser.goodString(json, 'description');
    statusCode = BaseJsonParser.goodString(json, 'statusCode');
    status = BaseJsonParser.goodString(json, 'status');
    lastmoddate = BaseJsonParser.goodString(json, 'lastmoddate');

    logs = BaseJsonParser.goodList(json, 'logs')
        .map((e) => TicketLogModel.fromJson(e))
        .toList();
  }
}

class TicketCommentModel {
  int id = 0;
  String? comment;
  String? user;
  String? userProfileKey;
  String? lastmoddate;

  TicketCommentModel.fromJson(Map<String, dynamic> json) {
    id = BaseJsonParser.goodInt(json, 'id') ?? 0;
    comment = BaseJsonParser.goodString(json, 'comment');
    user = BaseJsonParser.goodString(json, 'user');
    userProfileKey =
        BaseJsonParser.goodString(json, 'userProfileKey');
    lastmoddate = BaseJsonParser.goodString(json, 'lastmoddate');
  }
}

class MembersListModel{
  int? id;
  String? name;
  String? profileUrl;
  MembersListModel.fromJson(Map<String, dynamic> json){
    id = BaseJsonParser.goodInt(json, 'id');
    name = BaseJsonParser.goodString(json, 'name');
    profileUrl = BaseJsonParser.goodString(json, 'profileurl');
  }
}