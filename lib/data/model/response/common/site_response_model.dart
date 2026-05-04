import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';

class SiteResponseModel extends BaseResponseModel {
  List<SiteModel> resultObject = [];

  SiteResponseModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    List? list = json['resultObject'];
    if (list != null) {
      for (var item in list) {
        resultObject.add(SiteModel.fromJson(item));
      }
    }
  }
}

class SiteModel {
  int id = 0;
  int clientId = 0;
  String siteName = '';
  String building = '';
  String floor = '';
  String address = '';

  SiteModel({
    required this.id,
    required this.clientId,
    required this.siteName,
    required this.building,
    required this.floor,
    required this.address,
  });

  SiteModel.fromJson(Map<String, dynamic> json) {
    id = BaseJsonParser.goodInt(json, 'id') ?? 0;
    clientId = BaseJsonParser.goodInt(json, 'clientid') ?? 0;
    siteName = BaseJsonParser.goodString(json, 'sitename') ?? '';
    building = BaseJsonParser.goodString(json, 'building') ?? '';
    floor = BaseJsonParser.goodString(json, 'floor') ?? '';
    address = BaseJsonParser.goodString(json, 'address') ?? '';
  }
}