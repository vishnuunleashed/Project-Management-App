import 'dart:async';

import 'package:base/core/constants.dart';
import 'package:base/core/loader_value.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:interior_design/data/model/request/project_details/date_range_model.dart';
import 'package:interior_design/data/model/response/add_observation/add_observation_model.dart';
import 'package:interior_design/data/model/response/project_details/observation_model.dart';
import 'package:interior_design/domain/usecase/add_support_request/add_support_request_usecase.dart';
import 'package:interior_design/domain/usecase/my_observation/my_observation_usecase.dart';
import 'package:interior_design/domain/usecase/project_details/project_details_usecase.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';
import 'package:interior_design/presentation/view/common/custom_bottom_bar.dart';
import 'package:intl/intl.dart';


class MyObservationProvider extends BaseProvider{

  PageController pageController = PageController();
  List<ObservationDtlModel> observationList = [];
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

  bool isFromProjectDetails = false;
  String tag = "CREATED";
  bool observationFetched = false;

  ScrollController obsScrollController = ScrollController();

  void setNavigationParameter(Map<String, dynamic>? extra){
    if(extra != null){
      isFromProjectDetails = extra['isFromProjectDetails'];
      tag = extra['tag'];
      currentTabIndex = (tag == "CREATED") ? 0 : 1;
      notifyListeners();
    }
    notifyListeners();
  }

  String userName = "";
  bool isSuperUser = false;
  Future<void> getUserDetails() async{
    print("Username = $userName");
    userName =  await BaseSecureStorage.getString(BaseConstants.userName);
    isSuperUser = await BaseSecureStorage.getBool(BaseConstants.superUserYN);
    notifyListeners();
  }

  void initValues() {
    pageController = PageController();
    currentTabIndex = 0;
    observationList = [];
    obsDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
    tempObsDateFrom = null;
    obsDateTo = DateTime.now();
    tempObsDateTo = null;
    isShowAllObs = true;
    tempIsShowAllObs = null;
    obsRangeFilterApplied = false;
    selectedObsRange = null;
    selectedObsRangeLabel = "";
    obsScrollController = ScrollController();
    bottomBarStatus = CreatedObservationStatus.pending;
    obsStart = 0;
    obsLimit = 20;
    observationFetched = false;
    userName = "";
    isSuperUser = false;
    selectedOwner = null;
    filterPointsController = TextEditingController(text: "");
    filterTransNoController = TextEditingController(text: "");
    obsOwnerController = TextEditingController(text: "");
    paginationController();
    notifyListeners();
  }


  void paginationController(){
    obsScrollController.addListener((){
      if (obsScrollController.position.pixels ==
          obsScrollController.position.maxScrollExtent
          && (observationList.first.totalRecords ??0) > ((obsStart == 0) ? obsLimit : obsStart+obsLimit)) {
        obsStart += obsLimit;
        fetchObservationList();
      }
    });
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


  int obsStart = 0;
  int obsLimit = 20;
  int projectId = 0;
  int observationTotalRecords = 0;
  bool viewOtherTransactionYN = false;

  void setProjectId({required int projectId}) {
    this.projectId = projectId;
    notifyListeners();
  }

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
    }

    String? status;
    String? logStatus;
    if (bottomBarStatus == CreatedObservationStatus.pending) {
      status = 'PENDING';
    }else if((bottomBarStatus == CreatedObservationStatus.closed)){
      status = 'CLOSED';
    }else if((bottomBarStatus == CreatedObservationStatus.submit)){
      status = 'PENDING';
      logStatus = "SUBMIT";
    }
    else{
      status = null;
    }

    print("status ============ $status");

    MyClosedObservationUseCase().fetchObservationList(
        dateFrom: DateFormat('yyyy-MM-dd').format(dateFrom),
        dateTo: DateFormat('yyyy-MM-dd').format(dateTo),
        obsViewOtherTransactionYN: viewOtherTransactionYN,
        projectId: projectId,
        showAllObs: (obsRangeFilterApplied) ? false : isShowAllObs,
        flag: (currentTabIndex == 0) ? "RAISED" : "ACTION_TAKEN",
        status: (currentTabIndex == 1) ? null :status,
        logStatus:(currentTabIndex == 1) ? null : logStatus,
        start: obsStart,
        limit: obsLimit,
        points: filterPointsController.text,
        transNo: filterTransNoController.text,
        observerId: selectedOwner?.id,
        onRequestSuccess: (result){
          if(obsStart == 0) {
            observationList = result;
            observationTotalRecords = (result.isNotEmpty) ? result.first.totalRecords ?? 0 : 0;
          }
          else{
            observationList += result;
            observationTotalRecords = (result.isNotEmpty) ? result.first.totalRecords ?? 0 : 0;
          }

          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
          observationFetched = true;
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

  //bottom navigation bar
  CreatedObservationStatus bottomBarStatus = CreatedObservationStatus.pending;
  void onTapBottomSelected(CreatedObservationStatus status) {
    bottomBarStatus = status;
    fetchObservationList(changeStart: true);
    notifyListeners();
  }

  //Filter section

  //Observation related section
  DateTime obsDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime obsDateTo = DateTime.now();
  DateTime? tempObsDateFrom;
  DateTime? tempObsDateTo;
  bool? tempIsShowAllObs;
  bool isShowAllObs = true;
  bool obsRangeFilterApplied = false;
  DateRangeModel? selectedObsRange;
  String? selectedObsRangeLabel;
  TextEditingController filterPointsController = TextEditingController();
  TextEditingController filterTransNoController = TextEditingController();

  void changeIsShowAllObs(bool value){
    tempIsShowAllObs = value;
    obsDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
    obsDateTo = DateTime.now();

    notifyListeners();
  }
  void changeObsDateFrom(DateTime date) {
    tempObsDateFrom = date;
    notifyListeners();
  }

  void changeObsDateTo(DateTime date) {
    tempObsDateTo = date;
    notifyListeners();
  }


  void setIsShowAllObs(){
    isShowAllObs = tempIsShowAllObs ?? true;
    notifyListeners();
  }

  void setObsFilterDateField(){
    if(tempObsDateFrom != null) {
      obsDateFrom = tempObsDateFrom ?? DateTime(DateTime.now().year, DateTime.now().month, 1);
    }
    if(tempObsDateTo != null) {
      obsDateTo = tempObsDateTo ?? DateTime.now();
    }
    notifyListeners();
  }

  void setObsRangeFilterApplied(bool value){
    obsRangeFilterApplied = value;
    if(value == false){
      selectedObsRange = null;
      selectedObsRangeLabel = "";
    }
    notifyListeners();
  }
  void clearObservationFilter({required bool isFromClearButton,bool isFromRangeFilter = false}) {
    if(isFromClearButton) {
      obsDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
      obsDateTo = DateTime.now();
      tempObsDateFrom = null;
      tempObsDateTo = null;
      isShowAllObs = true;
      tempIsShowAllObs = null;
      viewOtherTransactionYN = false;
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

  //-------------------------------------------------------------------------------------------
  //Common filter Functions

  void setThisWeek() {
    observationList = [];
    selectedObsRange = DateRangeHelper.thisWeek();
    selectedObsRangeLabel = "This Week";
    obsRangeFilterApplied = true;
    fetchObservationList(changeStart: true);
    notifyListeners();
  }

  void setLastWeek() {
    observationList = [];
    selectedObsRange = DateRangeHelper.lastWeek();
    selectedObsRangeLabel = "Last Week";
    obsRangeFilterApplied = true;
    fetchObservationList(changeStart: true);
    notifyListeners();
  }


  void setThisMonth() {
    observationList = [];
    selectedObsRange = DateRangeHelper.thisMonth();
    selectedObsRangeLabel = "This Month";
    obsRangeFilterApplied = true;
    fetchObservationList(changeStart: true);
    notifyListeners();
  }

  void setLastMonth() {
    observationList = [];
    selectedObsRange = DateRangeHelper.lastMonth();
    selectedObsRangeLabel = "Last Month";
    obsRangeFilterApplied = true;
    fetchObservationList(changeStart: true);
    notifyListeners();
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