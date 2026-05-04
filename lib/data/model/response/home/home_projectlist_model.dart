/*------------------------------------------------------------------------------
AUTHOR		    : Aswani Mohan
CREATED DATE	: 07/08/2025
PURPOSE		    :
MODULE/TOPIC	:
REMARKS		    :
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------*/
import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';
import 'package:interior_design/data/model/response/project_location/user_status.dart';

class HomeDashboardWrapper extends BaseResponseModel {
  List<HomeProjectListModel> projectList = [];
  List<UserRightsModel> userRights = [];

  HomeDashboardWrapper.fromJson(Map<String, dynamic> parsedJson)
      : super.fromJson(parsedJson) {
    final resultObject = parsedJson['resultObject'];

    if (resultObject is List && resultObject.isNotEmpty) {
      final firstItem = (resultObject.first as Map<String, dynamic>? ?? {});

      projectList = (firstItem['projectlist'] as List<dynamic>? ?? [])
          .map((item) => HomeProjectListModel.fromJson(item))
          .toList();

      userRights = (firstItem['rightsjson'] as List<dynamic>? ?? [])
          .map((item) => UserRightsModel.fromJson(item))
          .toList();
    }
  }
}

class HomeProjectListModel {
  final int? rowNo;
  final int? projectId;
  final String? project;
  final String? latitude;
  final String? longitude;
  final String? radius;
  final String? projectLocation;
  final String? projectStatus;
  final DateTime? projectEndDate;
   int? pendingObservation;
   int? pendingSupportReq;
  final int? totalRecords;
  final bool projectscheduleyn;
  final bool materialchartyn;
  int? rootFolderId;

  List<SignInResultObjectModel> signInStatusList = [];
  bool isSignedIn = false;

  HomeProjectListModel({
    this.rowNo,
    this.projectId,
    this.project,
    this.projectLocation,
    this.projectStatus,
    this.projectEndDate,
    this.pendingObservation,
    this.pendingSupportReq,
    this.totalRecords,
    this.projectscheduleyn = false,
    this.materialchartyn = false,
    this.isSignedIn =false,
    this.signInStatusList = const [],
    this.latitude,
    this.longitude,
    this.radius,
    this.rootFolderId,
  });




  factory HomeProjectListModel.fromJson(Map<String, dynamic> json) {
    return HomeProjectListModel(
      rowNo: BaseJsonParser.goodInt(json, 'rowno'),
      projectId: BaseJsonParser.goodInt(json, 'projectid'),
      project: BaseJsonParser.goodString(json, 'project'),
      latitude: BaseJsonParser.goodString(json, 'latitude'),
      longitude: BaseJsonParser.goodString(json, 'longitude'),
      radius: BaseJsonParser.goodString(json, 'radius'),
      projectLocation: BaseJsonParser.goodString(json, 'projectlocation'),
      projectStatus: BaseJsonParser.goodString(json, 'projectstatus'),
      projectEndDate: BaseJsonParser.goodDateTime(json, 'projectenddate'),
      pendingObservation: BaseJsonParser.goodInt(json, 'pendingobservation'),
      pendingSupportReq: BaseJsonParser.goodInt(json, 'pendingsupportreq'),
      totalRecords: BaseJsonParser.goodInt(json, 'totalrecords'),
      projectscheduleyn: BaseJsonParser.goodBoolean(json, 'projectscheduleyn'),
      materialchartyn: BaseJsonParser.goodBoolean(json, 'materialchartyn'),
      rootFolderId: BaseJsonParser.goodInt(json, 'rootfolderid'),
    );
  }


  HomeProjectListModel copyWith({
    int? rowNo,
    int? projectId,
    String? project,
    String? latitude,
    String? longitude,
    String? radius,
    String? projectLocation,
    String? projectStatus,
    DateTime? projectEndDate,
    int? pendingObservation,
    int? pendingSupportReq,
    int? totalRecords,
    bool? projectscheduleyn,
    List<SignInResultObjectModel>? signInStatusList,
    bool? isSignedIn,
    bool? materialchartyn,
    int? rootFolderId,
  }) {
    return HomeProjectListModel(
      rowNo: rowNo ?? this.rowNo,
      projectId: projectId ?? this.projectId,
      project: project ?? this.project,
      projectLocation: projectLocation ?? this.projectLocation,
      projectStatus: projectStatus ?? this.projectStatus,
      projectEndDate: projectEndDate ?? this.projectEndDate,
      pendingObservation: pendingObservation ?? this.pendingObservation,
      pendingSupportReq: pendingSupportReq ?? this.pendingSupportReq,
      totalRecords: totalRecords ?? this.totalRecords,
      projectscheduleyn: projectscheduleyn ?? this.projectscheduleyn,
      signInStatusList: signInStatusList ?? this.signInStatusList,
      isSignedIn: isSignedIn ?? this.isSignedIn,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      materialchartyn: materialchartyn ?? this.materialchartyn,
      rootFolderId: rootFolderId??this.rootFolderId,
    );
  }




}

class UserRightsModel {
  final String? optionCode;
  final String? optionName;
  final List<RightsDataModel> rightsData;

  UserRightsModel({
    this.optionCode,
    this.optionName,
    this.rightsData = const [],
  });

  factory UserRightsModel.fromJson(Map<String, dynamic> json) {
    final rightsObj = json['Rights'] as Map<String, dynamic>? ?? {};
    return UserRightsModel(
      optionCode: BaseJsonParser.goodString(rightsObj, 'optioncode'),
      optionName: BaseJsonParser.goodString(rightsObj, 'optionname'),
      rightsData: (rightsObj['rights_data'] as List<dynamic>? ?? [])
          .map((item) => RightsDataModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'optioncode': optionCode,
    'optionname': optionName,
    'rights_data': rightsData.map((e) => e.toJson()).toList(),
  };
}

class RightsDataModel {
  final int? optionId;
  final String? addRightSyn;
  final String? editRightSyn;
  final String? viewRightSyn;
  final String? allowAccessYn;
  final String? printRightSyn;
  final String? deleteRightSyn;
  final int? parentOptionId;

  RightsDataModel({
    this.optionId,
    this.addRightSyn,
    this.editRightSyn,
    this.viewRightSyn,
    this.allowAccessYn,
    this.printRightSyn,
    this.deleteRightSyn,
    this.parentOptionId,
  });

  factory RightsDataModel.fromJson(Map<String, dynamic> json) {
    return RightsDataModel(
      optionId: BaseJsonParser.goodInt(json, 'optionid'),
      addRightSyn: BaseJsonParser.goodString(json, 'addrightsyn'),
      editRightSyn: BaseJsonParser.goodString(json, 'editrightsyn'),
      viewRightSyn: BaseJsonParser.goodString(json, 'viewrightsyn'),
      allowAccessYn: BaseJsonParser.goodString(json, 'allowaccessyn'),
      printRightSyn: BaseJsonParser.goodString(json, 'printrightsyn'),
      deleteRightSyn: BaseJsonParser.goodString(json, 'deleterightsyn'),
      parentOptionId: BaseJsonParser.goodInt(json, 'parentoptionid'),
    );
  }

  Map<String, dynamic> toJson() => {
    'optionid': optionId,
    'addrightsyn': addRightSyn,
    'editrightsyn': editRightSyn,
    'viewrightsyn': viewRightSyn,
    'allowaccessyn': allowAccessYn,
    'printrightsyn': printRightSyn,
    'deleterightsyn': deleteRightSyn,
    'parentoptionid': parentOptionId,
  };
}
