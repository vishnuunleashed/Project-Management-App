/*------------------------------------------------------------------------------
AUTHOR		    : Favas k
CREATED DATE	: 09/08/2025
PURPOSE		    :
MODULE/TOPIC	: IN0010-25
REMARKS		    :
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		    MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/models/response/image_upload_response.dart';
import 'package:base/data/services/utils/base_json_parser.dart';
import 'package:intl/intl.dart';


class StatusModelResponse extends BaseResponseModel {
  List<StatusModel> statusResponse = [];

  StatusModelResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    statusResponse = BaseJsonParser.goodList(json, 'resultObject')
        .map((e) => StatusModel.fromJson(e))
        .toList();
  }
}

class StatusModel extends BaseResponseModel {
  int? id;
  int? sortOrder;
  String? description;
  String? code;
  String? name;

  StatusModel({this.id, this.description, this.code});

  StatusModel.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    id = BaseJsonParser.goodInt(json, 'id');
    sortOrder = BaseJsonParser.goodInt(json, 'sortorder');
    description = BaseJsonParser.goodString(json, 'description');
    code = BaseJsonParser.goodString(json, 'code');
    name = BaseJsonParser.goodString(json, 'name');
  }



}

class ObservationResponse extends BaseResponseModel {
  List<ObservationDetailModel> observationDetail;

  ObservationResponse({required this.observationDetail});

  factory ObservationResponse.fromJson(Map<String, dynamic> json) {
    return ObservationResponse(
      observationDetail: BaseJsonParser.goodList(json, 'resultObject')
          .map((e) => ObservationDetailModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'statusCode': statusCode,
    'statusMessage': statusMessage,
    'resultObject': observationDetail.map((e) => e.toJson()).toList(),
  };
}

class ObservationDetailModel {
  final String? projectname;
  final String? projectlocation;
  final String? projectenddate;
  final int? projectid;
  final int? id;
  final int? tableid;
  final int? optionid;
  final String? transno;
  final String? transdate;
  final int? observerid;
  final String observername;
  final String? ownername;
  final String observerprofileurl;
  final String ownerprofileurl;
  final String? closedByProfileUrl;
  final String? closedBy;
  final String? observationpoints;
  final int? ownerid;
  final String? remarks;
  final String? submittedremarks;
  final bool rightsyn;
  final List<AttachedDoc>? attachmentjson;
  final String? uploadpath;
  final int? statusid;
  final int? notificationid;
  final int? logid;
  final String formattedDateTransDate;
  final String? observationstatuscode;
  final String? profileUrl;
  final String? requestStatus;
  final String? createdLabel;
  final String? statusLabel;
  final String? tocloseyn;
  final String? displayprofile;
  final String? displayprofilename;
  final String? observationStatusDate;
  final String? closingauthorityyn;
  final String? logstatuscode;
  final String? assignedto;
  final String? activitygroup;
  final int? activitygroupid;
  final String? sourceoferror;
  final int? sourceoferrorid;
  final List<MomDetail>? momJson;

  ObservationDetailModel({
    this.projectname,
    this.rightsyn = true,
    this.projectlocation,
    this.projectenddate,
    this.id,
    this.tableid,
    this.optionid,
    this.transno,
    this.transdate,
    this.observerid,
    this.observername="",
    this.observerprofileurl="",
    this.ownerprofileurl="",
    this.ownername,
    this.observationpoints,
    this.ownerid,
    this.remarks,
    this.submittedremarks,
    this.attachmentjson,
    this.uploadpath,
    this.statusid,
    this.notificationid,
    this.projectid,
    this.formattedDateTransDate= "",
    this.observationstatuscode,
    this.profileUrl,
    this.requestStatus,
    this.createdLabel,
    this.statusLabel,
    this.closedByProfileUrl,
    this.closedBy,
    this.observationStatusDate,
    this.tocloseyn,
    this.displayprofile,
    this.displayprofilename,
    this.closingauthorityyn,
    this.logstatuscode,
    this.logid,
    this.assignedto,
    this.activitygroup,
    this.activitygroupid,
    this.sourceoferror,
    this.sourceoferrorid,
    this.momJson

  });

  factory ObservationDetailModel.fromJson(Map<String, dynamic> json) {
    String rawDate = json['transdate'] ?? DateTime.now().toString(); // String
    final parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();

    String formattedDate;
    if (parsedDate.year == DateTime.now().year) {
      // Same year → don't show year
      formattedDate = DateFormat.MMMd().format(parsedDate); // e.g. Sep 12
    } else {
      // Different year → show year
      formattedDate = DateFormat.yMMMd().format(parsedDate); // e.g. Sep 12, 2024
    }

    return ObservationDetailModel(
      formattedDateTransDate: formattedDate,
      projectname: BaseJsonParser.goodString(json, 'projectname'),
      projectlocation: BaseJsonParser.goodString(json, 'projectlocation'),
      projectenddate: BaseJsonParser.goodString(json, 'projectenddate'),
      id: BaseJsonParser.goodInt(json, 'id'),
      tableid: BaseJsonParser.goodInt(json, 'tableid'),
      optionid: BaseJsonParser.goodInt(json, 'optionid'),
      logid: BaseJsonParser.goodInt(json, 'logid'),
      transno: BaseJsonParser.goodString(json, 'transno'),
      displayprofile: BaseJsonParser.goodString(json, 'displayprofile'),
      assignedto: BaseJsonParser.goodString(json, 'assignedto'),
      displayprofilename: BaseJsonParser.goodString(json, 'displayprofilename'),
      tocloseyn: BaseJsonParser.goodString(json, 'tocloseyn'),
      observerprofileurl: BaseJsonParser.goodString(json, 'observerprofileurl')??'',
      ownerprofileurl: BaseJsonParser.goodString(json, 'ownerprofileurl')??'',
      transdate: BaseJsonParser.goodString(json, 'transdate'),
      observerid: BaseJsonParser.goodInt(json, 'observerid'),
      observationstatuscode: BaseJsonParser.goodString(json, 'observationstatuscode'),
      observername: BaseJsonParser.goodString(json, 'observername')??"",
      observationpoints: BaseJsonParser.goodString(json, 'observationpoints'),
      ownername: BaseJsonParser.goodString(json, 'ownername'),
      ownerid: BaseJsonParser.goodInt(json, 'ownerid'),
      remarks: BaseJsonParser.goodString(json, 'remarks'),
      statusid: BaseJsonParser.goodInt(json, 'statusid'),
      rightsyn: BaseJsonParser.goodBoolean(json, 'rightsyn'),
      projectid: BaseJsonParser.goodInt(json, 'projectid')??0,
      notificationid: BaseJsonParser.goodInt(json, 'notificationid'),
      profileUrl: BaseJsonParser.goodString(json, 'ownerprofileurl'),
      closedBy: BaseJsonParser.goodString(json, 'closedby'),
      submittedremarks: BaseJsonParser.goodString(json, 'submittedremarks'),
      closedByProfileUrl: BaseJsonParser.goodString(json, 'closedbyprofileurl'),
      requestStatus: BaseJsonParser.goodString(json, 'requeststatus'),
      createdLabel: BaseJsonParser.goodString(json, 'createdlabel'),
      statusLabel: BaseJsonParser.goodString(json, 'statuslabel'),
      closingauthorityyn: BaseJsonParser.goodString(json, 'closingauthorityyn'),
      logstatuscode: BaseJsonParser.goodString(json, 'logstatuscode'),
      observationStatusDate: BaseJsonParser.goodString(json, 'observationstatusdate'),
      activitygroup: BaseJsonParser.goodString(json, 'activitygroup'),
      activitygroupid: BaseJsonParser.goodInt(json, 'activitygroupid'),
      sourceoferror: BaseJsonParser.goodString(json, 'sourceoferror'),
      sourceoferrorid: BaseJsonParser.goodInt(json, 'sourceoferrorid'),
      attachmentjson: json['attachmentjson'] is List
          ? (json['attachmentjson'] as List)
          .map((e) => AttachedDoc.fromJson(e as Map<String, dynamic>))
          .toList()
          : null,
      uploadpath: BaseJsonParser.goodString(json, 'uploadpath'),
      momJson: BaseJsonParser.goodList(json, 'momjson').map((e) => MomDetail.fromJson(e)).toList()
    );
  }

  Map<String, dynamic> toJson() => {
    'projectname': projectname,
    'projectlocation': projectlocation,
    'projectenddate': projectenddate,
    'id': id,
    'tableid': tableid,
    'optionid': optionid,
    'transno': transno,
    'transdate': transdate,
    'observerid': observerid,
    'observername': observername,
    'ownername': ownername,
    'observationpoints': observationpoints,
    'ownerid': ownerid,
    'remarks': remarks,
    'attachmentjson': attachmentjson?.map((e) => e.toJson()).toList(),
    'uploadpath': uploadpath,
    'statusid': statusid
  };
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

class AttachmentJson {
  final String? documentname;
  final List<AttachedDoc>? attacheddocs;

  AttachmentJson({
    this.documentname,
    this.attacheddocs,
  });

  factory AttachmentJson.fromJson(Map<String, dynamic> json) {
    return AttachmentJson(
      documentname: json['documentname'] as String?,
      attacheddocs: json['attacheddocs'] is List
          ? (json['attacheddocs'] as List)
          .map((e) => AttachedDoc.fromJson(e as Map<String, dynamic>))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'documentname': documentname,
    'attacheddocs': attacheddocs?.map((e) => e.toJson()).toList(),
  };
}

class AttachedDoc {
  final String? attachmentoriginalname;
  final String? code;
  final String? attachmentphysicalname;

  AttachedDoc({
    this.attachmentoriginalname,
    this.attachmentphysicalname,
    this.code,
  });

  factory AttachedDoc.fromJson(Map<String, dynamic> json) {
    return AttachedDoc(
      attachmentoriginalname: json['attachmentoriginalname'] as String?,
      attachmentphysicalname: json['attachmentphysicalname'] as String?,
      code: json['code'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'attachmentoriginalname': attachmentoriginalname,
    'attachmentphysicalname': attachmentphysicalname,
    'code': code,
  };
}

