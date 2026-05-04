import 'dart:io';
import 'package:base/data/models/response/image_upload_response.dart';
import 'package:base/data_export.dart';
import 'package:interior_design/data/model/request/add_observation/add_observation_model.dart';
import 'package:interior_design/data/model/response/add_observation/add_observation_model.dart';
import 'package:interior_design/data/model/response/add_support_request/add_support_request_dept_model.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';
import 'package:interior_design/data/model/response/project_details/project_details_model.dart';
import 'package:interior_design/data/remote/repository/add_observation/add_observation_repository_impl.dart';
import 'package:interior_design/data/remote/repository/add_support_request/add_support_request_repository_impl.dart';
import 'package:interior_design/data/remote/repository/project_details/project_details_repository_impl.dart';
import 'package:interior_design/presentation/view/close_observation/widgets/param_model.dart';

class AddObservationUseCase {
  factory AddObservationUseCase() => _instance;
  static final AddObservationUseCase _instance = AddObservationUseCase._internal();
  AddObservationUseCase._internal();
//For fetching owners
  void fetchOwners(
      {required int projectId,
        required Function(List<OwnerModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}){
    AddObservationRepositoryImpl().fetchOwners(
        projectId: projectId,
        excludeLoginUser: false,
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

  Future<void> fetchAttachmentsDetail(
      {required List<UploadResponse> attachmentList,
        required Function(AttachmentResponseModel) onRequestSuccess,
        required Function(AppException) onRequestFailure}
      )async{
    AddObservationRepositoryImpl().fetchAttachmentsDetail(
        attachmentList: attachmentList,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  //For adding observation to server
  void addObservationSave(
      { required AddObservationRequest request,
        required Function({required String transNo}) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}){
    AddObservationRepositoryImpl().addObservationSave(
        request: request,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  //For fetching department
  void fetchDepartmentDropDown(
      { required Function(List<DepartmentDropDownObj> departmentList) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}) {
    AddSupportRequestRepositoryImpl().fetchDepartmentDropDown(
        onRequestSuccess: onRequestSuccess, onRequestFailure: onRequestFailure);
  }
  void updateStatus(
      {required List<UploadResponse> uploadedImages,
        required String attachmentSeriesNo,
        required ObservationRawDataModel observationDetail,
        required Function(String) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}){
    AddObservationRepositoryImpl().updateStatus(
        uploadedImages: uploadedImages,
        attachmentSeriesNo: attachmentSeriesNo,
        observationDetail: observationDetail,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
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
