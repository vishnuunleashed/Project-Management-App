/*------------------------------------------------------------------------------
AUTHOR          :
CREATED DATE    : 27/02/2026
PURPOSE         : Base provider for all Service Ticket related providers
MODULE/TOPIC    : Service Ticket
REMARKS         : Shared identity, helpers, and ticket state
------------------------------------------------------------------------------*/

import 'package:base/core/constants.dart';
import 'package:base/core/loader_value.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/data/model/response/call_tracker/call_tracker_model.dart';
import 'package:interior_design/data/model/response/call_tracker/tracking_details_dto.dart';
import 'package:interior_design/domain/usecase/call_tracker/add_task_usecase.dart';
import 'package:interior_design/domain/usecase/call_tracker/call_tracker_usercase.dart';
import 'package:intl/intl.dart';

abstract class BaseServiceTicketProvider extends BaseProvider {

  // ── Shared ticket identity ──────────────────────────────────────────────────
  int currentTicketId = 0;
  int currentTaskId = 0;
  int loggedInUserID = 0;
  bool isSuperUser = false;
  bool isEditMode = false;

  // ── Shared current ticket ───────────────────────────────────────────────────
  CallTicketModel? currentTicket;

  // ── Init shared user session values ────────────────────────────────────────
  Future<void> initBaseValues() async {
    loggedInUserID = await BaseSecureStorage.getInt(BaseConstants.userID);
    isSuperUser = await BaseSecureStorage.getBool(BaseConstants.superUserYN);
  }

  // ── Priority color helper (shared across dashboard & tasks) ────────────────
  Color getPriorityColor(String? priority) {
    if (priority == null) return Colors.grey;
    if (priority.contains('1')) return Colors.red;
    if (priority.contains('2')) return Colors.orange;
    if (priority.contains('3')) return bayaInfraPaleGreen;
    return Colors.green;
  }

  // ── File type helper (shared across dashboard & tasks) ─────────────────────
  String getFileType(String? fileName) {
    if (fileName == null) return 'other';
    final lower = fileName.toLowerCase();
    if (lower.contains('.jpg') ||
        lower.contains('.jpeg') ||
        lower.contains('.png') ||
        lower.contains('.gif') ||
        lower.contains('.webp')) {
      return 'image';
    }
    if (lower.contains('.pdf')) return 'pdf';
    if (lower.contains('.xls') || lower.contains('.xlsx')) return 'xls';
    if (lower.contains('.doc') || lower.contains('.docx')) return 'doc';
    return 'other';
  }

  final TextEditingController commentController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  TicketDetailSummaryModel? trackingSummary;
  List<TicketLogModel> trackingLogs = [];
  List<TicketTaskModel> trackingTasks = [];
  List<TicketCommentModel> trackingComments = [];
  List<MembersListModel> membersList = [];

  Future<void> refreshTrackingData({Map<String, dynamic>? extra}) async {
    currentTicketId = extra?['ticketId'] ?? currentTicketId;
    await fetchGetTicketTracking();
  }

  Future<void> fetchGetTicketTracking() async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    try {
      CallTrackerUseCase().fetchGetTicketTracking(
        ticketId: currentTicketId,
        onRequestSuccess: (result) {
          if (result.isNotEmpty) {
            final data = result.first;
            trackingSummary = data.summary;
            print("tracking summary - - ${trackingSummary?.ticketdate}");
            trackingLogs = data.ticketLogs;
            trackingTasks = data.tasks;
            trackingComments = data.comments;
            membersList = data.membersList;
          }
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (error) {
          changeLoadingStatus(
              loadingStatus: LoadingStatus(
                loader: Loader.error,
                exception: error,
              ));
        },
      );
    } catch (error) {
      changeLoadingStatus(
          loadingStatus: LoadingStatus(
            loader: Loader.error,
            exception: AppException('Failed to fetch tracking: $error'),
          ));
    }
    notifyListeners();
  }

  Future<void> sendCommentServiceTicket() async {
    final comment = commentController.text.trim();
    if (comment.isEmpty) return;

    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    try {
      CallTrackerUseCase().addCommentServiceTask(
        ticketId: currentTicketId,
        comment: comment,
        onRequestSuccess: () {
          commentController.clear();
          fetchGetTicketTracking();
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (error) {
          changeLoadingStatus(
              loadingStatus: LoadingStatus(
                loader: Loader.error,
                exception: error,
              ));
        },
      );
    } catch (error) {
      changeLoadingStatus(
          loadingStatus: LoadingStatus(
            loader: Loader.error,
            exception: AppException('Failed to add comment: $error'),
          ));
    }
  }

  bool get isTrackingClosed =>
      trackingSummary?.statusCode?.toUpperCase() == 'CLOSED' ||
          trackingSummary?.statusCode?.toUpperCase() == 'CANCELLED';

  List<String> get allParticipants {
    final participants = <String>{};
    for (var log in trackingLogs) {
      participants.add(log.fromUser);
      if (log.toUser.isNotEmpty) {
        participants.add(log.toUser!);
      }
    }
    if ((currentTicket?.assignedUserForAdd ?? '').isNotEmpty) {
      participants.add(currentTicket!.assignedUserForAdd!);
    }

    if ((currentTicket?.coordinateuser ?? '').isNotEmpty) {
      participants.add(currentTicket!.coordinateuser!);
    }

    if ((currentTicket?.serviceReportUser ?? '').isNotEmpty) {
      participants.add(currentTicket!.serviceReportUser!);
    }
    return participants.toList();
  }

  String formatDate(DateTime? date) {
    final now = DateTime.now();
    final target = date ?? now;

    if (target.year == now.year &&
        target.month == now.month &&
        target.day == now.day) {
      return "Today";
    }

    return DateFormat('MMM dd, yyyy').format(target);
  }


  Color getStatusColorForUI(String statusCode) {
    switch (statusCode.toUpperCase()) {
      case 'CLOSED': return Colors.green;
      case 'IN_PROGRESS': return Colors.blue;
      case 'ASSIGNED': return Colors.indigo;
      case 'PENDING': return Colors.orange;
      case 'SUBMITTED': return Colors.teal;
      case 'REVIEWD': return Colors.cyan;
      case 'SEND_BACK': return Colors.red;
      case 'CANCELLED': return Colors.grey;
      default: return Colors.blueGrey;
    }
  }

  void clearTrackingData() {
    trackingSummary = null;
    trackingLogs = [];
    commentController.clear();
    notifyListeners();
  }



}