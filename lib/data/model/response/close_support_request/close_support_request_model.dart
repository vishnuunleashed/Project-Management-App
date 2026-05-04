

import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';


class CloseSupportRequestStatusModel extends BaseResponseModel {

  List<CloseSupportRequestStatusModelObj> statusList = [];

  CloseSupportRequestStatusModel.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    statusList = BaseJsonParser.goodList(json, 'resultObject').map((e) => CloseSupportRequestStatusModelObj.fromJson(e)).toList();
  }
}

//Status model
class CloseSupportRequestStatusModelObj {
  int id = 0;
  String code ="";
  String desc ="";

  CloseSupportRequestStatusModelObj({
    required this.id,
    required this.code,
    required this.desc
  });

  CloseSupportRequestStatusModelObj.fromJson(Map<String, dynamic> json) {
      id = BaseJsonParser.goodInt(json, 'id')?? 0 ;
      code =  BaseJsonParser.goodString(json, 'code')?? "" ;
      desc = BaseJsonParser.goodString(json, 'description')?? "" ;
  }
}

//Fill Model
class SupportRequestFillModel {
  String? projectName;
  int? projectid;
  String? projectLocation;
  String? projectEndDate;
  int id = 0;
  int? notificationbatchid;
  int? tableId;
  int? optionId;
  int? reftabledataid;
  String? transNo;
  String? transDate;
  int? escalatedById;
  String? escalatedByName;
  String? requestDescription;
  int? dependencyDeptId;
  String? dependencyDeptName;
  String? targetClosureDate;
  String? remarks;
  bool rightsyn = false;
  String? assignedFrom;
  String? assignedTo;
  int? assignedToUserId;
  String? assignedremarks;
  String? assignedstatuscode;
  String? requeststatus;
  List<SupportUserJson> supportUsersJson = [];
  String? closedBy;
  String? closedbyprofileurl;
  String? createdLabel;
  String? assignedToUserProfileUrl;
  String? assignedFromProfileUrl;
  String? escalatedbyprofileimage;
  int? assignedFromId;
  String? statusLabel;
  String? iscriticalyn;
  String? assignedstatus;
  String? reftransaction;
  int? logid;
  DateTime? statusDate;

  List<ReqTrackJson> reqtrackjson = [];
  List<ScheduleTaskDtlJson> scheduletaskdtljson = [];
  List<AdditionalMaterialJson> additionalMaterialJson = [];
  List<CCUsers> ccUsers = [];
  List<MomDetail> momJson = [];

  SupportRequestFillModel({
    this.projectName,
    this.projectLocation,
    this.projectEndDate,
    required this.id,
    this.notificationbatchid,
    this.tableId,
    this.optionId,
    this.projectid,
    this.transNo,
    this.transDate,
    this.escalatedById,
    this.escalatedByName,
    this.requestDescription,
    this.dependencyDeptId,
    this.dependencyDeptName,
    this.targetClosureDate,
    this.remarks,
    this.requeststatus,
    this.rightsyn = true,
    this.assignedTo,
    this.assignedremarks,
    this.assignedFrom,
    this.assignedstatuscode,
    this.reqtrackjson = const [],
    this.supportUsersJson = const [],
    required this.closedBy,
    this.createdLabel,
    this.statusLabel,
    this.logid,
    this.assignedToUserProfileUrl,
    this.assignedFromProfileUrl,
    this.assignedFromId,
    this.statusDate,
    this.assignedToUserId,
    this.escalatedbyprofileimage,
    this.iscriticalyn,
    this.assignedstatus,
    this.reftransaction,
    this.reftabledataid,
    this.closedbyprofileurl,
    this.scheduletaskdtljson = const [],
    this.additionalMaterialJson = const [],
    this.momJson = const [],

  });

  SupportRequestFillModel.fromJson(Map<String, dynamic> json) {
    projectName = BaseJsonParser.goodString(json, 'projectname') ?? "";
    projectLocation = BaseJsonParser.goodString(json, 'projectlocation') ?? "";
    projectEndDate = BaseJsonParser.goodString(json, 'enddate') ?? "";
    reftransaction = BaseJsonParser.goodString(json, 'reftransaction') ?? "";
    closedbyprofileurl = BaseJsonParser.goodString(json, 'closedbyprofileurl') ?? "";
    id = BaseJsonParser.goodInt(json, 'id') ?? 0;
    logid = BaseJsonParser.goodInt(json, 'logid') ?? 0;
    reftabledataid = BaseJsonParser.goodInt(json, 'reftabledataid') ?? 0;
    notificationbatchid = BaseJsonParser.goodInt(json, 'notificationbatchid') ?? 0;
    tableId = BaseJsonParser.goodInt(json, 'tableid') ?? 0;
    transNo = BaseJsonParser.goodString(json, 'transno') ?? "";
    transDate = BaseJsonParser.goodString(json, 'transdate') ?? "";
    assignedstatus = BaseJsonParser.goodString(json, 'assignedstatus') ?? "";
    optionId = BaseJsonParser.goodInt(json, 'optionid') ?? 0;
    projectid = BaseJsonParser.goodInt(json, 'projectid') ?? 0;
    requestDescription = BaseJsonParser.goodString(json, 'requestdescription') ?? "";
    escalatedById = BaseJsonParser.goodInt(json, 'escalatedby') ?? 0;
    escalatedByName = BaseJsonParser.goodString(json, 'escalatedbyname') ?? "";
    dependencyDeptId = BaseJsonParser.goodInt(json, 'dependencydepartmentid') ?? 0;
    dependencyDeptName = BaseJsonParser.goodString(json, 'departmentname') ?? "";
    targetClosureDate = BaseJsonParser.goodString(json, 'targetclosuredate') ?? "";
    rightsyn = BaseJsonParser.goodBoolean(json, 'rightsyn');
    assignedFrom  = BaseJsonParser.goodString(json, 'assignedfrom');
    assignedFromId  = BaseJsonParser.goodInt(json, 'assignedfromid');
    assignedTo = BaseJsonParser.goodString(json, 'assignedto');
    iscriticalyn = BaseJsonParser.goodString(json, 'iscriticalyn');
    assignedToUserId = BaseJsonParser.goodInt(json, 'assignedtoid');
    assignedremarks = BaseJsonParser.goodString(json, 'assignedremarks');
    assignedstatuscode = BaseJsonParser.goodString(json, 'assignedstatuscode');
    requeststatus = BaseJsonParser.goodString(json, 'requeststatus');
    createdLabel = BaseJsonParser.goodString(json, 'createdlabel');
    statusLabel = BaseJsonParser.goodString(json, 'statuslabel');
    closedBy = BaseJsonParser.goodString(json, 'closedby');
    assignedToUserProfileUrl = BaseJsonParser.goodString(json, 'assignedtoprofileurl');
    assignedFromProfileUrl = BaseJsonParser.goodString(json, 'assignedfromprofileurl');
    statusDate = BaseJsonParser.goodDateTime(json, 'statusdate');
    escalatedbyprofileimage = BaseJsonParser.goodString(json, 'escalatedbyprofileimage');
    momJson = BaseJsonParser.goodList(json, 'momjson').map((e) => MomDetail.fromJson(e)).toList();
    if (json['ccuserjson'] != null) {
      ccUsers = (json['ccuserjson'] as List)
          .map((e) => CCUsers.fromJson(e))
          .toList();
    } else {
      ccUsers = [];
    }
    if (json['supportusersjson'] != null) {
      supportUsersJson = (json['supportusersjson'] as List)
          .map((e) => SupportUserJson.fromJson(e))
          .toList();
    } else {
      supportUsersJson = [];
    }
    //  Parse reqtrackjson list
    if (json['reqtrackjson'] != null) {
      reqtrackjson = (json['reqtrackjson'] as List)
          .map((e) => ReqTrackJson.fromJson(e))
          .toList();
    } else {
      reqtrackjson = [];
    }
    if (json['scheduletaskdtljson'] != null) {
      scheduletaskdtljson = (json['scheduletaskdtljson'] as List)
          .map((e) => ScheduleTaskDtlJson.fromJson(e))
          .toList();
    }
    if (json['additionalmaterialjson'] != null) {
      additionalMaterialJson = (json['additionalmaterialjson'] as List)
          .map((e) => AdditionalMaterialJson.fromJson(e))
          .toList();
    }
  }
}


class MomDetail {
  final int? id;
  final int? tableid;
  final String? meetingtitle;
  final String? datetime;
  final String? actionitem;

  MomDetail({
    this.id,
    this.tableid,
    this.meetingtitle,
    this.datetime,
    this.actionitem,
  });

  factory MomDetail.fromJson(Map<String, dynamic> json) {
    return MomDetail(
      id: BaseJsonParser.goodInt(json, 'id'),
      tableid: BaseJsonParser.goodInt(json, 'tableid'),
      meetingtitle: BaseJsonParser.goodString(json, 'meetingtitle'),
      datetime: BaseJsonParser.goodString(json, 'datetime'),
      actionitem: BaseJsonParser.goodString(json, 'actionitem'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tableid': tableid,
    'meetingtitle': meetingtitle,
    'datetime': datetime,
    'actionitem': actionitem,
  };
}

class CCUsers{
  int? userid;
  String? username;
  String? profileimage;
  String? addedbycreatoryn;

  CCUsers({this.addedbycreatoryn,this.profileimage,this.userid,this.username});
  CCUsers.fromJson(Map<String, dynamic> json){
    userid = BaseJsonParser.goodInt(json, 'userid')??0;
    username = BaseJsonParser.goodString(json, 'username')??'';
    profileimage = BaseJsonParser.goodString(json, 'profileimage')??'';
    addedbycreatoryn = BaseJsonParser.goodString(json, 'addedbycreatoryn')??"";
  }

  CCUsers copyWith({
    int? userid,
    String? username,
    String? profileimage,
    String? addedbycreatoryn,
  }) {
    return CCUsers(
      userid: userid ?? this.userid,
      username: username ?? this.username,
      profileimage: profileimage ?? this.profileimage,
      addedbycreatoryn: addedbycreatoryn ?? this.addedbycreatoryn,
    );
  }
}

class SupportUserJson {
  String name = "";
  String profileImage = "";
  String profileUrl="";

  SupportUserJson({required this.name, required this.profileImage,required this.profileUrl});

  SupportUserJson.fromJson(Map<String, dynamic> json) {
    name = BaseJsonParser.goodString(json, 'name') ?? "";
    profileImage = BaseJsonParser.goodString(json, 'profileimage') ?? "";
    profileUrl = BaseJsonParser.goodString(json, 'profileurl') ?? "";
  }
}

//  Sub-model for reqtrackjson
class ReqTrackJson {
  int? rowno;
  int? id;
  int? fromUserId;
  String? fromUser;
  int? toUserId;
  String? toUser;
  int? statusId;
  String status ='';
  String? statusDate;
  String? remarks;
  String? fromUserProfileUrl;
  String? toUserProfileUrl;
  String? escalatedbyprofileimageurl;

  ReqTrackJson({
    this.rowno,
    this.id,
    this.fromUserId,
    this.fromUser,
    this.toUserId,
    this.toUser,
    this.statusId,
    required this.status,
    this.statusDate,
    this.remarks,
    this.fromUserProfileUrl,
    this.toUserProfileUrl,
    this.escalatedbyprofileimageurl
  });

  ReqTrackJson.fromJson(Map<String, dynamic> json) {
    rowno = BaseJsonParser.goodInt(json, 'rowno') ?? 0;
    id = BaseJsonParser.goodInt(json, 'id') ?? 0;
    fromUserId = BaseJsonParser.goodInt(json, 'fromuserid') ?? 0;
    fromUser = BaseJsonParser.goodString(json, 'fromuser') ?? "";
    toUserId = BaseJsonParser.goodInt(json, 'touserid') ?? 0;
    toUser = BaseJsonParser.goodString(json, 'touser') ?? "";
    statusId = BaseJsonParser.goodInt(json, 'statusid') ?? 0;
    status = BaseJsonParser.goodString(json, 'status') ?? "";
    statusDate = BaseJsonParser.goodString(json, 'statusdate') ?? "";
    remarks = BaseJsonParser.goodString(json, 'remarks') ?? "";
    fromUserProfileUrl = BaseJsonParser.goodString(json, 'fromuserprofileurl');
    toUserProfileUrl = BaseJsonParser.goodString(json, 'touserprofileurl');
    escalatedbyprofileimageurl = BaseJsonParser.goodString(json, 'escalatedbyprofileimageurl');
  }
}



class ScheduleTaskDtlJson {
  int? id;
  int? tableid;
  int? taskid;
  String? taskname;
  String? plannedstartdate;
  String? plannedenddate;
  String? actualstartdate;
  String? actualfinishdate;
  double? completionperc;
  String? duration;
  int? uomid;
  int? statusid;
  String? statuscode;
  String? status;
  String? iscritical;
  int? taskuserid;
  String? taskuser;
  String? taskuserprofile;
  String? taskuserprofileurl;

  ScheduleTaskDtlJson({
    this.id,
    this.tableid,
    this.taskid,
    this.taskname,
    this.plannedstartdate,
    this.plannedenddate,
    this.actualstartdate,
    this.actualfinishdate,
    this.completionperc,
    this.duration,
    this.uomid,
    this.statusid,
    this.statuscode,
    this.status,
    this.iscritical,
    this.taskuserid,
    this.taskuser,
    this.taskuserprofile,
    this.taskuserprofileurl,
  });

  ScheduleTaskDtlJson.fromJson(Map<String, dynamic> json) {
    id = BaseJsonParser.goodInt(json, 'id') ?? 0;
    tableid = BaseJsonParser.goodInt(json, 'tableid') ?? 0;
    taskid = BaseJsonParser.goodInt(json, 'taskid') ?? 0;
    taskname = BaseJsonParser.goodString(json, 'taskname') ?? "";
    plannedstartdate = BaseJsonParser.goodString(json, 'plannedstartdate');
    plannedenddate = BaseJsonParser.goodString(json, 'plannedenddate');
    actualstartdate = BaseJsonParser.goodString(json, 'actualstartdate');
    actualfinishdate = BaseJsonParser.goodString(json, 'actualfinishdate');
    completionperc = BaseJsonParser.goodDouble(json, 'completionperc') ?? 0.0;
    duration = BaseJsonParser.goodString(json, 'duration') ?? "";
    uomid = BaseJsonParser.goodInt(json, 'uomid') ?? 0;
    statusid = BaseJsonParser.goodInt(json, 'statusid') ?? 0;
    statuscode = BaseJsonParser.goodString(json, 'statuscode') ?? "";
    status = BaseJsonParser.goodString(json, 'status') ?? "";
    iscritical = BaseJsonParser.goodString(json, 'iscritical') ?? "";
    taskuserid = BaseJsonParser.goodInt(json, 'taskuserid') ?? 0;
    taskuser = BaseJsonParser.goodString(json, 'taskuser') ?? "";
    taskuserprofile = BaseJsonParser.goodString(json, 'taskuserprofile') ?? "";
    taskuserprofileurl = BaseJsonParser.goodString(json, 'taskuserprofileurl') ?? "";
  }
}

class AdditionalMaterialJson {
  int? id;
  int? tableid;
  String? workitem;
  String? name;
  int? uomid;
  String? uom;
  double? qty;
  int? reasontypeid;
  String? reasontypecode;
  String? reasontype;
  String? reason;
  String? poissuedyn;
  String? poissueddate;
  String? requireddate;
  String? receivedqty;
  double? poissuedqty;

  AdditionalMaterialJson({
    this.id,
    this.tableid,
    this.workitem,
    this.name,
    this.uomid,
    this.uom,
    this.qty,
    this.reasontypeid,
    this.reasontypecode,
    this.reasontype,
    this.reason,
    this.poissuedyn,
    this.poissueddate,
    this.poissuedqty,
    this.requireddate,
    this.receivedqty,
  });

  AdditionalMaterialJson.fromJson(Map<String, dynamic> json) {
    id = BaseJsonParser.goodInt(json, 'id') ?? 0;
    tableid = BaseJsonParser.goodInt(json, 'tableid') ?? 0;
    workitem = BaseJsonParser.goodString(json, 'workitem') ?? "";
    name = BaseJsonParser.goodString(json, 'name') ?? "";
    uomid = BaseJsonParser.goodInt(json, 'uomid') ?? 0;
    uom = BaseJsonParser.goodString(json, 'uom') ?? "";
    qty = BaseJsonParser.goodDouble(json, 'qty') ?? 0.0;
    reasontypeid = BaseJsonParser.goodInt(json, 'reasontypeid') ?? 0;
    reasontypecode = BaseJsonParser.goodString(json, 'reasontypecode') ?? "";
    reasontype = BaseJsonParser.goodString(json, 'reasontype') ?? "";
    reason = BaseJsonParser.goodString(json, 'reason') ?? "";
    receivedqty = BaseJsonParser.goodString(json, 'receivedqty') ?? "";
    poissuedyn = BaseJsonParser.goodString(json, 'poissuedyn') ?? "";
    requireddate = BaseJsonParser.goodString(json, 'requireddate') ?? "";
    poissueddate = BaseJsonParser.goodString(json, 'poissueddate') ?? "";
    poissuedqty = BaseJsonParser.goodDouble(json, 'poissuedqty') ?? 0.0;
  }






}
