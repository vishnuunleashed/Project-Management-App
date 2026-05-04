import 'dart:async';
import 'package:base/core/constants.dart';
import 'package:base/core/loader_value.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/data/model/request/project_details/date_range_model.dart';
import 'package:interior_design/data/model/response/add_observation/add_observation_model.dart';
import 'package:interior_design/data/model/response/project_details/observation_model.dart';
import 'package:interior_design/data/model/response/project_details/project_details_model.dart';
import 'package:interior_design/domain/usecase/add_support_request/add_support_request_usecase.dart';
import 'package:interior_design/domain/usecase/all_observation_and_support_request_usecase/all_observation_support_request_usecase.dart';
import 'package:interior_design/domain/usecase/project_details/project_details_usecase.dart';
import 'package:interior_design/presentation/provider/common_support/base_support_provider.dart';


import 'package:interior_design/presentation/view/common/custom_bottom_bar.dart';
import 'package:intl/intl.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';

class BaseAllObservationProvider extends BaseProvider {


  //Observation related section
  List<ObservationDtlModel> observationList = [];
  DateTime obsDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime obsDateTo = DateTime.now();
  DateTime? tempObsDateFrom;
  DateTime? tempObsDateTo;
  bool? tempIsShowAllObs;
  bool isShowAllObs = true;
  bool obsRangeFilterApplied = false;
  DateRangeModel? selectedObsRange;
  String? selectedObsRangeLabel;
  bool isSuperUserObsOnly = false;
  int obsStart = 0;
  int obsLimit = 20;
  int observationTotalRecords = 0;
  bool observationFetched = false;
  ScrollController observationScrollController = ScrollController();
  PageController pageController = PageController();

  TextEditingController filterPointsController = TextEditingController();
  TextEditingController filterTransNoController = TextEditingController();

  String tag = "OPENED";
  bool isFromDashboard = false;
  String raisedUser = "";
  String userprofileurl = "";

  void initState(){
    observationList = [];
    obsDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
    obsDateTo = DateTime.now();
    tempObsDateFrom = null;
    tempObsDateTo = null;
    tempIsShowAllObs = null;
    isShowAllObs = true;
    obsRangeFilterApplied = false;
    selectedObsRange = null;
    selectedObsRangeLabel = "";
    isSuperUserObsOnly = false;
    obsStart = 0;
    obsLimit = 20;
    observationTotalRecords = 0;
    observationFetched = false;
    observationScrollController = ScrollController();
    userName = "";
    isSuperUser = false;
    tag = "OPENED";
    isFromDashboard = false;
    raisedUser = "";
    userId = null;
    selectedOwner = null;
    filterPointsController = TextEditingController(text: "");
    filterTransNoController = TextEditingController(text: "");
    obsOwnerController = TextEditingController(text: "");
    notifyListeners();

  }

  AllObservationAndSupportStatus bottomBarStatus = AllObservationAndSupportStatus.opened;
  int projectId = 0;
  int? userId;

  void setNavigationParameters({required Map<String, dynamic> extra}){
    bottomBarStatus = extra["bottomBarStatus"];
    projectId = extra["projectId"];
    userId = extra['userId'];
    raisedUser = extra['raisedUser'] ?? "";
    userprofileurl = extra['userprofileurl']??"";
    isFromDashboard = (userId == null) ? false : true;
    notifyListeners();
    fetchProjectDetails(projectId: projectId);
    fetchObservationList(changeStart: true);
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

  String userName = "";
  bool isSuperUser = false;
  Future<void> getUserDetails() async{
    userName =  await BaseSecureStorage.getString(BaseConstants.userName);
    isSuperUser = await BaseSecureStorage.getBool(BaseConstants.superUserYN);
    notifyListeners();
  }


  //Attachments
  //Attachment section
  List<AttachmentModel> attachmentUrl = [];
  Future<void> fetchAttachmentsDetail({
    required List<AttachmentDetailObs> attachmentList,
  }) {
    final completer = Completer<void>();
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ProjectDetailsUseCase().fetchAttachmentsDetail(
      attachmentList: attachmentList,
      onRequestSuccess: (result) {
        attachmentUrl = result.attachmentUrl;
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


  int currentTabIndex = 0;
  void onTapSelected(int index) {
    if(currentTabIndex != index) {
      currentTabIndex = index;

      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      clearObservationFilter(isFromClearButton: true,isFromRangeFilter: true);
      fetchObservationList(changeStart: true);

      notifyListeners();
    }
  }

  void clearObservationFilter({required bool isFromClearButton,bool isFromRangeFilter = false}) {
    if(isFromClearButton) {
      obsDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
      obsDateTo = DateTime.now();
      tempObsDateFrom = null;
      tempObsDateTo = null;
      isShowAllObs = true;
      tempIsShowAllObs = null;
      isSuperUserObsOnly = false;
      selectedOwner = null;
      filterPointsController = TextEditingController(text: "");
      filterTransNoController = TextEditingController(text: "");
      obsOwnerController = TextEditingController(text: "");
      if(isFromRangeFilter){
        selectedObsRange = null;
        obsRangeFilterApplied = false;
        selectedObsRangeLabel = "";
      }

    }
    else{
      tempObsDateFrom = null;
      tempObsDateTo = null;
      tempIsShowAllObs = null;
    }
    notifyListeners();
  }

  void onTapBottomSelected(AllObservationAndSupportStatus status) {
    bottomBarStatus = status;
    fetchObservationList(changeStart: true);
    notifyListeners();
  }


  bool isObsLoadingMore = false;
  bool hasMoreObsData = true;

  void initObsScrollListener() {
    observationScrollController.addListener(() {
      if (observationScrollController.position.pixels >=
          observationScrollController.position.maxScrollExtent - 300) {
        loadMoreObservations();
      }
    });
  }

  void loadMoreObservations() {
    if (isObsLoadingMore || !hasMoreObsData) return;

    if (observationList.length >= observationTotalRecords) {
      hasMoreObsData = false;
      return;
    }

    isObsLoadingMore = true;
    obsStart += obsLimit;

    fetchObservationList(changeStart: false).then((_) {
      isObsLoadingMore = false;
      notifyListeners();
    });
  }


  List<ProjectDetailsModel> projectDetailList = [];

  Future<void> fetchProjectDetails({required int projectId}) async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    AllObservationAndSupportUseCase().fetchProjectDetails(
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



  // observation flag- OBSERV_LIST
  // support request flag- SUP_REQ_LIST
  // Status = OPEN,DELAYED,CLOSED
  Future<void> fetchObservationList({bool changeStart = false})async{
    observationFetched = false;
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    final dateFrom = selectedObsRange?.from ?? obsDateFrom;
    final dateTo = selectedObsRange?.to ?? obsDateTo;
    print("Date from $dateFrom");
    print("Date To $dateTo");
    if(changeStart){
      observationList = [];
      obsStart = 0;
    }else{
      observationFetched = true;
    }

    String? status;
    if (bottomBarStatus == AllObservationAndSupportStatus.opened) {
      status = 'OPENED';
    }else if((bottomBarStatus == AllObservationAndSupportStatus.delayed)){
      status = 'DELAYED';
    }else if((bottomBarStatus == AllObservationAndSupportStatus.closed)){
      status = 'CLOSED';
    }else{
      status = null;
    }

    AllObservationAndSupportUseCase().fetchAllObservationList(
        dateFrom: DateFormat('yyyy-MM-dd').format(dateFrom),
        dateTo: DateFormat('yyyy-MM-dd').format(dateTo),
        isSuperUserObsOnly: isSuperUserObsOnly,
        projectId: projectId,
        showAllObs: (obsRangeFilterApplied) ? false : isShowAllObs,
        flag: "OBSERV_LIST",
        status: status,
        start: obsStart,
        limit: obsLimit,
        userId: userId,
        points: filterPointsController.text,
        transNo: filterTransNoController.text,
        observerId: selectedOwner?.id,
        onRequestSuccess: (result){
          if (obsStart == 0) {
            observationList = result;
          } else {
            observationList.addAll(result);
          }

          observationTotalRecords = result.isNotEmpty
              ? (result.first.totalRecords ?? 0)
              : observationTotalRecords;

          hasMoreObsData = observationList.length < observationTotalRecords;

          observationFetched = true;
          notifyListeners();
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
          notifyListeners();
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus:
              LoadingStatus(loader: Loader.error, exception: exception));
          observationFetched = true;
          notifyListeners();

        });

    notifyListeners();
  }

  Future<void> onRefreshObsAction() async{
    observationFetched  = false;
    fetchObservationList(changeStart: true);
    notifyListeners();
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

  List<OwnerModel> owners = [];
  TextEditingController obsOwnerController = TextEditingController();
  OwnerModel? selectedOwner;

  void fetchOwners() {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    AddSupportRequestUseCase().fetchOwners(
        projectId: projectId ?? 0,
        onRequestSuccess: (result) {
          owners = result;
          changeLoadingStatus(
              loadingStatus:
              LoadingStatus(loader: Loader.success, message: "Owners fetched successfully"));
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.error, exception: exception));
        });
  }
  void setSelectedOwner(String name) {
    selectedOwner = owners.firstWhere((owner) => owner.name == name);
    obsOwnerController = TextEditingController(text: name);
    notifyListeners();
  }






}