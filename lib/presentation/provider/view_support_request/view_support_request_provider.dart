
import 'package:base/core/loader_value.dart';
import 'package:base/presentation/utility/base_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_design/domain/usecase/view_support_request/view_support_request_usecase.dart';
import 'package:interior_design/presentation/provider/common_support/base_support_provider.dart';
import 'package:interior_design/presentation/view/common/custom_bottom_bar.dart';


class ViewSupportRequestProvider extends BaseSupportProvider {

  PageController pageController = PageController();

  void changePage(int index) {
    pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }

  Status status = Status.pending;
  void setStatus({required Status status}){
    this.status = status;

    notifyListeners();
  }



  void reassignSupportRequest({required WidgetRef ref,required String status,required Function onSuccess}) {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));

    ViewSupportRequestUseCase().reassignSupportRequest(
        id: supportListData!.id,
        remarks: remarksController.text,
        projectId: projectId,
        escalatedTo: selectedOwner?.id,
        logId: supportListData?.logid??0,//to_do
        onRequestSuccess: () {
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success,
              message: "Close Support Request saved successfully"));
          onSuccess();
          notifyListeners();
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(loadingStatus:LoadingStatus(loader: Loader.error, exception: exception));
        });
  }

  void closeSupportRequest({required WidgetRef ref,required String status,required Function onSuccess}) {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));

    ViewSupportRequestUseCase().closeSupportRequest(
        id: supportListData!.id,
        remarks: remarksController.text,
        projectId: projectId,
        logId: supportListData?.logid??0,

        onRequestSuccess: () {
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success,
              message: "Close Support Request saved successfully"));
          onSuccess();
          notifyListeners();
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(loadingStatus:LoadingStatus(loader: Loader.error, exception: exception));
        });
  }

  void cancelSupportRequest({required WidgetRef ref,required String status,required Function onSuccess}) {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));

    ViewSupportRequestUseCase().cancelSupportRequest(
        id: supportListData!.id,
        logId: supportListData?.logid??0,

        onRequestSuccess: () {
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success,
              message: "Close Support Request saved successfully"));
          onSuccess();
          notifyListeners();
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(loadingStatus:LoadingStatus(loader: Loader.error, exception: exception));
        });
  }


}