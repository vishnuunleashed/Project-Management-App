import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';

class OwnerModelResponse extends BaseResponseModel {
  List<OwnerModel> ownerResponse = [];

  OwnerModelResponse.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    ownerResponse = BaseJsonParser.goodList(json, 'resultObject').map((e) => OwnerModel.fromJson(e)).toList();
  }
}

class OwnerModel {
  final int? id;
  final String? code;
  final String name;
  final String profileurl;
  final String departmentName;
  final String siteinchargeyn;

  final int departmentId;

  const OwnerModel({this.id, this.code, required this.name,this.siteinchargeyn="", required this.profileurl, required this.departmentName,required this.departmentId});

  factory OwnerModel.fromJson(Map<String, dynamic> json) {
    return OwnerModel(
      id: BaseJsonParser.goodInt(json, 'id'),
      code: BaseJsonParser.goodString(json, 'code'),
      name: BaseJsonParser.goodString(json, 'name')??"",
      profileurl: BaseJsonParser.goodString(json, 'profileurl')??"",
      departmentId: BaseJsonParser.goodInt(json, 'departmentid')??0,
      departmentName: BaseJsonParser.goodString(json, 'department')??"",
      siteinchargeyn: BaseJsonParser.goodString(json, 'siteinchargeyn')??"",
    );
  }

}

