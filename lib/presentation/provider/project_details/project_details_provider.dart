/*------------------------------------------------------------------------------
AUTHOR		    : Shamnas Abdulla
CREATED DATE	: 07/08/2025
PURPOSE		    : Observation List
MODULE/TOPIC	:
REMARKS		    : IN008 - 25
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		    MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
import 'dart:async';
import 'package:base/core/constants.dart';
import 'package:base/core/loader_value.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/navigator_key.dart';
import 'package:base/presentation/utility/show_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/request/project_details/date_range_model.dart';
import 'package:interior_design/data/model/response/add_observation/add_observation_model.dart';
import 'package:interior_design/data/model/response/close_observation/close_observation_model.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';
import 'package:interior_design/data/model/response/project_details/department_model.dart';
import 'package:interior_design/data/model/response/project_details/observation_model.dart';
import 'package:interior_design/data/model/response/project_details/project_details_model.dart';
import 'package:interior_design/data/model/response/project_details/support_request_model.dart';
import 'package:interior_design/domain/usecase/add_support_request/add_support_request_usecase.dart';
import 'package:interior_design/domain/usecase/all_observation_and_support_request_usecase/all_observation_support_request_usecase.dart';
import 'package:interior_design/domain/usecase/project_details/project_details_usecase.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/view/project_details/general_info_tab.dart';
import 'package:interior_design/presentation/view/project_details/partials/general_info_screen.dart';
import 'package:interior_design/presentation/view/project_details/partials/observation_list_screen.dart';
import 'package:interior_design/presentation/view/project_details/partials/support_request_list_screen.dart';
import 'package:intl/intl.dart';
import 'package:interior_design/data/local/hive/project_local_storage_service.dart';

class ProjectDetailsProvider extends BaseProvider {
  int bottomSelectedIndex = 0;
  int topTabIndex = 0;
  String selectedTab = 'GEN';
  int projectId = 0;
  PageController pageController = PageController();
  List<Map<String, dynamic>> tabs = [];
  int currentPage = 1;
  bool superUserYN = false;
  int departmentId = 0;
  int obsStart = 0;
  int obsLimit = 20;
  int supStart = 0;
  int supLimit = 20;
  ScrollController obsScrollController = ScrollController();
  ScrollController supScrollController = ScrollController();
  bool isFromObs = false;
  bool isFromSup = false;
  String delayedYNObs = "";
  String delayedYNSupport = "";
  String viewOtherTransYN = "";
  Map<String, dynamic>? extra;

  int userId = 0;
  String? scopeFlag = "";
  String? flagObs;
  String? flagSupport;
  String? filterLogStatus;

  bool? showAll;

  // DCC offline navigation — cached from Hive project list
  int? cachedProjectId;
  int? cachedRootFolderId;



  Future<void>  initState({ required Map<String, dynamic>? extra}) async {
    // ── Read user details FIRST, before any resets ──
    isSuperUser = await BaseSecureStorage.getBool(BaseConstants.superUserYN);
    userName = await BaseSecureStorage.getString(BaseConstants.userName);
    this.extra = extra;
    print("extra___2 "+extra.toString());
    setProjectId(projectId: extra!["projectId"] ?? 0);

    // ── Populate cached DCC values from Hive project list ──
    cachedProjectId = extra["projectId"] as int? ?? 0;

    cachedRootFolderId = extra["rootFolderId"];

    print("extra___1 "+extra.toString());
    filterLogStatus = extra["subStatus"]?.toString().toUpperCase();
    delayedYNObs = extra!["DelayedYN"]??"None";
    userId = extra["userId"] ?? await BaseSecureStorage.getInt(BaseConstants.userID);
    flagObs = extra["flagObs"];
    flagSupport = extra["flagSupport"];

    if(flagObs != null){
      setSelectObsType(observationTypeList.firstWhere((item){return item.code == flagObs;}));
    }
    if(flagSupport != null){
      setSelectSupportType(supportTypeList.firstWhere((item){return item.code == flagSupport;}));
    }
    if(delayedYNObs == "Y"){
      changeIsDelayedObs(true);
    }else if(delayedYNObs == "N"){
      changeIsDelayedObs(false);
    }
    delayedYNSupport = extra["DelayedYN"]??"None";
    if(delayedYNSupport == "Y"){
      changeIsDelayedSupport(true);
    }else if(delayedYNSupport == "N"){
      changeIsDelayedSupport(false);
    }
    viewOtherTransYN = extra["ViewOtherTransYN"]??"None";
    if(viewOtherTransYN == "Y" && (this.extra!["isFromObservation"]??false)){
      changeObsViewOtherTransactionYN(false);
    }else {
      changeObsViewOtherTransactionYN(true);
    }

    showAll = extra["showAll"];
    viewOtherTransYN = showAll??false ? "N" :"Y";

    if(viewOtherTransYN == "Y" && (extra["isFromSupport"]??false)){

      changeSupViewOtherTransactionYN(false);
    }else {
      changeSupViewOtherTransactionYN(true);
    }

    scopeFlag = extra["scopeFlag"]??"INDIVIDUAL";
    if(scopeFlag == "TEAM" && (this.extra!["isFromObservation"]??false)){
      changeObsViewOtherTransactionYN(false);
    }else {
      changeObsViewOtherTransactionYN(true);
    }

    if(showAll == null){
      scopeFlag = extra["scopeFlag"]??"INDIVIDUAL";
      if(scopeFlag == "TEAM" && (this.extra!["isFromSupport"]??false)){
        changeSupViewOtherTransactionYN(false);
      }else {
        changeSupViewOtherTransactionYN(true);
      }
    }


    obsScrollController = ScrollController();
    supScrollController = ScrollController();
    obsStart = 0;
    obsLimit = 20;
    supStart = 0;
    supLimit = 20;
    departmentList = [];
    selectedDept = null;
    selectedDependencyDept = null;
    observationList = [];
    supportRequestList = [];
    projectDetailList = [];
    obsDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
    tempObsDateFrom = null;
    obsDateTo = DateTime.now();
    tempObsDateTo = null;
    closureDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
    tempClosureDateFrom = null;
    closureDateTo = DateTime.now();
    tempClosureDateTo = null;
    isDateRangeObs = true;
    tempDateRangeObs = null;
    isShowAllSupport = true;
    tempIsShowAllSupport = null;
    sptRangeFilterApplied = false;
    selectedSptRange = null;
    selectedSptRangeLabel = "";
    obsRangeFilterApplied = false;
    selectedObsRange = null;
    selectedObsRangeLabel = "";
    tabs = [];
    attachmentUrl = [];
    observationFetched = false;
    supportRequestFetched = false;
    // currentPage =  extra["isFromObservation"]??false  ? 1 : (obsRight) ?  extra["isFromSupport"]??false  ? 2 :  extra["isFromSupport"]??false  ? 1 : 0 :  extra["isFromSupport"]??false  ? 1 :0;
    pageController = PageController(initialPage: currentPage);
    isExpandedDashBoard = false;
    isExpandedObsAndSupport = false;
    selectedOwner = null;
    obsOwnerController = TextEditingController(text: "");
    owners = [];
    selectedEscalatedUser = null;
    selectedDept = null;
    selectedDependencyDept = null;
    tempSelectedDept = null;
    tempSelectedDependencyDept = null;
    supportOwnerController = TextEditingController(text: "");
    filterPointsController.clear();
    filterPointsController.clear();
    filterTransNoController.clear();
    filterSupportPointsController.clear();
    filterEscalatedUserIdController.clear();
    filterDepartmentIdController.clear();
    paginationController();
    fetchDepartmentDropDown();
    fetchStatusTypes();
    getStatusType();
    fetchOwners();
    fetchObservationList();
    // initTabs(
    //   obsRight: obsRight,
    //   supRight: supRight,
    // );

    if(extra["isFromSupport"]??false){
      fetchSupportRequestList(changeStart: true);
    }else{
      fetchObservationList(changeStart: true);
    }
    notifyListeners();
  }


  void setTopTabIndex(int index) {
    topTabIndex = index;
    bottomSelectedIndex = 0;
    notifyListeners();
  }

  void setBottomIndex(int index) {
    bottomSelectedIndex = index;
    notifyListeners();
  }


  void refreshSupport(){
    if(tabs[currentPage]['value'] =='SPR'){
      fetchSupportRequestList(changeStart: true);
    }
  }

  String userName = "";
  bool isSuperUser = false;
  Future<void> getUserDetails() async{
    userName =  await BaseSecureStorage.getString(BaseConstants.userName);
    print("userName = "+userName);
    isSuperUser = await BaseSecureStorage.getBool(BaseConstants.superUserYN);
    notifyListeners();
  }

  bool _isAnimating = false; // Add this flag to prevent multiple animations

  void _onPageScroll() {
    if (_isAnimating) return; // Prevent multiple simultaneous animations

    final page = pageController.page ?? currentPage.toDouble();

    // If dragged past 50%, force complete the page change
    if ((page - currentPage).abs() > 0.5) {
      _isAnimating = true;
      final targetPage = page.round();

      pageController.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      ).then((_) {
        _isAnimating = false;
      });
    }
  }

  void goToPage({required int index, bool isFromButtonClick = false}) {
    currentPage = index;
if(isFromButtonClick) {
  pageController.jumpToPage(index);
}

    final value = tabs[index]['value'] as String;
    changeSelectedTab(value: value);
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

    supScrollController.addListener((){
      if (supScrollController.position.pixels ==
          supScrollController.position.maxScrollExtent
          && (supportRequestList.first.totalRecords ??0) > ((supStart == 0) ? supLimit : supStart+supLimit)) {
        supStart += supLimit;
        fetchSupportRequestList();
      }
    });
  }
  void setProjectId({required int projectId}) {
    this.projectId = projectId;
    notifyListeners();
    fetchProjectDetails(projectId: projectId);

  }

  int projectTotalDays = 0;
  int projectRemainingDays = 0;

  /// Calculates total number of project days (inclusive)
  void calculateTtlDaysOfPrj({
    required DateTime dateFrom,
    required DateTime dateTo,
  }) {
    projectTotalDays = dateTo.difference(dateFrom).inDays + 1;
    print("Total project days = $projectTotalDays");
    notifyListeners();
  }
  /// Calculates remaining project days (inclusive),
  /// considering both start and end date.
  /// If project hasn’t started yet, counts from start date.
  /// If project is already finished, sets remaining days = 0.
  void clcRemainingDaysOfPrj({
    required DateTime dateFrom,
    required DateTime dateTo,
  }) {
    final now = DateTime.now();

    if (now.isBefore(dateFrom)) {
      // Project hasn't started yet — full duration remains
      projectRemainingDays = dateTo.difference(dateFrom).inDays + 1;
    } else if (now.isAfter(dateTo)) {
      // Project already ended
      projectRemainingDays = 0;
    } else {
      // Project ongoing — remaining days from today to end date
      projectRemainingDays = dateTo.difference(now).inDays + 1;
    }

    print("Remaining project days = $projectRemainingDays");
    notifyListeners();
  }


  void calculateDelayedDays({required DateTime dateTo}){}

  void changeIsFromObs({required bool value}){
    isFromObs = value;
    notifyListeners();
  }

  void changeIsFromSup({required bool value}){
    isFromSup = value;
    notifyListeners();
  }

  void changeSelectedTab({required String value, bool isInitial = false}) {
    if (selectedTab != value || isInitial == true) {
      selectedTab = value;
      if(!isInitial){
        observationFetched = false;
        supportRequestFetched = false;
      }

      if (value == 'OBV') {
        fetchObservationList(changeStart: true);
      }
      if (value == 'SPR') {
        fetchSupportRequestList(changeStart: true);
      }
    }

    notifyListeners();
  }



  // Project Details related section
  List<ProjectDetailsModel> projectDetailList = [];

  Future<void> fetchProjectDetails({required int projectId}) async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ProjectDetailsUseCase().fetchProjectDetails(
        projectId: projectId,
        onRequestSuccess: (result) {
          projectDetailList = result;

          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.success));
          if(projectDetailList.isNotEmpty) {
            calculateTtlDaysOfPrj(
                dateFrom: projectDetailList.first.startDate ?? DateTime.now(),
                dateTo: projectDetailList.first.endDate ?? DateTime.now());
            clcRemainingDaysOfPrj(dateTo: projectDetailList.first.endDate ?? DateTime.now(), dateFrom: projectDetailList.first.startDate ?? DateTime.now());
          }
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.error));
        });
    notifyListeners();
  }

  //-------------------------------------------------------------------------------------------------
  //Observation related section
  List<ObservationDtlModel> observationList = [];
  DateTime obsDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime obsDateTo = DateTime.now();
  DateTime? tempObsDateFrom;
  DateTime? tempObsDateTo;
  bool? tempDateRangeObs;
  bool? tempIsDelayedObs;
  bool? tempIsDelayedSupport;
  bool isDateRangeObs = true;
  bool isDelayedObs = true;
  bool isDelayedSupport = true;
  bool obsRangeFilterApplied = false;
  DateRangeModel? selectedObsRange;
  String? selectedObsRangeLabel;
  bool obsViewOtherTransactionYN = true;
  TextEditingController filterPointsController = TextEditingController();
  TextEditingController filterTransNoController = TextEditingController();

  TextEditingController filterSupportPointsController = TextEditingController();
  TextEditingController filterEscalatedUserIdController = TextEditingController();
  TextEditingController filterDepartmentIdController = TextEditingController();

  void changeObsViewOtherTransactionYN(bool value){
    obsViewOtherTransactionYN = value;
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

  void changeIsShowAllObs(bool value){
    tempDateRangeObs = value;
    obsDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
    obsDateTo = DateTime.now();

    notifyListeners();
  }
  void changeIsDelayedObs(bool value){
    tempIsDelayedObs = value;
    if(value){
      delayedYNObs = "Y";
    }else{
      delayedYNObs = "N";
    }
    obsDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
    obsDateTo = DateTime.now();

    notifyListeners();
  }


  void changeIsDelayedSupport(bool value){
    tempIsDelayedSupport = value;
    if(value){
      delayedYNSupport = "Y";
    }else{
      delayedYNSupport = "N";
    }
    closureDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
    closureDateTo = DateTime.now();

    notifyListeners();
  }


  void setIsShowAllObs(){
    isDateRangeObs = tempDateRangeObs ?? true;
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

  void clearObservationFilter({required bool isFromClearButton}) {
    if(isFromClearButton) {
      obsDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
      obsDateTo = DateTime.now();
      tempObsDateFrom = null;
      tempObsDateTo = null;
      isDateRangeObs = true;
      delayedYNObs = extra!["DelayedYN"]??"None";
      if(delayedYNObs == "Y"){
        changeIsDelayedObs(true);
      }else if(delayedYNObs == "N"){
        changeIsDelayedObs(false);
      }

      viewOtherTransYN = extra!["ViewOtherTransYN"]??"None";
      if(viewOtherTransYN == "Y" && (extra!["isFromObservation"]??false)){
        changeObsViewOtherTransactionYN(false);
      }else {
        changeObsViewOtherTransactionYN(true);
      }

      tempDateRangeObs = null;
      selectedOwner = null;
      obsOwnerController = TextEditingController(text: "");
      filterPointsController = TextEditingController(text: "");
      filterTransNoController = TextEditingController(text: "");
      filterLogStatus = null;

    }
    else{
      tempObsDateFrom = null;
      tempObsDateTo = null;
      tempDateRangeObs = null;
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

  String formatDateSupport(String dateTimeStr) {
    DateTime dateTime;

    try {
      // Parse the backend format yyyy-MM-dd
      dateTime =  DateFormat('MMM dd, yyyy').parse(dateTimeStr);
    } catch (e) {
      return dateTimeStr; // fallback
    }

    final now = DateTime.now();
    final isToday = dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;

    if (isToday) {
      return "Today";
    } else {
      // Example: 19-Sep-2025
      return  DateFormat('MMM dd, yyyy').format(dateTime);
    }
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
  Future<void> onRefreshObsAction() async{
    observationFetched  = false;
    fetchObservationList(changeStart: true);
    notifyListeners();
  }

  bool observationFetched = false;
  int observationTotalRecords = 0;

  Future<void> fetchObservationList({bool changeStart = false}) async {
    final dateFrom = selectedObsRange?.from ?? obsDateFrom;
    final dateTo = selectedObsRange?.to ?? obsDateTo;
    if(changeStart){
      observationList = [];
      obsStart = 0;
    }
    print("entered___ "+obsViewOtherTransactionYN.toString());
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ProjectDetailsUseCase().fetchObservationList(
        projectId: projectId,
        start: obsStart,
        limit: obsLimit,
        userId:userId,
        dateFrom: DateFormat('yyyy-MM-dd').format(dateFrom),
        dateTo: DateFormat('yyyy-MM-dd').format(dateTo),
        showAllObs:(obsRangeFilterApplied) ? false : isDateRangeObs,
        status: filterLogStatus != null ? 'PENDING' : (selectedStatus == null ? 'PENDING' : selectedStatus!.code),
        logStatus: filterLogStatus,
        obsViewOtherTransactionYN : obsViewOtherTransactionYN,
        points: filterPointsController.text,
        transNo: filterTransNoController.text,
        observerId: selectedOwner?.id,
        delayedYN:delayedYNObs,
        flag: flagObs,
        onRequestSuccess: (result) {
          if(obsStart == 0) {
            observationList = result;
            observationTotalRecords = (result.isNotEmpty) ? result.first.totalRecords ?? 0 : 0;
          }
          else{
            observationList += result;
            observationTotalRecords = (result.isNotEmpty) ? result.first.totalRecords ?? 0 : 0;
          }
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.success));
          observationFetched = true;
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus:
                  LoadingStatus(loader: Loader.error, exception: exception));
          observationFetched = false;
        } );

  }

  List<StatusModel> observationTypeList = [
    StatusModel(
        id: 1,
        description: "My Observations",
        code: "RAISED"
    ),
    StatusModel(
        id: 2,
        description: "Assigned Observations",
        code: "AGAINST"
    ),
    StatusModel(
        id: 3,
        description: "Action Taken Observations",
        code: "ACTION_TAKEN"
    ),
    StatusModel(
        id: 4,
        description: "All Observations",
        code: "ALL_OBSERVATION"
    ),
  ];

  List<StatusModel> supportTypeList = [
    StatusModel(
        id: 1,
        description: "Assigned Requests",
        code: "AGAINST"
    ),
    StatusModel(
        id: 2,
        description: "My Requests",
        code: "RAISED"
    ),
    StatusModel(
        id: 3,
        description: "Action Taken Requests",
        code: "ACTION_TAKEN"
    ),
    StatusModel(
        id: 4,
        description: "All Requests",
        code: "ALL_SUPPORT"
    ),
  ];
  List<StatusModel> listOfStatusObs = [];
  void fetchStatusTypes() {
    listOfStatusObs = [];
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ProjectDetailsUseCase().fetchStatusTypes(onRequestSuccess: (result) {
      listOfStatusObs = result;
      listOfStatusObs.add(StatusModel(id: 0,code: "All",description: "All" ));
      setSelectStatus(listOfStatusObs.firstWhere((item){return item.code == "PENDING";}));


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

  List<CommonMasterModel> listOfStatusSupport = [];

  void getStatusType() {
    listOfStatusObs = [];
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ProjectDetailsUseCase().getStatusType(onRequestSuccess: (result) {
      listOfStatusSupport = result;
      if(listOfStatusSupport.any((item){return item.code == "TO_CLOSE";})){
        listOfStatusSupport.removeWhere((item){return item.code == "TO_CLOSE";});
      }
      listOfStatusSupport.add(CommonMasterModel(id: 0,code: "All",description: "All",clientname: "",cityname: "",name: "All",sortOrder: 0));
      setSelectStatusSupport(listOfStatusSupport.firstWhere((item){return item.code == "PENDING";}));


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



  //----------------------------------------------------------------------------------------------------
  // Department section
  List<DepartmentDropDownModel> departmentList = [];
  DepartmentDropDownModel? selectedDept;
  DepartmentDropDownModel? tempSelectedDept;
  DepartmentDropDownModel? selectedDependencyDept;
  DepartmentDropDownModel? tempSelectedDependencyDept;

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

  Future<void> fetchDepartmentDropDown() async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ProjectDetailsUseCase().fetchDepartmentDropDown(
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

  //----------------------------------------------------------------------------------------------------

  //Support request related section
  List<SupportRequestDtlModel> supportRequestList = [];
  DateTime closureDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime closureDateTo = DateTime.now();
  DateTime? tempClosureDateFrom;
  DateTime? tempClosureDateTo;
  bool isShowAllSupport = true;
  bool? tempIsShowAllSupport;
  bool sptRangeFilterApplied = false;
  DateRangeModel? selectedSptRange;
  String? selectedSptRangeLabel;
  bool supViewOtherTransactionYN = true;

  void changeSupViewOtherTransactionYN(bool value){
    print("entered___ $value");
    supViewOtherTransactionYN = value;
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
      selectedEscalatedUser = null;
      filterSupportPointsController = TextEditingController(text: "");
      supportOwnerController = TextEditingController(text: "");
      delayedYNSupport = extra!["DelayedYN"]??"None";
      if(delayedYNSupport == "Y"){
        changeIsDelayedSupport(true);
      }else if(delayedYNSupport == "N"){
        changeIsDelayedSupport(false);
      }
      
      filterLogStatus = null;

      viewOtherTransYN = extra!["ViewOtherTransYN"]??"None";
      if(viewOtherTransYN == "Y" && (extra!["isFromSupport"]??false)){
        changeSupViewOtherTransactionYN(false);
      }else {
        changeSupViewOtherTransactionYN(true);
      }
    }
    else{
      tempClosureDateFrom = null;
      tempClosureDateTo = null;
      tempSelectedDept = null;
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

  Future<void> onRefreshSptAction() async{
    supportRequestFetched = false;
    fetchSupportRequestList(changeStart: true);
    notifyListeners();
  }

  bool supportRequestFetched = false;
  int supportRequestTotalRecords = 0;

  Future<void> fetchSupportRequestList({bool changeStart = false}) async {
    final dateFrom = selectedSptRange?.from ?? closureDateFrom;
    final dateTo = selectedSptRange?.to ?? closureDateTo;
    if(changeStart){
      supportRequestList = [];
      supStart = 0;
    }
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ProjectDetailsUseCase().fetchSupportRequestList(
        projectId: projectId,
        status: filterLogStatus != null ? "PENDING" : (selectedStatusSupport == null ? "PENDING" : selectedStatusSupport!.code),
        logStatus: filterLogStatus,
        start: supStart,
        limit: supLimit,
        userId:userId,
        flag: flagSupport,
        deptId:selectedDept?.deptId ?? 0,
        dependencyDeptId: selectedDependencyDept?.deptId ?? 0,
        dateFrom: DateFormat('yyyy-MM-dd').format(dateFrom) ,
        dateTo: DateFormat('yyyy-MM-dd').format(dateTo),
        showAllSupport:(sptRangeFilterApplied) ? false : isShowAllSupport,
        supViewOtherTransactionYN: supViewOtherTransactionYN,
        point:filterSupportPointsController.text,
        escalatedUserId:selectedEscalatedUser?.id,
        delayedYN:delayedYNSupport,
        onRequestSuccess: (result) {
          if(supStart == 0) {
            supportRequestList = result;
            supportRequestTotalRecords = (result.isNotEmpty) ? result.first.totalRecords ?? 0 : 0;
          }
          else{
            supportRequestList += result;
            supportRequestTotalRecords = (result.isNotEmpty) ? result.first.totalRecords ?? 0 : 0;
          }
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.success));
          supportRequestFetched = true;

        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus:
                  LoadingStatus(loader: Loader.error, exception: exception));
          supportRequestFetched = false;
        });
    notifyListeners();
  }

  //------------------------------------------------------------------------------------------
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

  //-------------------------------------------------------------------------------------------
  //Common filter Functions
  void setThisWeek({required bool isSupport}) {
    if(isSupport) {
      selectedSptRange = DateRangeHelper.thisWeek();
      selectedSptRangeLabel = "This Week";
      sptRangeFilterApplied = true;
      fetchSupportRequestList(changeStart: true);
    }
    else{
      observationList = [];
      selectedObsRange = DateRangeHelper.thisWeek();
      selectedObsRangeLabel = "This Week";
      obsRangeFilterApplied = true;
      fetchObservationList(changeStart: true);
    }
    notifyListeners();
  }

  void setLastWeek({required bool isSupport}) {
    if(isSupport) {
      selectedSptRange = DateRangeHelper.lastWeek();
      selectedSptRangeLabel = "Last Week";
      sptRangeFilterApplied = true;
      fetchSupportRequestList(changeStart: true);
    }
    else{
      observationList = [];
      selectedObsRange = DateRangeHelper.lastWeek();
      selectedObsRangeLabel = "Last Week";
      obsRangeFilterApplied = true;
      fetchObservationList(changeStart: true);
    }
    notifyListeners();
  }

  void setNextWeek({required bool isSupport}) {
    if(isSupport) {
      selectedSptRange = DateRangeHelper.nextWeek();
      selectedSptRangeLabel = "Next Week";
      sptRangeFilterApplied = true;
      fetchSupportRequestList(changeStart: true);
    }
    else{
      observationList = [];
      selectedObsRange = DateRangeHelper.nextWeek();
      selectedObsRangeLabel = "Next Week";
      obsRangeFilterApplied = true;
      fetchObservationList(changeStart: true);
    }
    notifyListeners();
  }

  void setThisMonth({required bool isSupport}) {
    if(isSupport) {
      selectedSptRange = DateRangeHelper.thisMonth();
      selectedSptRangeLabel = "This Month";
      sptRangeFilterApplied = true;
      fetchSupportRequestList(changeStart: true);
    }
    else{
      observationList = [];
      selectedObsRange = DateRangeHelper.thisMonth();
      selectedObsRangeLabel = "This Month";
      obsRangeFilterApplied = true;
      fetchObservationList(changeStart: true);
    }
    notifyListeners();
  }

  void setLastMonth({required bool isSupport}) {
    if(isSupport) {
      selectedSptRange = DateRangeHelper.lastMonth();
      selectedSptRangeLabel = "Last Month";
      sptRangeFilterApplied = true;
      fetchSupportRequestList(changeStart: true);
    }
    else{
      observationList = [];
      selectedObsRange = DateRangeHelper.lastMonth();
      selectedObsRangeLabel = "Last Month";
      obsRangeFilterApplied = true;
      fetchObservationList(changeStart: true);
    }
    notifyListeners();
  }

  void setNextMonth({required bool isSupport}) {
    if(isSupport) {
      selectedSptRange = DateRangeHelper.nextMonth();
      selectedSptRangeLabel = "Next Month";
      sptRangeFilterApplied = true;
      fetchSupportRequestList(changeStart: true);
    }
    else{
      observationList = [];
      selectedObsRange = DateRangeHelper.nextMonth();
      selectedObsRangeLabel = "Next Month";
      obsRangeFilterApplied = true;
      fetchObservationList(changeStart: true);
    }
    notifyListeners();
  }

  void disposeVariables(){
    supportRequestList = [];
    observationList= [];
  }
  bool isExpandedDashBoard = false;
  bool isExpandedObsAndSupport = false;
  void expansionTileCollapseDashBoard(bool value) {
    isExpandedDashBoard = value;
    notifyListeners();

  }

  bool isExpandedClient = false;
  void expansionTileCollapseClient(bool value) {
    isExpandedClient = value;
    notifyListeners();
  }

  void expansionTileCollapseObsAndSupport(bool value) {
    isExpandedObsAndSupport = value;
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

  List<OwnerModel> owners = [];
  TextEditingController obsOwnerController = TextEditingController();
  TextEditingController obsStatusController = TextEditingController();
  TextEditingController supportStatusController = TextEditingController();
  TextEditingController obsTypeStatusController = TextEditingController();
  TextEditingController supportTypeStatusController = TextEditingController();
  OwnerModel? selectedOwner;

  TextEditingController supportOwnerController = TextEditingController();
  OwnerModel? selectedEscalatedUser;

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

  StatusModel? selectedStatus;
  void setSelectStatus(StatusModel statusModel) {
    selectedStatus = statusModel;
    obsStatusController = TextEditingController(text: statusModel.description);
    notifyListeners();
  }

  CommonMasterModel? selectedStatusSupport;
  void setSelectStatusSupport(CommonMasterModel statusModel) {
    selectedStatusSupport = statusModel;
    supportStatusController = TextEditingController(text: statusModel.description);
    notifyListeners();
  }
  void setSelectedEscalated(String name) {
    selectedEscalatedUser = owners.firstWhere((owner) => owner.name == name);
    supportOwnerController = TextEditingController(text: name);
    notifyListeners();
  }


  StatusModel? obsType;
  void setSelectObsType(StatusModel statusModel) {
    obsType = statusModel;
    obsTypeStatusController = TextEditingController(text: statusModel.description);
    notifyListeners();
  }

  StatusModel? supportType;
  void setSelectSupportType(StatusModel statusModel) {
    supportType = statusModel;
    supportTypeStatusController = TextEditingController(text: statusModel.description);
    notifyListeners();
  }





}
