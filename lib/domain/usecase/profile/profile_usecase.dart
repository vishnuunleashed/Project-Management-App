import 'dart:io';

import 'package:base/data/models/response/image_upload_response.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';
import 'package:interior_design/data/remote/repository/add_observation/add_observation_repository_impl.dart';
import 'package:interior_design/data/remote/repository/profile/profile_repository_impl.dart';

import '../../../data/model/response/add_observation/add_observation_model.dart';

class ProfileUseCase {
  Future<void> changePassword(
      {required String oldPassword,
      required String newPassword,
      required Function() onRequestSuccess,
      required Function(AppException) onRequestFailure}) async {
    ProfileRepositoryImpl().changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  Future<void> forgotPassword(
      {required String usernameOrEmail,
        required Function() onRequestSuccess,
        required Function(AppException) onRequestFailure}) async {
    ProfileRepositoryImpl().forgotPassword(
        usernameOrEmail: usernameOrEmail,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  Future<void> uploadImageFile(
      {required List<File> file,
        required Function(double progress) uploadProgress,
        required Function(List<UploadResponse> uploadResponse) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}){
    return AddObservationRepositoryImpl().uploadImageFile(
        images: file,
        isProfilePic: true,
        onRequestSuccess: onRequestSuccess,
        uploadProgress: uploadProgress,
        onRequestFailure: onRequestFailure);
  }

  Future<void> fetchAttachmentsDetail(
      {required List<UploadResponse> attachmentList,
        required Function(AttachmentResponseModel) onRequestSuccess,
        required Function(AppException) onRequestFailure, bool isProfilePic = false}
      )async{
    AddObservationRepositoryImpl().fetchAttachmentsDetail(
        isProfilePic: isProfilePic,
        attachmentList: attachmentList,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }
  Future<void> updateUserName(
      {required String name,
        required Function(String) onRequestSuccess,
        required Function(AppException) onRequestFailure, bool isProfilePic = false}
      )async{
    AddObservationRepositoryImpl().updateUserName(
        name: name,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }



}


