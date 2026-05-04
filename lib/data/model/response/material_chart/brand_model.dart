import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';


class BrandResponseModel extends BaseResponseModel {
  List<BrandResultObject> resultObject = [];

  BrandResponseModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    resultObject.add(BrandResultObject.fromJson(json['resultObject']));
  }
}

class BrandResultObject {
  List<BrandModel> list = [];
  String? templateKey = '';

  BrandResultObject.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null &&
        json['list'] is List) {
      for (var item in json['list']) {
        list.add(
          BrandModel.fromJson(item),
        );
      }
    }
    templateKey = BaseJsonParser.goodString(json, 'templateKey');
  }
}

class BrandModel {
  int? id = 0;
  int? optionid = 0;
  String? code = '';
  String? name = '';
  String? isactive = '';

  BrandModel.fromJson(Map<String, dynamic> json) {
    id = BaseJsonParser.goodInt(json, 'id');
    optionid = BaseJsonParser.goodInt(json, 'optionid');
    code = BaseJsonParser.goodString(json, 'code');
    name = BaseJsonParser.goodString(json, 'name');
    isactive = BaseJsonParser.goodString(json, 'isactive');
  }
}
