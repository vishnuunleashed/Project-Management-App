/*------------------------------------------------------------------------------
AUTHOR		    : Shamnas Abdulla
CREATED DATE	: 04/16/2026
PURPOSE		    :
MODULE/TOPIC	:
REMARKS		    : MOM option
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		    MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
import 'package:base/data/models/request/json_builder.dart';
import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/request/MOM/mom_save_model.dart';
import 'package:interior_design/data/model/response/MOM/mom_list_model.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/model/response/project_details/support_request_model.dart';
import 'package:interior_design/domain/repository/MOM/add_mom_repository.dart';

class AddMOMRepositoryImpl extends AddMOMRepository {
  @override
  Future<void> saveMOM(
      {required MOMSaveModel momSaveModel,
      required Function({required int momHdrId}) onRequestSuccess,
      required Function(AppException) onRequestFailure}) async {
    String urlExtension = "MoM/saveorupdate";

    Map<String, dynamic> rawData = momSaveModel.toJson();

    performRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (result) {
          BaseResponseModel response = BaseResponseModel.fromJson(result);
          if (response.statusCode == 0) {
            onRequestFailure(AppException(result["statusMessage"]));
          } else {
            int momHdrId = 0;
            if (result["resultObject"] != null &&
                result["resultObject"].isNotEmpty) {
              momHdrId = result["resultObject"][0]["momHdrId"] ?? 0;
            }
            onRequestSuccess(momHdrId:momHdrId);
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  Future<void> fetchMeetingTypes(
      {required Function(List<CommonMasterModel>) onRequestSuccess,
      required Function(AppException exception) onRequestFailure}) async {
    String urlExtension = "Lookup/GetCommonMasterByType";

    Map<String, dynamic> rawData = {};
    rawData["type"] = "MEETING_TYPE";

    performGetRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (result) {
          try {
            CommonMasterResponseModel response =
                CommonMasterResponseModel.fromJson(result);
            onRequestSuccess(response.resultObject);
          } catch (e) {
            onRequestFailure(AppException(
              "Error parsing user data: ${e.toString()}",
            ));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  Future<void> fetchEditModeMOMData(
      {required int momId,
      required Function(List<MOMListModel> p1) onRequestSuccess,
      required Function(AppException exception) onRequestFailure}) async {
    String urlExtension = "MoM/getMeetingById?";
    Map<String, dynamic> rawData = {};
    rawData["momId"] = momId;

    performGetRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          MOMListResponseModel response = MOMListResponseModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.momList);
          } else {
            onRequestFailure(AppException(response.statusMessage ?? ""));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  Future<void> sendMOMEmail(
      {required int momId,
      required Function() onRequestSuccess,
      required Function(AppException exception) onRequestFailure}) async {
    String urlExtension = "MoM/sendMailInvitation?";
    Map<String, dynamic> rawData = {};
    rawData["momId"] = momId;
    performGetRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (result) {
          BaseResponseModel response = BaseResponseModel.fromJson(result);
          if (response.statusCode == 0) {
            onRequestFailure(AppException(response.statusMessage ?? ""));
          } else {
            onRequestSuccess();
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  Future<void> fetchMOMBasedSupportRequests(
      {required int actionItemId,
        required int start,
        required int limit,
        required Function(List<SupportRequestDtlModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}) async {
    String urlExtension = "MoM/GetSupportRequestDetails";

    final builder = DataStructureBuilder()
        .addColumn("Id", actionItemId)
        .addColumn("Start", start)
        .addColumn("Limit", limit)
        .addColumn("Status", "ALL");

    final rawData = {
      "procName": "",
      "action": "",
      "actionSub": "",
      "columns": builder.build()["Columns"],
    };

    performRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (result) {
          SupportRequestModel response = SupportRequestModel.fromJson(result);
          if(response.statusCode == 1){
            onRequestSuccess(response.supportRequestList);
          }
          else{
            onRequestFailure(AppException(response.statusMessage ?? ""));
          }
        },
        onRequestFailure: onRequestFailure);

  }
}
