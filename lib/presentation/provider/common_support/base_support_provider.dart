import 'dart:async';

import 'package:base/core/constants.dart';
import 'package:base/core/loader_value.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:interior_design/data/model/response/add_observation/add_observation_model.dart';
import 'package:interior_design/data/model/response/add_support_request/add_support_request_dept_model.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';
import 'package:interior_design/data/model/response/project_details/observation_model.dart';
import 'package:interior_design/data/model/response/project_details/support_request_model.dart';
import 'package:interior_design/domain/usecase/all_observation_and_support_request_usecase/all_observation_support_request_usecase.dart';
import 'package:interior_design/domain/usecase/close_support_request/close_support_request_usecase.dart';
import 'package:interior_design/domain/usecase/project_details/project_details_usecase.dart';
import 'package:interior_design/domain/usecase/view_support_request/view_support_request_usecase.dart';
import 'package:base/presentation_export.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_design/data/model/request/close_support_request/close_support_request_model.dart';
import 'package:interior_design/data/model/response/close_support_request/close_support_request_model.dart';
import 'package:interior_design/presentation/view/common/profile_picture_card.dart';
import 'package:interior_design/utils/firebase_tap_config.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import '../../../domain/usecase/add_support_request/add_support_request_usecase.dart';

class BaseSupportProvider extends BaseProvider {
  int supportRequestId = 0;
  int projectId = 0;
  String optionName = "";
  String requestDescription = "";
  String assignedRemarks = "";
  String assignedStatusCode = "";
  String escalatedByName = "";
  String dependencyDeptName = "";
  bool rightsyn = true;
  DateTime escalationDate = DateTime.now();
  DateTime expectedClosureDate = DateTime.now();
  List<CloseSupportRequestStatusModelObj> supportRequestStatusList = [];
  TextEditingController remarksController = TextEditingController(text: '');
  OwnerModel? selectedOwner;
  List<OwnerModel> owners = [];
  List<String> namesFromOwnerModel = [];
  List<ReqTrackJson> reqTrackList = [];
  List<ScheduleTaskDtlJson> scheduleTaskDtlJson = [];
  bool isTileExpanded = false;
  ScrollController  scrollController = ScrollController();

  void changeIsTileExpanded(bool value){
    isTileExpanded = value;
    notifyListeners();
  }


  int pageIndex =  0;



  void setSupportRequestId(int supportReqId) {
    supportRequestId = supportReqId;
    notifyListeners();
  }

  void onHorizontalDrag(DragEndDetails details) {

    // Swipe left → show next page
    if (details.primaryVelocity! < 0) {
      print("entered");
      if (pageIndex == 0) {
         pageIndex = 1;
      }
    }
    // Swipe right → show previous page
    else if (details.primaryVelocity! > 0) {
      if (pageIndex == 1) {
        pageIndex = 0;
      }
    }
    notifyListeners();
  }

  String formatDate(DateTime? date) {
    final now = DateTime.now();
    final target = date ?? now;

    if (target.year == now.year &&
        target.month == now.month &&
        target.day == now.day) {
      return "Today | ${DateFormat("hh:mm a").format(target)}";
    }

    return DateFormat('MMM dd, yyyy | hh:mm a').format(target);
  }

  String formatDateOrToday(DateTime? date) {
    final now = DateTime.now();
    final target = date ?? now;

    if (target.year == now.year &&
        target.month == now.month &&
        target.day == now.day) {
      return "Today";
    }

    return DateFormat('MMM dd, yyyy').format(target);
  }


 

  String userName = "";
  bool isSuperUser = false;
  int loginUserID = 0;
  Future<void> getUserDetails() async{

    userName =  await BaseSecureStorage.getString(BaseConstants.userName);
    isSuperUser = await BaseSecureStorage.getBool(BaseConstants.superUserYN);
    loginUserID = await BaseSecureStorage.getInt(BaseConstants.userID);
    print("loginUserID = $loginUserID");
    notifyListeners();
  }

  void initValues() {
    selectedOwner = null;
    requestDescription = "";
    assignedStatusCode = "";
    assignedRemarks = "";
    escalatedByName = "";
    dependencyDeptName = "";
    escalationDate = DateTime.now();
    expectedClosureDate = DateTime.now();
    remarksController = TextEditingController(text: '');
    commentController = TextEditingController(text: '');
    userName = "";
    isSuperUser = false;
    isTileExpanded = false;
    scrollController = ScrollController();
    //Fetch Status Dropdown
    pageIndex = 0;
    ccUsers = [];
    ccUsersWithUrl = [];
    fetchStatusDropDown();

    notifyListeners();
  }

  void setSelectedOwner(String name) {
    selectedOwner = owners.firstWhere((owner) => owner.name == name);
    notifyListeners();
  }


  //To Fetch Status Dropdown
  void fetchStatusDropDown() {

    ViewSupportRequestUseCase().fetchStatusDropdown(
        onRequestSuccess: (result) {
          supportRequestStatusList = result;

          //Remove status pending from status list as it is close support screen
          supportRequestStatusList.removeWhere((status) => status.code == "PENDING");

          //Fill Support request details
          fillSupportRequestDetails();

          notifyListeners();
        },
        onRequestFailure: (exception) {});
  }

  String targetClosureDate = "";

  String getRemainingTime(String targetClosureDate) {
    final targetDate = DateTime.parse(targetClosureDate);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);


    final difference = targetDate.difference(today).inDays;
    print("Difference = $difference");

    if (difference < 0) {
      return 'Delayed';
    } else if (difference == 0) {
      return 'Due today';
    }
    else if (difference == 1){
      return 'Due tomorrow';
    }
    else {
      return '$difference day${difference > 1 ? 's' : ''} left';
    }
  }
  SupportRequestFillModel? supportListData;
  List<CCUsers> ccUsers = [];
  List<ProfileItem> ccUsersWithUrl = [];
  String escalatedByProfileImageURL = '';
  //To fill support request details
  bool isFromCallTracker = false;
  void fillSupportRequestDetails() {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ViewSupportRequestUseCase().fillSupportRequestDetails(
        supportRequestId: supportRequestId,
        onRequestSuccess: (result) {
          supportListData = result.first;
          if(result.first.projectid == null || result.first.projectid == 0){
            isFromCallTracker = result.first.projectid == null || result.first.projectid == 0;
            notifyListeners();
          }
          requestDescription = result[0].requestDescription ?? '';
          assignedRemarks = result[0].assignedremarks ?? '';
          assignedStatusCode = result[0].assignedstatuscode ?? '';
          rightsyn = result[0].rightsyn;
          escalatedByName = result[0].escalatedByName ?? '';
          dependencyDeptName = result[0].dependencyDeptName ?? '';
          escalationDate = DateTime.parse(result[0].transDate ?? '');
          expectedClosureDate = DateTime.parse(result[0].targetClosureDate ?? '');
          projectId = result[0].projectid??0;
          fetchOwners();
          reqTrackList = result.first.reqtrackjson??[];
          targetClosureDate = getRemainingTime(result.first.targetClosureDate??"");
          scheduleTaskDtlJson = result.first.scheduletaskdtljson??[];
          ccUsers = result.first.ccUsers??[];

          ccUsers.forEach((item){
            if(item.profileimage == null || item.profileimage!.isEmpty){
              ccUsersWithUrl.add(ProfileItem(
                  name: item.username??"",
                  profileUrl: "",
                  profilePicSubtitle: loginUserID == item.userid?"You":item.username??""));
            }else{
              fetchSingleImageAttachmentsDetail(fileName: item.profileimage??"");
            }
          });
          if(result.first.escalatedbyprofileimage != null
              && result.first.escalatedbyprofileimage!.isNotEmpty){
            fetchSingleImageAttachmentsDetailEscalatedBy(fileName: result.first.escalatedbyprofileimage??"");
          }




          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
          notifyListeners();
        },
        onRequestFailure: (exception) {});
  }

  //Attachment section
  List<AttachmentModel> projectScheduleProfilePic = [];
  Future<void> fetchAttachmentsDetail({
    required List<AttachmentDetailObs> attachmentList,
  }) {
    final completer = Completer<void>();
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ProjectDetailsUseCase().fetchAttachmentsDetail(
      attachmentList: attachmentList,
      isProfilePic: true,
      onRequestSuccess: (result) {
        projectScheduleProfilePic = result.attachmentUrl;
        changeLoadingStatus(
            loadingStatus: LoadingStatus(loader: Loader.success));
        completer.complete();
      },
      onRequestFailure: (exception) {
        changeLoadingStatus(
            loadingStatus: LoadingStatus(loader: Loader.error,exception: exception));
        completer.completeError(exception);
      },
    );

    return completer.future;
  }


  void  fetchSingleImageAttachmentsDetail({
    required String fileName,
  }) {

    ProjectDetailsUseCase().fetchSingleImageAttachmentsDetail(
      fileName: fileName,
      isProfilePic: true,
      onRequestSuccess: (result) {
        for (var item in ccUsers) {
          if(result.attachmentUrl.first.key == item.profileimage.toString()){
            ccUsersWithUrl.add(ProfileItem(
                name: item.username??"",
                profileUrl: result.attachmentUrl.first.url,
                profilePicSubtitle: loginUserID == item.userid?"You":item.username??""));
            break;
          }
        }

      },
      onRequestFailure: (exception) {
        changeLoadingStatus(
            loadingStatus: LoadingStatus(loader: Loader.error,exception: exception));
      },
    );


  }

  void  fetchSingleImageAttachmentsDetailEscalatedBy({
    required String fileName,
  }) {

    ProjectDetailsUseCase().fetchSingleImageAttachmentsDetail(
      fileName: fileName,
      isProfilePic: true,
      onRequestSuccess: (result) {
        escalatedByProfileImageURL = result.attachmentUrl.first.url;
        },
      onRequestFailure: (exception) {
        changeLoadingStatus(
            loadingStatus: LoadingStatus(loader: Loader.error,exception: exception));
      },
    );


  }

  int? notificationId;
  void setNotificationId(int id){
    notificationId =  id;
    updateStatus();
  }

  void updateStatus(){
    if(notificationId == null || notificationId == 0){
      return;
    }
    ViewSupportRequestUseCase().updateNotificationStatus(
        notificationId: notificationId??0,
        onRequestSuccess: (notificationIdlList){
          print("Success__vishnu");

          removeNotificationUsingIdList(notificationIdlList);


        },
        onRequestFailure: (exception){
          print("failure");
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error,exception: exception));
        });
  }



  bool isFromNotification = false;
  void fromNotification(bool isFromNotification) {
    this.isFromNotification = isFromNotification;
    notifyListeners();
  }

  List<OwnerModel> ownerDetails=[];
  void fetchOwners() {

    ViewSupportRequestUseCase().fetchOwners(
        projectId: projectId,
        excludeLoginUser: false,
        onRequestSuccess: (result) {
          owners = result;

          fetchDepartmentDropDown();

        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.error, exception: exception));
        });
  }

  List<DepartmentDropDownObj> departmentList = [];
  void fetchDepartmentDropDown() {
    CloseSupportRequestUseCase().fetchDepartmentDropDown(
        onRequestSuccess: (result) {
          departmentList = result;
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
          if(departmentList.isNotEmpty){
            ownerDetails = owners;
          }
          final escalatedById = supportListData?.escalatedById;
          final toUserId = supportListData?.assignedToUserId;
          ownerDetails.removeWhere((owner) =>
          owner.id == escalatedById || owner.id == toUserId);
          notifyListeners();
        },
        onRequestFailure: (exception) {});


  }

  TextEditingController commentController = TextEditingController();

  void followSupportRequest({required int supportId,required Function() onRequestSuccess,}){
    AllObservationAndSupportUseCase().followSupportRequest(
        supportId: supportId,
        onRequestSuccess: (){
          onRequestSuccess();
        },
        onRequestFailure: (exception)=>
            changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error,message: exception.toString()),)
    );
  }
  void sendCommentSupportTrack(){
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    CloseSupportRequestUseCase().sendCommentSupportTrack(
        comment: commentController.text,
        supportId: supportRequestId,
        onRequestSuccess: (){
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
          commentController.clear();
          followSupportRequest(
              supportId: supportRequestId,
              onRequestSuccess: (){

              }
          );
          fillSupportRequestDetails();
        },
        onRequestFailure: (exception) {
      changeLoadingStatus(
          loadingStatus: LoadingStatus(loader: Loader.error, exception: exception));
    });
  }
}
