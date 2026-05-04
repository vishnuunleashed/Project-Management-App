
import 'dart:convert';

class DropDownParams {
  List<Map> dropDownParams = [];

  DropDownParams() {
    dropDownParams = [];
  }

  DropDownParams addParams(
      {String key = "",
      String list = "",
      String xmlStr = "",
      String? procName,
      String? subActionFlag,
      String? actionFlag,
//      String docxml,
      List<Map<String, dynamic>>? params}) {
    dropDownParams.add(DropDownParamsItems(
      key: key,
      list: list,
      actionFlag: actionFlag,
      subActionFlag: subActionFlag,
      procName: procName,
      xmlStr: xmlStr,
//      docxml: docxml,
      params: params ?? [],
    ).toMap());
    return this;
  }

  List callReq() {
    Map map = Map<String, dynamic>();
    map["dropDownParams"] = dropDownParams;
    List objList = [];
    objList.add(json.encode(map));

    return objList;
  }

}

class DropDownParamsItems {
  Map dropDownParams = {"": ""};

  final String key;
  final String list;
  String? procName;
  String? subActionFlag;
  String? actionFlag;
  final String xmlStr;
//  final String docxml;
  final List<Map<String, dynamic>> params;

  DropDownParamsItems({
    required this.key,
    required this.list,
    required this.xmlStr,
    required this.params,
    this.subActionFlag,
    this.procName,
    this.actionFlag,

//    @required this.docxml,
  });

  Map toMap() {
    dropDownParams = Map<String, dynamic>();
    dropDownParams["list"] = list;
    dropDownParams["key"] = key;
    if (procName != null) dropDownParams["procName"] = procName;
    if (actionFlag != null) dropDownParams["actionFlag"] = actionFlag;
    if (subActionFlag != null)
      dropDownParams["subActionFlag"] = subActionFlag;
    dropDownParams["xmlStr"] = xmlStr;
//    dropDownParams["docAttachXml"] = docxml;
    if (params?.isNotEmpty ?? false) dropDownParams["params"] = params;
    return dropDownParams;
  }

  List callReq({List? requestParams}) {
    Map map = Map<String, dynamic>();
    if (requestParams == null) {
      requestParams = [];
      requestParams.add(toMap());
    }
    map["dropDownParams"] = requestParams;
    List objList = [];
    objList.add(json.encode(map));

    return objList;
  }
}
