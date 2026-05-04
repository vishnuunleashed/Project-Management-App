//
//
// import 'dart:io';
// import 'package:base/core/constants.dart';
// import 'package:base/core/loader_value.dart';
// import 'package:base/data/models/response/image_upload_response.dart';
// import 'package:base/data/repository/local/base_prefs.dart';
// import 'package:base/data/services/utils/app_exceptions.dart';
// import 'package:base/presentation/provider/base_provider.dart';
// import 'package:base/presentation/theme_config.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:interior_design/data/model/request/call_tracker/status_update_model.dart';
// import 'package:interior_design/data/model/response/call_tracker/call_tracker_model.dart';
// import 'package:interior_design/data/model/response/call_tracker/service_based_support_dashboard_model.dart';
// import 'package:interior_design/data/model/response/call_tracker/tracking_details_dto.dart';
// import 'package:interior_design/data/model/response/project_details/attachment_model.dart';
// import 'package:interior_design/data/model/response/project_schedule/project_schedule_dto.dart';
// import 'package:interior_design/domain/usecase/call_tracker/call_tracker_usercase.dart';
// import 'package:interior_design/presentation/provider/call_tracker/service_tasks_provider.dart';
// import 'package:interior_design/utils/firebase_tap_config.dart';
// import 'package:intl/intl.dart';
//
// class ServiceRequestDashboardProvider extends ServiceTasksProvider{
//   PageController pageController = PageController();
//   final TextEditingController remarksController = TextEditingController();
//
//   int loggedInUserID = 0;
//   bool isSuperUser = false;
//
//   // Initialize - for now just sets up hardcoded data
//   Future<void> initState({Map<String, dynamic>? extra}) async {
//     loggedInUserID = await BaseSecureStorage.getInt(BaseConstants.userID);
//     isSuperUser = await BaseSecureStorage.getBool(BaseConstants.superUserYN);
//
//     if (extra != null && extra['transid'] != null) {
//       currentTicketId = int.parse(extra['transid'].toString() ?? "0");
//       fetchCallTrackerInfo();
//       fetchServiceBasedSupportDashboardData();
//     }
//
//     notifyListeners();
//   }
//
//   List<CallTicketModel> tickets = [];
//   CallTicketModel? currentTicket;
//   int currentTicketId = 0;
//
//
//   // void uploadFiles(List<File> file) async {
//   //   changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
//   //   await CallTrackerUseCase().uploadImageFile(
//   //       file: file,
//   //       uploadProgress: (progress) {
//   //         loadingProgress = progress;
//   //         notifyListeners();
//   //       },
//   //       attachmentSerialNo: attachmentSeriesNo,
//   //       onRequestSuccess: (response) {
//   //         addImage(response);
//   //         attachmentSeriesNo = response.last.serialno ?? "";
//   //         changeLoadingStatus(
//   //             loadingStatus: LoadingStatus(loader: Loader.success));
//   //       },
//   //       onRequestFailure: (exception) {
//   //         changeLoadingStatus(
//   //             loadingStatus:
//   //                 LoadingStatus(loader: Loader.error, exception: exception));
//   //       });
//   // }
//
//
//   // List<UploadResponse> images = [];
//   // List<AttachmentModel> attachmentUrl = [];
//   //
//   // void addImage(List<UploadResponse> file) {
//   //   images.addAll(file);
//   //   attachmentUrl
//   //       .addAll(file.map((e) => AttachmentModel(url: e.url ?? "")).toList());
//   //   notifyListeners();
//   // }
//   List<ServiceTaskModel> tasks = [];
//
//   Future<void> fetchCallTrackerInfo() async {
//     changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
//     CallTrackerUseCase().fetchCallTrackerInfo(
//         start: 0,
//         limit: 10,
//         ticketNo: "",
//         refTableDataId: currentTicketId,
//         engineerId: 0,
//         statusId: 0,
//         type: "",
//         onRequestSuccess: (result) {
//           print("data called--");
//           if (result.isNotEmpty) {
//
//             tickets = result;
//             // setTasks(tickets.first.tasks ?? []);
//             tasks = tickets.first.tasks ?? [];
//
//
//             print("task lenght -- ${tasks.length}");
//             currentTicket = result.first;
//             updateNotificationStatus(
//                 transId: result.first.id ?? 0,
//                 tableId: result.first.tableId ?? 0,
//                 optionId: result.first.optionId ?? 0);
//           }
//           changeLoadingStatus(
//               loadingStatus: LoadingStatus(loader: Loader.success));
//         },
//         onRequestFailure: (exception) {
//           changeLoadingStatus(
//               loadingStatus:
//               LoadingStatus(loader: Loader.error, exception: exception));
//         });
//     notifyListeners();
//   }
//
//   void updateNotificationStatus(
//       {required int transId, required int tableId, required int optionId}) {
//     changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
//
//     CallTrackerUseCase().updateNotificationStatus(
//         transId: transId,
//         tableId: tableId,
//         optionId: optionId,
//         onRequestSuccess: (notificationIdlList) {
//           if (notificationIdlList.isNotEmpty) {
//             removeNotificationUsingIdList(notificationIdlList);
//           }
//           changeLoadingStatus(
//               loadingStatus: LoadingStatus(loader: Loader.success));
//         },
//         onRequestFailure: (exception) {
//           changeLoadingStatus(
//               loadingStatus:
//               LoadingStatus(loader: Loader.error, exception: exception));
//         });
//   }
//
//   List<TicketSummaryModel> dashboardSupport = [];
//
//   // Fetch service request details by ID (to be implemented when serviceRequestId is passed)
//   Future<void> fetchServiceBasedSupportDashboardData() async {
//     changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
//     CallTrackerUseCase().fetchServiceBasedSupportDashboardData(
//         dataId: currentTicketId,
//         onRequestSuccess: (result) {
//           dashboardSupport = result;
//           notifyListeners();
//           changeLoadingStatus(
//               loadingStatus: LoadingStatus(loader: Loader.success));
//         },
//         onRequestFailure: (exception) {
//           changeLoadingStatus(
//               loadingStatus:
//               LoadingStatus(loader: Loader.error, exception: exception));
//         });
//   }
//
//   // Start task action
//   Future<void> updateStatus({required String statusCode,
//     required Function(String) onSuccess,
//     required Function(AppException? exception) onFailure}) async {
//     changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
//     TicketStatusModel taskModel = TicketStatusModel(
//         id: currentTicket?.id ?? 0,
//         lastmoddate: currentTicket?.lastModDate,
//         remarks: remarksController.text,
//         statuscode: statusCode);
//     CallTrackerUseCase().updateStatus(
//         taskModel: taskModel,
//         onRequestSuccess: (message) {
//           changeLoadingStatus(
//               loadingStatus: LoadingStatus(loader: Loader.success));
//           onSuccess(message);
//         },
//         onRequestFailure: (exception) {
//           changeLoadingStatus(
//               loadingStatus:
//               LoadingStatus(loader: Loader.error, exception: exception));
//         });
//   }
//
//   // Dispose
//   void disposeVariables() {
//     dashboardSupport = [];
//     tickets = [];
//     notifyListeners();
//   }
//
//   int selectedOptionIndex = 0;
//
//   void onPageChanged(int index) {
//     selectedOptionIndex = index;
//     notifyListeners();
//   }
//
//   // New expansion state variables
//   bool _isExpandedDescription = true;
//   bool _isExpandedLocation = true;
//   bool _isExpandedServiceInfo = true;
//   bool _isExpandedTimeline = true;
//   bool _isExpandedAssignment = true;
//
//   // Getters for expansion states
//   bool get isExpandedDescription => _isExpandedDescription;
//
//   bool get isExpandedLocation => _isExpandedLocation;
//
//   bool get isExpandedServiceInfo => _isExpandedServiceInfo;
//
//   bool get isExpandedTimeline => _isExpandedTimeline;
//
//   bool get isExpandedAssignment => _isExpandedAssignment;
//
//   // Methods to toggle expansion states
//   void toggleDescriptionExpansion(bool value) {
//     _isExpandedDescription = value;
//     notifyListeners();
//   }
//
//   void toggleLocationExpansion(bool value) {
//     _isExpandedLocation = value;
//     notifyListeners();
//   }
//
//   void toggleServiceInfoExpansion(bool value) {
//     _isExpandedServiceInfo = value;
//     notifyListeners();
//   }
//
//   void toggleTimelineExpansion(bool value) {
//     _isExpandedTimeline = value;
//     notifyListeners();
//   }
//
//   void toggleAssignmentExpansion(bool value) {
//     _isExpandedAssignment = value;
//     notifyListeners();
//   }
//
//   // Optional: Method to collapse all sections
//   void collapseAllSections() {
//     _isExpandedDescription = false;
//     _isExpandedLocation = false;
//     _isExpandedServiceInfo = false;
//     _isExpandedTimeline = false;
//     _isExpandedAssignment = false;
//     notifyListeners();
//   }
//
//   // Optional: Method to expand all sections
//   void expandAllSections() {
//     _isExpandedDescription = true;
//     _isExpandedLocation = true;
//     _isExpandedServiceInfo = true;
//     _isExpandedTimeline = true;
//     _isExpandedAssignment = true;
//     notifyListeners();
//   }
//
//   Color getPriorityColor(String? priority) {
//     if (priority == null) return Colors.grey;
//
//     if (priority.contains('1')) {
//       return Colors.red;
//     } else if (priority.contains('2')) {
//       return Colors.orange;
//     } else if (priority.contains('3')) {
//       return bayaInfraPaleGreen;
//     } else {
//       return Colors.green;
//     }
//   }
//
//
//
//
//   /// Refresh tracking data
//   Future<void> refreshTrackingData() async {
//     await fetchGetTicketTracking();
//
//   }
//
//   // Tracking controllers and scrolling
//   final TextEditingController commentController = TextEditingController();
//   final ScrollController scrollController = ScrollController();
//
//   // Tracking data
//   TicketDetailSummaryModel? trackingSummary;
//   List<TicketLogModel> trackingLogs = [];
//   List<TicketTaskModel> trackingTasks = [];
//   List<TicketCommentModel> trackingComments = [];
//
//   Future<void> fetchGetTicketTracking() async {
//     changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
//     try {
//        CallTrackerUseCase().fetchGetTicketTracking(
//         ticketId: currentTicketId,
//         onRequestSuccess: (result) {
//           if(result.isNotEmpty){
//             final data = result.first;
//             trackingSummary = data.summary;
//             trackingLogs = data.ticketLogs;
//             trackingTasks = data.tasks;
//             trackingComments = data.comments;
//           }
//           changeLoadingStatus(
//               loadingStatus: LoadingStatus(loader: Loader.success));
//         },
//         onRequestFailure: (error) {
//           changeLoadingStatus(
//               loadingStatus: LoadingStatus(
//                 loader: Loader.error,
//                 exception: error,
//               ));
//         },
//       );
//     } catch (error) {
//       changeLoadingStatus(
//           loadingStatus: LoadingStatus(
//             loader: Loader.error,
//             exception: AppException('Failed to fetch tracking: $error'),
//           ));
//     }
//     notifyListeners();
//   }
//
//
//   /// Send comment on ticket
//   Future<void> sendCommentServiceTicket() async {
//     final comment = commentController.text.trim();
//     if (comment.isEmpty) return;
//
//     changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
//     try {
//       CallTrackerUseCase().addCommentServiceTask(
//        ticketId:  currentTicketId,
//         comment: comment,
//         onRequestSuccess: () {
//           commentController.clear();
//           fetchGetTicketTracking(); // Refresh to show new comment
//           changeLoadingStatus(
//               loadingStatus: LoadingStatus(loader: Loader.success));
//         },
//         onRequestFailure: (error) {
//           changeLoadingStatus(
//               loadingStatus: LoadingStatus(
//                 loader: Loader.error,
//                 exception: error,
//               ));
//         },
//       );
//     } catch (error) {
//       changeLoadingStatus(
//           loadingStatus: LoadingStatus(
//             loader: Loader.error,
//             exception: AppException('Failed to add comment: $error'),
//           ));
//     }
//   }
//
//
//
//
// }
