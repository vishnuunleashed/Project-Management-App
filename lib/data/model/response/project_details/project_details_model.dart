
import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';

class ProjectDetailsHdrModel extends BaseResponseModel {
  List<ProjectDetailsModel> projectDetails = [];
  ProjectDetailsHdrModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    projectDetails = BaseJsonParser.goodList(json, 'resultObject')
        .map((e) => ProjectDetailsModel.fromJson(e))
        .toList();
  }
}

class ProjectDetailsModel {
  int? projectId;
  String? projectName;
  String? clientName;
  String? location;
  int? projectStatusId;
  String? projectStatus;
  DateTime? startDate;
  DateTime? endDate;
  String? delayTime;
  String? isActiveYn;
  int? openObsCount;
  int? delayObsCount;
  int? closeObsCount;
  int? openSupCount;
  int? delaySupCount;
  int? closeSupCount;
  String reportingToYN = "";
  bool siteInChargeYN = false;

  ProjectDetailsModel.fromJson(Map<String, dynamic> json) {
    projectId = BaseJsonParser.goodInt(json, 'id');
    projectName = BaseJsonParser.goodString(json, 'project');
    clientName = BaseJsonParser.goodString(json, 'client');
    location = BaseJsonParser.goodString(json, 'projectlocation');
    projectStatusId = BaseJsonParser.goodInt(json, 'projectstatusid');
    projectStatus = BaseJsonParser.goodString(json, 'projectstatus');
    startDate = BaseJsonParser.goodDateTime(json, 'projectstartdate');
    endDate = BaseJsonParser.goodDateTime(json, 'projectenddate');
    openObsCount = BaseJsonParser.goodInt(json, 'openobscount');
    delayObsCount = BaseJsonParser.goodInt(json, 'delayobscount');
    closeObsCount = BaseJsonParser.goodInt(json , 'closeobscount');
    openSupCount = BaseJsonParser.goodInt(json, 'opensupreqcount');
    delaySupCount = BaseJsonParser.goodInt(json, 'delaysupreqcount');
    closeSupCount = BaseJsonParser.goodInt(json, 'closesupreqcount');
    isActiveYn = BaseJsonParser.goodString(json, 'isactiveyn');
    reportingToYN = BaseJsonParser.goodString(json,'reportingtoyn') ?? "";
    siteInChargeYN = BaseJsonParser.goodString(json, 'siteinchargeyn') == "Y" ? true : false;
  }
}
