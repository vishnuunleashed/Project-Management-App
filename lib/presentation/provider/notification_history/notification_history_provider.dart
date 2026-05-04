import 'package:base/core/loader_value.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/data/model/response/notification/notification_response_model.dart';
import 'package:interior_design/data/remote/repository/project_schedule/project_schedule_impl.dart';
import 'package:interior_design/domain/usecase/notification_history/notification_history_usecase.dart';

class NotificationHistoryProvider extends BaseProvider{

  List<NotificationList> notificationList = [];
  int start = 0;
  int limit = 20;
  final ScrollController scrollController = ScrollController();

  void initValues(){
    notificationList = [];
    start = 0;
    limit = 20;
    fetchNotificationHistoryList();
    paginationController();
  }

  void paginationController(){
    scrollController.addListener((){
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent
          && (notificationList.first.totalRecords ??0) > ((start == 0) ? limit : start+limit)) {
        start += limit;
        fetchNotificationHistoryList();
      }
    });
  }

  Future<void> fetchNotificationHistoryList({int? start})async{
    if(start == 0){
      notificationList = [];
      this.start = start ?? 0;
    }
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    NotificationHistoryUseCase().fetchNotificationHistoryList(
        start: start ?? this.start,
        limit: limit,
        onRequestSuccess: (result){
          if(start == 0) {
            notificationList = result;
          }
          else{
            notificationList += result;
          }
          notifyListeners();
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception){
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error,exception: exception));
        });
    notifyListeners();
  }

  updateReadStatus({
    required int notificationId,
  }){
    NotificationHistoryUseCase().updateReadStatus(
        notificationId: notificationId,
      onRequestSuccess: (result){
        print("read_status_update_success");
      },
      onRequestFailure: (exception){
        print("read_status_update_failure");
      },
    );
  }

  Future<void> refreshReadStatuses() async {
    if (notificationList.isEmpty) return; // just add this one guard
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    NotificationHistoryUseCase().fetchNotificationHistoryList(
      start: 0,
      limit: notificationList.length, // fetch all currently loaded items
      onRequestSuccess: (result) {
        // Only update readStatusYN, don't replace the list
        for (final updated in result) {
          final index = notificationList.indexWhere(
                (n) => n.notificationId == updated.notificationId,
          );
          if (index != -1) {
            final old = notificationList[index];
            notificationList[index] = NotificationList(
              routePath: old.routePath,
              notificationId: old.notificationId,
              clientId: old.clientId,
              viewOptionCode: old.viewOptionCode,
              viewOptionName: old.viewOptionName,
              title: old.title,
              message: old.message,
              optionId: old.optionId,
              transId: old.transId,
              transTableId: old.transTableId,
              lastModDate: old.lastModDate,
              notificationBatchId: old.notificationBatchId,
              projectId: old.projectId,
              readstatusupdatereqyn: old.readstatusupdatereqyn,
              createdDate: old.createdDate,
              readStatusYN: updated.readStatusYN, // <-- only this from DB
              totalRecords: old.totalRecords,
            );
          }
        }
        changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
        notifyListeners(); // rebuild tiles, scroll untouched
      },
      onRequestFailure: (exception) {
        changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error,exception: exception));
        print("refresh_read_status_failure");
      },
    );
  }

}