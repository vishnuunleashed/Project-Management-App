
import 'dart:async';

import 'package:base/core/constants.dart';
import 'package:base/core/loader_value.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/navigator_key.dart';
import 'package:base/presentation/utility/show_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/request/project_details/date_range_model.dart';
import 'package:interior_design/data/model/response/add_observation/add_observation_model.dart';
import 'package:interior_design/data/model/response/add_support_request/add_support_request_dept_model.dart';
import 'package:interior_design/data/model/response/project_details/department_model.dart';
import 'package:interior_design/data/model/response/project_details/project_details_model.dart';

import 'package:interior_design/data/model/response/project_details/support_request_model.dart';
import 'package:interior_design/domain/usecase/add_support_request/add_support_request_usecase.dart';
import 'package:interior_design/domain/usecase/all_observation_and_support_request_usecase/all_observation_support_request_usecase.dart';
import 'package:interior_design/domain/usecase/project_details/project_details_usecase.dart';
import 'package:interior_design/presentation/provider/common_support/base_support_provider.dart';

import 'package:interior_design/presentation/view/common/custom_bottom_bar.dart';
import 'package:intl/intl.dart';


class BaseAllSupportProvider extends BaseSupportProvider{

  bool isFromObservation = true;
  String tag = "OPENED";
  bool isFromDashboard = false;
  String raisedUser = "";
  String userprofileurl = "";
  bool superUserYN = false;
  bool isCritical = false;
  bool isAllSupport = false;
  int projectId = 0;
  int? userId;

  void initState(){
    userName = "";
    isSuperUser = false;
    tag = "OPENED";
    isFromDashboard = false;
    raisedUser = "";
    userprofileurl = "";
    supportRequestFetched = false;
    userId = null;
    closureDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
    closureDateTo = DateTime.now();
    tempClosureDateFrom = null;
    tempClosureDateTo = null;
    isShowAllSupport = true;
    tempIsShowAllSupport = null;
    sptRangeFilterApplied = false;
    selectedSptRange = null;
    selectedSptRangeLabel = null;
    isSuperUserSupportOnly = false;
    filterSupportPointsController = TextEditingController(text: "");
    supportOwnerController = TextEditingController(text: "");
    selectedEscalatedUser = null;
    selectedDept = null;
    selectedDependencyDept = null;
    tempSelectedDept = null;
    tempSelectedDependencyDept = null;
    notifyListeners();
  }

  void setNavigationParameters({required Map<String, dynamic> extra}){
    bool isFromPieChart = extra["isFromPieChart"] ?? false;
    bottomBarStatus = extra["bottomBarStatus"];
    projectId = extra["projectId"];
    userId = extra["userId"];
    raisedUser = extra['raisedUser'] ?? "";
    userprofileurl = extra['userprofileurl']??"";
    isCritical = extra['isCritical']??false;
    isFromDashboard = (userId==null) ? false : true;
    isAllSupport = (isFromPieChart) ? false : !isFromDashboard;
    notifyListeners();
    fetchProjectDetails(projectId: projectId);
    fetchSupportRequestList(changeStart: true);
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


  DateTime closureDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime closureDateTo = DateTime.now();
  DateTime? tempClosureDateFrom;
  DateTime? tempClosureDateTo;
  bool isShowAllSupport = true;
  bool? tempIsShowAllSupport;
  bool sptRangeFilterApplied = false;
  DateRangeModel? selectedSptRange;
  String? selectedSptRangeLabel;
  bool isSuperUserSupportOnly = false;

  void changeIsSuperuserSupportOnly(bool value){
    isSuperUserSupportOnly = value;
    notifyListeners();
  }

  void changeIsShowAllSupport(bool value){
    tempIsShowAllSupport = value;
    closureDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
    closureDateTo = DateTime.now();
    notifyListeners();
  }

  void setIsShowAllSupport(){
    isShowAllSupport = tempIsShowAllSupport ?? true;
    notifyListeners();
  }

  void changeClosureDateFrom(DateTime date) {
    tempClosureDateFrom = date;
    notifyListeners();
  }

  void changeClosureDateTo(DateTime date) {
    tempClosureDateTo = date;
    notifyListeners();
  }

  void setSptFilterDateField(){
    if(tempClosureDateFrom != null) {
      closureDateFrom = tempClosureDateFrom ?? DateTime(DateTime.now().year, DateTime.now().month, 1);
    }
    if(tempClosureDateTo != null) {
      closureDateTo = tempClosureDateTo ?? DateTime.now();
    }
    notifyListeners();
  }

  void clearSupportReqFilter({required bool isFromClearButton}) {
    if(isFromClearButton) {
      closureDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
      closureDateTo = DateTime.now();
      selectedDept = null;
      selectedDependencyDept = null;
      tempSelectedDept = null;
      tempSelectedDependencyDept = null;
      tempClosureDateFrom = null;
      tempClosureDateTo = null;
      isShowAllSupport = true;
      tempIsShowAllSupport = null;
      isSuperUserSupportOnly = false;
      filterSupportPointsController = TextEditingController(text: "");
      supportOwnerController = TextEditingController(text: "");
      selectedEscalatedUser = null;
    }
    else{
      tempClosureDateFrom = null;
      tempClosureDateTo = null;
      tempSelectedDept = null;
      tempSelectedDependencyDept = null;
      tempIsShowAllSupport = null;
    }
    notifyListeners();
  }

  void setSptRangeFilterApplied(bool value){
    sptRangeFilterApplied = value;
    if(value == false){
      selectedSptRange = null;
      selectedSptRangeLabel = "";
    }
    notifyListeners();
  }

  List<SupportRequestDtlModel> supportRequestList = [];
  int supStart = 0;
  int supLimit = 20;
  DepartmentDropDownModel? tempSelectedDept;
  DepartmentDropDownModel? selectedDept;
  DepartmentDropDownModel? selectedDependencyDept;
  DepartmentDropDownModel? tempSelectedDependencyDept;
  ScrollController supScrollController = ScrollController();

  bool supRequestFetched = false;

  bool isSupLoadingMore = false;
  bool hasMoreSupData = true;

  void initSupScrollListener() {
    supScrollController.addListener(() {
      if (supScrollController.position.pixels >= supScrollController.position.maxScrollExtent - 300) {
        loadMoreSupportRequests();
      }
    });
  }


  void loadMoreSupportRequests() {
    if (isSupLoadingMore || !hasMoreSupData) return;

    // If already loaded all records, stop
    if (supportRequestList.length >= supportRequestTotalRecords) {
      hasMoreSupData = false;
      return;
    }

    isSupLoadingMore = true;
    supStart += supLimit;

    fetchSupportRequestList(changeStart: false).then((_) {
      isSupLoadingMore = false;
      notifyListeners();
    });
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





  Future<void> onRefreshSptAction() async{
    supportRequestFetched = false;
    fetchSupportRequestList(changeStart: true);
    notifyListeners();
  }

  int currentTabIndex = 0;

  AllObservationAndSupportStatus bottomBarStatus = AllObservationAndSupportStatus.opened;

  void changeCurrentIndex(int index){
    currentTabIndex = index;
    bottomBarStatus = AllObservationAndSupportStatus.opened;
    fetchSupportRequestList();
    notifyListeners();
  }

  void onTapBottomSelected(AllObservationAndSupportStatus status) {
    supportRequestList = [];
    bottomBarStatus = status;
    fetchSupportRequestList(changeStart: true);
    notifyListeners();
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


  bool supportRequestFetched = false;
  int supportRequestTotalRecords = 0;

  Future<void> fetchSupportRequestList({bool changeStart = false}) async {
    supportRequestFetched = false;
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    if(changeStart){
      supportRequestList = [];
      supStart = 0;
    }else{
      supportRequestFetched = true;
    }
    final dateFrom = selectedSptRange?.from ?? closureDateFrom;
    final dateTo = selectedSptRange?.to ?? closureDateTo;

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



    AllObservationAndSupportUseCase().fetchAllSupportRequestList(
        start: supStart,
        limit: supLimit,
        isCritical:isCritical,
        isAllSupport: isAllSupport,
        showAllSupport: (sptRangeFilterApplied) ? false : isShowAllSupport,
        isSuperUserSupportOnly: isSuperUserSupportOnly,
        projectId: projectId,
        userId: userId,
        deptId:selectedDept?.deptId ?? 0,
        selectedDependencyDeptId : selectedDependencyDept?.deptId ?? 0,
        flag: "SUP_REQ_LIST",
        status: (currentTabIndex == 1) ? null :status,
        dateFrom: DateFormat('yyyy-MM-dd').format(dateFrom) ,
        dateTo: DateFormat('yyyy-MM-dd').format(dateTo),
        point:filterSupportPointsController.text,
        escalatedUserId: selectedEscalatedUser?.id,

        onRequestSuccess: (result){
          if (supStart == 0) {
            supportRequestList = result;
          } else {
            supportRequestList.addAll(result);
          }

          supportRequestTotalRecords = result.isNotEmpty
              ? (result.first.totalRecords ?? 0)
              : supportRequestTotalRecords;


          hasMoreSupData = supportRequestList.length < supportRequestTotalRecords;

          supportRequestFetched = true;
          notifyListeners();
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus: LoadingStatus(
                  loader: Loader.error,
                  exception: exception));
          supportRequestFetched = true;
          notifyListeners();

        });
    print("Support request fetched --- $supRequestFetched");
    notifyListeners();
  }

  //Common filter Functions
  void setThisWeek({required bool isSupport}) {
      selectedSptRange = DateRangeHelper.thisWeek();
      selectedSptRangeLabel = "This Week";
      sptRangeFilterApplied = true;
      fetchSupportRequestList(changeStart: true);

    notifyListeners();
  }

  void setLastWeek({required bool isSupport}) {
      selectedSptRange = DateRangeHelper.lastWeek();
      selectedSptRangeLabel = "Last Week";
      sptRangeFilterApplied = true;
      fetchSupportRequestList(changeStart: true);
    notifyListeners();
  }

  void setNextWeek({required bool isSupport}) {
      selectedSptRange = DateRangeHelper.nextWeek();
      selectedSptRangeLabel = "Next Week";
      sptRangeFilterApplied = true;
      fetchSupportRequestList(changeStart: true);

    notifyListeners();
  }

  void setThisMonth({required bool isSupport}) {
      selectedSptRange = DateRangeHelper.thisMonth();
      selectedSptRangeLabel = "This Month";
      sptRangeFilterApplied = true;
      fetchSupportRequestList(changeStart: true);
    notifyListeners();
  }

  void setLastMonth({required bool isSupport}) {
      selectedSptRange = DateRangeHelper.lastMonth();
      selectedSptRangeLabel = "Last Month";
      sptRangeFilterApplied = true;
      fetchSupportRequestList(changeStart: true);


    notifyListeners();
  }

  void setNextMonth({required bool isSupport}) {
      selectedSptRange = DateRangeHelper.nextMonth();
      selectedSptRangeLabel = "Next Month";
      sptRangeFilterApplied = true;
      fetchSupportRequestList(changeStart: true);

    notifyListeners();
  }

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


  void unFollowSupportRequest({required int supportId,required Function() onRequestSuccess,}){
    AllObservationAndSupportUseCase().unFollowSupportRequest(
      supportId: supportId,
      onRequestSuccess: (){
        onRequestSuccess();

      },
      onRequestFailure: (exception)=>
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error,message: exception.toString()),)
    );
  }
  void updateSupportListForFollow(int index){
    supportRequestList[index].notifyuseryn = "Y";
    supportRequestList[index].addedbycreatoryn = "N";
    notifyListeners();
  }
  void updateSupportListForUnFollow(int index){
    supportRequestList[index].notifyuseryn = "N";
    supportRequestList[index].addedbycreatoryn = "N";
    notifyListeners();
  }

  TextEditingController filterSupportPointsController = TextEditingController();
  TextEditingController supportOwnerController = TextEditingController();
  OwnerModel? selectedEscalatedUser;

  @override
  void fetchOwners() {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    AddSupportRequestUseCase().fetchOwners(
        projectId: projectId ?? 0,
        excludeLoginUser: false,
        onRequestSuccess: (result) {
          owners = result;
          fetchDepartmentDropDown();
          changeLoadingStatus(
              loadingStatus:
              LoadingStatus(loader: Loader.success, message: "Success"));
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.error, exception: exception));
        });
  }
  void setSelectedEscalated(String name) {
    selectedEscalatedUser = owners.firstWhere((owner) => owner.name == name);
    supportOwnerController = TextEditingController(text: name);
    notifyListeners();
  }

  List<DepartmentDropDownModel> filterDepartment = [];

  @override
  Future<void> fetchDepartmentDropDown() async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ProjectDetailsUseCase().fetchDepartmentDropDown(
      onRequestSuccess: (result) async {
        filterDepartment = result;

        changeLoadingStatus(
          loadingStatus: LoadingStatus(loader: Loader.success),
        );
      },
      onRequestFailure: (exception) {
        changeLoadingStatus(
          loadingStatus: LoadingStatus(
            loader: Loader.error,
            exception: exception,
          ),
        );
      },
    );
    notifyListeners();
  }

  void changeDepartment(DepartmentDropDownModel department) {
    tempSelectedDept = department;
    notifyListeners();
  }

  void setSelectedDepartment(){
    if(tempSelectedDept != null) {
      selectedDept = tempSelectedDept;
    }
    notifyListeners();
  }

  void changeDependencyDepartment(DepartmentDropDownModel department) {
    tempSelectedDependencyDept = department;
    notifyListeners();
  }

  void setSelectedDependencyDepartment(){
    if(tempSelectedDependencyDept != null) {
      selectedDependencyDept = tempSelectedDependencyDept;
    }
    notifyListeners();
  }

}