import 'dart:convert';

import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';

class ProjectTaskListModel extends BaseResponseModel {
  List<ProjectTaskDtlModel> projectTaskList = [];

  ProjectTaskListModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    List projectTaskListJson = json['resultObject'];
    if(projectTaskListJson.isNotEmpty){
      List listParsing = jsonDecode(projectTaskListJson.first);
      for (var result in listParsing) {
        projectTaskList.add(ProjectTaskDtlModel.fromJson(result));
      }
    }
  }
}

class ProjectTaskDtlModel {
  int? id;
  int? optionid;
  int? tableId;
  int? projectId;
  int? taskId;
  String? taskUid;
  String? taskName;
  String? project;
  String? projectlocation;
  String? projectenddate;
  String? plannedStartDate;
  String? plannedEndDate;
  String? actualStartDate;
  String? actualFinishDate;
  double? completionPerc;
  String? duration;
  int? uomId;
  int? statusId;
  String? statusCode;
  String? status;
  String? isCritical;
  int? taskUserId;
  String? taskUser;
  String? taskUserProfile;
  String? taskuserprofileurl;
  String? lastmoddate;
  String? activityGroupCode;
  String? activityGroupName;
  List<ProjectTaskPredecessorModel> predecessorList = [];

  ProjectTaskDtlModel.fromJson(Map<String,dynamic> json) {
    print("result___ "+json.runtimeType.toString());
    id = BaseJsonParser.goodInt(json, 'id');
    optionid = BaseJsonParser.goodInt(json, 'optionid');
    tableId = BaseJsonParser.goodInt(json, 'tableid');
    projectId = BaseJsonParser.goodInt(json, 'projectid');
    taskId = BaseJsonParser.goodInt(json, 'taskid');
    taskUid = BaseJsonParser.goodString(json, 'taskuid');
    taskName = BaseJsonParser.goodString(json, 'taskname');
    project = BaseJsonParser.goodString(json, 'project');
    projectlocation = BaseJsonParser.goodString(json, 'projectlocation');
    projectenddate = BaseJsonParser.goodString(json, 'projectenddate');
    plannedStartDate = BaseJsonParser.goodString(json, 'plannedstartdate');
    plannedEndDate = BaseJsonParser.goodString(json, 'plannedenddate');
    actualStartDate = BaseJsonParser.goodString(json, 'actualstartdate');
    actualFinishDate = BaseJsonParser.goodString(json, 'actualfinishdate');
    activityGroupCode = BaseJsonParser.goodString(json, 'activitygroupcode');
    activityGroupName = BaseJsonParser.goodString(json, 'activitygroupname');
    completionPerc = BaseJsonParser.goodDouble(json, 'completionperc');
    duration = BaseJsonParser.goodString(json, 'duration');
    uomId = BaseJsonParser.goodInt(json, 'uomid');
    statusId = BaseJsonParser.goodInt(json, 'statusid');
    statusCode = BaseJsonParser.goodString(json, 'statuscode');
    status = BaseJsonParser.goodString(json, 'status');
    isCritical = BaseJsonParser.goodString(json, 'iscritical');
    taskUserId = BaseJsonParser.goodInt(json, 'taskuserid');
    taskUser = BaseJsonParser.goodString(json, 'taskuser');
    taskUserProfile = BaseJsonParser.goodString(json, 'taskuserprofile');
    taskuserprofileurl = BaseJsonParser.goodString(json, 'taskuserprofileurl');
    lastmoddate = BaseJsonParser.goodString(json, 'lastmoddate');

    final predecessorJson = BaseJsonParser.goodList(json, 'predecessorjson');
    predecessorList = predecessorJson
        .map((e) => ProjectTaskPredecessorModel.fromJson(e))
        .toList();
  }
}

class ProjectTaskPredecessorModel {
  int? id;
  int? tableId;
  int? taskId;
  String? taskName;
  int? taskUserId;
  String? taskUser;
  int? dependencyTypeId;
  String? dependencyTypeCode;
  String? dependencyType;
  String? taskstatus;
  String? lagDuration;
  String? taskuserprofileurl;

  ProjectTaskPredecessorModel.fromJson(json) {
    id = BaseJsonParser.goodInt(json, 'id');
    tableId = BaseJsonParser.goodInt(json, 'tableid');
    taskId = BaseJsonParser.goodInt(json, 'taskid');
    taskName = BaseJsonParser.goodString(json, 'taskname');
    taskUserId = BaseJsonParser.goodInt(json, 'taskuserid');
    taskUser = BaseJsonParser.goodString(json, 'taskuser');
    dependencyTypeId = BaseJsonParser.goodInt(json, 'dependencytypeid');
    dependencyTypeCode = BaseJsonParser.goodString(json, 'dependencytypecode');
    dependencyType = BaseJsonParser.goodString(json, 'dependencytype');
    taskstatus = BaseJsonParser.goodString(json, 'taskstatus');
    lagDuration = BaseJsonParser.goodString(json, 'lagduration');
    taskuserprofileurl = BaseJsonParser.goodString(json, 'taskuserprofileurl');
  }
}
