import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';

class ProjectRoleOptionResponseModel extends BaseResponseModel {
  List<ProjectRoleOptionModel> resultObject = [];

  ProjectRoleOptionResponseModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    resultObject = BaseJsonParser.goodList(json, 'resultObject')
        .map((e) => ProjectRoleOptionModel.fromJson(e))
        .toList();
  }
}
class ProjectRoleOptionModel {
  int? optionid;
  int? subtypeid;
  String? matchtype;

  ProjectRoleOptionModel({
    this.optionid = 0,
    this.subtypeid = 0,
    this.matchtype = '',
  });

  factory ProjectRoleOptionModel.fromJson(Map<String, dynamic> json) {
    return ProjectRoleOptionModel(
      optionid: BaseJsonParser.goodInt(json, 'optionid'),
      subtypeid: BaseJsonParser.goodInt(json, 'subtypeid'),
      matchtype: BaseJsonParser.goodString(json, 'matchtype'),
    );
  }
}


