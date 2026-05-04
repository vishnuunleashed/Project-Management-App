/*------------------------------------------------------------------------------
AUTHOR		    : Shamnas Abdulla
CREATED DATE	: 11/08/2025
PURPOSE		    : Department dropdown
MODULE/TOPIC	:
REMARKS		    : IN008 - 25
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		    MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';

class DepartmentModel extends BaseResponseModel {
  List<DepartmentDropDownModel> departmentList = [];
  DepartmentModel.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    departmentList = BaseJsonParser.goodList(json, 'resultObject')
        .map((e) => DepartmentDropDownModel.fromJson(e))
        .toList();
  }
}

class DepartmentDropDownModel {
  int? deptId;
  String? deptName;
  String? deptCode;

  DepartmentDropDownModel.fromJson(Map<String, dynamic> json) {
    deptId = BaseJsonParser.goodInt(json, 'id');
    deptName = BaseJsonParser.goodString(json, 'description');
    deptCode = BaseJsonParser.goodString(json, 'code');
  }
}
