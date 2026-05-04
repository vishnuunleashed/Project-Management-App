import 'package:base/core/loader_value.dart';
import 'package:interior_design/data/model/response/call_tracker/user_list.dart';
import 'package:interior_design/domain/usecase/all_observation_and_support_request_usecase/all_observation_support_request_usecase.dart';
import 'package:interior_design/domain/usecase/call_tracker/service_support_usecase.dart';
import 'package:interior_design/presentation/provider/common_support/base_all_support_provider.dart';
import 'package:interior_design/presentation/view/common/custom_bottom_bar.dart';
import 'package:intl/intl.dart';

class ServiceDetailsSupportRequestProvider extends BaseAllSupportProvider{

  int refDataId = 0;
  @override
  void setNavigationParameters({required Map<String, dynamic> extra}){
    bottomBarStatus = extra["bottomBarStatus"];
    refDataId = extra["refDataId"];
    userId = extra["userId"];
    raisedUser = extra['raisedUser'];
    userprofileurl = extra['userprofileurl']??"";
    isCritical = extra['isCritical']??false;
    isFromDashboard = (userId==null) ? false : true;
    isAllSupport = !isFromDashboard;
    notifyListeners();
    getUserForCallTracker();
    fetchSupportRequestList(changeStart: true);
  }


  @override
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



    ServiceSupportUseCase().fetchServiceDetailBasedSupportRequestList(
        start: supStart,
        limit: supLimit,
        isCritical:isCritical,
        isAllSupport: isAllSupport,
        showAllSupport: (sptRangeFilterApplied) ? false : isShowAllSupport,
        isSuperUserSupportOnly: isSuperUserSupportOnly,
        refDataId: refDataId,
        refOptionCode: "CALL_TRACKER",
        userId: userId,
        deptId:selectedDept?.deptId ?? 0,
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

  List<EmployeeModel> employeeList = [];

  void getUserForCallTracker(){
    ServiceSupportUseCase().getUserForCallTracker(
        onRequestSuccess: (result){
          employeeList = result;
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error, exception: exception));
        });
  }

}