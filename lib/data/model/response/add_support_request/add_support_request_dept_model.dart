/*------------------------------------------------------------------------------
AUTHOR		    : Brenta Roy
CREATED DATE	: 13/08/2025
PURPOSE		    :
MODULE/TOPIC	: AddSupportRequestDepartmentModel
REMARKS		    :
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------*/
import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';

class AddSupportRequestDepartmentModel extends BaseResponseModel {

  List<DepartmentDropDownObj> departmentList = [];

  AddSupportRequestDepartmentModel.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    departmentList = BaseJsonParser.goodList(json, 'resultObject').map((e) => DepartmentDropDownObj.fromJson(e)).toList();
  }
}

class DepartmentDropDownObj {
  int id = 0;
  String code = "";
  String desc = "";

  DepartmentDropDownObj({required this.id, required this.code, required this.desc});

  DepartmentDropDownObj.fromJson(Map<String, dynamic> json) {
    id = BaseJsonParser.goodInt(json, 'id') ?? 0;
    code = BaseJsonParser.goodString(json, 'code') ?? "";
    desc = BaseJsonParser.goodString(json, 'description') ?? "";
  }
}
