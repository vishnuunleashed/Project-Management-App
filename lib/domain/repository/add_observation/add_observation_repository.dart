import 'dart:io';
import 'package:base/data/models/response/image_upload_response.dart';
import 'package:base/data/repository/remote/base_repository.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/request/add_observation/add_observation_model.dart';
import 'package:interior_design/data/model/response/add_observation/add_observation_model.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';
import 'package:interior_design/presentation/view/close_observation/widgets/param_model.dart';

abstract class AddObservationRepository extends BaseRepository {
  void fetchOwners(
      {int? projectId,
        required bool excludeLoginUser,
        required Function(List<OwnerModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}) ;

  void addObservationSave(
      { required AddObservationRequest request,
        required Function({required String transNo}) onRequestSuccess,
        required Function(AppException exception) onRequestFailure});


  Future<void> fetchAttachmentsDetail({
    required List<UploadResponse> attachmentList,
    required Function(AttachmentResponseModel) onRequestSuccess,
    required Function(AppException) onRequestFailure,
  });

  Future<void> uploadImageFile(
      {required List<File> images,
        required String attachmentSerialNo,
        required Function(double progress) uploadProgress,
        required Function(List<UploadResponse> uploadResponse) onRequestSuccess,
        required Function(AppException exception) onRequestFailure});

  Future<void> updateUserName(
      { required String name,
        required Function(String) onRequestSuccess,
        required Function(AppException exception) onRequestFailure});

  void updateStatus(
      {required List<UploadResponse> uploadedImages,
        required String attachmentSeriesNo,
        required ObservationRawDataModel observationDetail,
        required Function(String) onRequestSuccess,
        required Function(AppException exception) onRequestFailure});
}