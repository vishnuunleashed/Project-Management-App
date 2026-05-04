import 'dart:io';

import 'package:base/data/models/response/image_upload_response.dart';
import 'package:base/data_export.dart';
import 'package:interior_design/data/model/response/close_observation/close_observation_model.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';
import 'package:interior_design/data/remote/repository/add_observation/add_observation_repository_impl.dart';
import 'package:interior_design/data/remote/repository/close_observation/close_observation_repository_impl.dart';
import 'package:interior_design/data/remote/repository/project_details/project_details_repository_impl.dart';
import 'package:interior_design/presentation/view/close_observation/widgets/param_model.dart';

class CloseObservationUseCase {
  factory CloseObservationUseCase() => _instance;
  static final CloseObservationUseCase _instance = CloseObservationUseCase._internal();
  CloseObservationUseCase._internal();


  //For fetching observation details
  void fetchObservationDetails(
      {required int observationId,
      required Function(List<ObservationDetailModel>) onRequestSuccess,
      required Function(AppException exception) onRequestFailure}) {
    CloseObservationRepositoryImpl().fetchObservationDetails(
        observationId: observationId,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  //For fetching status types
  void fetchStatusTypes(
      {required Function(List<StatusModel>) onRequestSuccess,
      required Function(AppException exception) onRequestFailure}) {
    CloseObservationRepositoryImpl().fetchStatusTypes(
        onRequestSuccess: onRequestSuccess, onRequestFailure: onRequestFailure);
  }

  Future<void> fetchAttachmentsDetail(
      {required List<AttachedDoc> attachmentList,
        required Function(AttachmentResponseModel) onRequestSuccess,
        required Function(AppException) onRequestFailure}
      )async{
    CloseObservationRepositoryImpl().fetchAttachmentsDetail(
        attachmentList: attachmentList,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }
  Future<void> fetchAttachmentsDetailForUploadedFiles(
      {required List<UploadResponse> attachmentList,
        required Function(AttachmentResponseModel) onRequestSuccess,
        required Function(AppException) onRequestFailure}
      )async{
    AddObservationRepositoryImpl().fetchAttachmentsDetail(
        attachmentList: attachmentList,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  //For closing observation
  void closeObservationSave(
      {
        required List<UploadResponse> uploadedImages,
        required String attachmentSeriesNo,
        required ObservationRawDataModel observationDetail,
      required Function(String) onRequestSuccess,
      required Function(AppException exception) onRequestFailure,
        }) {
    CloseObservationRepositoryImpl().closeObservationSave(
      uploadedImages: uploadedImages,
        attachmentSeriesNo: attachmentSeriesNo,
        observationDetail: observationDetail,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  //For uploading image
  Future<void> uploadImageFile(
      {required List<File> file,
        required String attachmentSerialNo,
        required Function(double progress) uploadProgress,
        required Function(List<UploadResponse> uploadResponse) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}){
    return AddObservationRepositoryImpl().uploadImageFile(
        images: file,
        attachmentSerialNo: attachmentSerialNo,
        onRequestSuccess: onRequestSuccess,
        uploadProgress: uploadProgress,
        onRequestFailure: onRequestFailure);
  }

  void fetchSingleImageAttachmentsDetail({
    required String fileName,
    bool isProfilePic = false,

    required Function(AttachmentResponseModel) onRequestSuccess,
    required Function(AppException) onRequestFailure,
  }){
    ProjectDetailsRepositoryImpl().fetchSingleImageAttachmentsDetail(
        fileName: fileName,
        isProfilePic: true,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void fetchActivityGroups({
    required Function(List<CommonMasterModel>) onRequestSuccess,
    required Function(AppException exception) onRequestFailure}){
    CloseObservationRepositoryImpl().fetchActivityGroups(
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void updateActivityStatus({
    required int observationId,
    required int? activityGroupId,
    required int? sourceOfErrorId,
    required int prevLogId,
    required int? ownerId,
    required String remarks,
    required Function() onRequestSuccess,
    required Function(AppException exception) onRequestFailure}){
    CloseObservationRepositoryImpl().updateActivityStatus(
      observationId: observationId,
        activityGroupId: activityGroupId,
        sourceOfErrorId: sourceOfErrorId,
        prevLogId: prevLogId,
        ownerId: ownerId,
        remarks: remarks,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }
}
