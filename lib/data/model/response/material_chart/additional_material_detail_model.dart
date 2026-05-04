import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';
import 'package:interior_design/data/model/response/material_chart/additional_material_chart_model.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';

// Material Request Header DTO
class MaterialRequestHdrModel extends BaseResponseModel {
  List<MaterialRequestModel> requests = [];

  MaterialRequestHdrModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    requests = BaseJsonParser.goodList(json, 'resultObject')
        .map((e) => MaterialRequestModel.fromJson(e))
        .toList();
  }
}