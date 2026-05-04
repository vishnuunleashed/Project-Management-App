import 'package:base/core/constants.dart';
import 'package:base/data/models/response/image_upload_response.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/request/material_chart/update_status_model.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/model/response/material_chart/additional_material_chart_model.dart';
import 'package:interior_design/data/model/response/material_chart/additional_material_detail_model.dart';
import 'package:interior_design/data/model/response/material_chart/all_reason_type_mode.dart';
import 'package:interior_design/data/model/response/material_chart/brand_model.dart';
import 'package:interior_design/data/model/response/material_chart/material_chart_model.dart';
import 'package:interior_design/data/model/response/material_chart/uom_model.dart';
import 'package:interior_design/domain/repository/material_chart/material_chart_repo.dart';
import 'package:interior_design/presentation/view/material_chart/model/params_model.dart';
import 'package:interior_design/presentation/view/material_chart/model/quantity_update_model.dart';
import 'package:interior_design/presentation/view/material_chart/partials/upload_model.dart';

class MaterialChartImpl extends MaterialChartRepository{
  @override
  Future<void> fetchMaterialChart(
      {required int projectId,
        required Function(List<MaterialDetailsWrapperModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}) async {
    const String urlExtension = "MaterialChart/getmaterialchart";
    final Map<String, dynamic> rawData = {};

    rawData["projectId"] = projectId;

    performGetRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          MaterialDetailsHdrModel response =
          MaterialDetailsHdrModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.materialDetails);
          } else {
            onRequestFailure(AppException(response.statusMessage??""));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  Future<void> fetchAdditionalMaterialChart(
      {required int projectId,
        required String flag,
        required String teamYn,
        required int userId,
        required Function(List<MaterialRequestModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}) async {
    const String urlExtension = "MaterialChart/getAdditionalMaterialsListAll";
    final Map<String, dynamic> rawData = {};

    rawData["projectId"] = projectId;
    if(flag != ""){
      rawData["flag"] = flag;
    }
    if(flag != ""){
      rawData["teamyn"] = teamYn;
    }
    if(flag != ""){
      rawData["userid"] = userId;
    }

    performGetRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          MaterialRequestListResponseModel response =
          MaterialRequestListResponseModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.resultObject);
          } else {
            onRequestFailure(AppException(response.statusMessage??""));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  Future<void> updateIGFCQuantity({
    required UploadModel uploadModel,
    required Function() onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  })async {
    const String urlExtension = "materialChart/update";
    final Map<String, dynamic> rawData = {};
    List<MaterialModel> model= [];
    model.addAll(uploadModel.initialMaterialsDataToBeUploaded);
    model.addAll(uploadModel.specialMaterialsDataToBeUploaded);
    model.addAll(uploadModel.standardMaterialsDataToBeUploaded);

    rawData['chartdetailslist'] = model.map((item) {
          return {
            "id": item.id ?? 0,
            "qty": item.isTempMaterialChart
                ? item.qty ?? 0
                : item.igfcQty ?? 0,
            "istemp": item.isTempMaterialChart,
            "lastmoddate": item.lastmoddate
          };
        }).toList();



    performRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (response) {
          try {

            onRequestSuccess();
          } catch (e) {
            onRequestFailure(AppException('Add Support Request submit failed: ${e.toString()}'));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  Future<void> verifyIGFCQuantities({
    required int projectId,
    required Function() onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  }) async {
    const String urlExtension = "materialChart/verify";
    final Map<String, dynamic> rawData = {};

    rawData["projectId"] = projectId;

    performRequestWithStringBody(
        urlExtension: urlExtension,
        rawData: projectId.toString(),
        onRequestSuccess: (response) {
          print("entered__");
          try {
            if(response["statusCode"] == 0){
              onRequestFailure(AppException(response["statusMessage"].toString()));
            }else{
              onRequestSuccess();
            }
          } catch (e) {
            onRequestFailure(AppException('${e.toString()}'));
          }
        },
        onRequestFailure:(exception){

          onRequestFailure(exception);
        } );
  }

  @override
  void getUoms(
      {required Function(List<UomModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}) async {
    const String urlExtension = "lookup/GetUoms";


    performGetRequest(
        rawData: {},
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          UomListResponseModel response =
          UomListResponseModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.resultObject);
          } else {
            onRequestFailure(AppException(response.statusMessage??""));
          }
        },
        onRequestFailure: onRequestFailure);
  }
  @override
  void getReasonType(
      {required Function(List<CommonMasterModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}) async {
    const String urlExtension = "lookup/GetCommonMasterByType";
    final Map<String, dynamic> rawData = {};

    rawData["type"] = "ADDT_MAT_REASON";

    performGetRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          CommonMasterResponseModel response =
          CommonMasterResponseModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.resultObject);
          } else {
            onRequestFailure(AppException(response.statusMessage??""));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  void getBrandType(
      {required Function(List<BrandResultObject>) onRequestSuccess,
        required Function(AppException) onRequestFailure}) async {
    const String urlExtension = "Brand/GetBrands";

    performGetRequest(
        rawData: {},
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          BrandResponseModel response =
          BrandResponseModel.fromJson(result);
          if (response.statusCode == 1) {
            print("Brand List: ");
            onRequestSuccess(response.resultObject);
          } else {
            onRequestFailure(AppException(response.statusMessage??""));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  Future<void> saveMaterial({
    required AddMaterialChartRequest addMaterialChartRequest,
    required Function() onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  }) async {
    const String urlExtension = "materialChart/saveadditionalmaterial";

    final Map<String, dynamic> rawData = {
      "projectid": addMaterialChartRequest.projectId,
      "optionid": addMaterialChartRequest.optionId,
      "optioncode": addMaterialChartRequest.optionCode,
      "detailslist": addMaterialChartRequest.detailsList.map((item) {
        return {
          "name": item.name,
          "workitem": item.workItem,
          "qty": item.qty,
          "uomid": item.uomId,
          "reasonid": item.reasonId,
          "reason": item.reason,
          "requireddate": item.requiredDate,
        };
      }).toList(),
    };

    performRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (response) {
          try {
            if (response["statusCode"] == 0) {
              onRequestFailure(AppException(response["statusMessage"]));
            }else {
              onRequestSuccess();
            }
          } catch (e) {
            onRequestFailure(AppException(e.toString()));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  Future<void> updateQuantityAdditionMaterial({
    required MaterialQtyUpdateRequest materialQtyUpdateRequest,
    required Function() onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  }) async {
    const String urlExtension = "materialChart/updateadditionalmaterial";

    final Map<String, dynamic> rawData = {
      "projectid": materialQtyUpdateRequest.projectId,
      "optionid": materialQtyUpdateRequest.optionId,
      "optioncode": "ADDT_MAT_CHART",
      "actiontaken": "RECEIVED_QTY_UPDATE",
      "detailslist": materialQtyUpdateRequest.detailsList.map((item) {
        return {
          "Id": item.id,
          "qty": item.qty,
          "poqty": item.poQty,
          "issueddate": item.issuedDate,
          "expectedddate": item.expectedDate,
          "receivedqty": item.receivedQty,
          "receiveddate": item.receivedDate,
          "balanceqty": item.balanceqty,
          "Lastmoddate": item.lastmoddate,
          "docAttachments": [
            {
              "DocumentId": 0,
              "seriesno": item.serialNo,
              "attachmentDtls": _buildAttachmentDtls(item.imagesDtl),
            }
          ],
        };
      }).toList(),
    };

    performRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (response) {
          try {
            if (response["statusCode"] == 0) {
              onRequestFailure(AppException(response["statusMessage"]));
            }else {
              onRequestSuccess();
            }
          } catch (e) {
            onRequestFailure(AppException(e.toString()));
          }
        },
        onRequestFailure: onRequestFailure);
  }
  List<Map<String, dynamic>> _buildAttachmentDtls(List<UploadResponse> imagesDtl) {
    return imagesDtl.map((img) => {
      "filename": img.filename ?? "",
      "physicalfilename": img.physicalfilename ?? "",
    }).toList();
  }


  @override
  void getRoleWiseReasonListByUser(
      {required Function(List<ProjectRoleOptionModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}) async {
    const String urlExtension = "MaterialChart/getRolewiseReasonListByUser";
    final Map<String, dynamic> rawData = {};

    rawData["userId"] = await BaseSecureStorage.getInt(BaseConstants.userID);

    performGetRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          ProjectRoleOptionResponseModel response =
          ProjectRoleOptionResponseModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.resultObject);
          } else {
            onRequestFailure(AppException(response.statusMessage??""));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  void updateStatus(
      {required ProjectApprovalModel statusModel,
        required Function(String) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}) {
    String urlExtension = "materialChart/changestatusadditionalmaterial";

    Map<String, dynamic> rawData = {};
    rawData["rowid"] = statusModel.rowid??0;
    rawData["projectid"] = statusModel.projectid??"";
    rawData["status"] = statusModel.status??"";
    rawData["LastModDate"] = statusModel.lastModDate;
    if(statusModel.remarks != ""){
      rawData["remarks"] = statusModel.remarks??"";
    }
    rawData["qty"] = statusModel.qty??"";



    performRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (result) {
          try {
            if (result["statusCode"] == 0) {
              onRequestFailure(AppException(result["statusMessage"]));
            }else {
              onRequestSuccess(result["statusMessage"]);
            }
          } catch (e) {
            onRequestFailure(AppException(e.toString()));
          }
        },
        onRequestFailure: onRequestFailure);
  }



  @override
  Future<void> fetchDetailedAdditionalMaterial(
      {required int id,
        required Function(List<MaterialRequestModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}) async {
    const String urlExtension = "MaterialChart/getAdditionalMaterialsListAll";
    final Map<String, dynamic> rawData = {};

    // rawData["projectId"] = projectId;
    rawData["id"] = id;
    // http://192.168.10.50:5002/api/MaterialChart/getAdditionalMaterialsListAll?projectId=9&id=47&appType=USER_APP_WEB
    performGetRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          MaterialRequestHdrModel response =
          MaterialRequestHdrModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.requests);
          } else {
            onRequestFailure(AppException(response.statusMessage??""));
          }
        },
        onRequestFailure: onRequestFailure);
  }


}