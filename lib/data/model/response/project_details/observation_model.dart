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
import 'package:base/data_export.dart';
import 'package:intl/intl.dart';

class ObservationModel extends BaseResponseModel {
  List<ObservationDtlModel> observationList = [];


  ObservationModel.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    observationList = BaseJsonParser.goodList(json, 'resultObject')
        .map((e) => ObservationDtlModel.fromJson(e))
        .toList();
  }
}

class ObservationDtlModel {
  int? id;
  String? transNo;
  int? tableId;
  int? optionId;
  String? transDate;
  String? projectLocation;
  String? observerName;
  int? observerId;
  String? ownerName;
  String? points;
  String? observationStatusCode;
  String? observationStatus;
  String? remarks;
  DateTime? createdDateTime;
  List<AttachmentDetailObs>? attachmentJson;
  String? uploadPath;
  String? remainingTime;
  String? delayTime;
  int? totalRecords;
  String? projectName;
  int? projectId;
  int? logid;
  String? profileUrl;
  String? statusLabel;
  String? observationProfileUrl;
  String? ownerprofileurl;
  String? closedby;
  String? closedbyprofileurl;
  String? tocloseyn;
  String? observationstatuscode;
  DateTime? observationStatusDate;
  String? logstatuscode;
  String? assignedfromprofileurl;
  String? assignedfrom;
  String? assignedto;
  String? closingauthorityyn;
  String? activitygroup;
  int? activitygroupid;
  String? sourceoferror;
  int? sourceoferrorid;
  String? refoptionname;





  ObservationDtlModel.fromJson(Map<String, dynamic> json) {
    id = BaseJsonParser.goodInt(json, 'id');
    transNo = BaseJsonParser.goodString(json, 'transno');
    tableId = BaseJsonParser.goodInt(json, 'tableid');
    optionId = BaseJsonParser.goodInt(json, 'optionid');
    logid = BaseJsonParser.goodInt(json, 'logid');
    transDate = BaseJsonParser.goodString(json, 'transdate');
    tocloseyn = BaseJsonParser.goodString(json, 'tocloseyn');
    projectLocation = BaseJsonParser.goodString(json, 'projectlocation');
    observerName = BaseJsonParser.goodString(json, 'observername');
    observationstatuscode = BaseJsonParser.goodString(json, 'observationstatuscode');
    observerId = BaseJsonParser.goodInt(json, 'observerid');
    ownerName = BaseJsonParser.goodString(json, 'ownername');
    ownerprofileurl = BaseJsonParser.goodString(json, 'ownerprofileurl');
    closedby = BaseJsonParser.goodString(json, 'closedby');
    closedbyprofileurl = BaseJsonParser.goodString(json, 'closedbyprofileurl');
    points = BaseJsonParser.goodString(json, 'points');
    observationStatusCode = BaseJsonParser.goodString(json, 'observationstatuscode');
    observationStatus = BaseJsonParser.goodString(json, 'observationstatus');
    remarks = BaseJsonParser.goodString(json, 'remarks');
    createdDateTime = DateFormat("dd-MM-yyyy hh:mm:ss a").parse(json['createdtime']);
    uploadPath = BaseJsonParser.goodString(json, 'uploadpath');
    delayTime = BaseJsonParser.goodString(json, 'delayedtime');
    remainingTime = BaseJsonParser.goodString(json, 'remainingtime');
    projectName = BaseJsonParser.goodString(json, 'projectname');
    projectId = BaseJsonParser.goodInt(json,'projectid');
    totalRecords = BaseJsonParser.goodInt(json, 'totalrecords');
    profileUrl = BaseJsonParser.goodString(json, "profileurl");
    statusLabel = BaseJsonParser.goodString(json, 'statuslabel');
    assignedfromprofileurl = BaseJsonParser.goodString(json, 'assignedfromprofileurl');
    observationProfileUrl = BaseJsonParser.goodString(json, 'observerprofileurl');
    assignedfrom = BaseJsonParser.goodString(json, 'assignedfrom');
    assignedto = BaseJsonParser.goodString(json, 'assignedto');
    logstatuscode = BaseJsonParser.goodString(json, 'logstatuscode');
    closingauthorityyn = BaseJsonParser.goodString(json, 'closingauthorityyn');
    observationStatusDate = BaseJsonParser.goodDateTime(json, 'observationstatusdate');
    activitygroup = BaseJsonParser.goodString(json, 'activitygroup');
    activitygroupid = BaseJsonParser.goodInt(json, 'activitygroupid');
    sourceoferror = BaseJsonParser.goodString(json, 'sourceoferror');
    refoptionname = BaseJsonParser.goodString(json, 'refoptionname');
    sourceoferrorid = BaseJsonParser.goodInt(json, 'sourceoferrorid');
    attachmentJson = BaseJsonParser.goodList(json, 'attachmentjson').map((e) => AttachmentDetailObs.fromJson(e)).toList();
  }




}

class AttachmentDetailObs{
  String? attachmentName;
  String? attachmentPhysicalName;

  AttachmentDetailObs({this.attachmentName, this.attachmentPhysicalName});

  AttachmentDetailObs.fromJson(Map<String, dynamic> json){
    attachmentName = BaseJsonParser.goodString(json,'attachmentoriginalname');
    attachmentPhysicalName = BaseJsonParser.goodString(json, 'attachmentphysicalname');
  }

}