import 'dart:io';

import 'package:base/data/models/response/image_upload_response.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/close_observation/read_status_update_dto.dart';
import 'package:interior_design/data/model/response/project_details/project_details_model.dart';
import 'package:interior_design/data/model/response/project_location/geo_location.dart';
import 'package:interior_design/data/model/response/project_location/user_status.dart';
import 'package:interior_design/data/remote/repository/add_observation/add_observation_repository_impl.dart';
import 'package:interior_design/data/remote/repository/close_support_request/close_support_request_repository_impl.dart';
import 'package:interior_design/data/remote/repository/project_details/project_details_repository_impl.dart';
import 'package:interior_design/data/remote/repository/project_location/project_location_impl.dart';

class ProjectLocationUseCase{
  void captureGeoLocation(
      {required LocationParams params,
        required Function() onRequestSuccess,
        required Function(AppException) onRequestFailure}){
    ProjectLocationImpl().captureGeoLocation(
        params: params,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }
  void signInToProjectLocation(
      {required LocationParams params,
        required Function(String) onRequestSuccess,
        required Function(AppException) onRequestFailure}) {
    ProjectLocationImpl().signInToProjectLocation(
        params: params,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void signOutToProjectLocation(
      {required LocationParams params,
        required Function(String) onRequestSuccess,
        required Function(AppException) onRequestFailure}){
    ProjectLocationImpl().signOutToProjectLocation(
        params: params,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }
  void getUserSignInStatus(

      {required Function(bool) onRequestSuccess,
        required Function(AppException) onRequestFailure,
        required int projectId}){
    ProjectLocationImpl().getUserSignInStatus(
        projectId:projectId,
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

  void getGeoCoordinatedByProject(
      { required Function(List<ProjectGeoResultObjectModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure,
        required int projectId}){
    ProjectLocationImpl().getGeoCoordinatedByProject(
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure,
        projectId: projectId);
  }


  Future<void> fetchProjectDetails(
      {required int projectId,
        required Function(List<ProjectDetailsModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}) async {
    ProjectDetailsRepositoryImpl().fetchProjectDetails(
        projectId: projectId,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

}