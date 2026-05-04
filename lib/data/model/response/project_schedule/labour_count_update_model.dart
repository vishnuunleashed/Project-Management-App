import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';

class LabourCountUpdateResponseModel extends BaseResponseModel {
  List<LabourCountModel> labourCountResponse = [];
  LabourCountUpdateResponseModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    labourCountResponse = BaseJsonParser.goodList(json, 'resultObject')
        .map((e) => LabourCountModel.fromJson(e))
        .toList();
  }
}

class LabourCountModel {
  bool? isUpdated;
  String? message;
  LabourCountModel.fromJson(Map<String, dynamic> json) {
    isUpdated = BaseJsonParser.goodBoolean(json, 'updated');
    message = BaseJsonParser.goodString(json, 'message');
  }
}
