/*------------------------------------------------------------------------------
AUTHOR          :
CREATED DATE    : 03/03/2026
PURPOSE         : Provider for Service Details Landing Page (Grid Menu)
MODULE/TOPIC    : Call Tracker / Service Details Landing
REMARKS         : Extends BaseProvider. Manages ticket data and user
                  permissions for the grid menu tiles.
------------------------------------------------------------------------------*/

import 'dart:ui';

import 'package:base/core/constants.dart';
import 'package:base/core/loader_value.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:base/presentation/utility/base_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/data/model/response/call_tracker/call_tracker_model.dart';
import 'package:interior_design/domain/usecase/call_tracker/add_service_request_usecase.dart';
import 'package:interior_design/domain/usecase/call_tracker/call_tracker_usercase.dart';
import 'package:intl/intl.dart';

class ServiceDetailsLandingProvider extends BaseProvider {

  int loggedInUserID = 0;
  bool isSuperUser = false;
  DateTime? changedTgtClosureDate;

  void setSelectedClosureDate(DateTime date) {
    changedTgtClosureDate = date;
    notifyListeners();
  }

  void clearSelectedClosureDate() {
    changedTgtClosureDate = null;
    notifyListeners();
  }

  void updateClosureDate({required int ticketId, required lastModDate, required Function() onSuccess, required Function(AppException e) onFailure  }) {
    String? formattedDate;

    if (changedTgtClosureDate != null) {
      formattedDate = DateFormat('yyyy-MM-dd').format(changedTgtClosureDate!);
    }
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    AddServiceRequestUsecase().updateClosureDate(
        ticketId: ticketId,
        targetClosureDate: formattedDate ?? "",
        lastModDate: lastModDate,
        onRequestSuccess: (){
          onSuccess();
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));

        },
        onRequestFailure: (e){
          onFailure(e);
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error,exception: e));
        } );
    // your API call here using selectedClosureDate
    changedTgtClosureDate = null;
    notifyListeners();
  }

  bool isCancelServiceTicketLoading = false;
  Future<void> cancelServiceTicket({
    required int ticketId,
    required String lastModDate,
    required String notifyClientYN,
    required VoidCallback onSuccess,
  }) async {
    isCancelServiceTicketLoading = true;
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    await CallTrackerUseCase().cancelServiceTicket(
      ticketId: ticketId,
      lastModDate: lastModDate,
      notifyClientYN: notifyClientYN,
      onRequestSuccess: () {
        onSuccess();
        changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
        isCancelServiceTicketLoading = false;
        notifyListeners();
      },
      onRequestFailure: (e) {
        isCancelServiceTicketLoading = false;
        changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error, exception: e));
        notifyListeners();
      },
    );
    notifyListeners();
  }

  void changeShouldRefreshAfterPop(bool value){
    notifyListeners();
  }

  CallTicketModel? currentTicket;
  int currentTicketId = 0;
  int currentStatusId = 0;

  // ── Computed visibility flags ──────────────────────────────────────────

  bool get canEditTicket =>
      currentTicket != null &&
      (currentTicket!.coordinateuserid == loggedInUserID || isSuperUser) && (currentTicket?.statusCode == "PENDING" /*||currentTicket?.statusCode == "ASGN_PENDING" || currentTicket?.statusCode == "ASSIGNED"*/) ;

  bool get canAddSupport {
    if (currentTicket == null) return false;

    final hasNonReviewedTask = currentTicket!.tasks
        ?.any((task) => task.statusCode == "PENDING"
        || task.statusCode == "SEND_BACK" || task.statusCode != "CLOSED"
        || task.statusCode != "REVIEWD"|| task.statusCode != "SUBMITTED") ?? false;

    return currentTicket!.statusCode != "CLOSED" && currentTicket!.statusCode != "CANCELLED" &&
        hasNonReviewedTask;
  }

  bool get canReassignEng {
    if (currentTicket == null) return false;
    final hasNotReviewedTask = currentTicket!.tasks?.any((task) => task.statusCode != "REVIEWD") ?? false;
    return currentTicket!.statusCode == "IN_PROGRESS" && hasNotReviewedTask && (currentTicket!.coordinateuserid == loggedInUserID || isSuperUser);
  }

  bool get canUpdateClosure {
    if (currentTicket == null) return false;
    return currentTicket!.statusCode == "IN_PROGRESS" && (currentTicket!.coordinateuserid == loggedInUserID || isSuperUser);
  }

  bool get canCancelTicket {
    if (currentTicket == null) return false;
    return (currentTicket!.coordinateuserid == loggedInUserID || isSuperUser) && currentTicket!.statusCode != "CLOSED" && currentTicket!.statusCode != "CANCELLED";
  }

  bool get isTicketStarted {
    if (currentTicket == null) return false;

    final hasAnyStartedTask = currentTicket!.tasks
        ?.any((task) => task.statusCode == "SUBMITTED" || task.statusCode == "SEND_BACK" || task.statusCode == "REVIEWD" || task.statusCode == "REVIEWED" || task.statusCode == "REJECTED" || task.statusCode == "REOPENED" || task.statusCode == "ACCEPTED") ?? false;
    return currentTicket!.statusCode == "IN_PROGRESS" && hasAnyStartedTask;
  }

  // ── Initialisation ─────────────────────────────────────────────────────

  bool isFromCallTracker = false;

  Future<void> initState({Map<String, dynamic>? extra}) async {
    loggedInUserID = await BaseSecureStorage.getInt(BaseConstants.userID);
    isSuperUser = await BaseSecureStorage.getBool(BaseConstants.superUserYN);
    isCancelServiceTicketLoading = false;

    if (extra != null && extra['transid'] != null) {
      currentTicketId = int.parse(extra['transid'].toString());
      print("currentTicketId  == $currentTicketId");
      
      if (extra['isFromCallTracker'] != null) {
        isFromCallTracker = extra['isFromCallTracker'] as bool;
      }
      
      fetchTicketInfo();
    }

  }

  // ── Fetch ticket info ──────────────────────────────────────────────────

  Future<void> fetchTicketInfo() async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    CallTrackerUseCase().fetchCallTrackerInfo(
        start: 0,
        limit: 10,
        ticketNo: "",
        refTableDataId: currentTicketId,
        engineers: [],
        statuses: [],
        clientList: [],
        cities:[],
        priorityList: [],
        sitesList: [],
        type: "",
        sitenames: "",
        taskId: currentStatusId,
        dateFrom: "",
        dateTo: "",
        onRequestSuccess: (result) {
          if (result.isNotEmpty) {
            currentTicket = result.first;

          }
          notifyListeners();

          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus:
                  LoadingStatus(loader: Loader.error, exception: exception));
        });
  }

  // ── Refresh after pop ──────────────────────────────────────────────────

  void refreshIfNeeded() {
      fetchTicketInfo();

  }

  // ── Dispose ────────────────────────────────────────────────────────────

  void disposeVariables() {
    currentTicket = null;
  }
}
