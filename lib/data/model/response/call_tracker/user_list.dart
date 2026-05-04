import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';

class EmployeeModelResponse extends BaseResponseModel {
  List<EmployeeModel> employeeResponse = [];

  EmployeeModelResponse.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    employeeResponse = BaseJsonParser
        .goodList(json, 'resultObject')
        .map((e) => EmployeeModel.fromJson(e))
        .toList();
  }
}
class EmployeeModel {
  final int id;
  final int tableid;
  final String? code;
  final String name;
  final int departmentid;
  final String departmentcode;
  final String department;

  const EmployeeModel({
    required this.id,
    required this.tableid,
    this.code,
    required this.name,
    required this.departmentid,
    required this.departmentcode,
    required this.department,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: BaseJsonParser.goodInt(json, 'id')??0,
      tableid: BaseJsonParser.goodInt(json, 'tableid') ?? 0,
      code: BaseJsonParser.goodString(json, 'code'),
      name: BaseJsonParser.goodString(json, 'name') ?? "",
      departmentid: BaseJsonParser.goodInt(json, 'departmentid') ?? 0,
      departmentcode:
      BaseJsonParser.goodString(json, 'departmentcode') ?? "",
      department:
      BaseJsonParser.goodString(json, 'department') ?? "",
    );
  }
}
