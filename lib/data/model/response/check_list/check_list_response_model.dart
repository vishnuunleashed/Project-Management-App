import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';

class CheckListResponseModel extends BaseResponseModel {
  List<CheckListModel> checkList = [];

  CheckListResponseModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    checkList = BaseJsonParser.goodList(json, 'resultObject')
        .map((e) => CheckListModel.fromJson(e))
        .toList();
  }
}

class CheckListModel extends BaseResponseModel {
  int? checklistId;
  String? name;
  int? companyId;
  bool isActive = false;
  int? lastModUserId;
  DateTime? lastModDate;
  int? checklistTableId;
  int? logId;
  bool isChecked = false;
  int? refTableDataId;
  int? refTableId;
  int? logTableId;
  bool isMandatory = false;
  int? excelLastModUser;
  DateTime? excelLastModDate;

  CheckListModel();

  CheckListModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    checklistId = BaseJsonParser.goodInt(json, 'checklistid');
    name = BaseJsonParser.goodString(json, 'name');
    companyId = BaseJsonParser.goodInt(json, 'companyid');
    isActive = BaseJsonParser.goodString(json, 'isactive') == 'Y' ? true : false;
    lastModUserId = BaseJsonParser.goodInt(json, 'lastmoduserid');
    lastModDate = BaseJsonParser.goodDateTime(json, 'lastmoddate');
    checklistTableId = BaseJsonParser.goodInt(json, 'checklisttableid');
    logId = BaseJsonParser.goodInt(json, 'logid');
    isChecked = BaseJsonParser.goodString(json, 'ischecked') == "Y" ? true : false;
    refTableDataId = BaseJsonParser.goodInt(json, 'reftabledataid');
    refTableId = BaseJsonParser.goodInt(json, 'reftableid');
    logTableId = BaseJsonParser.goodInt(json, 'logtableid');
    isMandatory = BaseJsonParser.goodString(json, 'ismandatory') == "Y" ? true : false;
    excelLastModUser = BaseJsonParser.goodInt(json, 'excelastmoduser');
    excelLastModDate = BaseJsonParser.goodDateTime(json, 'excelastmoddate');
  }

  /// Creates a deep copy of this model with optional field overrides.
  CheckListModel copyWith({
    int? checklistId,
    String? name,
    int? companyId,
    bool? isActive,
    int? lastModUserId,
    DateTime? lastModDate,
    int? checklistTableId,
    int? logId,
    bool? isChecked,
    int? refTableDataId,
    int? refTableId,
    int? logTableId,
    bool? isMandatory,
    int? excelLastModUser,
    DateTime? excelLastModDate,
  }) {
    final copy = CheckListModel()
      ..checklistId = checklistId ?? this.checklistId
      ..name = name ?? this.name
      ..companyId = companyId ?? this.companyId
      ..isActive = isActive ?? this.isActive
      ..lastModUserId = lastModUserId ?? this.lastModUserId
      ..lastModDate = lastModDate ?? this.lastModDate
      ..checklistTableId = checklistTableId ?? this.checklistTableId
      ..logId = logId ?? this.logId
      ..isChecked = isChecked ?? this.isChecked
      ..refTableDataId = refTableDataId ?? this.refTableDataId
      ..refTableId = refTableId ?? this.refTableId
      ..logTableId = logTableId ?? this.logTableId
      ..isMandatory = isMandatory ?? this.isMandatory
      ..excelLastModUser = excelLastModUser ?? this.excelLastModUser
      ..excelLastModDate = excelLastModDate ?? this.excelLastModDate;
    return copy;
  }
}