import 'dart:io';
import 'package:base/core/constants.dart';
import 'package:base/data/models/response/image_upload_response.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/data/repository/remote/base_file_upload_repository.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/request/add_observation/add_observation_model.dart';
import 'package:interior_design/data/model/response/add_observation/add_observation_model.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';
import 'package:interior_design/domain/repository/add_observation/add_observation_repository.dart';
import 'package:interior_design/presentation/view/close_observation/widgets/param_model.dart';
import 'package:intl/intl.dart';

class AddObservationRepositoryImpl extends AddObservationRepository {
  factory AddObservationRepositoryImpl() => _instance;
  static final AddObservationRepositoryImpl _instance = AddObservationRepositoryImpl._internal();
  AddObservationRepositoryImpl._internal();
  @override
  void fetchOwners(
      {int? projectId,
        required bool excludeLoginUser,
      required Function(List<OwnerModel>) onRequestSuccess,
      required Function(AppException exception) onRequestFailure}) {
    String urlExtension = "Project/GetUsersByProject";

    Map<String, dynamic> rawData = {};
    if(projectId != null){
      rawData["projectId"] = projectId;
    }

    rawData["excludeLoginUser"] = excludeLoginUser;




    performGetRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (result) {
          try {
            OwnerModelResponse response = OwnerModelResponse.fromJson(result);
            onRequestSuccess(response.ownerResponse);
          } catch (e) {
            onRequestFailure(AppException(
              "Error parsing user data: ${e.toString()}",
            ));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  Future<void> uploadImageFile(
      {required List<File> images,
        String? attachmentSerialNo,
        required Function(double progress) uploadProgress,
      required Function(List<UploadResponse> uploadResponse) onRequestSuccess,
      required Function(AppException exception) onRequestFailure, bool isProfilePic = false}) async {

    FileUploadRepository(
      onRequestFailure: (e) {
        onRequestFailure(e);
      },
      onRequestSuccess: (response) {
        onRequestSuccess(response ?? []);
      },
    ).uploadImages(images,isProfilePic,attachmentSerialNo: attachmentSerialNo, uploadProgress: uploadProgress);
  }


  @override
  Future<void> fetchAttachmentsDetail({
    bool isProfilePic = false,
    required List<UploadResponse> attachmentList,
    required Function(AttachmentResponseModel) onRequestSuccess,
    required Function(AppException) onRequestFailure,
  }) async {
    final List<String> fileNames = attachmentList
        .map((attachment) => attachment.physicalfilename ?? '')
        .where((name) => name.isNotEmpty)
        .toList();

    final Map<String, dynamic> rawData = {};

    // Option A: Multiple keys with same parameter name
    for (int i = 0; i < fileNames.length; i++) {
      rawData['keys[$i]'] = fileNames[i];
      rawData['IsProfilePic'] = isProfilePic;
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
        else{
          onRequestSuccess(response);
        }
      },
      onRequestFailure: onRequestFailure,
    );
  }

  @override
  void updateStatus(
      {
        required List<UploadResponse> uploadedImages,
        required String attachmentSeriesNo,
        required ObservationRawDataModel observationDetail,
        required Function(String) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}) {
    String urlExtension = "Observation/updateStatus";

    Map<String, dynamic> rawData = {};
    rawData["ObservationId"] = observationDetail.observationid;
    rawData["StatusCode"] = observationDetail.statuscode;
    rawData["remarks"] = observationDetail.remarks;
    rawData["Prevlogid"] = observationDetail.prevlogid??"";
    rawData["OwnerId"] = observationDetail.ownerId??"";

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

  @override
  Future<void> addObservationSave(
      { required AddObservationRequest request,
        required Function({required String transNo}) onRequestSuccess,
      required Function(AppException exception) onRequestFailure}) async {
    String urlExtension = "Observation/saveorupdate";
    String transDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    int userID = await BaseSecureStorage.getInt(BaseConstants.userID);

    Map<String, dynamic> rawData = {};
    rawData["id"] = 0;
    rawData["optionid"] = request.optionId;
    rawData["transdate"] = transDate;
    rawData["observerid"] = userID;
    rawData["projectid"] = request.projectId;
    if(request.ownerId != 0){
        rawData["ownerid"] = request.ownerId;
    }
    rawData["observationpoints"] = request.observationPoints;

    if(request.isFromMOM){
      rawData["From"] = "MOM";
      rawData["Fromid"] = request.actionItemId;
    }

    //	8	SUBMIT ATTACHMENT
    //  7	GENERAL
    // Build docAttachments with dynamic attachmentDtls from imagesDtl
    if(request.imagesDtl.isNotEmpty){
      rawData["docAttachments"] = [
        {
          "DocumentId": 7,
          "seriesno": request.seriesNo,
          "attachmentDtls": _buildAttachmentDtls(request.imagesDtl),
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
              final resultObject = result['resultObject'];
              final transNo = resultObject.first['transactionNo'];
              onRequestSuccess(transNo: transNo);
            }
          } catch (e) {
            onRequestFailure(AppException(
              "Error parsing user data: ${e.toString()}",
            ));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  Future<void> updateUserName(
      { required String name,
        required Function(String) onRequestSuccess,
      required Function(AppException exception) onRequestFailure}) async {
    String urlExtension = "User/updateLoginUserName";

    performRequestWithStringBody(
        urlExtension: urlExtension,
        rawData: name,
        onRequestSuccess: (result) {
          if(result["statusCode"] == 1){
            onRequestSuccess(name);
          }else{
            onRequestSuccess("Failure");
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
}
