/*------------------------------------------------------------------------------
AUTHOR		    : Favas k
CREATED DATE	: 09/08/2025
PURPOSE		    :
MODULE/TOPIC	: IN0010-25
REMARKS		    :
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		    MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
import 'dart:async';
import 'package:base/core/constants.dart';
import 'package:base/core/loader_value.dart';
import 'package:base/data/models/response/image_upload_response.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/data/model/request/add_observation/add_observation_model.dart';
import 'package:interior_design/data/model/response/add_support_request/add_support_request_dept_model.dart';
import 'package:interior_design/data/model/response/close_observation/close_observation_model.dart';
import 'package:interior_design/data/model/response/home/home_projectlist_model.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';
import 'package:interior_design/data/model/response/project_details/project_details_model.dart';
import 'dart:io';
import 'package:interior_design/domain/usecase/add_observation/add_observation_usecase.dart';
import 'package:interior_design/data/model/response/add_observation/add_observation_model.dart';
import 'package:interior_design/presentation/view/close_observation/widgets/param_model.dart';


class AddObservationProvider extends BaseProvider {
  OwnerModel? selectedOwner;
  int? parentOptionId;
  int? projectId;
  String optionName = "";
  String attachmentSeriesNo="";
  List<AttachmentModel> imageUploaded = [];
  List<OwnerModel> owners = [];



  List<UploadResponse>  images = [];
  List<AttachmentModel>  attachmentUrl = [];
  TextEditingController obsOwnerController = TextEditingController();
  List<DepartmentDropDownObj> departmentList = [];

  TextEditingController observationPointsController = TextEditingController();

  int loggedInUserId = 0;
  String loggedInUserName = "";
  String ownerNameFromMOM = "";
  bool isFromMOM = false;
  int? actionItemId;

  Future<void> initValues() async {
    selectedOwner = null;
    images = [];
    attachmentUrl = [];
    observationList = [];
    attachmentSeriesNo="";
    ownerNameFromMOM = "";
    observationPointsController = TextEditingController();
    obsOwnerController = TextEditingController();
    departmentList = [];
    isFromMOM = false;
    actionItemId = null;
    loggedInUserId = await BaseSecureStorage.getInt(BaseConstants.userID);
    loggedInUserName = await BaseSecureStorage.getString(BaseConstants.userName);
    notifyListeners();
  }


  List<ObservationDetailModel> observationList = [];
  void setParameter(Map<String, dynamic>? extra) {
    if(extra != null && extra["observationList"] != null){
      observationList.add(extra["observationList"]);
      setProjectId(observationList.first.projectid??0);
      List<UploadResponse> attachmentList = [];
      if(observationList.first.attachmentjson != null
          && observationList.first.attachmentjson!.isNotEmpty) {
        attachmentList = observationList.first.attachmentjson!.map((e) =>
            UploadResponse(physicalfilename: e.attachmentphysicalname)
        ).toList();
        if(attachmentList.isNotEmpty){
          fetchAttachmentsDetail(attachmentList: attachmentList);
        }
      }

      observationPointsController.text = observationList.first.observationpoints??"";

    }else{
      setProjectId(extra!["projectId"]??0);
      if(extra["observationPoint"] != null){
        setObservationPoint(extra["observationPoint"]);
      }
      if(extra["owner"] != null){
        ownerNameFromMOM = extra["owner"] ?? "";
      }
      if(extra["isFromMOM"] != null){
        isFromMOM = extra["isFromMOM"];
        actionItemId = extra["actionItemId"];
      }
    }
    fetchOwners();

  }
  void addImage(List<UploadResponse> file) {
    images.addAll(file);
    attachmentUrl.addAll(
        file.map((e) => AttachmentModel(url: e.url ?? "")).toList()
    );
    notifyListeners();
  }

  void removeAt(int index) {
    if (index < 0 || index >= images.length) return;
    images.removeAt(index);
    notifyListeners();
  }

  void clearImages() {
    images.clear();
    notifyListeners();
  }

  void setSelectedOwner(String name) {
    selectedOwner = owners.firstWhere((owner) => owner.name == name);
    obsOwnerController = TextEditingController(text: name);
    notifyListeners();
  }


  void setProjectId(int id) {
    projectId = id;
    notifyListeners();
    fetchProjectDetails(projectId: projectId??0);
  }

  void setObservationPoint(String point) {
    observationPointsController.text = point;
    notifyListeners();
  }


  void setOptionDtl({required UserRightsModel optionObj}) {
    parentOptionId = optionObj.rightsData[0].parentOptionId ;
    optionName = optionObj.optionName!;
    notifyListeners();
  }

  void fetchOwners() {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    AddObservationUseCase().fetchOwners(
        projectId: projectId ?? 0,

        onRequestSuccess: (result) {
          final loggedInUser = result.firstWhere(
                (u) => u.id == loggedInUserId,
          );

          owners = result.where((item) {
            if (item.id == loggedInUserId) return false;
            if (loggedInUser.siteinchargeyn == "Y") {
              return item.siteinchargeyn != "Y";
            }
            return true;
          }).toList();

          if(observationList.isNotEmpty){
            owners.removeWhere((item){return item.id == observationList.first.observerid;});
          }
          fetchDepartmentDropDown();
          if(ownerNameFromMOM != "" && ownerNameFromMOM != loggedInUserName ) {
            setSelectedOwner(ownerNameFromMOM);
          }
          notifyListeners();
          changeLoadingStatus(
              loadingStatus:
                  LoadingStatus(loader: Loader.success, message: "Owners fetched successfully"));
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.error, exception: exception));
        });
  }

  List<ProjectDetailsModel> projectDetailList = [];

  Future<void> fetchProjectDetails({required int projectId}) async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    AddObservationUseCase().fetchProjectDetails(
        projectId: projectId,
        onRequestSuccess: (result) {
          projectDetailList = result;
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.success));

        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.error));
        });
    notifyListeners();
  }




  void uploadImageFile(List<File> file) async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    await AddObservationUseCase().uploadImageFile(
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

  //For view uploaded images
  Future<void> fetchAttachmentsDetail({
    required List<UploadResponse> attachmentList,
  }) {
    final completer = Completer<void>();

    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));

    AddObservationUseCase().fetchAttachmentsDetail(
      attachmentList: attachmentList,
      onRequestSuccess: (result) {
        attachmentUrl.addAll(result.attachmentUrl);
        notifyListeners();
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


  void addObservation({required Function({required String transNo}) onSuccess,required Function(AppException? exception) onFailure}) {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    final request = AddObservationRequest(
      optionId: parentOptionId ?? 0,
      projectId: projectId ?? 0,
      ownerId: selectedOwner?.id ?? 0,
      observationPoints: observationPointsController.text,
      seriesNo: attachmentSeriesNo,
      imagesDtl: images,
      isFromMOM: isFromMOM,
      actionItemId: actionItemId,
    );

    AddObservationUseCase().addObservationSave(
        request: request,
        onRequestSuccess: ({required String transNo}) {
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success,message: "Observation added successfully"));
          onSuccess(transNo: transNo);
          notifyListeners();
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success,exception: exception));
          onFailure(exception);
        });
  }

  void updateStatus(
      {required Function(String) onSuccess,
        required Function(AppException? exception) onFailure}) {
    int id = 0;
    String observationStatusCode = "ASSIGN";

    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));

    AddObservationUseCase().updateStatus(
        uploadedImages: images,
        attachmentSeriesNo: attachmentSeriesNo,
        observationDetail: ObservationRawDataModel(
            observationid: observationList.first.id??0,
            statusid: id,
            remarks: observationPointsController.text,
            prevlogid: observationList.first.logid,
            statuscode: observationStatusCode,
          ownerId: selectedOwner?.id??0
        ),
        onRequestSuccess: (result) {

          onSuccess(observationList.first.transno??"");
          notifyListeners();
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception) {
          onFailure(exception);
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
        });
  }


  void fetchDepartmentDropDown() {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    AddObservationUseCase().fetchDepartmentDropDown(
        onRequestSuccess: (result) {
          departmentList = result;
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
          notifyListeners();
        },
        onRequestFailure: (exception) {});
  }

}

