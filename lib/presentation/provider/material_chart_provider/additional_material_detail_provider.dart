import 'dart:io';

import 'package:base/core/constants.dart';
import 'package:base/core/loader_value.dart';
import 'package:base/data/models/response/image_upload_response.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:flutter/material.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:interior_design/data/model/request/material_chart/update_status_model.dart';
import 'package:interior_design/data/model/response/material_chart/additional_material_chart_model.dart';
import 'package:interior_design/data/model/response/material_chart/additional_material_detail_model.dart';
import 'package:interior_design/data/model/response/material_chart/all_reason_type_mode.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';
import 'package:interior_design/domain/usecase/material_chart/material_chart_usecase.dart';
import 'package:interior_design/presentation/provider/material_chart_provider/additional_material_chart_main_provider.dart';
import 'package:interior_design/utils/firebase_tap_config.dart';

class AdditionalMaterialDetailProvider extends AdditionalMaterialMainProvider {
  // Material item data
  List<MaterialRequestModel> materialItem = [];
  TextEditingController qtyController = TextEditingController(text: "");
  
  // Permission flags
  bool approveColumnYN = false;
  bool isDisableBtn = false;
  bool showApproveBtn = false;
  bool showRejectBtn = false;
  bool showReworkBtn = false;
  bool showResubmitBtn = false;
  
  // User and project info
  // int loggedInUserID = 0;
  // int projectId = 0;
  // bool isSuperUser = false;
  // bool isProjectDepartment = false;
  


  
  // Loading states
  bool isLoading = false;
  bool isUpdatingStatus = false;
  
  // Error handling
  String? errorMessage;

  int materialId = 0;
  Future<void> setParameters({Map<String, dynamic>? extra}) async {
    reset();
    materialId = int.parse(extra!["transid"].toString()??"0");
    if(extra["projectid"] != null){
      projectId = int.parse(extra["projectid"].toString()??"0");
    }
    loggedInUserID = await BaseSecureStorage.getInt(BaseConstants.userID);
    isSuperUser = await BaseSecureStorage.getBool(BaseConstants.superUserYN);
    isProjectDepartment = await BaseSecureStorage.getString(BaseConstants.departmentCode) == "PRJ";

    initializeWithItem();
  }


  // Initialize with material item
  void initializeWithItem() {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    MaterialChartUseCase().fetchDetailedAdditionalMaterial(
        id: materialId,
        onRequestSuccess: (result){
          if(result.isNotEmpty){
            materialItem = result;
            projectId = materialItem.first.projectId;
            qtyController.text = "${materialItem.first.qty}";

            getRoleWiseReasonListByUser();
          }
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error, exception: exception));
        });
    notifyListeners();
  }


  int? notificationId;
  void setNotificationId(int id){
    notificationId =  id;
    updateNotificationStatus();
  }

  void updateNotificationStatus() {
    if(notificationId == null || notificationId == 0){
      return;
    }
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));


    MaterialChartUseCase().updateNotificationStatus(
        notificationId:notificationId??0,
        onRequestSuccess: (notificationId) {

          removeNotificationUsingIdList(notificationId);

          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus:
              LoadingStatus(loader: Loader.error, exception: exception));
        });
  }
  // Set user permissions and project info
  void setUserPermissions({
    required int userId,
    required int pId,
    required bool superUser,
    required bool projectDept,
    required List<ProjectRoleOptionModel> roleOptions,
  }) {
    loggedInUserID = userId;
    projectId = pId;
    isSuperUser = superUser;
    isProjectDepartment = projectDept;
    projectRoleOptionList = roleOptions;
    
    // Recalculate permissions after setting user info
    if (materialItem.isNotEmpty) {
      calculatePermissions();
    }
    notifyListeners();
  }
  List<ProjectRoleOptionModel> projectRoleOptionList = [];
  void getRoleWiseReasonListByUser(){
    MaterialChartUseCase().getRoleWiseReasonListByUser(
        onRequestSuccess: (result){
          projectRoleOptionList = result;

          setUserPermissions(
            userId: loggedInUserID ,
            pId: projectId,
            superUser: isSuperUser,
            projectDept: isProjectDepartment,
            roleOptions: result,
          );
          notifyListeners();
        },
        onRequestFailure: (exception){
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error,exception: exception));
        });
  }

  // Calculate all permissions based on current state
  void calculatePermissions() {
    if (materialItem.isEmpty) return;

    // Calculate approveColumnYN
    approveColumnYN = hasMatchingSubtype(
      reasonRoleList: projectRoleOptionList,
      item: materialItem.first,
    );

    final String recStatus = materialItem.first.approvalStatus ?? "";
    final bool isApproved = materialItem.first.approvalYn == 'Y';

    // Calculate disable button
    isDisableBtn = isApproved ||
        recStatus == 'REJECTED' ||
        (!approveColumnYN &&
            recStatus == 'SEND_BACK' &&
            !isProjectDepartment) ||
        (!approveColumnYN && recStatus != 'SEND_BACK');

    // Calculate show approve button
    showApproveBtn = (recStatus == 'PENDING' && approveColumnYN) ||
        (recStatus == 'RESUBMITTED' && approveColumnYN) ||  // Add this line
        (!isDisableBtn &&
            recStatus != 'SEND_BACK' &&
            (isSuperUser || loggedInUserID == materialItem.first.requestedBy));

// Calculate show reject button
    showRejectBtn = (recStatus == 'PENDING' && approveColumnYN) ||
        (recStatus == 'RESUBMITTED' && approveColumnYN) ||  // Add this line
        (!isDisableBtn &&
            recStatus != 'SEND_BACK' &&
            (isSuperUser || loggedInUserID == materialItem.first.requestedBy));

    // Calculate show rework button
    showReworkBtn = (recStatus == 'PENDING' && approveColumnYN) ||
        (!isApproved &&
            recStatus != 'REJECTED' &&
            recStatus != 'SEND_BACK' &&
            (isSuperUser || approveColumnYN));

    // Calculate show resubmit button
    showResubmitBtn = recStatus == 'SEND_BACK' && isProjectDepartment;

    notifyListeners();
  }

  // Check if user has matching subtype
  bool hasMatchingSubtype({
    required List<ProjectRoleOptionModel>? reasonRoleList,
    required MaterialRequestModel item,
  }) {
    if (reasonRoleList == null || reasonRoleList.isEmpty) {
      return false;
    }

    final Set<int> subtypeSet =
        reasonRoleList.map((e) => e.subtypeid ?? 0).toSet();

    return subtypeSet.contains(item.reasonTypeId);
  }

  // Update material item after status change
  // void updateMaterialItem(MaterialRequestDetailedModel updatedItem) {
  //   materialItem = updatedItem;
  //   calculatePermissions();
  //   notifyListeners();
  // }

  // Set loading state
  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }

  // Set status updating state
  void setStatusUpdating(bool updating) {
    isUpdatingStatus = updating;
    notifyListeners();
  }

  // Set error message
  void setError(String? error) {
    errorMessage = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  // Reset provider state
  void reset() {
    materialItem = [];
    approveColumnYN = false;
    isDisableBtn = false;
    showApproveBtn = false;
    showRejectBtn = false;
    showReworkBtn = false;
    showResubmitBtn = false;
    loggedInUserID = 0;
    projectId = 0;
    isSuperUser = false;
    isProjectDepartment = false;
    projectRoleOptionList = [];
    isLoading = false;
    isUpdatingStatus = false;
    errorMessage = null;
    images = [];
    attachmentUrl = [];
    notifyListeners();
  }

  // Check if any action button should be shown
  bool hasAnyActionButton() {
    return showApproveBtn || showRejectBtn || showReworkBtn || showResubmitBtn;
  }

  // Get status color
  Color getStatusColor() {
    if (materialItem.isEmpty) return bayaInfraGreyColor;

    final status = materialItem.first.approvalStatus?.toUpperCase() ?? "";

    switch (status) {
      case "PENDING":
        return Color(0xFFFF8C00);
      case "APPROVED":
        return Color(0xff28A745);
      case "SEND_BACK":
      case "SENDBACK":
        return Color(0xffC9B037);
      case "REJECTED":
        return Color(0xffDC3545);
      case "RESUBMITTED":
        return Color(0xff007BFF);
      default:
        return bayaInfraGreyColor;
    }
  }

  // Get status icon
  IconData getStatusIcon() {
    if (materialItem.isEmpty) return Icons.help_outline;

    final status = materialItem.first.approvalStatus?.toUpperCase() ?? "";

    switch (status) {
      case "PENDING":
        return Icons.pending_outlined;
      case "APPROVED":
        return Icons.check_circle_outline;
      case "SEND_BACK":
      case "SENDBACK":
        return Icons.replay;
      case "REJECTED":
        return Icons.cancel_outlined;
      case "RESUBMITTED":
        return Icons.refresh;
      default:
        return Icons.help_outline;
    }
  }

  // Get display status text
  String getDisplayStatus() {
    if (materialItem.isEmpty) return "";

    final status = materialItem.first.approvalStatus?.toUpperCase() ?? "";

    switch (status) {
      case "SEND_BACK":
      case "SENDBACK":
        return "SEND BACK";
      default:
        return status;
    }
  }

  // Check if PO is issued
  bool isPOIssued() {
    return materialItem.first.poIssuedYn == "Y";
  }

  // Check if material is approved
  bool isApproved() {
    return materialItem.first.approvalYn == "Y";
  }

  // Check if quantity is received
  bool isQuantityReceived() {
    return materialItem.first.receivedYn == "Y";
  }

  // Check if attachments exist
  bool hasAttachments() {
    return materialItem.first.attachments.isNotEmpty ?? false;
  }

  // Get attachment count
  int getAttachmentCount() {
    return materialItem.first.attachments.length ?? 0;
  }

  // Get attachment URLs
  List<String> getAttachmentUrls() {
    if (materialItem.isEmpty) return [];
    return materialItem.first.attachments
        .map((e) => e.attachmentPhysicalNameUrl??"")
        .toList();
  }

  void updateStatus({
    required ProjectApprovalModel statusModel,
    required Function(String) onSuccess,
    required Function(AppException? exception) onFailure}) {

    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    MaterialChartUseCase().updateStatus(
        statusModel: statusModel,
        onRequestSuccess: (message){
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
          onSuccess(message);
        },
        onRequestFailure: (exception){
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
          onFailure(exception);
        });
  }



  String attachmentSeriesNo = '';
  void uploadImageFile(List<File> file) async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    await MaterialChartUseCase().uploadImageFile(
        file: file,
        uploadProgress: (progress){
          loadingProgress = progress;
          notifyListeners();
        },
        attachmentSerialNo: attachmentSeriesNo ,
        onRequestSuccess: (response) {
          addImage(response);
          attachmentSeriesNo = response.last.serialno ?? "";
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error, exception: exception));
        });

  }
  List<UploadResponse>  images = [];
  List<AttachmentModel>  attachmentUrl = [];

  void addImage(List<UploadResponse> file) {
    images.addAll(file);
    attachmentUrl.addAll(
        file.map((e) => AttachmentModel(url: e.url ?? "")).toList()
    );
    notifyListeners();
  }

  void initDialog() {
    images = [];
    attachmentUrl = [];
    notifyListeners();
  }
}
