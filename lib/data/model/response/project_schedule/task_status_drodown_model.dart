import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';

class TaskStatusDropdownModel extends BaseResponseModel {
  List<TaskStatusDropdownDtlModel> taskStatusDropdownList = [];
  TaskStatusDropdownModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    taskStatusDropdownList = BaseJsonParser.goodList(json, 'resultObject')
        .map((e) => TaskStatusDropdownDtlModel.fromJson(e))
        .toList();
  }
}

class TaskStatusDropdownDtlModel {
  int? taskStatusId;
  String? taskStatusDescription;
  String? taskStatusCode;
  TaskStatusDropdownDtlModel.fromJson(json) {
    taskStatusId = BaseJsonParser.goodInt(json, 'id');
    taskStatusDescription = BaseJsonParser.goodString(json, 'description');
    taskStatusCode = BaseJsonParser.goodString(json, 'code');
  }
}
