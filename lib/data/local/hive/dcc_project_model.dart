import 'package:dcc_module/core/dcc_json_parser.dart';

class DccProjectModel {
  final int? projectId;
  final String? projectName;
  final String? location;
  final DateTime? endDate;
  int? rootFolderId;

  DccProjectModel({
    this.projectId,
    this.projectName,
    this.location,
    this.endDate,
    this.rootFolderId,
  });

  factory DccProjectModel.fromJson(Map<String, dynamic> json) {
    return DccProjectModel(
      projectId: DccJsonParser.goodInt(json, 'projectId')
          ?? DccJsonParser.goodInt(json, 'projectid'),
      projectName: DccJsonParser.goodString(json, 'projectName')
          ?? DccJsonParser.goodString(json, 'project'),
      location: DccJsonParser.goodString(json, 'location')
          ?? DccJsonParser.goodString(json, 'projectlocation'),
      endDate: DccJsonParser.goodDateTime(json, 'endDate')
          ?? DccJsonParser.goodDateTime(json, 'projectenddate'),
      rootFolderId: DccJsonParser.goodInt(json, 'rootFolderId')
          ?? DccJsonParser.goodInt(json, 'rootfolderid'),
    );
  }

  Map<String, dynamic> toJson() => {
    'projectId': projectId,
    'projectName': projectName,
    'location': location,
    'endDate': endDate?.toIso8601String(),
    'rootFolderId': rootFolderId,
  };
}
