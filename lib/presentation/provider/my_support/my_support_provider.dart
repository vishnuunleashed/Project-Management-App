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
import 'package:interior_design/data/model/response/project_details/department_model.dart';
import 'package:interior_design/data/model/response/project_details/support_request_model.dart';
import 'package:interior_design/domain/usecase/add_support_request/add_support_request_usecase.dart';
import 'package:interior_design/domain/usecase/all_observation_and_support_request_usecase/all_observation_support_request_usecase.dart';
import 'package:interior_design/domain/usecase/my_support/my_support_usecase.dart';
import 'package:interior_design/presentation/view/common/custom_bottom_bar.dart';
import 'package:intl/intl.dart';

class MySupportProvider extends BaseProvider{
  bool isFromProjectDetails = false;
  List<SupportRequestDtlModel> supportRequestList = [];
  PageController pageController = PageController();
  ScrollController supScrollController = ScrollController();
  String tag = "";
  bool supRequestFetched = false;

 void changeCurrentIndex(int index){
   currentTabIndex = index;
   bottomBarStatus = Status.pending;
   fetchSupportRequestList();
   notifyListeners();
 }


  void setProjectId({required int projectId}) {
    // this.projectId = (isFromProjectDetails) ? projectId : 0;
    this.projectId = projectId;
    notifyListeners();
  }

  void initValue(){
    pageController = PageController();
    supScrollController = ScrollController();
    currentTabIndex = 0;
    isFromProjectDetails = false;
    supportRequestList = [];
    projectId = 0;
    supStart = 0;
    supLimit = 20;
    sptRangeFilterApplied = false;
    supRequestFetched = false;
    bottomBarStatus = Status.pending;
    userName = "";
    isSuperUser = false;
    selectedDept = null;
    selectedDependencyDept = null;
    tempSelectedDept = null;
    tempSelectedDependencyDept = null;
    filterSupportPointsController = TextEditingController(text: "");
    supportOwnerController = TextEditingController(text: "");
    selectedEscalatedUser = null;
    paginationController();
    notifyListeners();
    fetchOwners();
  }

  String userName = "";
  bool isSuperUser = false;
  Future<void> getUserDetails() async{
    print("Username = $userName");
    userName =  await BaseSecureStorage.getString(BaseConstants.userName);
    isSuperUser = await BaseSecureStorage.getBool(BaseConstants.superUserYN);
    notifyListeners();
  }

  int currentTabIndex = 0;

  Status bottomBarStatus = Status.pending;

  void paginationController(){
    supScrollController.addListener((){
      if (supScrollController.position.pixels ==
          supScrollController.position.maxScrollExtent
          && (supportRequestList.first.totalRecords ??0) > ((supStart == 0) ? supLimit : supStart+supLimit)) {
        supStart += supLimit;
        fetchSupportRequestList();
      }
    });
  }

  void onTapSelected(int index) {
    currentTabIndex = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    supportRequestList = [];

    clearSupportReqFilter(isFromClearButton: true,isFromRangeFilter: true);
    fetchSupportRequestList(changeStart: true);
    notifyListeners();
  }

  void onTapBottomSelected(Status status) {
    supportRequestList = [];
    bottomBarStatus = status;
    fetchSupportRequestList(changeStart: true);
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


  DepartmentDropDownModel? selectedDept;
  DepartmentDropDownModel? selectedDependencyDept;
  List<DepartmentDropDownModel> departmentList = [];
  bool superUserYN = false;
  int departmentId = 0;
  Future<void> fetchDepartmentDropDown() async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    MySupportRequestUseCase().fetchDepartmentDropDown(
      onRequestSuccess: (result) async {
        departmentList = result;
        superUserYN = await BaseSecureStorage.getBool(BaseConstants.superUserYN);
        departmentId = await BaseSecureStorage.getInt(BaseConstants.departmentId);

        notifyListeners();
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

  bool isShowAllSupport = true;
  int supStart = 0;
  int projectId = 0;
  int supLimit = 20;
  int supportRequestTotalRecords = 0;
  bool isSuperUserSupportOnly = false;
  DateTime closureDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime closureDateTo = DateTime.now();
  DateRangeModel? selectedSptRange;

  Future<void> fetchSupportRequestList({bool changeStart = false}) async {
    supRequestFetched = false;
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    if(changeStart){
      supportRequestList = [];
      supStart = 0;
    }
    final dateFrom = selectedSptRange?.from ?? closureDateFrom;
    final dateTo = selectedSptRange?.to ?? closureDateTo;
    String? status;
    if (bottomBarStatus == Status.pending) {
      status = 'PENDING';
    }else if(bottomBarStatus == Status.readyToClose){
      status = 'TO_CLOSE';
    }else if((bottomBarStatus == Status.closed)){
      status = 'CLOSED';
    }else{
      status = null;
    }
    MySupportRequestUseCase().fetchSupportRequestList(
        start: supStart,
        limit: supLimit,

        showAllSupport: (sptRangeFilterApplied) ? false : isShowAllSupport,
        supViewOtherTransactionYN: isSuperUserSupportOnly,
        projectId: projectId,
        deptId:selectedDept?.deptId ?? 0,
        dependencyDeptId : selectedDependencyDept?.deptId ?? 0,
        flag: (currentTabIndex == 0) ?"RAISED":"ACTION_TAKEN",
        status: (currentTabIndex == 1) ? null :status,
        dateFrom: DateFormat('yyyy-MM-dd').format(dateFrom) ,
        dateTo: DateFormat('yyyy-MM-dd').format(dateTo),
        point: filterSupportPointsController.text,
        escalatedUserId: selectedEscalatedUser?.id,
        onRequestSuccess: (result){
          if(supStart == 0) {
            supportRequestList = result;
            supportRequestTotalRecords = (result.isNotEmpty) ? result.first.totalRecords ?? 0 : 0;
          }
          else{
            supportRequestList += result;
            supportRequestTotalRecords = (result.isNotEmpty) ? result.first.totalRecords ?? 0 : 0;
          }
          supRequestFetched = true;
          notifyListeners();
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus: LoadingStatus(
                  loader: Loader.error,
                  exception: exception));
          supRequestFetched = true;
          notifyListeners();

        });
    notifyListeners();
  }

  //filter section
  DepartmentDropDownModel? tempSelectedDept;
  DepartmentDropDownModel? tempSelectedDependencyDept;

  void changeIsShowAllSupport(bool value){
    tempIsShowAllSupport = value;
    closureDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
    closureDateTo = DateTime.now();
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

  void setIsShowAllSupport(){
    isShowAllSupport = tempIsShowAllSupport ?? true;
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

  void setSptRangeFilterApplied(bool value){
    sptRangeFilterApplied = value;
    if(value == false){
      selectedSptRange = null;
      selectedSptRangeLabel = "";
    }
    notifyListeners();
  }

  DateTime? tempClosureDateFrom;
  DateTime? tempClosureDateTo;
  bool? tempIsShowAllSupport;
  bool sptRangeFilterApplied = false;
  String? selectedSptRangeLabel;
  void clearSupportReqFilter({required bool isFromClearButton, bool isFromRangeFilter = false}) {
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
      if(isFromRangeFilter){
        selectedSptRange = null;
        sptRangeFilterApplied = false;
        selectedSptRangeLabel = "";
      }
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

  //Date range filter
  //Common filter Functions
  void setThisWeek() {
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
  void followSupportRequest({required int supportId,required Function() onRequestSuccess}){
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
  List<OwnerModel> owners = [];
  void fetchOwners() {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    AddSupportRequestUseCase().fetchOwners(
        projectId: projectId ?? 0,
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

  void refreshPage() {
    supportRequestList = [];
    print("entered___ ");
    fetchSupportRequestList(changeStart: true);
    notifyListeners();
  }

}