/*------------------------------------------------------------------------------
AUTHOR		    : Brenta Roy
CREATED DATE	: 20/08/2025
PURPOSE		    :
MODULE/TOPIC	: CloseSupportRequestProvider
REMARKS		    :
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------*/

import 'package:base/core/constants.dart';
import 'package:base/core/loader_value.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_design/data/model/response/call_tracker/user_list.dart';
import 'package:interior_design/data/model/response/close_support_request/close_support_request_model.dart';
import 'package:interior_design/data/model/response/home/home_projectlist_model.dart';
import 'package:interior_design/domain/usecase/call_tracker/service_support_usecase.dart';
import 'package:interior_design/domain/usecase/view_support_request/view_support_request_usecase.dart';
import 'package:interior_design/presentation/provider/common_support/base_support_provider.dart';


class CloseSupportRequestProvider extends BaseSupportProvider {


  PageController pageController = PageController();
  // String prevRoute = "";
  // Map<String, dynamic> screenExtra = {};

  void changePage(int index) {
    pageController.jumpToPage(
      index,

    );
  }
  bool fromProjectSchedule = false;
  void setFromProjectScheduleFlag(flag) {
    fromProjectSchedule = flag;
    notifyListeners();
  }

  String materialChartOptionName = '';
  int materialChartParentOptionId = 0;
  bool isProjectDepartment = false;
  Future<void> setOptionDtl({required UserRightsModel? optionObj}) async {
    materialChartParentOptionId = optionObj?.rightsData[0].parentOptionId ??0;
    materialChartOptionName = optionObj?.optionName??"";
    isProjectDepartment = await BaseSecureStorage.getString(BaseConstants.departmentCode) == "PRJ";
    notifyListeners();
  }


  void setParameter(Map<String, dynamic>? extra) {
    isFromCallTracker = extra!["isFromCallTracker"]??false;
    // prevRoute = extra["prevRoute"] ?? "";
    // screenExtra = extra["screenExtra"] ?? {};

  }

  void submitSupportRequest({required WidgetRef ref,required String status,required Function onSuccess}) {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));

    ViewSupportRequestUseCase().submitSupportRequest(
        id: supportListData!.id,
        projectId: projectId,
        remarks: remarksController.text,
        logId: supportListData?.logid??0,//to_do
        onRequestSuccess: () {
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success,
              message: "Submit Support Request saved successfully"));
          onSuccess();
          notifyListeners();
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(loadingStatus:LoadingStatus(loader: Loader.error, exception: exception));
        });
  }


  void forwardSupportRequest({required WidgetRef ref,required String status,required Function onSuccess}) {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ViewSupportRequestUseCase().forwardSupportRequest(
        id: supportListData!.id,
        remarks: remarksController.text,
        projectId: projectId,
        escalatedTo: isFromCallTracker ? selectedEmployee?.id :  selectedOwner?.id,
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

  void reassignedSupportRequest({required WidgetRef ref,required String status,required Function onSuccess}) {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ViewSupportRequestUseCase().reassignSupportRequest(
      id: supportListData!.id,
      remarks: remarksController.text,
      projectId: projectId,
      escalatedTo: isFromCallTracker ? selectedEmployee?.id : selectedOwner?.id,
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

  void closeSupportRequest({required WidgetRef ref,required String status,required Function onSuccess}) {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ViewSupportRequestUseCase().closeSupportRequest(
      id: supportListData!.id,
      remarks: remarksController.text,
      projectId: projectId,
      logId: supportListData?.logid??0,//to_do
      onRequestSuccess: () {
        changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success,
            message: "Close Support Request saved successfully"));
        onSuccess();
        notifyListeners();
      },
      onRequestFailure: (exception) {
        changeLoadingStatus(loadingStatus:LoadingStatus(loader: Loader.error, exception: exception));
      },
    );
  }

  void cancelSupportRequest({required WidgetRef ref,required String status,required Function onSuccess}) {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ViewSupportRequestUseCase().cancelSupportRequest(
      id: supportListData!.id,
      logId: supportListData?.logid??0,//to_do
      onRequestSuccess: () {
        changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success,
            message: "Close Support Request saved successfully"));
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