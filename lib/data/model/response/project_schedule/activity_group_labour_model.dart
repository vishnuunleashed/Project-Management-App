import 'package:base/data_export.dart';

class ActivityGroupLabourResponseModel extends BaseResponseModel{
  List<ActivityGroupLabourModel> activityGroupLabourList = [];

  ActivityGroupLabourResponseModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    // resultObject is List<List<dynamic>> in the provided JSON
    final outerList = BaseJsonParser.goodList(json, 'resultObject');
    if (outerList.isNotEmpty && outerList.first is List) {
      activityGroupLabourList = (outerList.first as List)
          .map((e) => ActivityGroupLabourModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }
}

class ActivityGroupLabourModel {
  int id = 0;
  String? code;
  String? description;

  ActivityGroupLabourModel({
    this.id = 0,
    this.code,
    this.description,
  });

  ActivityGroupLabourModel.fromJson(Map<String, dynamic> json) {
    id = BaseJsonParser.goodInt(json, 'id') ?? 0;
    code = BaseJsonParser.goodString(json, 'code');
    description = BaseJsonParser.goodString(json, 'description');
  }
}