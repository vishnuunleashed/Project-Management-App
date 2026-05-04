import 'package:base/data/models/response/image_upload_response.dart';

class MaterialQtyUpdateRequest {
  final int projectId;
  final int optionId;
  final String optionCode;
  final String actionTaken;
  final List<MaterialQtyUpdateDetail> detailsList;

  MaterialQtyUpdateRequest({
    required this.projectId,
    required this.optionId,
    this.optionCode = "ADDT_MAT_CHART",
    this.actionTaken="RECEIVED_QTY_UPDATE",
    required this.detailsList,
  });


}
class MaterialQtyUpdateDetail {
  final int id;
  final double qty;
  final double poQty;
  final String issuedDate;
  final String expectedDate;
  final double receivedQty;
  final String receivedDate;
  final String serialNo;
  final String lastmoddate;
  final double balanceqty;
  final List<UploadResponse> imagesDtl;

  MaterialQtyUpdateDetail({
    required this.id,
    required this.qty,
    required this.poQty,
    required this.issuedDate,
    required this.expectedDate,
    required this.receivedQty,
    required this.receivedDate,
    required this.serialNo,
    required this.imagesDtl,
    required this.lastmoddate,
    required this.balanceqty,
  });



}
