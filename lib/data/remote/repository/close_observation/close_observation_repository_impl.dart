
import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/models/response/image_upload_response.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';
import 'package:interior_design/domain/repository/close_observation/close_observation_repository.dart';
import 'package:interior_design/data/model/response/close_observation/close_observation_model.dart';
import 'package:interior_design/presentation/view/close_observation/widgets/param_model.dart';


class CloseObservationRepositoryImpl extends CloseObservationRepository {
  factory CloseObservationRepositoryImpl() => _instance;
  static final CloseObservationRepositoryImpl _instance = CloseObservationRepositoryImpl._internal();
  CloseObservationRepositoryImpl._internal();

  @override
  void fetchStatusTypes(
      {required Function(List<StatusModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}) {
    String urlExtension = "Lookup/GetCommonMasterByType";

    Map<String, dynamic> rawData = {};
    rawData["type"] = "OBSERVATION_STATUS";

    performGetRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (result) {
          try {
            StatusModelResponse response = StatusModelResponse.fromJson(result);
            onRequestSuccess(response.statusResponse);
          } catch (e) {
            onRequestFailure(AppException(
              "Error parsing user data: ${e.toString()}",
            ));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  void fetchObservationDetails(
      {required int observationId,
        required Function(List<ObservationDetailModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}) {
    String urlExtension = "Observation/ObservationsList";



    Map<String, dynamic> rawData = {};
    rawData["key"] = "Id";
    rawData["value"] = observationId;
    Map<String,dynamic> data = {
      "columns" : [
        rawData
      ]
    };

    performRequest(
        urlExtension: urlExtension,
        rawData: data,
        onRequestSuccess: (result) {
          try {
            ObservationResponse response = ObservationResponse.fromJson(result);
            onRequestSuccess(response.observationDetail);
          } catch (e) {
            onRequestFailure(AppException(
              "Error parsing user data: ${e.toString()}",
            ));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  Future<void> fetchAttachmentsDetail({
    required List<AttachedDoc> attachmentList,
    required Function(AttachmentResponseModel) onRequestSuccess,
    required Function(AppException) onRequestFailure,
  }) async {
    final List<String> fileNames = attachmentList
        .map((attachment) => attachment.attachmentphysicalname ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    final Map<String, dynamic> rawData = {};

    // Option A: Multiple keys with same parameter name
    for (int i = 0; i < fileNames.length; i++) {
      rawData['keys[$i]'] = fileNames[i];
    }

    final String urlExtension = "FileUpload/GetFiles?";

    performGetRequest(
      rawData: rawData,
      urlExtension: urlExtension,
      onRequestSuccess: (result) {
        AttachmentResponseModel response = AttachmentResponseModel.fromJson(result);
        if (response.statusCode == 1) {
          onRequestSuccess(response);
        }
      },
      onRequestFailure: onRequestFailure,
    );
  }

  @override
  void closeObservationSave(
      {
        required List<UploadResponse> uploadedImages,
        required String attachmentSeriesNo,
        required ObservationRawDataModel observationDetail,
      required Function(String) onRequestSuccess,
      required Function(AppException exception) onRequestFailure}) {
    String urlExtension = "Observation/updateStatus";

    Map<String, dynamic> rawData = {};
    rawData["observationid"] = observationDetail.observationid;
    rawData["statusid"] = observationDetail.statusid;
    rawData["statuscode"] = observationDetail.statuscode;
    rawData["remarks"] = observationDetail.remarks;
    rawData["Prevlogid"] = observationDetail.prevlogid??"";

    //	8	SUBMIT ATTACHMENT
    //  7	GENERAL
    // Build docAttachments with dynamic attachmentDtls from imagesDtl
    if(uploadedImages.isNotEmpty){
      rawData["docAttachments"] = [
        {
          "DocumentId": 8,
          "seriesno": attachmentSeriesNo,
          "attachmentDtls": _buildAttachmentDtls(uploadedImages),
        }
      ];
    }
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



  List<Map<String, dynamic>> _buildAttachmentDtls(List<UploadResponse> imagesDtl) {
    return imagesDtl.map((img) => {
      "filename": img.filename ?? "",
      "physicalfilename": img.physicalfilename ?? "",
    }).toList();
  }

  @override
  Future<void> fetchActivityGroups({
    required Function(List<CommonMasterModel>) onRequestSuccess,
    required Function(AppException exception) onRequestFailure}) async {
    final Map<String, dynamic> rawData = {};

    final String urlExtension = "Project/GetActivityGroupList";

    performGetRequest(
      rawData: rawData,
      urlExtension: urlExtension,
      onRequestSuccess: (result) {
        CommonMasterResponseModel response = CommonMasterResponseModel.fromJson(result);
        if (response.statusCode == 1) {
          onRequestSuccess(response.resultObject);
        }
      },
      onRequestFailure: onRequestFailure,
    );
  }

  @override
  Future<void> updateActivityStatus({
    required int observationId,
    required int? activityGroupId,
    required int? sourceOfErrorId,
    required int prevLogId,
    required int? ownerId,
    required String remarks,
    required Function() onRequestSuccess,
    required Function(AppException exception) onRequestFailure}) async{
    String urlExtension = "Observation/updateStatus";

    Map<String, dynamic> rawData = {};
    rawData["ObservationId"] = observationId;
    rawData["StatusCode"] = "TAGGING";
    rawData["Activitygroupid"] = activityGroupId;
    rawData["Sourceoferrorid"] = sourceOfErrorId;
    rawData["OwnerId"] = ownerId;
    rawData["remarks"] = remarks;
    rawData["Prevlogid"] = prevLogId;

    performRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (result) {
          BaseResponseModel response = BaseResponseModel.fromJson(result);
          if( response.statusCode == 1){
            onRequestSuccess();
          }
          else{
            onRequestFailure(AppException(response.statusMessage ?? ""));
          }
        },
        onRequestFailure: onRequestFailure);
  }
}
