import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';

import 'call_tracker_model.dart';

class TicketTaskListHdrModel extends BaseResponseModel {
  List<TaskModel> tasks = [];

  TicketTaskListHdrModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    tasks = BaseJsonParser.goodList(json, 'resultObject')
        .map((e) => TaskModel.fromJson(e))
        .toList();
  }
}

class TaskModel {
  int? ticketId;
  String? ticketNo;
  int? id;
  int? slno;
  String? description;

  String? statusCode;
  String? status;
  String? ticketStatus;

  String? lastModDate;
  String? statusRemarks;

  bool isEngineer = false;
  bool isReporter = false;
  bool isCoordinator = false;
  bool hasSupport = false;
  bool clientDependencyYN = false;
  bool allTasksReviewedOrSubmitted = false;
  String? workStatusName;
  String? workStatusCode;
  String? targetClosureDate;
  String? assignedEngineerName;
  List<TaskAttachmentModel> attachments = [];
  List<TaskAttachmentModel> submittedAttachments = [];
  List<TaskAttachmentModel> prevSubmittedAttachments = [];
  List<DocAttachDetailModel> docAttachDetails = [];

  TaskModel.fromJson(Map<String, dynamic> json) {
    ticketId = BaseJsonParser.goodInt(json, 'ticketId');
    ticketNo = BaseJsonParser.goodString(json, 'ticketNo');

    id = BaseJsonParser.goodInt(json, 'id');
    slno = BaseJsonParser.goodInt(json, 'slno');
    description = BaseJsonParser.goodString(json, 'description');

    statusCode = BaseJsonParser.goodString(json, 'statusCode');
    status = BaseJsonParser.goodString(json, 'status');
    ticketStatus = BaseJsonParser.goodString(json, 'ticketStatus');

    lastModDate = BaseJsonParser.goodString(json, 'lastmoddate');
    statusRemarks = BaseJsonParser.goodString(json, 'statusremarks');

    isEngineer = BaseJsonParser.goodBoolean(json, 'isEngineer');
    isReporter = BaseJsonParser.goodBoolean(json, 'isReporter');
    isCoordinator = BaseJsonParser.goodBoolean(json, 'isCoordinator');
    hasSupport = BaseJsonParser.goodBoolean(json, 'hasSupport');
    workStatusName = BaseJsonParser.goodString(json, "workstatusName");
    workStatusCode = BaseJsonParser.goodString(json, "workstatusCode");
    targetClosureDate = BaseJsonParser.goodString(json, "targetclosuredate");
    assignedEngineerName = BaseJsonParser.goodString(json, "assignedusername");
    clientDependencyYN = BaseJsonParser.goodBoolean(json, "clientdependancyyn");
    allTasksReviewedOrSubmitted =
        BaseJsonParser.goodBoolean(json, 'allTasksReviewedOrSubmitted');

    attachments = BaseJsonParser.goodList(json, 'attachments')
        .map((e) => TaskAttachmentModel.fromJson(e))
        .toList();

    submittedAttachments = BaseJsonParser.goodList(json, 'submittedAttachments')
        .map((e) => TaskAttachmentModel.fromJson(e))
        .toList();

    prevSubmittedAttachments =
        BaseJsonParser.goodList(json, 'prevSubmittedAttachments')
            .map((e) => TaskAttachmentModel.fromJson(e))
            .toList();

    docAttachDetails = BaseJsonParser.goodList(json, 'docAttchDetails')
        .map((e) => DocAttachDetailModel.fromJson(e))
        .toList();
  }
}