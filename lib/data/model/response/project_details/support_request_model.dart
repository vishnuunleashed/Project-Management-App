/*------------------------------------------------------------------------------
AUTHOR		    : Shamnas Abdulla
CREATED DATE	: 11/08/2025
PURPOSE		    : Observation List
MODULE/TOPIC	:
REMARKS		    : IN008 - 25
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		    MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';
import 'package:intl/intl.dart';

class SupportRequestModel extends BaseResponseModel {
  List<SupportRequestDtlModel> supportRequestList = [];
  SupportRequestModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    supportRequestList = BaseJsonParser.goodList(json, 'resultObject')
        .map((e) => SupportRequestDtlModel.fromJson(e))
        .toList();
  }
}

class SupportRequestDtlModel {
  int? id;
  int? logid;
  String? transNo;
  String? refTransaction;
  int? tableId;
  DateTime? transDate;
  String? escalatedBy;
  String? points;
  DateTime? expectedClosureDate;
  String? closureDate;
  String? departmentName;
  String? remarks;
  int? totalRecords;
  String? remainingTime;
  String? delayedDays;
  DateTime? createdTime;
  String? delayedTime;
  String? requestStatusCode;
  String? projectName;
  String? transno;
  int? projectId;
  String? logFromUser;
  String? logToUser;
  String? logStatusCode;
  String? closedBy;
  String? closedByProfileUrl;
  String? logFromUserProfileUrl;
  String? logfromuserprofile;
  String? logToUserProfileUrl;
  String? escalatedByProfileUrl;
  String? statusLabel;
  DateTime? closedDate;
  int? scheduleTaskId;
  String? supportTypeCode;
  String? supportTypeDescription;
  String? notifyuseryn;
  String? addedbycreatoryn;
  String? iscriticalyn;
  String? refoptionname;
  String? sitename;
  String? clientname;


  SupportRequestDtlModel(
      {this.id,
      this.logid,
      this.transNo,
      this.tableId,
      this.transDate,
      this.escalatedBy,
      this.points,
      this.expectedClosureDate,
      this.closureDate,
      this.departmentName,
      this.remarks,
      this.totalRecords,
      this.remainingTime,
      this.delayedDays,
      this.createdTime,
      this.delayedTime,
      this.requestStatusCode,
      this.projectName,
      this.transno,
      this.projectId,
      this.logFromUser,
      this.logToUser,
      this.logStatusCode,
      this.closedBy,
      this.closedByProfileUrl,
      this.logFromUserProfileUrl,
      this.logToUserProfileUrl,
      this.escalatedByProfileUrl,
      this.statusLabel,
      this.closedDate,
      this.scheduleTaskId,
      this.supportTypeCode,
      this.supportTypeDescription,
      this.notifyuseryn,
      this.addedbycreatoryn,
      this.logfromuserprofile,
      this.refoptionname,
      this.refTransaction,
      this.iscriticalyn,
      this.sitename,
      this.clientname
      });

  SupportRequestDtlModel.fromJson(Map<String, dynamic> json) {
    id = BaseJsonParser.goodInt(json, 'id');
    logid = BaseJsonParser.goodInt(json, 'logid');
    transNo = BaseJsonParser.goodString(json, 'transno');
    clientname = BaseJsonParser.goodString(json, 'clientname');
    sitename = BaseJsonParser.goodString(json, 'sitename');
    transDate = BaseJsonParser.goodDateTime(json, 'transdate');
    escalatedBy = BaseJsonParser.goodString(json, 'escalatedby');
    points = BaseJsonParser.goodString(json, 'points');
    refoptionname = BaseJsonParser.goodString(json, 'refoptionname');
    refTransaction = BaseJsonParser.goodString(json, 'reftransaction');
    expectedClosureDate = BaseJsonParser.goodDateTime(json, 'expectedclosuredate');
    closureDate = BaseJsonParser.goodString(json, 'closuredate');
    departmentName = BaseJsonParser.goodString(json, 'departmentname');
    remarks = BaseJsonParser.goodString(json, 'remarks');
    totalRecords = BaseJsonParser.goodInt(json, 'totalrecords');
    remainingTime = BaseJsonParser.goodString(json, 'remainingtime');
    projectName = BaseJsonParser.goodString(json, 'projectname');
    transno = BaseJsonParser.goodString(json, 'transno');
    projectId = BaseJsonParser.goodInt(json, 'projectid');
    requestStatusCode = BaseJsonParser.goodString(json, 'requeststatuscode');
    logFromUser = BaseJsonParser.goodString(json, 'logfromuser');
    logToUser = BaseJsonParser.goodString(json, 'logtouser');
    logStatusCode = BaseJsonParser.goodString(json, 'logstatuscode');
    closedBy = BaseJsonParser.goodString(json, 'closedby');
    closedByProfileUrl = BaseJsonParser.goodString(json, 'closedbyprofileurl');
    logFromUserProfileUrl = BaseJsonParser.goodString(json, 'logfromuserprofileurl');
    logToUserProfileUrl = BaseJsonParser.goodString(json, 'logtouserprofileurl');
    escalatedByProfileUrl = BaseJsonParser.goodString(json, 'escalatedbyprofileurl');
    statusLabel = BaseJsonParser.goodString(json, 'statuslabel');
    closedDate = BaseJsonParser.goodDateTime(json, 'requeststatusdate');
    createdTime = DateFormat("dd-MM-yyyy hh:mm:ss a").parse(json['createdtime']);
    delayedTime = BaseJsonParser.goodString(json, 'delayedtime');
    scheduleTaskId = BaseJsonParser.goodInt(json, 'scheduletaskid');
    supportTypeCode = BaseJsonParser.goodString(json, 'supporttypecode');
    supportTypeDescription = BaseJsonParser.goodString(json, 'supporttypedesc');
    iscriticalyn = BaseJsonParser.goodString(json, 'iscriticalyn');
    notifyuseryn = BaseJsonParser.goodString(json, 'notifyuseryn');
    addedbycreatoryn = BaseJsonParser.goodString(json, 'addedbycreatoryn');
    logfromuserprofile = BaseJsonParser.goodString(json, 'logfromuserprofile');


  }






  String formatDelayDays(String escalatedDate) {
    final DateTime escalated = DateTime.parse(escalatedDate);
    final DateTime today = DateTime.now();

    final int difference = today.difference(escalated).inDays;

    if (difference <= 0) {
      return "Today";
    } else if (difference == 1) {
      return "1 day ago";
    } else {
      return "$difference days ago";
    }
  }

  SupportRequestDtlModel copyWith({
    int? id,
    String? transNo,
    int? tableId,
    DateTime? transDate,
    String? escalatedBy,
    String? points,
    DateTime? expectedClosureDate,
    String? closureDate,
    String? departmentName,
    String? remarks,
    int? totalRecords,
    String? remainingTime,
    String? delayedDays,
    DateTime? createdTime,
    String? delayedTime,
    String? requestStatusCode,
    String? projectName,
    int? projectId,
    String? logFromUser,
    String? logToUser,
    String? logStatusCode,
    String? closedBy,
    String? closedByProfileUrl,
    String? logFromUserProfileUrl,
    String? logToUserProfileUrl,
    String? escalatedByProfileUrl,
    String? statusLabel,
    DateTime? closedDate,
    int? scheduleTaskId,
    String? supportTypeCode,
    String? supportTypeDescription,
    String? notifyuseryn,
    String? addedbycreatoryn,
    String? iscriticalyn,
    String? logfromuserprofile,
  }) {
    return SupportRequestDtlModel(
      id: id ?? this.id,
      transNo: transNo ?? this.transNo,
      tableId: tableId ?? this.tableId,
      transDate: transDate ?? this.transDate,
      escalatedBy: escalatedBy ?? this.escalatedBy,
      points: points ?? this.points,
      expectedClosureDate: expectedClosureDate ?? this.expectedClosureDate,
      closureDate: closureDate ?? this.closureDate,
      departmentName: departmentName ?? this.departmentName,
      remarks: remarks ?? this.remarks,
      totalRecords: totalRecords ?? this.totalRecords,
      remainingTime: remainingTime ?? this.remainingTime,
      delayedDays: delayedDays ?? this.delayedDays,
      createdTime: createdTime ?? this.createdTime,
      delayedTime: delayedTime ?? this.delayedTime,
      requestStatusCode: requestStatusCode ?? this.requestStatusCode,
      projectName: projectName ?? this.projectName,
      projectId: projectId ?? this.projectId,
      logFromUser: logFromUser ?? this.logFromUser,
      logToUser: logToUser ?? this.logToUser,
      logStatusCode: logStatusCode ?? this.logStatusCode,
      closedBy: closedBy ?? this.closedBy,
      closedByProfileUrl: closedByProfileUrl ?? this.closedByProfileUrl,
      logFromUserProfileUrl:
          logFromUserProfileUrl ?? this.logFromUserProfileUrl,
      logToUserProfileUrl: logToUserProfileUrl ?? this.logToUserProfileUrl,
      escalatedByProfileUrl:
          escalatedByProfileUrl ?? this.escalatedByProfileUrl,
      statusLabel: statusLabel ?? this.statusLabel,
      closedDate: closedDate ?? this.closedDate,
      scheduleTaskId: scheduleTaskId ?? this.scheduleTaskId,
      supportTypeCode: supportTypeCode ?? this.supportTypeCode,
      supportTypeDescription:
          supportTypeDescription ?? this.supportTypeDescription,
      notifyuseryn: notifyuseryn ?? this.notifyuseryn,
      addedbycreatoryn: addedbycreatoryn ?? this.addedbycreatoryn,
      iscriticalyn: iscriticalyn ?? this.iscriticalyn,
      logfromuserprofile: logfromuserprofile ?? this.logfromuserprofile,
    );
  }
}
