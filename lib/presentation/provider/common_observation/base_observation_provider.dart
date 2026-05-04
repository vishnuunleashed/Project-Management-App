import 'dart:async';
import 'dart:io';
import 'package:base/core/constants.dart';
import 'package:base/core/loader_value.dart';
import 'package:base/data/models/response/image_upload_response.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';
import 'package:interior_design/domain/usecase/close_observation/close_observation_usecase.dart';
import 'package:interior_design/data/model/response/close_observation/close_observation_model.dart';
import 'package:interior_design/presentation/view/close_observation/widgets/param_model.dart';
import 'package:interior_design/presentation/view/common/custom_bottom_bar.dart';
import 'package:interior_design/utils/firebase_tap_config.dart';
import 'package:interior_design/domain/usecase/close_support_request/close_support_request_usecase.dart';

class BaseObservationProvider extends BaseProvider {
  String selectedDate = '';
  List<AttachedDoc> attachments = [];
  bool isExpanded = false;
  // int parentOptionId = 0;
  int projectId = 0;
  int loginUserId = 0;
  int observationId = 0;

  // String optionName = "";
  String remarks = "";
  String submittedremarks = "";

  List<String> observerOptions = [];
  List<StatusModel> listOfStatus = [];
  List<AttachmentModel> attachmentUrl = [];
  List<AttachmentModel> attachmentUrlToBeUploaded = [];

  TextEditingController remarksController = TextEditingController();
  TextEditingController closedRemarksController = TextEditingController();
  TextEditingController submittedRemarksController = TextEditingController();
  String points = "";
  String observer = "";
  String owner = "";
  String projectName = "";
  String profileUrl = "";
  String observerUrl = "";
  String createdLabel = "";
  String statusLabel = "";
  String displayprofile = "";
  String displayprofilename = "";
  String transNo = "";
  String observationstatuscode = "";
  String ownername = "";
  String closedBy = "";
  String ownerprofileurl = "";
  String closedByProfileUrl = "";
  bool rightsyn = true;

  List<ObservationDetailModel> observationList = [];

  void initValues() {
    selectedDate = "";
    isExpanded = false;
    remarksController = TextEditingController(text: '');
    submittedRemarksController = TextEditingController(text: '');

    points = "";
    observer = "";
    closedBy = "";
    owner = "";
    transNo = "";
    projectName = "";
    closedByProfileUrl = "";
    profileUrl = "";
    observerUrl = "";
    createdLabel = "";
    statusLabel = "";
    displayprofile = "";
    displayprofilename = "";
    remarks = "";
    userName = "";
    isSuperUser = false;
    attachmentUrlToBeUploaded.clear();
    imagesDtl.clear();
    attachmentUrl.clear();
    notifyListeners();
  }

  String userName = "";
  bool isSuperUser = false;
  Future<void> getUserDetails() async{

    userName =  await BaseSecureStorage.getString(BaseConstants.userName);
    isSuperUser = await BaseSecureStorage.getBool(BaseConstants.superUserYN);
    notifyListeners();
  }

  void setObservationId(int id) {
    observationId = id;
    notifyListeners();
  }

  void setStatus(Status status){
    status = status;
    notifyListeners();
  }

  void setLoginUserId(int id) {
    loginUserId = id;
    notifyListeners();
  }

  void setProjectId(int id) {
    projectId = id;
    notifyListeners();
  }

  // void setOptionDtl({int? parentOptionId, required optionName}) {
  //   this.parentOptionId = parentOptionId ?? 0;
  //   this.optionName = optionName;
  //   notifyListeners();
  // }

  void fetchStatusTypes() {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    CloseObservationUseCase().fetchStatusTypes(onRequestSuccess: (result) {
      listOfStatus = result;

      notifyListeners();
      changeLoadingStatus(
          loadingStatus: LoadingStatus(
              loader: Loader.success, message: "Owners fetched successfully"));
    }, onRequestFailure: (exception) {
      changeLoadingStatus(
          loadingStatus:
          LoadingStatus(loader: Loader.error, exception: exception));
    });
  }



  //For fetching observation details
  void fetchObservationDetails() {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    CloseObservationUseCase().fetchObservationDetails(
        observationId: observationId,
        onRequestSuccess: (list) {
          observationList = list;
          closedRemarksController.text = list.first.remarks ?? '';
          submittedRemarksController.text = list.first.submittedremarks ?? '';
          remarks = list.first.remarks ?? "";
          submittedremarks = list.first.submittedremarks ?? "";
          selectedDate = list.first.formattedDateTransDate;
          observer = list.first.observername ;
          points = list.first.observationpoints ?? '';
          owner = list.first.ownername ?? '';
          transNo = list.first.transno ?? '';
          projectName = list.first.projectname ?? '';
          profileUrl = list.first.profileUrl ?? "";
          observerUrl = list.first.observerprofileurl ;
          createdLabel = list.first.createdLabel ?? "";
          statusLabel = list.first.statusLabel ?? "";
          displayprofilename = list.first.displayprofilename ?? "";
          displayprofile = list.first.displayprofile ?? "";
          rightsyn = list.first.rightsyn;
          observationstatuscode = list.first.observationstatuscode??"";
          ownername = list.first.ownername??"";
          ownerprofileurl = list.first.ownerprofileurl;
          closedByProfileUrl = list.first.closedByProfileUrl??"";
          closedBy = list.first.closedBy??"";
          activityGroupController.text = list.first.activitygroup ?? "";
          selectedActivityGroup = CommonMasterModel(id: list.first.activitygroupid ?? 0, description:  list.first.activitygroup ?? "", clientname: '', cityname: '', name: '', code: '', sortOrder: 0);
          sourceOfErrorController.text = list.first.sourceoferror ?? "";
          selectedSourceOfError = CommonMasterModel(id: list.first.sourceoferrorid ?? 0, description:  list.first.sourceoferror ?? "", clientname: '', cityname: '', name: '', code: '', sortOrder: 0);

          fetchSingleImageAttachmentsDetail(fileName: displayprofile);

          changeLoadingStatus(
              loadingStatus: LoadingStatus(
                  loader: Loader.success,
                  message: "Observation details fetched successfully"));
          if( list.first.attachmentjson != null
              && list.first.attachmentjson!.isNotEmpty) {

            List<AttachedDoc> imageListFirst = list.first.attachmentjson!
                .where(
                  (item) => (item.code ?? '').toUpperCase() == "GEN",
            )
                .map(
                  (item) => AttachedDoc(
                attachmentoriginalname: item.attachmentoriginalname,
                attachmentphysicalname: item.attachmentphysicalname,
              ),
            ).toList();

            if(imageListFirst.isNotEmpty){
              fetchAttachmentsDetail(
                attachmentList: imageListFirst,
              );
            }


            List<UploadResponse> imageList =  list.first.attachmentjson!
                .where((item) => item.code == "SUB")
                .map(
                  (item) => UploadResponse(
                physicalfilename:  item.attachmentphysicalname,
              ),
            ).toList();

            if(imageList.isNotEmpty){
              attachmentUrlToBeUploaded.clear();
              fetchAttachmentsDetailForUploadedImage(attachmentList: imageList);
            }


          }
          notifyListeners();
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus:
              LoadingStatus(loader: Loader.error, exception: exception));
        });
    notifyListeners();
  }

  //For view uploaded images
  Future<void> fetchAttachmentsDetail({
    required List<AttachedDoc> attachmentList,
  }) {
    final completer = Completer<void>();

    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));

    CloseObservationUseCase().fetchAttachmentsDetail(
      attachmentList: attachmentList,
      onRequestSuccess: (result) {
        attachmentUrl = result.attachmentUrl;
        notifyListeners();
        changeLoadingStatus(
            loadingStatus: LoadingStatus(loader: Loader.success));
        completer.complete();
      },
      onRequestFailure: (exception) {
        changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error));
        completer.completeError(exception);
      },
    );

    return completer.future;
  }

  void closeObservation(String status,
      {required Function onSuccess,
        required Function(AppException? exception) onFailure}) {
    int id = 0;
    String observationStatusCode = "";
    if (status == "Closed") {
      id = listOfStatus.any((status) => status.code == "CLOSED")
          ? listOfStatus.firstWhere((status) => status.code == "CLOSED").id ?? 14
          : 14;
      observationStatusCode = "CLOSED";
    }else if(status == "Pending"){
      id = listOfStatus.any((status) => status.code == "PENDING")
          ? listOfStatus.firstWhere((status) => status.code == "PENDING").id ?? 13
          : 13;
      observationStatusCode = "REQUEST_FOR_CLOSURE";
    }else if(status == "Reject"){
      id = listOfStatus.any((status) => status.code == "PENDING")
          ? listOfStatus.firstWhere((status) => status.code == "PENDING").id ?? 13
          : 13;
      observationStatusCode = "REJECT";
    } else {
      id = 0;
      observationStatusCode = "";
    }
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));

    CloseObservationUseCase().closeObservationSave(
        uploadedImages: imagesDtl,
        attachmentSeriesNo: attachmentSeriesNo,
        observationDetail: ObservationRawDataModel(
            observationid: observationId,
            statusid: id,
            remarks: remarksController.text,
            prevlogid: observationList.first.logid,
            statuscode: observationStatusCode
        ),
        onRequestSuccess: (result) {
          changeLoadingStatus(
              loadingStatus: LoadingStatus(
                  loader: Loader.success,
                  message: "Observation added successfully"));
          onSuccess();
          notifyListeners();
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus:
              LoadingStatus(loader: Loader.error, exception: exception));
          onFailure(exception);
        });
  }

  bool isFromNotification = false;
  void fromNotification(bool isFromNotification) {
    this.isFromNotification = isFromNotification;
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

    CloseSupportRequestUseCase().updateNotificationStatus(
      notificationId: notificationId??0,
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

  List<UploadResponse> imagesDtl = [];

  String attachmentSeriesNo="";

  void uploadImageFile(List<File> file) async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    await CloseObservationUseCase().uploadImageFile(
        file: file,
        uploadProgress: (progress){
          loadingProgress = progress;
          notifyListeners();
        },
        attachmentSerialNo: attachmentSeriesNo ,
        onRequestSuccess: (response) {
          imagesDtl.addAll(response);
          fetchAttachmentsDetailForUploadedImage(attachmentList: response);
          attachmentSeriesNo = response.last.serialno ?? "";
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error, exception: exception));
        });


  }

  String displayProfileUrl = "";
  void  fetchSingleImageAttachmentsDetail({
    required String fileName,
  }) {
    CloseObservationUseCase().fetchSingleImageAttachmentsDetail(
      fileName: fileName,
      isProfilePic: true,
      onRequestSuccess: (result) {
        if (result.attachmentUrl.first.key == fileName) {
          displayProfileUrl = result.attachmentUrl.first.url;
          notifyListeners();
        }
      },
      onRequestFailure: (exception) {
        changeLoadingStatus(
            loadingStatus: LoadingStatus(
                loader: Loader.error, exception: exception));
      },
    );
  }

    //For view uploaded images
  Future<void> fetchAttachmentsDetailForUploadedImage({
    required List<UploadResponse> attachmentList,
  }) {
    final completer = Completer<void>();

    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));

    CloseObservationUseCase().fetchAttachmentsDetailForUploadedFiles(
      attachmentList: attachmentList,
      onRequestSuccess: (result) {

        attachmentUrlToBeUploaded.addAll(result.attachmentUrl);

        changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
        completer.complete();
      },
      onRequestFailure: (exception) {
        changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error));
        completer.completeError(exception);
      },
    );

    return completer.future;
  }

  TextEditingController activityGroupController = TextEditingController();
  List<CommonMasterModel> activityGroupList = [];
  CommonMasterModel? selectedActivityGroup;

  TextEditingController sourceOfErrorController = TextEditingController();
  CommonMasterModel? selectedSourceOfError;

  void setActivityGroup(CommonMasterModel activityGroup) {
    selectedActivityGroup = activityGroup;
    activityGroupController.text = selectedActivityGroup?.description ?? "";
    notifyListeners();
  }

  void setSourceOfError(CommonMasterModel sourceOfError) {
    selectedSourceOfError = sourceOfError;
    sourceOfErrorController.text = selectedSourceOfError?.description ?? "";
    notifyListeners();
  }

  void fetchActivityGroup(){
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    CloseObservationUseCase().fetchActivityGroups(
        onRequestSuccess: (result){
          activityGroupList = result;
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception){
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error, exception: exception));
        });
  }

  void updateActivityStatus({required Function onSuccess}){
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    CloseObservationUseCase().updateActivityStatus(
        observationId: observationId,
        activityGroupId: (selectedActivityGroup?.id != null && selectedActivityGroup?.id != 0) ? selectedActivityGroup?.id : null ,
        sourceOfErrorId: (selectedSourceOfError?.id != null && selectedSourceOfError?.id != 0) ? selectedSourceOfError?.id : null,
        prevLogId: observationList.first.logid ?? 0,
        ownerId: null,
        remarks: "",
        onRequestSuccess: (){
          onSuccess();
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception){
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error,exception: exception));
        });
  }

  void clearTagsDialog(){
    if(observationList.first.activitygroupid != null){
      selectedActivityGroup =  CommonMasterModel(id: observationList.first.activitygroupid ?? 0, description:  observationList.first.activitygroup ?? "", clientname: '', cityname: '', name: '', code: '', sortOrder: 0);
      activityGroupController.text = observationList.first.activitygroup ?? "" ;
    }
    else{
      selectedActivityGroup = null;
      activityGroupController.clear();
    }

    if(observationList.first.sourceoferrorid != null){
      sourceOfErrorController.text = observationList.first.sourceoferror ?? "";
      selectedSourceOfError = CommonMasterModel(id: observationList.first.sourceoferrorid ?? 0, description:  observationList.first.sourceoferror ?? "", clientname: '', cityname: '', name: '', code: '', sortOrder: 0);
    }
    else{
      selectedSourceOfError = null;
      sourceOfErrorController.clear();
    }

    notifyListeners();
  }

  void clearActivityGroup(){
    selectedActivityGroup = null;
    activityGroupController.clear();
    notifyListeners();
  }

  void clearSourceOfError(){
    selectedSourceOfError = null;
    sourceOfErrorController.clear();
    notifyListeners();
  }



}
