import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';

class ProjectGeoResponseModel extends BaseResponseModel {
  List<ProjectGeoResultObjectModel> locationList = [];

  ProjectGeoResponseModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    if (json["statusCode"] != 0) {
      locationList.add(ProjectGeoResultObjectModel.fromJson(json["resultObject"]));
    }
  }
}

class ProjectGeoResultObjectModel {
  int projectId = 0;
  double latitude = 0.0;
  double longitude = 0.0;
  double allowedRadiusMeters = 0.0;
  int geoTolerance = 0;
  String? projectName;
  String? allowaccessyn;

  ProjectGeoResultObjectModel();

  ProjectGeoResultObjectModel.fromJson(Map<String, dynamic> json) {
    projectId = BaseJsonParser.goodInt(json, 'projectId') ?? 0;
    latitude = BaseJsonParser.goodDouble(json, 'latitude') ?? 0.0;
    longitude = BaseJsonParser.goodDouble(json, 'longitude') ?? 0.0;
    allowedRadiusMeters =
        BaseJsonParser.goodDouble(json, 'allowedRadiusMeters') ?? 0.0;
    geoTolerance = BaseJsonParser.goodInt(json, 'geoTolerance') ?? 0;
    projectName = BaseJsonParser.goodString(json, 'projectName');
    allowaccessyn = BaseJsonParser.goodString(json, 'allowaccessyn')??"N";
  }
}
