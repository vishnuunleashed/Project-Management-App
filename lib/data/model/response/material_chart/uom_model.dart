import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';


class UomListResponseModel extends BaseResponseModel {
  List<UomModel> resultObject = [];

  UomListResponseModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    List? list = json['resultObject'];
    if (list != null) {
      for (var item in list) {
        resultObject.add(UomModel.fromJson(item));
      }
    }
  }
}


class UomModel {
  int uomId = 0;
  String uomDescription = "";
  String uomCode = '';

  UomModel({
    required this.uomId,
    required this.uomDescription,
    required this.uomCode,
  });

  UomModel.fromJson(Map<String, dynamic> json) {
    uomId = BaseJsonParser.goodInt(json, 'id')??0;
    uomDescription = BaseJsonParser.goodString(json, 'description')??"";
    uomCode = BaseJsonParser.goodString(json, 'code')??"";
  }
}
