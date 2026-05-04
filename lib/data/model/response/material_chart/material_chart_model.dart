/*------------------------------------------------------------------------------
AUTHOR       : [Your Name]
CREATED DATE  : 08/01/2026
PURPOSE      : Material Details List
MODULE/TOPIC  : Material Management
REMARKS      : Material DTO for BOQ items
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#  DATE      MODIFIED BY   TICKET#       DESCRIPTION
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';

class MaterialDetailsHdrModel extends BaseResponseModel {
  List<MaterialDetailsWrapperModel> materialDetails = [];

  MaterialDetailsHdrModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    materialDetails = BaseJsonParser.goodList(json, 'resultObject')
        .map((e) => MaterialDetailsWrapperModel.fromJson(e))
        .toList();
  }
}

class MaterialDetailsWrapperModel {
  List<MaterialModel> initialMaterials = [];
  List<MaterialModel> specialMaterials = [];
  List<MaterialModel> standardMaterials = [];

  MaterialDetailsWrapperModel.fromJson(Map<String, dynamic> json) {
    initialMaterials = BaseJsonParser.goodList(json, 'initailmaterialjson')
        .map((e) => MaterialModel.fromJson(e))
        .toList();

    specialMaterials = BaseJsonParser.goodList(json, 'specialmaterialjson')
        .map((e) => MaterialModel.fromJson(e))
        .toList();

    standardMaterials = BaseJsonParser.goodList(json, 'standardmaterialjson')
        .map((e) => MaterialModel.fromJson(e))
        .toList();
  }
}

class MaterialModel {
  int? id;
  int? tableId;
  String? boqItem;
  String? materialDescription;
  String? finalizedBrand;
  String? isSpecialYn;
  int? boqId;
  double? boqQty;
  double? igfcQty;
  double? qty;
  String? units;
  String? qroYn;
  String? boqItemYn;
  String? isigfcverifiedyn;
  String? requiredDate;
  String? lastmoddate;
  String? longLeadYesNo;
  int? leadTimeInclTransportInDays;
  bool isIgfcEnabled = false;
  bool isEditableField = false;
  bool isTempMaterialChart = false;

  MaterialModel.fromJson(Map<String, dynamic> json) {
    id = BaseJsonParser.goodInt(json, 'id');
    tableId = BaseJsonParser.goodInt(json, 'tableid');
    boqItem = BaseJsonParser.goodString(json, 'boqitem');
    materialDescription = BaseJsonParser.goodString(json, 'materialdescription');
    finalizedBrand = BaseJsonParser.goodString(json, 'finalizedbrand');
    isSpecialYn = BaseJsonParser.goodString(json, 'isspecialyn');
    lastmoddate = json["lastmoddate"]??"";
    boqId = BaseJsonParser.goodInt(json, 'boqid');
    boqQty = BaseJsonParser.goodDouble(json, 'boqqty');
    igfcQty = BaseJsonParser.goodDouble(json, 'igfcqty');
    qty = BaseJsonParser.goodDouble(json, 'qty');
    isEditableField = qty == null;
    units = BaseJsonParser.goodString(json, 'units');
    qroYn = BaseJsonParser.goodString(json, 'qroyn');
    boqItemYn = BaseJsonParser.goodString(json, 'boqitemyn');
    isigfcverifiedyn = BaseJsonParser.goodString(json, 'isigfcverifiedyn');
    requiredDate = BaseJsonParser.goodString(json, 'requireddate')??"";
    longLeadYesNo = BaseJsonParser.goodString(json, 'longleadyesno');
    leadTimeInclTransportInDays = BaseJsonParser.goodInt(json, 'leadtimeincltransportindays');
  }

  // Add copyWith method for deep copying
  MaterialModel copyWith({
    int? id,
    int? tableId,
    String? boqItem,
    String? materialDescription,
    String? finalizedBrand,
    String? isSpecialYn,
    int? boqId,
    double? boqQty,
    double? igfcQty,
    double? qty,
    String? units,
    String? qroYn,
    String? boqItemYn,
    String? requiredDate,
    String? longLeadYesNo,
    String? isigfcverifiedyn,
    String? lastmoddate,
    int? leadTimeInclTransportInDays,
    bool? isIgfcEnabled,
    bool? isEditableField,
    bool? isTempMaterialChart,
  }) {
    final copy = MaterialModel._internal();
    copy.id = id ?? this.id;
    copy.isTempMaterialChart = isTempMaterialChart ?? this.isTempMaterialChart;
    copy.tableId = tableId ?? this.tableId;
    copy.boqItem = boqItem ?? this.boqItem;
    copy.materialDescription = materialDescription ?? this.materialDescription;
    copy.finalizedBrand = finalizedBrand ?? this.finalizedBrand;
    copy.isSpecialYn = isSpecialYn ?? this.isSpecialYn;
    copy.boqId = boqId ?? this.boqId;
    copy.boqQty = boqQty ?? this.boqQty;
    copy.igfcQty = igfcQty ?? this.igfcQty;
    copy.isigfcverifiedyn = isigfcverifiedyn ?? this.isigfcverifiedyn;
    copy.qty = qty ?? this.qty;
    copy.units = units ?? this.units;
    copy.qroYn = qroYn ?? this.qroYn;
    copy.boqItemYn = boqItemYn ?? this.boqItemYn;
    copy.requiredDate = requiredDate ?? this.requiredDate;
    copy.lastmoddate = lastmoddate ?? this.lastmoddate;
    copy.longLeadYesNo = longLeadYesNo ?? this.longLeadYesNo;
    copy.leadTimeInclTransportInDays = leadTimeInclTransportInDays ?? this.leadTimeInclTransportInDays;
    copy.isIgfcEnabled = isIgfcEnabled ?? this.isIgfcEnabled;
    copy.isEditableField = isEditableField ?? this.isEditableField;
    return copy;
  }

  // Private constructor for copyWith
  MaterialModel._internal();

  // Helper methods to identify material type
  bool get isInitialMaterial => boqItem != null || boqId != null;
  bool get isSpecialMaterial => isSpecialYn?.toLowerCase() == 'y';
  bool get isStandardMaterial => !isInitialMaterial && !isSpecialMaterial;
}