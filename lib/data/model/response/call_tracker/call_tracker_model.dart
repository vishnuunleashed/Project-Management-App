import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';

// Call Tracker Tickets Response Model
class CallTrackerTicketsHdrModel extends BaseResponseModel {
  List<CallTicketModel> tickets = [];

  CallTrackerTicketsHdrModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    tickets = BaseJsonParser.goodList(json, 'resultObject')
        .map((e) => CallTicketModel.fromJson(e))
        .toList();
  }
}

class CallTicketModel {
  int? id;
  String? ticketNo;
  String? ticketDate;
  bool hasSupport = false;
  String? description;
  String? client;
  String? site;
  String? building;
  String? floor;
  String? address;
  String? category;
  int? categoryId;
  String? priority;
  int? priorityId;
  String? status;
  // String? taskstatuscode;
  // String? taskstatus;
  String? statusCode;
  String? statusDate;
  String? targetClosureDateForAdd;
  // String? actualClosureDate;
  String? assignedUserForAdd;
  // int? assignedUserId;
  String? serviceReportUser;
  int? serviceReportUserId;
  int? coordinateuserid;
  String? lastModDate;
  String? coordinateuser;
  // String? assignedUserprofileurl;
  String? servicereportuserprofileurl;
  String? coordinateuserprofileurl;
  int? totalRecords;
  int? tableId;
  int? optionId;
  String? reviewremarks;
  String? cityName;
  String? taskName;
  int? sortOrder;
  List<ServiceTaskModel>? tasks;
  List<TaskDetailsDto>? taskDetailsDto;
  String? workStatusName;
  String? workStatusCode;
  String? clientdependancyyn;
  List<ServiceTaskModel>? newTaskLists;

  CallTicketModel.fromJson(Map<String, dynamic> json) {
    // ── existing mappings (unchanged) ────────────────────────
    id                          = BaseJsonParser.goodInt(json, 'Id');
    tableId                     = BaseJsonParser.goodInt(json, 'Tableid');
    optionId                    = BaseJsonParser.goodInt(json, 'Optionid');
    coordinateuserid            = BaseJsonParser.goodInt(json, 'Coordinateuserid');
    coordinateuser              = BaseJsonParser.goodString(json, 'Coordinateuser');
    // reviewremarks               = BaseJsonParser.goodString(json, 'Reviewremarks') ?? "";
    // assignedUserprofileurl      = BaseJsonParser.goodString(json, 'AssignedUserprofileurl');
    servicereportuserprofileurl = BaseJsonParser.goodString(json, 'Servicereportuserprofileurl');

    coordinateuserprofileurl    = BaseJsonParser.goodString(json, 'Coordinateuserprofileurl');
    hasSupport                  = BaseJsonParser.goodBoolean(json, 'HasSupport');
    ticketNo                    = BaseJsonParser.goodString(json, 'Ticketno');
    ticketDate                  = BaseJsonParser.goodString(json, 'Ticketdate');
    description                 = BaseJsonParser.goodString(json, 'Description');
    client                      = BaseJsonParser.goodString(json, 'Client');
    site                        = BaseJsonParser.goodString(json, 'Site');
    building                    = BaseJsonParser.goodString(json, 'Building');
    floor                       = BaseJsonParser.goodString(json, 'Floor');
    address                     = BaseJsonParser.goodString(json, 'Address');
    category                    = BaseJsonParser.goodString(json, 'Category');
    categoryId                  = BaseJsonParser.goodInt(json, 'Categoryid');
    priority                    = BaseJsonParser.goodString(json, 'Priority');
    priorityId                  = BaseJsonParser.goodInt(json, 'Priorityid');
    status                      = BaseJsonParser.goodString(json, 'Status');
    statusCode                  = BaseJsonParser.goodString(json, 'StatusCode');
    statusDate                  = BaseJsonParser.goodString(json, 'Statusdate');
    targetClosureDateForAdd           = BaseJsonParser.goodString(json, 'Targetclosuredate');
    // actualClosureDate           = BaseJsonParser.goodString(json, 'Actualclosuredate');
    assignedUserForAdd                = BaseJsonParser.goodString(json, 'AssignedUser');
    // assignedUserId              = BaseJsonParser.goodInt(json, 'Assigneduserid');
    serviceReportUser           = BaseJsonParser.goodString(json, 'Servicereportuser');
    serviceReportUserId         = BaseJsonParser.goodInt(json, 'Servicereportuserid');
    lastModDate                 = BaseJsonParser.goodString(json, 'Lastmoddate');
    totalRecords                = BaseJsonParser.goodInt(json, 'totalRecords');
    cityName                    = BaseJsonParser.goodString(json, 'cityname');
    taskName                    = BaseJsonParser.goodString(json, 'taskname');
    sortOrder                   = BaseJsonParser.goodInt(json, 'sortorder');
    clientdependancyyn          = BaseJsonParser.goodString(json, 'clientdependancyyn');
    // taskstatuscode              = BaseJsonParser.goodString(json, 'taskstatuscode');
    // taskstatus                  = BaseJsonParser.goodString(json, 'taskstatus');
    tasks = BaseJsonParser.goodList(json, 'taskDetails').map((e) => ServiceTaskModel.fromJson(e))
        .toList();

    newTaskLists = BaseJsonParser.goodList(json, 'taskDetailsForMobile').map((e) => ServiceTaskModel.fromJson(e))
        .toList();

    // workStatusName = BaseJsonParser.goodString(json, "workstatus");
    // workStatusCode = BaseJsonParser.goodString(json, "workstatuscode");

    // ── fallbacks for second JSON format (only fills if first JSON left it null/empty) ──
    // ── fallbacks for second JSON format (only fills if first JSON left it null/empty) ──
    id                ??= BaseJsonParser.goodInt(json, 'id');
    ticketNo          ??= BaseJsonParser.goodString(json, 'ticketno');
    ticketDate        ??= BaseJsonParser.goodString(json, 'ticketdate');
    description       ??= BaseJsonParser.goodString(json, 'description');
    category          ??= BaseJsonParser.goodString(json, 'category');
    categoryId        ??= BaseJsonParser.goodInt(json, 'categoryid');
    priority          ??= BaseJsonParser.goodString(json, 'priority');
    priorityId        ??= BaseJsonParser.goodInt(json, 'priorityid');
    status            ??= BaseJsonParser.goodString(json, 'ticketstatus');
    statusCode        ??= BaseJsonParser.goodString(json, 'statuscode');
    statusDate        ??= BaseJsonParser.goodString(json, 'statusdate');
    targetClosureDateForAdd ??= BaseJsonParser.goodString(json, 'targetclosuredate');
    // actualClosureDate ??= BaseJsonParser.goodString(json, 'actualclosuredate');
    client            ??= BaseJsonParser.goodString(json, 'clientname');
    site              ??= BaseJsonParser.goodString(json, 'site');
    building          ??= BaseJsonParser.goodString(json, 'building');
    floor             ??= BaseJsonParser.goodString(json, 'floor');
    address           ??= BaseJsonParser.goodString(json, 'address');
    // assignedUser      ??= BaseJsonParser.goodString(json, 'engineer');
    // assignedUserId    ??= BaseJsonParser.goodInt(json, 'assigneduserid');
    // assignedUserprofileurl      ??= BaseJsonParser.goodString(json, 'assigneduserprofileurl');
    serviceReportUser ??= BaseJsonParser.goodString(json, 'reportingmanager');
    serviceReportUserId         ??= BaseJsonParser.goodInt(json, 'servicereportuserid');
    servicereportuserprofileurl ??= BaseJsonParser.goodString(json, 'servicereportuserprofileurl');
    coordinateuserid  ??= BaseJsonParser.goodInt(json, 'coordinateuserid');
    coordinateuser    ??= BaseJsonParser.goodString(json, 'coordinator');
    coordinateuserprofileurl    ??= BaseJsonParser.goodString(json, 'coordinateuserprofileurl');
    lastModDate       ??= BaseJsonParser.goodString(json, 'lastmoddate');
    cityName          ??= BaseJsonParser.goodString(json, 'cityname');
    taskName          ??= BaseJsonParser.goodString(json, 'taskname');
    tableId           ??= BaseJsonParser.goodInt(json, 'tableid');
    optionId          ??= BaseJsonParser.goodInt(json, 'optionid');
    totalRecords      ??= BaseJsonParser.goodInt(json, 'totalrecords');
  }
}

class TaskDetailsDto {
  final int id;
  final String taskname;
  final int sortorder;
  final String statusCode;
  final List<DocAttachmentDto> docAttachments;

  TaskDetailsDto({
    required this.id,
    required this.taskname,
    required this.sortorder,
    required this.statusCode,
    required this.docAttachments,
  });

  factory TaskDetailsDto.fromJson(Map<String, dynamic> json) {
    return TaskDetailsDto(
      id: json['id'],
      taskname: json['taskname'],
      sortorder: json['sortorder'],
      statusCode: json['statusCode'],
      docAttachments: (json['docAttachments'] as List)
          .map((e) => DocAttachmentDto.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskname': taskname,
      'sortorder': sortorder,
      'statusCode': statusCode,
      'docAttachments': docAttachments.map((e) => e.toJson()).toList(),
    };
  }
}

class DocAttachmentDto {
  DocAttachmentDto();

  factory DocAttachmentDto.fromJson(Map<String, dynamic> json) {
    return DocAttachmentDto();
  }

  Map<String, dynamic> toJson() {
    return {};
  }
}

// Engineers Response Model
class EngineersHdrModel extends BaseResponseModel {
  List<EngineerModel> engineers = [];

  EngineersHdrModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    engineers = BaseJsonParser.goodList(json, 'resultObject')
        .map((e) => EngineerModel.fromJson(e))
        .toList();
  }
}

class EngineerModel {
  int? id;
  String? code;
  String? name;

  EngineerModel.fromJson(Map<String, dynamic> json) {
    id = BaseJsonParser.goodInt(json, 'id');
    code = BaseJsonParser.goodString(json, 'code');
    name = BaseJsonParser.goodString(json, 'name');
  }
}

// Status Options Response Model
class StatusOptionsHdrModel extends BaseResponseModel {
  List<StatusOptionModel> statusOptions = [];

  StatusOptionsHdrModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    statusOptions = BaseJsonParser.goodList(json, 'resultObject')
        .map((e) => StatusOptionModel.fromJson(e))
        .toList();
  }
}

class StatusOptionModel {
  int? id;
  String? description;
  String? code;
  int? sortOrder;

  StatusOptionModel.fromJson(Map<String, dynamic> json) {
    id = BaseJsonParser.goodInt(json, 'id');
    description = BaseJsonParser.goodString(json, 'description');
    code = BaseJsonParser.goodString(json, 'code');
    sortOrder = BaseJsonParser.goodInt(json, 'sortorder');
  }
}

// Type Options Model (for local use, not from API)
class TypeOptionModel {
  int? id;
  String? name;
  String? code;

  TypeOptionModel({
    required this.id,
    required this.name,
    required this.code,
  });

  TypeOptionModel.fromJson(Map<String, dynamic> json) {
    id = BaseJsonParser.goodInt(json, 'id');
    name = BaseJsonParser.goodString(json, 'name');
    code = BaseJsonParser.goodString(json, 'code');
  }
}

// ─────────────────────────────────────────────────────────────
// Task models for the Tasks section inside a service ticket
// ─────────────────────────────────────────────────────────────

/// Response wrapper for a list of tasks belonging to one ticket.
class ServiceTasksHdrModel extends BaseResponseModel {
  List<ServiceTaskModel> tasks = [];

  ServiceTasksHdrModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    tasks = BaseJsonParser.goodList(json, 'resultObject')
        .map((e) => ServiceTaskModel.fromJson(e))
        .toList();
  }
}

/// One task under a service ticket.
class ServiceTaskModel {
  int? id;
  int? slNo;
  int? callTrackerId;
  String? taskName;
  String? description;
  String? statusCode;
  String? status;
  String? assignedUser;
  int? assignedUserId;
  String? assignedUserProfileUrl;
  String? serviceReportUser;
  int? serviceReportUserId;
  String? createdDate;
  String?   lastModDate;
  String? statusRemarks;
  String? workStatusName;
  String? workStatusCode;
  String? clientdependancyyn;
  String? targetclosuredate;

  List<TaskAttachmentModel> attachments;
  List<TaskAttachmentModel> submittedAttachments;
  List<TaskAttachmentModel> prevSubmittedAttachments;
  List<DocAttachDetailModel> docAttachDetails;

  bool isEngineer = false;
  bool isReporter = false;
  bool isCoordinator = false;

  ServiceTaskModel({
    this.attachments = const [],
    this.docAttachDetails = const [],
    this.submittedAttachments = const [],
    this.prevSubmittedAttachments = const[],
    this.id
  });

  ServiceTaskModel.fromJson(Map<String, dynamic> json)
      : attachments = [],
        docAttachDetails = [],
  submittedAttachments = [],
        prevSubmittedAttachments = []{

    id                     = BaseJsonParser.goodInt(json, 'id');
    slNo                     = BaseJsonParser.goodInt(json, 'slno') ?? BaseJsonParser.goodInt(json, 'sortorder');
    callTrackerId          = BaseJsonParser.goodInt(json, 'CallTrackerId');
    taskName               = BaseJsonParser.goodString(json, 'taskname');
    description            = BaseJsonParser.goodString(json, 'description');
    statusCode             = BaseJsonParser.goodString(json, 'statusCode');
    status                 = BaseJsonParser.goodString(json, 'status');
    assignedUser           = BaseJsonParser.goodString(json, 'AssignedUser');
    assignedUser           ??= BaseJsonParser.goodString(json, 'assignedusername');
    assignedUserId         = BaseJsonParser.goodInt(json, 'Assigneduserid')??BaseJsonParser.goodInt(json, 'assigneduserid');
    assignedUserProfileUrl = BaseJsonParser.goodString(json, 'AssignedUserProfileUrl') ?? BaseJsonParser.goodString(json, 'AssignedUserprofilekey');
    createdDate            = BaseJsonParser.goodString(json, 'CreatedDate');
    lastModDate            = BaseJsonParser.goodString(json, 'lastmoddate');
    serviceReportUserId    = BaseJsonParser.goodInt(json, 'Servicereportuserid');
    serviceReportUser      = BaseJsonParser.goodString(json, 'Servicereportuser');
    statusRemarks = BaseJsonParser.goodString(json, "statusremarks");
    workStatusName = BaseJsonParser.goodString(json, "workstatusName");
    workStatusCode = BaseJsonParser.goodString(json, "workstatusCode");
    clientdependancyyn = BaseJsonParser.goodString(json, "clientdependancyyn");
    targetclosuredate = BaseJsonParser.goodString(json, "targetclosuredate");


    /// Attachments
    attachments = BaseJsonParser
        .goodList(json, 'attachments')
        .map((e) => TaskAttachmentModel.fromJson(e))
        .toList();

    submittedAttachments = BaseJsonParser
        .goodList(json, 'submittedAttachments')
        .map((e) => TaskAttachmentModel.fromJson(e))
        .toList();

    prevSubmittedAttachments = BaseJsonParser
        .goodList(json, 'prevSubmittedAttachments')
        .map((e) => TaskAttachmentModel.fromJson(e))
        .toList();

    /// NEW → docAttchDetails
    docAttachDetails = BaseJsonParser
        .goodList(json, 'docAttchDetails')
        .map((e) => DocAttachDetailModel.fromJson(e))
        .toList();

    isEngineer = BaseJsonParser.goodBoolean(json, 'isEngineer');
    isReporter = BaseJsonParser.goodBoolean(json, 'isReporter');
    isCoordinator = BaseJsonParser.goodBoolean(json, 'isCoordinator');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id ?? 0,
      'description': description ?? '',
      'statusCode': statusCode ?? '',
      'targetclosuredate': targetclosuredate,
      'assignedUserId': assignedUserId,
      'clientdependancyyn': clientdependancyyn,
      'attachments': attachments.map((e) => e.toJson()).toList(),
      'docAttchDetails':
      docAttachDetails.map((e) => e.toJson()).toList(),
    };
  }
}


class DocAttachDetailModel {
  int? docAttachId;
  String? serialNo;
  int? createdUserId;

  DocAttachDetailModel({
    this.docAttachId,
    this.serialNo,
    this.createdUserId,
  });

  DocAttachDetailModel.fromJson(Map<String, dynamic> json) {
    docAttachId  = BaseJsonParser.goodInt(json, 'docAttachId');
    serialNo     = BaseJsonParser.goodString(json, 'serialno');
    createdUserId = BaseJsonParser.goodInt(json, 'createdUserID');
  }

  Map<String, dynamic> toJson() {
    return {
      'docAttachId': docAttachId ?? 0,
      'serialno': serialNo ?? '',
      'createdUserID': createdUserId ?? 0,
    };
  }
}

/// An attachment that belongs to a task.
class TaskAttachmentModel {
  int? id;
  String? fileName;
  String? filePhysicalName;
  String? url;

  TaskAttachmentModel({
    this.id,
    this.fileName,
    this.filePhysicalName,
    this.url,
  });

  TaskAttachmentModel.fromJson(Map<String, dynamic> json) {
    id               = BaseJsonParser.goodInt(json, 'id');
    fileName         = BaseJsonParser.goodString(json, 'filename');
    filePhysicalName = BaseJsonParser.goodString(json, 'physicalfilename');
    url              = BaseJsonParser.goodString(json, 'fileurl');
  }

  Map<String, dynamic> toJson() {
    return {
      'filename': fileName ?? '',
      'physicalfilename': filePhysicalName ?? '',
      'fileurl': url ?? '',
    };
  }
}