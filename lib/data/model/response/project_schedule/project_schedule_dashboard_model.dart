import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';

class DashboardDto extends BaseResponseModel{

  List<ProjectData>? resultObject;

  DashboardDto.fromJson(Map<String, dynamic> json) {
    resultObject = BaseJsonParser.goodList(json, 'resultObject')
        .map((e) => ProjectData.fromJson(e))
        .toList();
  }
}

class ProjectData {
  int? projectId;
  String? projectName;
  String? clientName;
  String? projectLocation;
  List<ProjectProgress> projectProgressJson = [];
  List<DelayTaskByDays> delayTaskInDaysJson = [];
  List<DelayTaskByUser> delayTaskUserJson = [];
  List<CompleteTaskByUser> completeTaskUserJson = [];
  List<SupportRequestOverDelay> supprtReqOverDelay = [];
  List<ActivityGroupModel> activityGroupModel = [];

  ProjectData({
    this.projectId,
    this.projectName,
    this.clientName,
    this.projectLocation,
    this.projectProgressJson = const [],
    this.delayTaskInDaysJson = const [],
    this.delayTaskUserJson = const [],
    this.completeTaskUserJson = const [],
    this.supprtReqOverDelay = const [],
  });

  ProjectData.fromJson(Map<String, dynamic> json) {
    projectId = BaseJsonParser.goodInt(json, 'projectid');
    projectName = BaseJsonParser.goodString(json, 'projectname');
    clientName = BaseJsonParser.goodString(json, 'clientname');
    projectLocation = BaseJsonParser.goodString(json, 'projectlocation');

    projectProgressJson = BaseJsonParser.goodList(json, 'projectprogressjson')
        .map((e) => ProjectProgress.fromJson(e))
        .toList();

    delayTaskInDaysJson = BaseJsonParser.goodList(json, 'delaytaskindaysjson')
        .map((e) => DelayTaskByDays.fromJson(e))
        .toList();

    delayTaskUserJson = BaseJsonParser.goodList(json, 'delaytaskuserjson')
        .map((e) => DelayTaskByUser.fromJson(e))
        .toList();

    completeTaskUserJson = BaseJsonParser.goodList(json, 'completetaskuserjson')
        .map((e) => CompleteTaskByUser.fromJson(e))
        .toList();
    supprtReqOverDelay = BaseJsonParser.goodList(json, 'supprtreqoverdelayjson')
        .map((e) => SupportRequestOverDelay.fromJson(e))
        .toList();
    activityGroupModel = BaseJsonParser.goodList(json, 'activitygroupjson')
        .map((e) => ActivityGroupModel.fromJson(e))
        .toList();
  }
}

class ProjectProgress {
  String chartName = '';
  String progressCategory = '';
  int? taskCount;

  ProjectProgress({
    this.chartName = '',
    this.progressCategory = '',
    this.taskCount,
  });

  ProjectProgress.fromJson(Map<String, dynamic> json) {
    chartName = BaseJsonParser.goodString(json, 'chartname') ?? '';
    progressCategory = BaseJsonParser.goodString(json, 'progresscategory') ?? '';
    taskCount = BaseJsonParser.goodInt(json, 'taskcount') ?? 0;
  }
}

class DelayTaskByDays {
  String? delayCategory;
  String? delaycategorycode;
  int? taskCount;
  String chartName='';

  DelayTaskByDays({this.delayCategory, this.taskCount, this.chartName=''});

  DelayTaskByDays.fromJson(Map<String, dynamic> json) {
    delayCategory = BaseJsonParser.goodString(json, 'delaycategory');
    delaycategorycode = BaseJsonParser.goodString(json, 'delaycategorycode');
    taskCount = BaseJsonParser.goodInt(json, 'taskcount') ?? 0;
    chartName = BaseJsonParser.goodString(json, 'chartname')??"";
  }
}

class DelayTaskByUser {
  String? assignedTo;
  String? assigneduserid;
  int? delayedTaskCount;
  String chartName="";



  DelayTaskByUser.fromJson(Map<String, dynamic> json) {
    assignedTo = BaseJsonParser.goodString(json, 'assignedto');
    assigneduserid = BaseJsonParser.goodString(json, 'assigneduserid');
    delayedTaskCount = BaseJsonParser.goodInt(json, 'delayedtaskcount') ?? 0;
    chartName = BaseJsonParser.goodString(json, 'chartname')??"";
  }
}

class CompleteTaskByUser {
  String? assignedTo;
  String? assigneduserid;
  int? completeTaskCount;
  String chartName='';

  CompleteTaskByUser({this.assignedTo, this.completeTaskCount, this.chartName=''});

  CompleteTaskByUser.fromJson(Map<String, dynamic> json) {
    assignedTo = BaseJsonParser.goodString(json, 'assignedto');
    assigneduserid = BaseJsonParser.goodString(json, 'assigneduserid');
    completeTaskCount = BaseJsonParser.goodInt(json, 'completetaskcount') ?? 0;
    chartName = BaseJsonParser.goodString(json, 'chartname')??'';
  }
}

class SupportRequestOverDelay {
  String? supporttypename;
  String? supporttypecode;
  int? supportcount;
  String chartName='';

  SupportRequestOverDelay({this.supporttypename, this.supportcount, this.chartName=''});

  SupportRequestOverDelay.fromJson(Map<String, dynamic> json) {
    supporttypename = BaseJsonParser.goodString(json, 'supporttypename');
    supporttypecode = BaseJsonParser.goodString(json, 'supporttypecode');
    supportcount = BaseJsonParser.goodInt(json, 'supportcount') ?? 0;
    chartName = BaseJsonParser.goodString(json, 'chartname')??'';
  }
}

class ActivityGroupModel {
  int? estimatedlabourcount;
  String? description;
  int? projectid;
  int? activitygroupid;
  int? actuallabourcount;
  String code='';

  ActivityGroupModel.fromJson(Map<String, dynamic> json) {
    actuallabourcount = BaseJsonParser.goodInt(json, 'actuallabourcount');
    activitygroupid = BaseJsonParser.goodInt(json, 'activitygroupid');
    actuallabourcount = BaseJsonParser.goodInt(json, 'actuallabourcount');
    projectid = BaseJsonParser.goodInt(json, 'projectid');
    estimatedlabourcount = BaseJsonParser.goodInt(json, 'estimatedlabourcount')??0;
    description = BaseJsonParser.goodString(json, 'description') ?? "";
    code = BaseJsonParser.goodString(json, 'code')??'';
  }
}
