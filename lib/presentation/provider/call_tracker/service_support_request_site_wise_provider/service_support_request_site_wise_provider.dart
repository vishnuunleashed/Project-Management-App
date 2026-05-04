// import 'package:base/core/constants.dart';
// import 'package:base/core/loader_value.dart';
// import 'package:base/data/repository/local/base_prefs.dart';
// import 'package:base/presentation/provider/base_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:interior_design/data/model/request/project_details/date_range_model.dart';
// import 'package:interior_design/data/model/response/add_observation/add_observation_model.dart';
// import 'package:interior_design/data/model/response/common/common_master_dto.dart';
// import 'package:interior_design/data/model/response/project_details/department_model.dart';
// import 'package:interior_design/data/model/response/project_details/support_request_model.dart';
// import 'package:interior_design/domain/usecase/add_support_request/add_support_request_usecase.dart';
// import 'package:interior_design/domain/usecase/all_observation_and_support_request_usecase/all_observation_support_request_usecase.dart';
// import 'package:interior_design/domain/usecase/call_tracker/service_support_request_site_wise_usecase.dart';
// import 'package:interior_design/domain/usecase/call_tracker/service_support_usecase.dart';
// import 'package:interior_design/domain/usecase/my_support/my_support_usecase.dart';
// import 'package:interior_design/presentation/provider/close_support_request/close_support_request_provider.dart';
// import 'package:interior_design/presentation/view/common/custom_bottom_bar.dart';
// import 'package:intl/intl.dart';
//
// class ServiceSupportRequestSiteWiseProvider extends CloseSupportRequestProvider{
//   bool isFromProjectDetails = false;
//   List<SupportRequestDtlModel> supportRequestList = [];
//   PageController pageController = PageController();
//   ScrollController supScrollController = ScrollController();
//   String tag = "";
//   bool supRequestFetched = false;
//
//
//
//   String delayedYNSupport = "";
//   int refDataId = 0;
//   int userId = 0;
//   // String transNo = "";
//   String refOptionCode = "";
//
//   String? scopeFlag;
//   String? siteName;
//   String? flagSupport;
//   String? subStatus;
//
//   Future<void> setParameters({Map<String, dynamic>? extra}) async {
//     if(extra == null) return;
//     delayedYNSupport = extra["delayedYNSupport"]??"None";
//     userId = extra["userId"] ?? await BaseSecureStorage.getInt(BaseConstants.userID);
//     scopeFlag = extra["scopeFlag"]??"INDIVIDUAL";
//     siteName = extra["siteName"]??"";
//     flagSupport = extra["flagSupport"];
//     subStatus = extra["subStatus"];
//     bottomBarStatus = extra["ServiceStatus"] ?? ServiceStatus.all;
//     notifyListeners();
//     getUserDetails();
//     fetchOwners();
//     fetchServiceSupportRequestSiteWiseList(changeStart: true);
//
//
//   }
//
//   void initValue(){
//     pageController = PageController();
//     supScrollController = ScrollController();
//     isFromProjectDetails = false;
//     supportRequestList = [];
//     projectId = 0;
//     supStart = 0;
//     supLimit = 20;
//     sptRangeFilterApplied = false;
//     supRequestFetched = false;
//     bottomBarStatus = ServiceStatus.all;
//     userName = "";
//     isSuperUser = false;
//     selectedDept = null;
//     tempSelectedDept = null;
//     filterSupportPointsController = TextEditingController(text: "");
//     supportOwnerController = TextEditingController(text: "");
//     selectedEscalatedUser = null;
//     paginationController();
//     notifyListeners();
//   }
//
//   bool? tempIsDelayedSupport;
//
//   void changeIsDelayedSupport(bool value){
//     tempIsDelayedSupport = value;
//     if(value){
//       delayedYNSupport = "Y";
//     }else{
//       delayedYNSupport = "N";
//     }
//     closureDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
//     closureDateTo = DateTime.now();
//
//     notifyListeners();
//   }
//
//   String userName = "";
//   bool isSuperUser = false;
//   Future<void> getUserDetails() async{
//     print("Username = $userName");
//     userName =  await BaseSecureStorage.getString(BaseConstants.userName);
//     isSuperUser = await BaseSecureStorage.getBool(BaseConstants.superUserYN);
//     notifyListeners();
//   }
//
//
//
//   ServiceStatus bottomBarStatus = ServiceStatus.all;
//
//   void paginationController(){
//     supScrollController.addListener((){
//       if (supScrollController.position.pixels ==
//           supScrollController.position.maxScrollExtent
//           && (supportRequestList.first.totalRecords ??0) > ((supStart == 0) ? supLimit : supStart+supLimit)) {
//         supStart += supLimit;
//         fetchServiceSupportRequestSiteWiseList();
//       }
//     });
//   }
//
//
//   void onTapBottomSelected(ServiceStatus status) {
//     supportRequestList = [];
//     bottomBarStatus = status;
//     fetchServiceSupportRequestSiteWiseList(changeStart: true);
//     notifyListeners();
//   }
//
//
//   String formatDateOrToday(DateTime? date) {
//     final now = DateTime.now();
//     final target = date ?? now;
//
//     if (target.year == now.year &&
//         target.month == now.month &&
//         target.day == now.day) {
//       return "Today";
//     }
//
//     return DateFormat('MMM dd, yyyy').format(target);
//   }
//
//
//   DepartmentDropDownModel? selectedDept;
//
//   List<DepartmentDropDownModel> department = [];
//   bool superUserYN = false;
//   int departmentId = 0;
//   Future<void> fetchDepartmentDropDown() async {
//     changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
//     MySupportRequestUseCase().fetchDepartmentDropDown(
//       onRequestSuccess: (result) async {
//         department = result;
//         superUserYN = await BaseSecureStorage.getBool(BaseConstants.superUserYN);
//         departmentId = await BaseSecureStorage.getInt(BaseConstants.departmentId);
//
//         notifyListeners();
//         changeLoadingStatus(
//           loadingStatus: LoadingStatus(loader: Loader.success),
//         );
//       },
//       onRequestFailure: (exception) {
//         changeLoadingStatus(
//           loadingStatus: LoadingStatus(
//             loader: Loader.error,
//             exception: exception,
//           ),
//         );
//       },
//     );
//     notifyListeners();
//   }
//   List<CommonMasterModel> statusTypeList = [];
//   Future<void> getStatusType() async {
//     changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
//     ServiceSupportUseCase().getStatusType(
//       onRequestSuccess: (result) async {
//         statusTypeList = result;
//         notifyListeners();
//         changeLoadingStatus(
//           loadingStatus: LoadingStatus(loader: Loader.success),
//         );
//       },
//       onRequestFailure: (exception) {
//         changeLoadingStatus(
//           loadingStatus: LoadingStatus(
//             loader: Loader.error,
//             exception: exception,
//           ),
//         );
//       },
//     );
//     notifyListeners();
//   }
//
//   bool isShowAllSupport = true;
//   int supStart = 0;
//   int projectId = 0;
//   int supLimit = 20;
//   int supportRequestTotalRecords = 0;
//   bool isSuperUserSupportOnly = false;
//   DateTime closureDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
//   DateTime closureDateTo = DateTime.now();
//   DateRangeModel? selectedSptRange;
//
//   Future<void> fetchServiceSupportRequestSiteWiseList({bool changeStart = false}) async {
//     supRequestFetched = false;
//     changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
//     if(changeStart){
//       supportRequestList = [];
//       supStart = 0;
//     }
//     final dateFrom = selectedSptRange?.from ?? closureDateFrom;
//     final dateTo = selectedSptRange?.to ?? closureDateTo;
//     String? status;
//     if (bottomBarStatus == ServiceStatus.all) {
//       status = null;
//     }else if(bottomBarStatus == ServiceStatus.pending){
//       status = 'PENDING';
//     }else if((bottomBarStatus == ServiceStatus.closed)){
//       status = 'CLOSED';
//     }else if((bottomBarStatus == ServiceStatus.cancelled)){
//       status = "CANCELLED";
//     }else{
//       status = null;
//     }
//     ServiceSupportRequestSiteWiseUseCase().fetchServiceSupportRequestSiteWiseList(
//         delayedYN: delayedYNSupport,
//         scopeFlag: scopeFlag,
//         siteName: siteName,
//         userId: userId,
//         start: supStart,
//         limit: supLimit,
//         doPassAppType: false,
//         showAllSupport: (sptRangeFilterApplied) ? false : isShowAllSupport,
//         deptId:selectedDept?.deptId ?? 0,
//         flag: flagSupport ?? "AGAINST",
//         status: subStatus != null ? 'PENDING' : status,
//         logStatus: subStatus, // Note: Make sure logStatus is added to ServiceSupportUseCase if it supports it, like ProjectDetailsUseCase did.
//         dateFrom: DateFormat('yyyy-MM-dd').format(dateFrom) ,
//         dateTo: DateFormat('yyyy-MM-dd').format(dateTo),
//         point: filterSupportPointsController.text,
//         escalatedUserId: selectedEscalatedUser?.id,
//         onRequestSuccess: (result){
//           if(supStart == 0) {
//             supportRequestList = result;
//             supportRequestTotalRecords = (result.isNotEmpty) ? result.first.totalRecords ?? 0 : 0;
//           }
//           else{
//             supportRequestList += result;
//             supportRequestTotalRecords = (result.isNotEmpty) ? result.first.totalRecords ?? 0 : 0;
//           }
//           supRequestFetched = true;
//           notifyListeners();
//           changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
//         },
//         onRequestFailure: (exception) {
//           changeLoadingStatus(
//               loadingStatus: LoadingStatus(
//                   loader: Loader.error,
//                   exception: exception));
//           supRequestFetched = true;
//           notifyListeners();
//
//         });
//     notifyListeners();
//   }
//
//   //filter section
//   DepartmentDropDownModel? tempSelectedDept;
//   CommonMasterModel? selectedStatus;
//
//   void changeIsShowAllSupport(bool value){
//     tempIsShowAllSupport = value;
//     closureDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
//     closureDateTo = DateTime.now();
//     notifyListeners();
//   }
//
//   void changeClosureDateFrom(DateTime date) {
//     tempClosureDateFrom = date;
//     notifyListeners();
//   }
//
//   void changeClosureDateTo(DateTime date) {
//     tempClosureDateTo = date;
//     notifyListeners();
//   }
//
//   void setIsShowAllSupport(){
//     isShowAllSupport = tempIsShowAllSupport ?? true;
//     notifyListeners();
//   }
//
//   void setSptFilterDateField(){
//     if(tempClosureDateFrom != null) {
//       closureDateFrom = tempClosureDateFrom ?? DateTime(DateTime.now().year, DateTime.now().month, 1);
//     }
//     if(tempClosureDateTo != null) {
//       closureDateTo = tempClosureDateTo ?? DateTime.now();
//     }
//     notifyListeners();
//   }
//
//   void changeDepartment(DepartmentDropDownModel department) {
//     tempSelectedDept = department;
//     notifyListeners();
//   }
//
//   void changeStatusType(CommonMasterModel status) {
//     selectedStatus = status;
//     notifyListeners();
//   }
//
//   void setSelectedDepartment(){
//     if(tempSelectedDept != null) {
//       selectedDept = tempSelectedDept;
//     }
//     notifyListeners();
//   }
//
//   void setSptRangeFilterApplied(bool value){
//     sptRangeFilterApplied = value;
//     if(value == false){
//       selectedSptRange = null;
//       selectedSptRangeLabel = "";
//     }
//     notifyListeners();
//   }
//
//   DateTime? tempClosureDateFrom;
//   DateTime? tempClosureDateTo;
//   bool? tempIsShowAllSupport;
//   bool sptRangeFilterApplied = false;
//   String? selectedSptRangeLabel;
//   void clearSupportReqFilter({required bool isFromClearButton, bool isFromRangeFilter = false}) {
//     if(isFromClearButton) {
//       closureDateFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
//       closureDateTo = DateTime.now();
//       selectedDept = null;
//       tempSelectedDept = null;
//       tempClosureDateFrom = null;
//       tempClosureDateTo = null;
//       isShowAllSupport = true;
//       tempIsShowAllSupport = null;
//       isSuperUserSupportOnly = false;
//       filterSupportPointsController = TextEditingController(text: "");
//       supportOwnerController = TextEditingController(text: "");
//       selectedEscalatedUser = null;
//       if(isFromRangeFilter){
//         selectedSptRange = null;
//         sptRangeFilterApplied = false;
//         selectedSptRangeLabel = "";
//       }
//     }
//     else{
//       tempClosureDateFrom = null;
//       tempClosureDateTo = null;
//       tempSelectedDept = null;
//       tempIsShowAllSupport = null;
//     }
//     notifyListeners();
//   }
//
//   //Date range filter
//   //Common filter Functions
//   void setThisWeek() {
//     selectedSptRange = DateRangeHelper.thisWeek();
//     selectedSptRangeLabel = "This Week";
//     sptRangeFilterApplied = true;
//     fetchServiceSupportRequestSiteWiseList(changeStart: true);
//
//     notifyListeners();
//   }
//
//   void setLastWeek({required bool isSupport}) {
//     selectedSptRange = DateRangeHelper.lastWeek();
//     selectedSptRangeLabel = "Last Week";
//     sptRangeFilterApplied = true;
//     fetchServiceSupportRequestSiteWiseList(changeStart: true);
//     notifyListeners();
//   }
//
//   void setNextWeek({required bool isSupport}) {
//     selectedSptRange = DateRangeHelper.nextWeek();
//     selectedSptRangeLabel = "Next Week";
//     sptRangeFilterApplied = true;
//     fetchServiceSupportRequestSiteWiseList(changeStart: true);
//     notifyListeners();
//   }
//
//   void setThisMonth({required bool isSupport}) {
//     selectedSptRange = DateRangeHelper.thisMonth();
//     selectedSptRangeLabel = "This Month";
//     sptRangeFilterApplied = true;
//     fetchServiceSupportRequestSiteWiseList(changeStart: true);
//     notifyListeners();
//   }
//
//   void setLastMonth({required bool isSupport}) {
//     selectedSptRange = DateRangeHelper.lastMonth();
//     selectedSptRangeLabel = "Last Month";
//     sptRangeFilterApplied = true;
//     fetchServiceSupportRequestSiteWiseList(changeStart: true);
//
//     notifyListeners();
//   }
//
//   void setNextMonth({required bool isSupport}) {
//     selectedSptRange = DateRangeHelper.nextMonth();
//     selectedSptRangeLabel = "Next Month";
//     sptRangeFilterApplied = true;
//     fetchServiceSupportRequestSiteWiseList(changeStart: true);
//     notifyListeners();
//   }
//
//
//   void unFollowSupportRequest({required int supportId,required Function() onRequestSuccess,}){
//     AllObservationAndSupportUseCase().unFollowSupportRequest(
//         supportId: supportId,
//         onRequestSuccess: (){
//           onRequestSuccess();
//         },
//         onRequestFailure: (exception)=>
//             changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error,message: exception.toString()),)
//     );
//   }
//   void updateSupportListForFollow(int index){
//     supportRequestList[index].notifyuseryn = "Y";
//     supportRequestList[index].addedbycreatoryn = "N";
//     notifyListeners();
//   }
//   void updateSupportListForUnFollow(int index){
//     supportRequestList[index].notifyuseryn = "N";
//     supportRequestList[index].addedbycreatoryn = "N";
//     notifyListeners();
//   }
//
//   TextEditingController filterSupportPointsController = TextEditingController();
//   TextEditingController supportOwnerController = TextEditingController();
//   OwnerModel? selectedEscalatedUser;
//
//
//
//   void setSelectedEscalated(String name) {
//     selectedEscalatedUser = owners.firstWhere((owner) => owner.name == name);
//     supportOwnerController = TextEditingController(text: name);
//     notifyListeners();
//   }
//
//   void refreshPage() {
//     supportRequestList = [];
//     print("entered___ ");
//     fetchServiceSupportRequestSiteWiseList(changeStart: true);
//     notifyListeners();
//   }
//
//
//
//
//
//
// }