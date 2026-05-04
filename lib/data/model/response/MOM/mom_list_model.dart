/*------------------------------------------------------------------------------
AUTHOR		    : Shamnas Abdulla
CREATED DATE	: 04/16/2026
PURPOSE		    :
MODULE/TOPIC	:
REMARKS		    : MOM option
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		    MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';
import 'package:interior_design/data/model/response/project_details/observation_model.dart';
import 'package:interior_design/data/model/response/project_details/support_request_model.dart';

class MOMListResponseModel extends BaseResponseModel {
  List<MOMListModel> momList = [];

  MOMListResponseModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    momList = BaseJsonParser.goodList(json, 'resultObject')
        .map((e) => MOMListModel.fromJson(e))
        .toList();
  }
}

class MOMListModel {
  int? id;
  int? companyId;
  int? optionId;
  int? projectId;
  String? meetingTitle;
  int? meetingTypeId;
  String? meetingTypeName;
  String? dateTime;
  String? location;
  String? onlineLink;
  String? discussionPoint;
  String? externalUsers;
  String? externalUserEmails;
  String? decisionTaken;
  String? createdByUser;

  List<MOMDetailModel> moMDtls = [];
  List<MOMAttendeeModel> moMAttendeesDtls = [];

  MOMListModel.fromJson(Map<String, dynamic> json) {
    id = BaseJsonParser.goodInt(json, 'id');
    companyId = BaseJsonParser.goodInt(json, 'companyId');
    optionId = BaseJsonParser.goodInt(json, 'optionId');
    projectId = BaseJsonParser.goodInt(json, 'projectId');
    meetingTitle = BaseJsonParser.goodString(json, 'meetingTitle');
    meetingTypeId = BaseJsonParser.goodInt(json, 'meetingTypeId');
    meetingTypeName = BaseJsonParser.goodString(json, 'meetingTypeName');
    dateTime = BaseJsonParser.goodString(json, 'dateTime');
    location = BaseJsonParser.goodString(json, 'location');
    onlineLink = BaseJsonParser.goodString(json, 'onlineLink');
    discussionPoint = BaseJsonParser.goodString(json, 'discussionPoint');
    externalUsers = BaseJsonParser.goodString(json, 'externalUsers');
    externalUserEmails = BaseJsonParser.goodString(json, 'externalUserEmails');
    decisionTaken = BaseJsonParser.goodString(json, 'decisionTaken');
    createdByUser = BaseJsonParser.goodString(json, 'lastModUserName');

    moMDtls = BaseJsonParser.goodList(json, 'moMDtls')
        .map((e) => MOMDetailModel.fromJson(e))
        .toList();

    moMAttendeesDtls = BaseJsonParser.goodList(json, 'moMAttendeesDtls')
        .map((e) => MOMAttendeeModel.fromJson(e))
        .toList();
  }
}

class MOMDetailModel {
  int? id;
  String? actionItem;
  int? ownerId;
  String? ownerName;
  int? refOptionId;

  List<ObservationDetailModel> observationDetails = [];
  List<SupportRequestDtlModel> supportRequestDetails = [];

  MOMDetailModel.fromJson(Map<String, dynamic> json) {
    id = BaseJsonParser.goodInt(json, 'id');
    actionItem = BaseJsonParser.goodString(json, 'actionItem');
    ownerId = BaseJsonParser.goodInt(json, 'ownerId');
    ownerName = BaseJsonParser.goodString(json, 'ownerName');
    refOptionId = BaseJsonParser.goodInt(json, 'refOptionId');

    observationDetails = BaseJsonParser.goodList(json, 'observationDetails')
        .map((e) => ObservationDetailModel.fromJson(e))
        .toList();

    // supportRequestDetails = BaseJsonParser.goodList(json, 'supportRequestDetails')
    //     .map((e) => SupportRequestDtlModel.fromJson(e))
    //     .toList();
  }
}

class MOMAttendeeModel {
  int? id;
  int? userId;
  String? userName;

  MOMAttendeeModel.fromJson(Map<String, dynamic> json) {
    id = BaseJsonParser.goodInt(json, 'id');
    userId = BaseJsonParser.goodInt(json, 'userId');
    userName = BaseJsonParser.goodString(json, 'userName');
  }
}

class ObservationDetailModel {
  int? id;
  int? optionId;
  String? transNo;
  String? transDate;
  int? observerId;
  int? projectId;
  String? observationPoints;
  int? ownerId;
  int? observationStatusId;
  String? observationStatusDate;

  String? from;
  int? fromId;
  String? remarks;
  int? activityGroupId;
  int? sourceOfErrorId;

  ObservationDetailModel.fromJson(Map<String, dynamic> json) {
    id = BaseJsonParser.goodInt(json, 'id');
    optionId = BaseJsonParser.goodInt(json, 'optionid');
    transNo = BaseJsonParser.goodString(json, 'transno');
    transDate = BaseJsonParser.goodString(json, 'transdate');
    observerId = BaseJsonParser.goodInt(json, 'observerid');
    projectId = BaseJsonParser.goodInt(json, 'projectid');
    observationPoints = BaseJsonParser.goodString(json, 'observationpoints');
    ownerId = BaseJsonParser.goodInt(json, 'ownerid');
    observationStatusId = BaseJsonParser.goodInt(json, 'observationstatusid');
    observationStatusDate = BaseJsonParser.goodString(json, 'observationstatusdate');

    from = BaseJsonParser.goodString(json, 'from');
    fromId = BaseJsonParser.goodInt(json, 'fromid');
    remarks = BaseJsonParser.goodString(json, 'remarks');
    activityGroupId = BaseJsonParser.goodInt(json, 'activitygroupid');
    sourceOfErrorId = BaseJsonParser.goodInt(json, 'sourceoferrorid');
  }
}

class SupportRequestDetailModel {
  int? id;
  int? optionId;
  String? transNo;
  String? transDate;
  String? requestDescription;
  int? projectId;
  int? escalatedBy;
  String? targetClosureDate;
  int? requestStatusId;
  String? statusDate;
  bool? isCritical;

  SupportRequestDetailModel.fromJson(Map<String, dynamic> json) {
    id = BaseJsonParser.goodInt(json, 'id');
    optionId = BaseJsonParser.goodInt(json, 'optionid');
    transNo = BaseJsonParser.goodString(json, 'transno');
    transDate = BaseJsonParser.goodString(json, 'transdate');
    requestDescription = BaseJsonParser.goodString(json, 'requestdescription');
    projectId = BaseJsonParser.goodInt(json, 'projectid');
    escalatedBy = BaseJsonParser.goodInt(json, 'escalatedby');
    targetClosureDate = BaseJsonParser.goodString(json, 'targetclosuredate');
    requestStatusId = BaseJsonParser.goodInt(json, 'requeststatusid');
    statusDate = BaseJsonParser.goodString(json, 'statusdate');
    isCritical = json['iscritical'];
  }
}