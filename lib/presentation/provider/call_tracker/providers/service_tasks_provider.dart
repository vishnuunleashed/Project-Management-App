

import 'dart:io';

import 'package:base/core/loader_value.dart';
import 'package:base/data/models/response/image_upload_response.dart';
import 'package:flutter/cupertino.dart';
import 'package:interior_design/data/model/response/call_tracker/call_tracker_model.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';
import 'package:interior_design/domain/usecase/call_tracker/add_task_usecase.dart';
import 'package:interior_design/domain/usecase/call_tracker/call_tracker_usercase.dart';
import 'package:interior_design/presentation/view/call_tracker/detail_view/_partials/_partials/task_filter_tab.dart';
import 'package:intl/intl.dart';


import 'base_service_ticket_provider.dart';

class ServiceTasksProvider extends BaseServiceTicketProvider {

  List<ServiceTaskModel> tasks = [];
  List<CommonMasterModel> workStatusOptionList = [];
  CommonMasterModel? selectedWorkStatusOption;
  final TextEditingController taskNameCtrl = TextEditingController();
  final TextEditingController remarkCtrl = TextEditingController();
  final TextEditingController workOptionController = TextEditingController();
  final TextEditingController sendBackRemarkCtrl = TextEditingController();

  int? taskOwnerId;
  String? taskOwnerName;
  String? taskTargetClosureDate;
  bool isClientDependency = false;

  int? docAttachId;
  int? createdUserId;
  String attachmentSeriesNo = "";

  List<TaskAttachmentModel> newTaskAttachments = [];
  List<TaskAttachmentModel> submittedTaskAttachments = [];


  String taskStatusCode = 'PENDING';

  int serviceReportUserId = 0;
  String taskStatusLabel = '';
  bool isUploadingNew = false;
  bool isUploadingSubmitted = false;


  void clearTaskBottomSheet() {
    taskNameCtrl.clear();
    remarkCtrl.clear();
    workOptionController.clear();
    sendBackRemarkCtrl.clear();
    newTaskAttachments.clear();
    submittedTaskAttachments.clear();
    currentEditIndex = null;
    selectedTask = null;
    selectedWorkStatusOption = null;
    taskOwnerId = null;
    taskOwnerName = null;
    taskTargetClosureDate = null;
    isClientDependency = false;

    notifyListeners();
  }

  void setTaskOwner(int id, String name) {
    taskOwnerId = id;
    taskOwnerName = name;
    notifyListeners();
  }


  Future<void> uploadFilesForTask({
    required List<File> files,
    required void Function(List<UploadResponse> uploaded) onSuccess,
    required void Function(dynamic error) onFailure,
  }) async {
    await CallTrackerUseCase().uploadImageFile(
      file: files,
      uploadProgress: (_) {},
      attachmentSerialNo: attachmentSeriesNo,
      onRequestSuccess: (response) {
        if (response.isNotEmpty) {
          if(newTaskAttachments.isEmpty) {
            attachmentSeriesNo = response.last.serialno ?? "";
            print("Attachment seriel no -- $attachmentSeriesNo");
          }
        }
        onSuccess(response);
      },
      onRequestFailure: (exception) {
        onFailure(exception);
      },
    );
  }

// ─────────────────────────────────────────────
// Attachment Type from filename
// ─────────────────────────────────────────────
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

  Future<void> uploadNewTaskFiles(List<File> files) async {
    isUploadingNew = true;
    notifyListeners();

    await uploadFilesForTask(
      files: files,
      onSuccess: (uploaded) {
        final newDetails = uploaded.map((r) {
          return TaskAttachmentModel(
            fileName: r.filename ?? r.physicalfilename ?? '',
            url: r.url ?? '',
            filePhysicalName: r.physicalfilename,
          );
        }).toList();

        newTaskAttachments.addAll(newDetails);

        isUploadingNew = false;
        notifyListeners();
      },
      onFailure: (_) {
        isUploadingNew = false;
        notifyListeners();
      },
    );
  }
  // antigravity check --?
  Future<void> uploadSubmittedTaskFiles(List<File> files) async {
    print("SUBmitted task lenght 1--- ${submittedTaskAttachments.length}");
    isUploadingSubmitted = true;
    notifyListeners();

    await uploadFilesForTask(
      files: files,
      onSuccess: (uploaded) {
        final newDetails = uploaded.map((r) {
          return TaskAttachmentModel(
            fileName: r.filename ?? r.physicalfilename ?? '',
            url: r.url ?? '',
            filePhysicalName: r.physicalfilename,
          );
        }).toList();

        submittedTaskAttachments.addAll(newDetails);
        print("SUBmitted task lenght 2--- ${submittedTaskAttachments.length}");

        isUploadingSubmitted = false;
        notifyListeners();
      },
      onFailure: (_) {
        isUploadingSubmitted = false;
        notifyListeners();
      },
    );
  }

  // Future<void> uploadTaskFiles(List<File> files, String statusCode) async {
  //
  //   if (statusCode == "PENDING") {
  //     isUploadingSubmitted = true;
  //   } else {
  //     isUploadingNew = true;
  //   }
  //
  //   notifyListeners();
  //
  //   await uploadFilesForTask(
  //     files: files,
  //     onSuccess: (uploaded) {
  //
  //       final newDetails = uploaded.map((r) {
  //         return TaskAttachmentModel(
  //           fileName: r.filename ?? r.physicalfilename ?? '',
  //           url: r.url ?? '',
  //           filePhysicalName: r.physicalfilename,
  //         );
  //       }).toList();
  //
  //       if (statusCode == "PENDING" || statusCode == "SEND_BACK") {
  //         submittedTaskAttachments.addAll(newDetails);
  //         isUploadingSubmitted = false;
  //       } else {
  //         newTaskAttachments.addAll(newDetails);
  //         isUploadingNew = false;
  //       }
  //
  //       notifyListeners();
  //     },
  //     onFailure: (_) {
  //       if (statusCode == "PENDING") {
  //         isUploadingSubmitted = false;
  //       } else {
  //         isUploadingNew = false;
  //       }
  //
  //       notifyListeners();
  //     },
  //   );
  // }



// ─────────────────────────────────────────────
// Remove attachment
// ─────────────────────────────────────────────
  void removeAttachment(int index) {
    newTaskAttachments.removeAt(index);
    notifyListeners();
  }

  void removeSubmittedAttachment(int index) {
    submittedTaskAttachments.removeAt(index);
    notifyListeners();
  }

// ─────────────────────────────────────────────
// Change status
// ─────────────────────────────────────────────
  void changeStatus(String code, String label) {
    taskStatusCode = code;
    taskStatusLabel = label;
    notifyListeners();
  }

// ─────────────────────────────────────────────
// Submit task
// ─────────────────────────────────────────────
  // check antigravity ----???
  void submitNewTask({required int taskId, required bool isEditMode, int? editIndex}) {
    print("task id == $taskId");
    print("task id == $isEditMode");
    print("task id == $editIndex");
    print("task id == $currentEditIndex");
    final task = ServiceTaskModel(
      id: taskId,
      attachments: List<TaskAttachmentModel>.from(newTaskAttachments),
      docAttachDetails: [
        DocAttachDetailModel(
          docAttachId: docAttachId ?? 0,
          serialNo: attachmentSeriesNo,
          createdUserId: createdUserId,
        )
      ],
    );

    task.taskName = taskNameCtrl.text.trim();
    task.description = taskNameCtrl.text.trim();
    task.statusCode = taskStatusCode;
    task.status = taskStatusLabel;
    task.assignedUserId = taskOwnerId;
    task.assignedUser = taskOwnerName;
    task.targetclosuredate = taskTargetClosureDate;
    task.clientdependancyyn = isClientDependency ? "Y" : "N";
    task.submittedAttachments = List<TaskAttachmentModel>.from(submittedTaskAttachments);

    // 🔥 CHECK EDIT OR ADD
    final resolvedIndex = editIndex ?? currentEditIndex;

    if (isEditMode && resolvedIndex != null && resolvedIndex >= 0 && resolvedIndex < tasks.length) {
      tasks[resolvedIndex] = task;
    }
    else {
      //  ADD MODE
      tasks.add(task);
      print("New Task Added at index ${tasks.length - 1}");
    }

    clearTaskBottomSheet();
    notifyListeners();
  }
  List<UploadResponse> images = [];
  List<AttachmentModel> attachmentUrl = [];

  void addImage(List<UploadResponse> file) {
    images.addAll(file);
    attachmentUrl
        .addAll(file.map((e) => AttachmentModel(url: e.url ?? "")).toList());
    notifyListeners();
  }

  ServiceTaskModel? selectedTask;
  int? currentEditIndex; //  add this field

  void fillTaskDetails(ServiceTaskModel task, int index) {
    selectedTask = task;
    currentEditIndex = index;
    print("selected task -- $selectedTask");
    print("current index -- $currentEditIndex");

    taskNameCtrl.text = task.description ?? '';
    taskStatusCode = task.statusCode ?? '';
    taskStatusLabel = task.status ?? '';
    taskOwnerId = task.assignedUserId;
    taskOwnerName = task.assignedUser;
    taskTargetClosureDate = task.targetclosuredate;
    isClientDependency = task.clientdependancyyn == "Y";

    if (task.docAttachDetails.isNotEmpty) {
      final doc = task.docAttachDetails.first;
      docAttachId = doc.docAttachId;
      attachmentSeriesNo = doc.serialNo ?? "";
      createdUserId = doc.createdUserId;
    }
    remarkCtrl.clear();
    sendBackRemarkCtrl.clear();
    workOptionController.clear();

    newTaskAttachments = List<TaskAttachmentModel>.from(task.attachments);

    notifyListeners();
  }

  ServiceTasksProvider() {
    initBaseValues();
  }

  void fetchTaskDetails({required int ticketId}){
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    CallTrackerUseCase().fetchCallTrackerInfo(
        taskId: 0,
        start: 0,
        limit: 10,
        ticketNo: "",
        refTableDataId: ticketId,
        engineers:[],
        statuses: [],
        clientList: [],
        cities: [],
        priorityList: [],
        sitesList: [],
        dateFrom: "",
        dateTo: "",
        type: "",
        sitenames: "",
        onRequestSuccess: (result){
          currentTicket = result.first;
          tasks = result.first.newTaskLists ?? [];
          displayedTasks;
          docAttachId =  (tasks.first.docAttachDetails.isNotEmpty) ? tasks.first.docAttachDetails.first.docAttachId : null;
          createdUserId = (tasks.first.docAttachDetails.isNotEmpty) ? tasks.first.docAttachDetails.first.createdUserId : null;
          attachmentSeriesNo = (tasks.first.docAttachDetails.isNotEmpty) ? tasks.first.docAttachDetails.first.serialNo ?? "" : "";
          notifyListeners();
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception){
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error));
        });

  }

  void fetchWorkStatusOptions(){
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    AddTaskUseCase().fetchWorkStatusOptions(
        onRequestSuccess: (result){
          workStatusOptionList = result;
          print("workStatusOptionList___ "+workStatusOptionList.length.toString());
          notifyListeners();
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception){
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error));
        });

  }

  void changedWorkStatusOption(CommonMasterModel? value){
    selectedWorkStatusOption = value;
    workOptionController.text = selectedWorkStatusOption?.description ?? "";
    notifyListeners();
  }


  TaskFilter selectedTaskFilter = TaskFilter.all;



  List<ServiceTaskModel> get displayedTasks {
    switch (selectedTaskFilter) {
      case TaskFilter.task_notification:
        return tasks.where((e) => e.id == currentTaskId).toList();
      case TaskFilter.assignment_pending:
        return tasks.where((e) => e.statusCode == "ASSIGNMENT_PENDING" || e.statusCode == "PENDING").toList();
      case TaskFilter.assigned:
        return tasks.where((e) => e.statusCode == "ASSIGNED").toList();
      case TaskFilter.accepted:
        return tasks.where((e) => e.statusCode == "ACCEPTED" || e.statusCode == "IN_PROGRESS").toList();
      case TaskFilter.submitted:
        return tasks.where((e) => e.statusCode == "SUBMITTED").toList();
      case TaskFilter.send_back:
        return tasks.where((e) => e.statusCode == "SEND_BACK").toList();
      case TaskFilter.reviewed:
        return tasks.where((e) => e.statusCode == "REVIEWD" || e.statusCode == "REVIEWED").toList();
      case TaskFilter.closed:
        return tasks.where((e) => e.statusCode == "CLOSED").toList();
      case TaskFilter.rejected:
        return tasks.where((e) => e.statusCode == "REJECTED").toList();
      case TaskFilter.reopened:
        return tasks.where((e) => e.statusCode == "REOPENED").toList();
      case TaskFilter.cancelled:
        return tasks.where((e) => e.statusCode == "CANCELLED").toList();
      case TaskFilter.all:
      default:
        return tasks;
    }
  }

  void changeFilter(TaskFilter filter) {
    selectedTaskFilter = filter;
    notifyListeners();
  }

// Remove task
  void removeTask(int index) {
    if (index < 0 || index >= tasks.length) return;

    final task = tasks[index];

    if (task.id == 0) {
      tasks.removeAt(index);
      notifyListeners();
      return;
    }

    // If currently editing this task, clear the bottom sheet state too
    if (currentEditIndex == index) {
      clearTaskBottomSheet();
    }

    tasks.removeAt(index);
    notifyListeners();
  }

  int getCountForFilter(TaskFilter filter) {
    if (filter == TaskFilter.all) return tasks.length;

    return tasks.where((t) {
      final String status = (t.statusCode ?? '').toUpperCase();

      switch (filter) {
        case TaskFilter.assignment_pending:
          return status == "ASSIGNMENT_PENDING" || status == "PENDING";
        case TaskFilter.assigned:
          return status == "ASSIGNED";
        case TaskFilter.accepted:
          return status == "ACCEPTED" || status == "IN_PROGRESS";
        case TaskFilter.submitted:
          return status == "SUBMITTED";
        case TaskFilter.send_back:
          return status == "SEND_BACK";
        case TaskFilter.reviewed:
          return status == "REVIEWD" || status == "REVIEWED";
        case TaskFilter.closed:
          return status == "CLOSED";
        case TaskFilter.rejected:
          return status == "REJECTED";
        case TaskFilter.reopened:
          return status == "REOPENED";
        case TaskFilter.cancelled:
          return status == "CANCELLED";
        case TaskFilter.task_notification:
          return t.id == currentTaskId;
        default:
          return false;
      }
    }).length;
  }

  void setTargetClosureDate(DateTime date) {
    taskTargetClosureDate = DateFormat('yyyy-MM-dd').format(date);
    notifyListeners();
  }

}
