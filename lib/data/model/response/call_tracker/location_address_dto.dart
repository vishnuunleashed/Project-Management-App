
import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';

class LocationModelHdrModel extends BaseResponseModel {
  List<LocationModelAddresses> locations = [];

  LocationModelHdrModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    locations = BaseJsonParser.goodList(json, 'resultObject')
        .map((e) => LocationModelAddresses.fromJson(e))
        .toList();
  }
}


class LocationModelAddresses {
 int? id;
 int? clientId;
 String? site;
 String? building;
 String? floor;
 String? address;

  LocationModelAddresses({
    this.id,
    this.clientId,
    this.site,
    this.building,
    this.floor,
    this.address,
  });


 LocationModelAddresses.fromJson(Map<String, dynamic> json) {
    id = BaseJsonParser.goodInt(json, 'id')??0;
    clientId = BaseJsonParser.goodInt(json, 'clientid')??0;
    site = BaseJsonParser.goodString(json, 'sitename')??"";
    building = BaseJsonParser.goodString(json, 'building')??"";
    floor = BaseJsonParser.goodString(json, 'floor')??"";
    address = BaseJsonParser.goodString(json, 'address')??"";
  }
}
