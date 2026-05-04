import 'dart:convert';

import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';

class TaskAttachmentResponseModel extends BaseResponseModel{
  List<TaskAttachmentModel> taskAttachmentList = [];
  TaskAttachmentResponseModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    taskAttachmentList = BaseJsonParser.goodList(json, 'resultObject')
        .map((e) => TaskAttachmentModel.fromJson(e))
        .toList();
  }
}

class TaskAttachmentModel {
  int? id;
  String? documentDate;
  String? remarks;
  String? filename;
  String? filePhysicalName;
  TaskAttachmentModel.fromJson(json){
    id = BaseJsonParser.goodInt(json, 'id');
    documentDate = BaseJsonParser.goodString(json,'documentdate' );
    remarks = BaseJsonParser.goodString(json, 'remarks');
    filename = BaseJsonParser.goodString(json, 'name');
    filePhysicalName = BaseJsonParser.goodString(json, 'physicalname');
  }
}