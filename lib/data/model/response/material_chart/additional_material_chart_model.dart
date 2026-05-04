import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';

class MaterialRequestListResponseModel extends BaseResponseModel {
  List<MaterialRequestModel> resultObject = [];

  MaterialRequestListResponseModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    List? list = json['resultObject'];
    if (list != null) {
      for (var item in list) {
        resultObject.add(MaterialRequestModel.fromJson(item));
      }
    }
  }
}
class MaterialRequestModel {
  int id = 0;
  int tableId = 0;
  int optionId = 0;
  int companyId = 0;
  int projectId = 0;
  int rowNo = 0;

  String workItem = '';
  String name = '';

  int? brandId;
  String brand = '';

  int uomId = 0;
  String uom = '';

  double qty = 0.0;
  double wastagePerc = 0.0;

  int requestedBy = 0;
  String requestedByName = '';
  String requestedDate = '';

  int reasonTypeId = 0;
  String reasonTypeCode = '';
  String reasonType = '';
  String reason = '';

  String requiredDate = '';

  int approvalStatusId = 0;
  String approvalStatus = '';
  String approvalYn = '';

  int? approvedBy;
  String? approvedByUser;
  String? approvalDate;

  String? remarks;

  String? poIssuedYn;
  int? poIssuedBy;
  String? poIssuedByUser;
  String? poIssuedDate;
  double? poIssuedQty;

  String? expectedDeliveryDate;

  double? receivedQty;
  double balanceQty = 0.0;
  String? receivedDate;
  String? lastReceivedDate;
  String? receivedYn;

  String? supportReqYn;

  int createdBy = 0;
  String createdDate = '';

  int lastModUserId = 0;
  String lastModDate = '';

  List<AttachmentModelDto> attachments = [];

  MaterialRequestModel.fromJson(Map<String, dynamic> json) {
    id = BaseJsonParser.goodInt(json, 'id') ?? 0;
    tableId = BaseJsonParser.goodInt(json, 'tableid') ?? 0;
    optionId = BaseJsonParser.goodInt(json, 'optionid') ?? 0;
    companyId = BaseJsonParser.goodInt(json, 'companyid') ?? 0;
    projectId = BaseJsonParser.goodInt(json, 'projectid') ?? 0;
    rowNo = BaseJsonParser.goodInt(json, 'rowno') ?? 0;

    workItem = BaseJsonParser.goodString(json, 'workitem') ?? '';
    name = BaseJsonParser.goodString(json, 'name') ?? '';

    brandId = BaseJsonParser.goodInt(json, 'brandid');
    brand = BaseJsonParser.goodString(json, 'brand') ?? '';

    uomId = BaseJsonParser.goodInt(json, 'uomid') ?? 0;
    uom = BaseJsonParser.goodString(json, 'uom') ?? '';

    qty = BaseJsonParser.goodDouble(json, 'qty') ?? 0.0;
    wastagePerc = BaseJsonParser.goodDouble(json, 'wastageperc') ?? 0.0;

    requestedBy = BaseJsonParser.goodInt(json, 'requestedby') ?? 0;
    requestedByName = BaseJsonParser.goodString(json, 'requestedbyname') ?? '';
    requestedDate = BaseJsonParser.goodString(json, 'requesteddate') ?? '';

    reasonTypeId = BaseJsonParser.goodInt(json, 'reasontypeid') ?? 0;
    reasonTypeCode = BaseJsonParser.goodString(json, 'reasontypecode') ?? '';
    reasonType = BaseJsonParser.goodString(json, 'reasontype') ?? '';
    reason = BaseJsonParser.goodString(json, 'reason') ?? '';

    requiredDate = BaseJsonParser.goodString(json, 'requireddate') ?? '';

    approvalStatusId = BaseJsonParser.goodInt(json, 'approvalstatusid') ?? 0;
    approvalStatus = BaseJsonParser.goodString(json, 'approvalstatus') ?? '';
    approvalYn = BaseJsonParser.goodString(json, 'approvalyn') ?? '';

    approvedBy = BaseJsonParser.goodInt(json, 'approvedby');
    approvedByUser = BaseJsonParser.goodString(json, 'approvedbyuser');
    approvalDate = BaseJsonParser.goodString(json, 'approvaldate');

    remarks = BaseJsonParser.goodString(json, 'remarks');

    poIssuedYn = BaseJsonParser.goodString(json, 'poissuedyn');
    poIssuedBy = BaseJsonParser.goodInt(json, 'poissuedby');
    poIssuedByUser = BaseJsonParser.goodString(json, 'poissuedbyuser');
    poIssuedDate = BaseJsonParser.goodString(json, 'poissueddate');
    poIssuedQty = BaseJsonParser.goodDouble(json, 'poissuedqty');

    // API has misspelling: 'expectedelverdate' instead of 'expecteddeliverydate'
    expectedDeliveryDate = BaseJsonParser.goodString(json, 'expectedelverdate');

    receivedYn = BaseJsonParser.goodString(json, 'receivedyn');
    receivedQty = BaseJsonParser.goodDouble(json, 'receivedqty');
    balanceQty = BaseJsonParser.goodDouble(json, 'balanceqty') ?? 0.0;
    receivedDate = BaseJsonParser.goodString(json, 'receiveddate');
    lastReceivedDate = BaseJsonParser.goodString(json, 'lastreceiveddate');

    supportReqYn = BaseJsonParser.goodString(json, 'supportreqyn');

    createdBy = BaseJsonParser.goodInt(json, 'createdby') ?? 0;
    createdDate = BaseJsonParser.goodString(json, 'createddate') ?? '';

    lastModUserId = BaseJsonParser.goodInt(json, 'lastmoduserid') ?? 0;
    lastModDate = BaseJsonParser.goodString(json, 'lastmoddate') ?? '';

    if (json['attachmentjson'] != null && json['attachmentjson'] is List) {
      attachments = (json['attachmentjson'] as List)
          .map((item) => AttachmentModelDto.fromJson(item))
          .toList();
    }
  }
}

class AttachmentModelDto {
  String code = '';
  int documentId = 0;
  String attachmentOriginalName = '';
  String attachmentPhysicalName = '';
  String attachmentPhysicalNameUrl = '';

  AttachmentModelDto.fromJson(Map<String, dynamic> json) {
    code = BaseJsonParser.goodString(json, 'code') ?? '';
    documentId = BaseJsonParser.goodInt(json, 'documentid') ?? 0;
    attachmentOriginalName =
        BaseJsonParser.goodString(json, 'attachmentoriginalname') ?? '';
    attachmentPhysicalName =
        BaseJsonParser.goodString(json, 'attachmentphysicalname') ?? '';
    attachmentPhysicalNameUrl =
        BaseJsonParser.goodString(json, 'attachmentphysicalnameurl') ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'documentid': documentId,
      'attachmentoriginalname': attachmentOriginalName,
      'attachmentphysicalname': attachmentPhysicalName,
      'attachmentphysicalnameurl': attachmentPhysicalNameUrl,
    };
  }
}