
import 'package:base/core/constants.dart';
import 'package:base/core/loader_value.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/presentation/utility/base_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_design/data/model/response/call_tracker/user_list.dart';
import 'package:interior_design/domain/usecase/call_tracker/service_support_usecase.dart';
import 'package:interior_design/domain/usecase/view_support_request/view_support_request_usecase.dart';
import 'package:interior_design/presentation/provider/close_support_request/close_support_request_provider.dart';
import 'package:interior_design/presentation/provider/common_support/base_support_provider.dart';
import 'package:interior_design/presentation/view/common/custom_bottom_bar.dart';


class ViewServiceSupportRequestProvider extends CloseSupportRequestProvider {

  PageController pageController = PageController();

  void changePage(int index) {
    pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }

  ServiceSupportSiteWiseStatus status = ServiceSupportSiteWiseStatus.all;
  void setStatus({required ServiceSupportSiteWiseStatus status}){
    this.status = status;

    notifyListeners();
  }


  @override
  void forwardSupportRequest({required WidgetRef ref,required String status,required Function onSuccess}) {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ViewSupportRequestUseCase().forwardSupportRequest(
      id: supportListData!.id,
      remarks: remarksController.text,
      projectId: projectId,
      escalatedTo: selectedEmployee?.id,
      logId: supportListData?.logid??0,//to_do
      onRequestSuccess: () {
        changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success,
            message: "Forward Support Request saved successfully"));
        onSuccess();
        notifyListeners();
      },
      onRequestFailure: (exception) {
        changeLoadingStatus(loadingStatus:LoadingStatus(loader: Loader.error, exception: exception));
      },
    );
  }

  @override
  void reassignedSupportRequest({required WidgetRef ref,required String status,required Function onSuccess}) {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ViewSupportRequestUseCase().reassignSupportRequest(
      id: supportListData!.id,
      remarks: remarksController.text,
      projectId: projectId,
      escalatedTo: selectedEmployee?.id,
      logId: supportListData?.logid??0,//to_do
      onRequestSuccess: () {
        changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success,
            message: "Reassign Support Request saved successfully"));
        onSuccess();
        notifyListeners();
      },
      onRequestFailure: (exception) {
        changeLoadingStatus(loadingStatus:LoadingStatus(loader: Loader.error, exception: exception));
      },
    );
  }


  List<EmployeeModel> employeeList = [];

  void getUserForCallTracker(){
    ServiceSupportUseCase().getUserForCallTracker(
        onRequestSuccess: (result) async {
          employeeList = result;
          final loggedInUserId = await BaseSecureStorage.getInt(BaseConstants.userID);
          employeeList.removeWhere((item){return item.id == loggedInUserId;});
          notifyListeners();
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error, exception: exception));
        });
  }

  EmployeeModel? selectedEmployee;
  void setSelectedEmployee(EmployeeModel name) {
    selectedEmployee = name;
    notifyListeners();
  }

}