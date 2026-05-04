import 'dart:io';

import 'package:base/data/models/response/image_upload_response.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:flutter/cupertino.dart';
import 'package:interior_design/data/model/request/material_chart/update_status_model.dart' show ProjectApprovalModel;
import 'package:interior_design/data/model/response/add_observation/add_observation_model.dart';
import 'package:interior_design/data/model/response/close_observation/read_status_update_dto.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/model/response/material_chart/additional_material_chart_model.dart';
import 'package:interior_design/data/model/response/material_chart/additional_material_detail_model.dart';
import 'package:interior_design/data/model/response/material_chart/all_reason_type_mode.dart';
import 'package:interior_design/data/model/response/material_chart/brand_model.dart';
import 'package:interior_design/data/model/response/material_chart/material_chart_model.dart';
import 'package:interior_design/data/model/response/material_chart/uom_model.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';
import 'package:interior_design/data/model/response/project_details/project_details_model.dart';
import 'package:interior_design/data/remote/repository/add_observation/add_observation_repository_impl.dart';
import 'package:interior_design/data/remote/repository/close_support_request/close_support_request_repository_impl.dart';
import 'package:interior_design/data/remote/repository/material_chart/material_chart_impl.dart';
import 'package:interior_design/data/remote/repository/project_details/project_details_repository_impl.dart';
import 'package:interior_design/presentation/view/material_chart/model/params_model.dart';
import 'package:interior_design/presentation/view/material_chart/model/quantity_update_model.dart';
import 'package:interior_design/presentation/view/material_chart/partials/upload_model.dart';

class MaterialChartUseCase{

  void fetchMaterialChart(
      {required int projectId,
        required Function(List<MaterialDetailsWrapperModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}){
    MaterialChartImpl().fetchMaterialChart(
        projectId: projectId,
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
  void getUoms(
      {
        required Function(List<UomModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}){
    MaterialChartImpl().getUoms(
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }


  void getReasonType(
      {required Function(List<CommonMasterModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}){
    MaterialChartImpl().getReasonType(
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }


  void getBrandType(
      {required Function(List<BrandResultObject>) onRequestSuccess,
        required Function(AppException) onRequestFailure}){
    MaterialChartImpl().getBrandType(
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }



  void fetchOwners(
      {required int projectId,
        bool excludeLoginUser = false,
        required Function(List<OwnerModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}){
    AddObservationRepositoryImpl().fetchOwners(
        projectId: projectId,
        excludeLoginUser: excludeLoginUser,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void updateIGFCQuantity({
    required UploadModel  uploadModel ,
    required Function() onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  }){
    MaterialChartImpl().updateIGFCQuantity(
        uploadModel: uploadModel,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void verifyIGFCQuantities({
    required int projectId,
    required Function() onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  }){
    MaterialChartImpl().verifyIGFCQuantities(
        projectId: projectId,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }
  void saveMaterial({
    required AddMaterialChartRequest addMaterialChartRequest,
    required Function() onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  }){
    MaterialChartImpl().saveMaterial(
        addMaterialChartRequest: addMaterialChartRequest,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void fetchAdditionalMaterialChart(
      {required int projectId,
        required String flag,
        required String teamYn,
        required int userId,
        required Function(List<MaterialRequestModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}) {
    MaterialChartImpl().fetchAdditionalMaterialChart(
        projectId: projectId,
        flag: flag,
        userId: userId,
        teamYn: teamYn,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }
  void updateQuantityAdditionMaterial({
    required MaterialQtyUpdateRequest materialQtyUpdateRequest,
    required Function() onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  })  {
    MaterialChartImpl().updateQuantityAdditionMaterial(
        materialQtyUpdateRequest: materialQtyUpdateRequest,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

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

  void getRoleWiseReasonListByUser(
      {required Function(List<ProjectRoleOptionModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}){
    MaterialChartImpl().getRoleWiseReasonListByUser(
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void updateStatus(
      {required ProjectApprovalModel statusModel,
        required Function(String) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}){
    MaterialChartImpl().updateStatus(
        statusModel: statusModel,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void fetchDetailedAdditionalMaterial(
      {
        required int id,
        required Function(List<MaterialRequestModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}){
    MaterialChartImpl().fetchDetailedAdditionalMaterial(

        id: id,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void updateNotificationStatus(
      {
        required int notificationId,
        required Function(int) onRequestSuccess,
        required Function(AppException) onRequestFailure}
      ){
    CloseSupportRequestRepositoryImpl().updateNotificationStatus(
       notificationId: notificationId,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);


  }

}