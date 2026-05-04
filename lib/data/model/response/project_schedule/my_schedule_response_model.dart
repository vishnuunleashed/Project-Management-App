import 'dart:convert';

import 'package:base/data_export.dart';
import 'package:interior_design/data/model/response/project_schedule/schedule_project_details.dart';

class MyScheduleResponseModel extends BaseResponseModel {
  List<MyScheduleModel> myScheduleList = [];
  ScheduleProjectDetails? scheduleProjectDetails;

  MyScheduleResponseModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    List list = json['resultObject']["schedule"];
    for (var result in list) {
      myScheduleList.add(MyScheduleModel.fromJson(result));
    }
    Map<String,dynamic> map = json['resultObject']["projectDetails"];
    scheduleProjectDetails = ScheduleProjectDetails.fromJson(map);
  }

}

class MyScheduleModel {
  // Identification
  int? id;
  int? taskId;
  String? uid;
  String? name;
  int? taskMasterID;

  String? wbs;
  String? outlineNumber;

  // Scheduling
  int? duration;
  String? durationUnits;
  String? plannedStart;
  String? plannedFinish;
  String? actualStart;
  String? taskMasterName;
  String? actualFinish;

  double? totalSlack;
  double? freeSlack;
  bool? isCritical;

  // Progress
  int? percentComplete;
  bool? milestoneFlag;
  bool? hasAttachments;

  // Status
  int? statusid;
  String? statusText;
  String? statusDetails;
  String? color;
  String? status;
  String? predecessorTaskIds;
  String? taskMasterProfile;

  String? uom;

  String? type;
  int? lag;
  String? lagUom;
  MyScheduleModel({
    this.id,
    this.taskId,
    this.uid,
    this.name,
    this.taskMasterID,
    this.wbs,
    this.outlineNumber,

    this.duration,
    this.durationUnits,
    this.plannedStart,
    this.plannedFinish,
    this.actualStart,
    this.actualFinish,

    this.totalSlack,
    this.freeSlack,
    this.isCritical,

    this.percentComplete,
    this.milestoneFlag,

    this.statusid,
    this.statusText,
    this.statusDetails,
    this.color,

    this.uom,

    this.type,
    this.lag,
    this.lagUom,
    this.predecessorTaskIds,
    this.taskMasterName,
    this.taskMasterProfile,
  });

  MyScheduleModel.fromJson(Map<String, dynamic> json) {
    // Identification
    id = BaseJsonParser.goodInt(json, 'id');
    taskId = BaseJsonParser.goodInt(json, 'taskId');
    uid = BaseJsonParser.goodString(json, 'uid');
    name = BaseJsonParser.goodString(json, 'name');
    taskMasterID = BaseJsonParser.goodInt(json, 'taskMasterID');
    taskMasterName = BaseJsonParser.goodString(json, 'taskMasterName');
    predecessorTaskIds = BaseJsonParser.goodString(json, 'predecessorTaskIds');
    taskMasterProfile = BaseJsonParser.goodString(json, 'taskMasterProfile');

    status = BaseJsonParser.goodString(json, 'status');
    wbs = BaseJsonParser.goodString(json, 'wbs');
    outlineNumber = BaseJsonParser.goodString(json, 'outlineNumber');

    // Scheduling
    duration = BaseJsonParser.goodInt(json, 'duration');
    durationUnits = BaseJsonParser.goodString(json, 'durationUnits');
    plannedStart = json['plannedStart'];
    plannedFinish = json['plannedFinish'];
    actualStart = json['actualStart'];
    actualFinish = json['actualFinish'];

    totalSlack = BaseJsonParser.goodDouble(json, 'totalSlack');
    freeSlack = BaseJsonParser.goodDouble(json, 'freeSlack');
    hasAttachments = BaseJsonParser.goodBoolean(json, 'hasAttachments');
    isCritical = BaseJsonParser.goodBoolean(json, 'isCritical');

    // Progress
    percentComplete = BaseJsonParser.goodInt(json, 'percentComplete');
    milestoneFlag = BaseJsonParser.goodBoolean(json, 'milestoneFlag');

    // Status
    statusid = BaseJsonParser.goodInt(json, 'statusid');
    statusText = BaseJsonParser.goodString(json, 'statusText');
    statusDetails = BaseJsonParser.goodString(json, 'statusDetails');
    color = BaseJsonParser.goodString(json, 'color');

    uom = BaseJsonParser.goodString(json, 'uom');
    type = BaseJsonParser.goodString(json, 'type');
    lag = BaseJsonParser.goodInt(json, 'lag');
    lagUom = BaseJsonParser.goodString(json, 'lagUom');
  }
}
