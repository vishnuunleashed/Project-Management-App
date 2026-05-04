import 'dart:convert';

import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data_export.dart';

class TaskTypeDropdownModel extends BaseResponseModel {
  List<TaskTypeDropdownDtlModel> taskTypeDropdownList = [];
  TaskTypeDropdownModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    taskTypeDropdownList = BaseJsonParser.goodList(json, 'resultObject')
        .map((e) => TaskTypeDropdownDtlModel.fromJson(e))
        .toList();
  }
}

class TaskTypeDropdownDtlModel {
  int? taskTypeId;
  String? taskTypeDescription;
  String? taskTypeCode;
  TaskTypeDropdownDtlModel.fromJson(json) {
    taskTypeId = BaseJsonParser.goodInt(json, 'id');
    taskTypeDescription = BaseJsonParser.goodString(json, 'description');
    taskTypeCode = BaseJsonParser.goodString(json, 'code');
  }
}
