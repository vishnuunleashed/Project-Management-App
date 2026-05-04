// /*------------------------------------------------------------------------------
// AUTHOR          : Auto-generated
// CREATED DATE    : 27/02/2026
// PURPOSE         : Dedicated provider for ServiceTasksScreen
// MODULE/TOPIC    : Service Tasks
// REMARKS         : Extracted from ServiceRequestDashboardProvider
// ------------------------------------------------------------------------------*/
//
// import 'dart:io';
//
// import 'package:base/data/models/response/image_upload_response.dart';
// import 'package:base/presentation/provider/base_provider.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:interior_design/data/model/response/call_tracker/call_tracker_model.dart';
// import 'package:interior_design/data/model/response/project_details/attachment_model.dart';
// import 'package:interior_design/domain/usecase/call_tracker/call_tracker_usercase.dart';
//
// class ServiceTasksProvider extends BaseProvider {
//   List<ServiceTaskModel> tasks = [];
//   final TextEditingController taskNameCtrl = TextEditingController();
//
//   String statusCode = 'PENDING';
//   String statusLabel = 'Pending';
//   bool isUploading = false;
//   List<TaskAttachmentHdrModel> newTaskAttachments = [];
//   String attachmentSeriesNo = "";
//
//   void clearTaskBottomSheet() {
//     taskNameCtrl.clear();
//     newTaskAttachments.clear();
//     newTaskAttachments = [];
//     notifyListeners();
//   }
//
//   Future<void> uploadFilesForTask({
//     required List<File> files,
//     required void Function(List<UploadResponse> uploaded) onSuccess,
//     required void Function(dynamic error) onFailure,
//   }) async {
//     await CallTrackerUseCase().uploadImageFile(
//       file: files,
//       uploadProgress: (_) {},
//       attachmentSerialNo: attachmentSeriesNo,
//       onRequestSuccess: (response) {
//         if (response.isNotEmpty) {
//           if(newTaskAttachments.isEmpty) {
//             attachmentSeriesNo = response.last.serialno ?? attachmentSeriesNo;
//             print("Attachment seriel no -- $attachmentSeriesNo");
//           }
//         }
//         onSuccess(response);
//       },
//       onRequestFailure: (exception) {
//         onFailure(exception);
//       },
//     );
//   }
//
// // ─────────────────────────────────────────────
// // Attachment Type from filename
// // ─────────────────────────────────────────────
//   String getFileType(String? fileName) {
//     if (fileName == null) return 'other';
//
//     final lower = fileName.toLowerCase();
//
//     if (lower.contains('.jpg') ||
//         lower.contains('.jpeg') ||
//         lower.contains('.png') ||
//         lower.contains('.gif') ||
//         lower.contains('.webp')) {
//       return 'image';
//     }
//
//     if (lower.contains('.pdf')) return 'pdf';
//
//     if (lower.contains('.xls') || lower.contains('.xlsx')) return 'xls';
//
//     if (lower.contains('.doc') || lower.contains('.docx')) return 'doc';
//
//     return 'other';
//   }
//
// // Upload files
//   Future<void> uploadTaskFiles(List<File> files) async {
//     isUploading = true;
//     notifyListeners();
//
//     await uploadFilesForTask(
//       files: files,
//       onSuccess: (uploaded) {
//
//         final newDetails = uploaded.map((r) {
//           return TaskAttachmentModel(
//             fileName: r.filename ?? r.physicalfilename ?? '',
//             url: r.url ?? '',
//             filePhysicalName: r.physicalfilename,
//           );
//         }).toList();
//
//         if (newTaskAttachments.isEmpty) {
//           //  Create header only once
//           newTaskAttachments.add(
//             TaskAttachmentHdrModel(
//               id: 0,
//               createdUserId: null,
//               seriesno: attachmentSeriesNo,
//               attachmentDtl: newDetails,
//             ),
//           );
//         } else {
//           newTaskAttachments.first.attachmentDtl?.addAll(newDetails);
//         }
//
//         isUploading = false;
//         notifyListeners();
//       },
//       onFailure: (_) {
//         isUploading = false;
//         notifyListeners();
//       },
//     );
//   }
//
// // ─────────────────────────────────────────────
// // Remove attachment
// // ─────────────────────────────────────────────
//   void removeAttachment(int index) {
//     newTaskAttachments.removeAt(index);
//     notifyListeners();
//   }
//
// // ─────────────────────────────────────────────
// // Change status
// // ─────────────────────────────────────────────
//   void changeStatus(String code, String label) {
//     statusCode = code;
//     statusLabel = label;
//     notifyListeners();
//   }
//
// // ─────────────────────────────────────────────
// // Submit task
// // ─────────────────────────────────────────────
//   void submitNewTask() {
//     final task = ServiceTaskModel(
//       attachments: List<TaskAttachmentHdrModel>.from(newTaskAttachments),
//     );
//     task.taskName = taskNameCtrl.text.trim();
//     task.statusCode = statusCode;
//     task.status = statusLabel;
//     taskNameCtrl.clear();
//     newTaskAttachments.clear();
//     statusCode = 'PENDING';
//     statusLabel = 'Pending';
//     tasks.add(task);
//     print("task length -- ${tasks.length}");
//     clearTaskBottomSheet();
//     notifyListeners();
//   }
//
//   List<UploadResponse> images = [];
//   List<AttachmentModel> attachmentUrl = [];
//
//   void addImage(List<UploadResponse> file) {
//     images.addAll(file);
//     attachmentUrl
//         .addAll(file.map((e) => AttachmentModel(url: e.url ?? "")).toList());
//     notifyListeners();
//   }
//
//   // void serviceProviderInitValues(){
//   //   tasks = [];
//   //   print("called -- 00");
//   //   notifyListeners();
//   // }
//
//   // void setTasks(List<ServiceTaskModel> tasksList){
//   //   tasks = tasksList;
//   //   print("Calleddddd");
//   //   print("Calleddddd ${tasks.length}");
//   //   notifyListeners();
//   // }
// }
