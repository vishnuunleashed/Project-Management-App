import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';

class CommonMasterResponseModel extends BaseResponseModel {
  List<CommonMasterModel> resultObject = [];

  CommonMasterResponseModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    List? list = json['resultObject'];
    if (list != null) {
      for (var item in list) {
        resultObject.add(CommonMasterModel.fromJson(item));
      }
    }
  }
}

class CommonMasterModel {
  int id = 0;
  String description = '';
  String cityname = '';
  String clientname = '';
  String name = '';
  String code = '';
  int sortOrder = 0;
  String? mailId;
  String? contactNo;

  CommonMasterModel({
     this.id = 0,
     this.description = '',
     this.clientname = '',
     this.cityname = '',
     this.name = '',
     this.code = '',
     this.sortOrder = 0,
    this.mailId,
    this.contactNo
  });

  CommonMasterModel.fromJson(Map<String, dynamic> json) {
    id = BaseJsonParser.goodInt(json, 'id') ?? 0;
    description =
        BaseJsonParser.goodString(json, 'description') ?? '';
    clientname =
        BaseJsonParser.goodString(json, 'clientname') ?? '';
    cityname =
        BaseJsonParser.goodString(json, 'cityname') ?? '';
    name =
        BaseJsonParser.goodString(json, 'name') ?? '';
    code = BaseJsonParser.goodString(json, 'code') ?? '';
    sortOrder =
        BaseJsonParser.goodInt(json, 'sortorder') ?? 0;
    mailId = BaseJsonParser.goodString(json, 'mailid');
    contactNo = BaseJsonParser.goodString(json, 'contactno');
  }
}
