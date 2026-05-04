// import 'dart:developer';
//
// import 'package:base/core/constants.dart';
// import 'package:base/data/models/request/drop_down_params.dart';
// import 'package:base/data/models/response/document_type_model.dart';
// import 'package:base/data/models/response/login_response.dart';
// import 'package:base/data/models/response/profile/pending_order_model.dart';
// import 'package:base/data/models/response/scanner_model.dart';
// import 'package:base/data/models/response/item_attachment_model.dart';
// import 'package:base/data/repository/local/base_prefs.dart';
// import 'package:base/data/repository/local/injection_container.dart';
// import 'package:base/data/services/utils/app_exceptions.dart';
// import 'package:base/data/services/utils/base_dates.dart';
// import 'package:base/data/services/utils/base_json_parser.dart';
// import 'package:base/data/services/utils/xml_builder.dart';
// import 'package:base/domain/repository/scan_repository.dart';
//
// import 'package:flutter/widgets.dart';
//
// class ScanRepositoryImpl extends ScanRepository {
//   static final ScanRepositoryImpl _instance = ScanRepositoryImpl._();
//
//   ScanRepositoryImpl._();
//
//   factory ScanRepositoryImpl() => _instance;
//
//   @override
//   void getFileFormats(
//       {required Function(List<FileFormatsModel>, List<DocOption>)
//           onRequestSuccess,
//       required Function(AppException) onRequestFailure,
//       bool forPreSaleOrder = false}) {
//     List<ModuleListModel> moduleList = BaseServiceLocator.getModuleList();
//
//     int? optionId;
//     if (forPreSaleOrder) {
//       for (var element in moduleList) {
//         if (element.context == "MOB_PRE_SALE_ORDR_OTHR") {
//           optionId = element.optionId;
//         }
//       }
//     } else {
//       for (var element in moduleList) {
//         if (element.context == "MOB_USER_REGISTER") {
//           optionId = element.optionId;
//         }
//       }
//     }
//
//     String url = "/security/controller/cmn/getdropdownlist";
//
//     String fileFormatsXml = XMLBuilder(tag: "List")
//         .addElement(key: "TableCode", value: "FILE_FORMATS_TO_UPLOAD")
//         .buildElement();
//
//     String optionMappingXmlWithOptionId = XMLBuilder(tag: "List")
//         .addElement(key: "Flag", value: "DROPDOWN")
//         .addElement(key: "OptionId", value: "$optionId")
//         .addElement(key: "OptionCode", value: "MOB_USER_REGISTER")
//         .buildElement();
//
//     List jssArr = DropDownParams()
//         .addParams(
//           list: "MOBILE_BAYACONTROLCODES_LIST",
//           xmlStr: fileFormatsXml,
//           key: "fileFormats",
//         )
//         .addParams(
//           list: "MOBILE_DOC_ATTACH_OPTIONS",
//           xmlStr: optionMappingXmlWithOptionId,
//           key: "optionList",
//         )
//         .callReq();
//     String service = "getdata";
//     performRequest(
//         jsonArr: jssArr,
//         service: service,
//         url: url,
//         onRequestFailure: onRequestFailure,
//         onRequestSuccess: (result) {
//           ScannerConfigModel responseJson = ScannerConfigModel.fromJson(result);
//           if (responseJson.statusCode == 1) {
//             onRequestSuccess(responseJson.fileFormats, responseJson.options);
//           } else {
//             onRequestFailure(InvalidInputException(responseJson.statusMessage));
//           }
//         });
//   }
//
//   @override
//   void getDocumentTypes(
//       {int? mappingId,
//       bool forPreSaleOrder = false,
//       required Function(List<DocumentTypes>, List<ItemAttachmentModel>)
//           onRequestSuccess,
//       required Function(AppException exception) onRequestFailure}) async {
//     String service = "getdata";
//     String url = "/security/controller/cmn/getdropdownlist";
//
//     String xml = XMLBuilder(tag: "List")
//         .addElement(key: "DocMappingId", value: "$mappingId")
//         .buildElement();
//     String tableId = "";
//     String transId = "";
//
//     PendingDataList pendingDataList =
//         BaseServiceLocator.getpendingDataListFromProfile();
//
//     if (forPreSaleOrder) {
//       tableId = pendingDataList.tableid.toString();
//
//       transId = pendingDataList.saleenqid.toString();
//       log("executed__ $transId");
//     } else {
//       // tableId = await BasePrefs.getString(BaseConstants.USER_REG_INFO_TABLE_ID);
//       // transId = await BasePrefs.getString(BaseConstants.USER_REG_INFO_ID);
//     }
//
//     String attachmentXml = XMLBuilder(tag: "List")
//         .addElement(key: "TransId", value: transId)
//         .addElement(key: "TransTableId", value: tableId)
//         .buildElement();
//     DropDownParams jssArr = DropDownParams().addParams(
//       list: "MOBILE_DOC_ATTACH_OPTIONS",
//       xmlStr: xml,
//       key: "resultObject",
//     );
//     if (tableId != "" && transId != "") {
//       jssArr.addParams(
//         list: "MOBILE_DOC_DTL",
//         xmlStr: attachmentXml,
//         key: "resultDocs",
//       );
//     }
//
//     performRequest(
//         jsonArr: jssArr.callReq(),
//         service: service,
//         url: url,
//         onRequestFailure: onRequestFailure,
//         onRequestSuccess: (result) {
//           DocumentTypeModel responseJson = DocumentTypeModel.fromJson(result);
//           if (responseJson.statusCode == 1) {
//             var documentTypes = responseJson.documentTypes;
//             documentTypes
//                 .sort((a, b) => (a.sortOrder! > b.sortOrder!) ? 1 : -1);
//             List<ItemAttachmentModel> uploadedDocs =
//                 BaseJsonParser.goodList(result, "resultDocs")
//                     .map((e) => ItemAttachmentModel.fromJson(e))
//                     .toList();
//             onRequestSuccess(documentTypes, uploadedDocs);
//           } else {
//             onRequestFailure(InvalidInputException(responseJson.statusMessage));
//           }
//         });
//   }
//
//   @override
//   void generateXML(
//     bool forPreSaleOrder,
//     List<ItemAttachmentModel> attachments,
//     DocOption docOption,
//     int fileTypeBccId,
//     ValueSetter<String> onSuccess,
//   ) async {
//     String xml = "";
//
//     PendingDataList pendingDataList =
//         BaseServiceLocator.getpendingDataListFromProfile();
//     List<ModuleListModel> moduleList = BaseServiceLocator.getModuleList();
//     int userId = await BasePrefs.getInt(BaseConstants.USERID_KEY);
//
//     int? optionId;
//     if (forPreSaleOrder) {
//       for (var element in moduleList) {
//         if (element.context == "MOB_PRE_SALE_ORDR_OTHR") {
//           optionId = element.optionId;
//         }
//       }
//     } else {
//       for (var element in moduleList) {
//         if (element.context == "MOB_USER_REGISTER") {
//           optionId = element.optionId;
//         }
//       }
//     }
//
//     if (forPreSaleOrder) {
//       for (var attachment in attachments) {
//         XMLBuilder builder = XMLBuilder(tag: "Insert")
//             .addElement(
//                 key: "TransDocAttchId",
//                 value: "${attachment.transDocAttchId ?? "0"}")
//             .addElement(
//                 key: "DocOptionTableId",
//                 value: '${attachment.documentType?.tableId}')
//             .addElement(
//                 key: "DocOptionTableDataId",
//                 value: '${attachment.documentType?.id}')
//             .addElement(key: "RefTableId", value: "${pendingDataList.tableid}")
//             .addElement(key: "RefTableDataId", value: "${pendingDataList.saleenqid}")
//             .addElement(key: "RefOptionId", value: "$optionId")
//             .addElement(key: "RefTransNo", value: "${pendingDataList.saleenquniqueno}")
//             .addElement(key: "RefTransDate", value: "${pendingDataList.salenquirydate}")
//             .addElement(
//                 key: "DocumentId",
//                 value: '${attachment.documentType?.documentId}')
//             .addElement(key: "DocumentNo", value: '${attachment.docNo}')
//             .addElement(key: "noofpages", value: '1')
//             .addElement(key: "HandOverLaterYN", value: 'N')
//             .addElement(key: "DocNameSeries", value: '${attachment.docNo}')
//             .addElement(
//                 key: "DocumentDate",
//                 value: '${BaseDates(attachment.docDate).dbformat}')
//             .addElement(key: "TempMappingId", value: "${attachment.mappingId}")
//             .addElement(
//                 key: "TempMappingParentId",
//                 value: "${attachment.mappingId ?? 0}");
//         if (attachment.documentType != null) {
//           builder
//               .addElement(
//                   key: "ParentDocRefTableId",
//                   value: "${attachment.documentType!.tableId}")
//               .addElement(
//                   key: "ParentDocRefTableDataId",
//                   value: "${attachment.documentType!.id}");
//         }
//         builder
//             .addElement(
//                 key: "isactiveyn",
//                 value: attachment.isActive == true ? "Y" : "N")
//             .addElement(key: "CreatedUserId", value: "$userId")
//             .addElement(key: "LastModUserId", value: "$userId");
//
//         xml += builder.buildElement();
//         attachment.uploadedImages?.forEach((element) {
//           xml += XMLBuilder(tag: "Attachment")
//               .addElement(
//                   key: "reftabledataid",
//                   value: "${attachment.transDocAttchId ?? 0}")
//               .addElement(key: "LastModUserId", value: "$userId")
//               .addElement(
//                   key: "TempMappingId", value: "${attachment.mappingId}")
//               .addElement(
//                   key: "attachmentoriginalname", value: element.data?.filename)
//               .addElement(
//                   key: "attachmentphysicalname",
//                   value: element.data?.filephysicalname)
//               .addElement(key: "filetypebccid", value: "$fileTypeBccId")
//               .buildElement();
//         });
//       }
//       onSuccess(xml);
//     } else {
//       ///document attachment for MOB_USER_REGISTER
//       // String tableId = await BasePrefs.getString(BaseConstants.USER_REG_INFO_TABLE_ID);
//       // String transId = await BasePrefs.getString(BaseConstants.USER_REG_INFO_ID);
//        String currentDateTime = BaseDates(DateTime.now()).dbformat.toString();
//       for (var attachment in attachments) {
//         XMLBuilder builder = XMLBuilder(tag: "Insert")
//             .addElement(
//                 key: "TransDocAttchId",
//                 value: "${attachment.transDocAttchId ?? "0"}")
//             .addElement(
//                 key: "DocOptionTableId",
//                 value: '${attachment.documentType?.tableId}')
//             .addElement(
//                 key: "DocOptionTableDataId",
//                 value: '${attachment.documentType?.id}')
//             // .addElement(key: "RefTableId", value: tableId)
//             // .addElement(key: "RefTableDataId", value: transId)
//             .addElement(key: "RefOptionId", value: "$optionId")
//             .addElement(key: "RefTransNo", value: "")
//             .addElement(key: "RefTransDate", value: currentDateTime)
//             .addElement(
//                 key: "DocumentId",
//                 value: '${attachment.documentType?.documentId}')
//             .addElement(key: "DocumentNo", value: '${attachment.docNo}')
//             .addElement(key: "noofpages", value: '1')
//             .addElement(key: "HandOverLaterYN", value: 'N')
//             .addElement(key: "DocNameSeries", value: '${attachment.docNo}')
//             .addElement(
//                 key: "DocumentDate",
//                 value: '${BaseDates(attachment.docDate).dbformat}')
//             .addElement(key: "TempMappingId", value: "${attachment.mappingId}")
//             .addElement(
//                 key: "TempMappingParentId",
//                 value: "${attachment.mappingId ?? 0}");
//         if (attachment.documentType != null) {
//           builder
//               .addElement(
//                   key: "ParentDocRefTableId",
//                   value: "${attachment.documentType!.tableId}")
//               .addElement(
//                   key: "ParentDocRefTableDataId",
//                   value: "${attachment.documentType!.id}");
//         }
//         builder
//             .addElement(
//                 key: "isactiveyn",
//                 value: attachment.isActive == true ? "Y" : "N")
//             .addElement(key: "CreatedUserId", value: "$userId")
//             .addElement(key: "LastModUserId", value: "$userId");
//
//         xml += builder.buildElement();
//         attachment.uploadedImages?.forEach((element) {
//           xml += XMLBuilder(tag: "Attachment")
//               .addElement(
//                   key: "reftabledataid",
//                   value: "${attachment.transDocAttchId ?? 0}")
//               .addElement(key: "LastModUserId", value: "$userId")
//
//               .addElement(
//                   key: "TempMappingId", value: "${attachment.mappingId}")
//               .addElement(
//                   key: "attachmentoriginalname", value: element.data?.filename)
//               .addElement(
//                   key: "attachmentphysicalname",
//                   value: element.data?.filephysicalname)
//               .addElement(key: "filetypebccid", value: "$fileTypeBccId")
//               .buildElement();
//         });
//       }
//       onSuccess(xml);
//     }
//   }
// }
