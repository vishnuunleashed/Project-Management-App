import 'package:interior_design/data/model/response/call_tracker/call_tracker_model.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';

class TicketStatusModel {
  final int id;
  final String statuscode;
  final String? lastmoddate;
  final String? remarks;
  final String? statusType;
  final int? docAttachID;
  final String? seriesNo;
  List<TaskAttachmentModel> attachmentList;
  final int? createdUserID;
  final int? workStatusOptionId;
  final String? notifyClientYN;
  final List<TaskStatusUpdate>? taskliststatusupdation;

  TicketStatusModel({
    required this.id,
    required this.statuscode,
    this.lastmoddate,
    this.remarks,
    required this.statusType,
    required this.seriesNo,
    required this.attachmentList,
    required this.docAttachID,
    required this.createdUserID,
    required this.workStatusOptionId,
    this.notifyClientYN,
    this.taskliststatusupdation,
  });

}

class TaskStatusUpdate {
  final int id;
  final String statusType;
  final String statuscode;
  final String? lastmoddate;

  TaskStatusUpdate({
    required this.id,
    required this.statusType,
    required this.statuscode,
    this.lastmoddate,
  });
}

