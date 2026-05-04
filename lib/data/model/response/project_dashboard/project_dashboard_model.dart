import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';

class UserDashboardResponseModel extends BaseResponseModel {
  List<UserDashboardData> resultObject = [];

  UserDashboardResponseModel.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    List? list = json['resultObject'];
    if (list != null) {
      for (var result in list) {
        resultObject.add(UserDashboardData.fromJson(result));
      }
    }
  }
}

class UserDashboardData {
  int? userId;
  ObservationCount? observationCount;
  SupportReqCount? supportReqCount;
  ScheduleTaskCount? scheduleTaskCount;
  AdditionalMaterialCount? additionalMaterialCount;
  CallTrackSupportCount? callTrackSupportCount;
  CallTrackCount? callTrackCount;
  List<RightsModel> rightsJson = [];

  UserDashboardData.fromJson(Map<String, dynamic> json) {
    userId = BaseJsonParser.goodInt(json, 'userid');

    Map<String, dynamic>? obsMap = json['observationcount'];
    if (obsMap != null) {
      observationCount = ObservationCount.fromJson(obsMap);
    }

    Map<String, dynamic>? supMap = json['supportreqcount'];
    if (supMap != null) {
      supportReqCount = SupportReqCount.fromJson(supMap);
    }

    Map<String, dynamic>? schedMap = json['scheduletaskcount'];
    if (schedMap != null) {
      scheduleTaskCount = ScheduleTaskCount.fromJson(schedMap);
    }

    Map<String, dynamic>? addMatMap = json['additionalmaterialcount'];
    if (addMatMap != null) {
      additionalMaterialCount = AdditionalMaterialCount.fromJson(addMatMap);
    }

    Map<String, dynamic>? callTrackSupMap = json['calltracksupportcount'];
    if (callTrackSupMap != null) {
      callTrackSupportCount = CallTrackSupportCount.fromJson(callTrackSupMap);
    }

    Map<String, dynamic>? callTrackMap = json['calltrackcount'];
    if (callTrackMap != null) {
      callTrackCount = CallTrackCount.fromJson(callTrackMap);
    }

    List? rightsList = json['rightsjson'];
    if (rightsList != null) {
      for (var result in rightsList) {
        rightsJson.add(RightsModel.fromJson(result));
      }
    }
  }
}

class ObservationCount {
  int? totalCount;
  List<ProjectWiseCount> projectWise = [];

  ObservationCount.fromJson(Map<String, dynamic> json) {
    totalCount = BaseJsonParser.goodInt(json, 'TotalCount');
    List? pwList = json['ProjectWise'];
    if (pwList != null) {
      for (var result in pwList) {
        projectWise.add(ProjectWiseCount.fromJson(result));
      }
    }
  }
}

class SupportReqCount {
  int? totalCount;
  List<ProjectWiseCount> projectWise = [];

  SupportReqCount.fromJson(Map<String, dynamic> json) {
    totalCount = BaseJsonParser.goodInt(json, 'TotalCount');
    List? pwList = json['ProjectWise'];
    if (pwList != null) {
      for (var result in pwList) {
        projectWise.add(ProjectWiseCount.fromJson(result));
      }
    }
  }
}

class ScheduleTaskCount {
  int? totalCount;
  List<ProjectWiseSchedule> projectWise = [];

  ScheduleTaskCount.fromJson(Map<String, dynamic> json) {
    totalCount = BaseJsonParser.goodInt(json, 'TotalCount');
    List? pwList = json['ProjectWise'];
    if (pwList != null) {
      for (var result in pwList) {
        projectWise.add(ProjectWiseSchedule.fromJson(result));
      }
    }
  }
}

class AdditionalMaterialCount {
  int? totalCount;
  List<ProjectWiseMaterial> projectWise = [];

  AdditionalMaterialCount.fromJson(Map<String, dynamic> json) {
    totalCount = BaseJsonParser.goodInt(json, 'TotalCount');
    List? pwList = json['ProjectWise'];
    if (pwList != null) {
      for (var result in pwList) {
        projectWise.add(ProjectWiseMaterial.fromJson(result));
      }
    }
  }
}

class CallTrackSupportCount {
  int? totalCount;
  List<TicketWise> ticketWise = [];

  CallTrackSupportCount.fromJson(Map<String, dynamic> json) {
    totalCount = BaseJsonParser.goodInt(json, 'TotalCount');
    List? twList = json['SiteWise'];
    if (twList != null) {
      for (var result in twList) {
        ticketWise.add(TicketWise.fromJson(result));
      }
    }
  }
}

class CallTrackCount {
  int? totalCount;
  int? toCloseCount;
  int? assignmentPendingCount;
  String? isCoordinatorYN;
  List<CallTrackTicket> tickets = [];

  CallTrackCount.fromJson(Map<String, dynamic> json) {
    totalCount = BaseJsonParser.goodInt(json, 'TotalCount');
    toCloseCount = BaseJsonParser.goodInt(json, 'ToCloseCount');
    assignmentPendingCount = BaseJsonParser.goodInt(json, 'AssignmentPendingCount');
    isCoordinatorYN = BaseJsonParser.goodString(json, 'iscordinatoryn');
    List? ticketList = json['Tickets'];
    if (ticketList != null) {
      for (var result in ticketList) {
        tickets.add(CallTrackTicket.fromJson(result));
      }
    }
  }
}

class CallTrackTicket {
  int? ticketId;
  int? clientId;
  int? locationId;
  int? totalticketcount;
  String? ticketNo;
  String? clientName;
  String? siteName;
  int? sendBack;
  int? submitted;
  int? accepted;
  int? rejected;
  int? reopened;
  int? reviewed;
  int? assigned;
  int? totalTaskCount;
  int? assignPending;
  String? hasPendingTasksYN;

  // accepted: 0, assigned: 0, clientid: 21, rejected: 0, reopened: 0, reviewed: 0, sendback: 0, sitename: test, submitted: 0, clientname: Auto Ingress, totaltaskcount: 1, assignment_pending: 1}

  CallTrackTicket.fromJson(Map<String, dynamic> json) {
    ticketId = BaseJsonParser.goodInt(json, 'ticketid');
    clientId = BaseJsonParser.goodInt(json, 'clientid');
    totalticketcount = BaseJsonParser.goodInt(json, 'totalticketcount');
    locationId = BaseJsonParser.goodInt(json, 'locationid');
    ticketNo = BaseJsonParser.goodString(json, 'ticketno');
    clientName = BaseJsonParser.goodString(json, 'clientname');
    siteName = BaseJsonParser.goodString(json, 'sitename');
    sendBack = BaseJsonParser.goodInt(json, 'sendback');
    submitted = BaseJsonParser.goodInt(json, 'submitted');
    accepted = BaseJsonParser.goodInt(json, 'accepted');
    assigned = BaseJsonParser.goodInt(json, 'assigned');
    rejected = BaseJsonParser.goodInt(json, 'rejected');
    reopened = BaseJsonParser.goodInt(json, 'reopened');
    reviewed = BaseJsonParser.goodInt(json, 'reviewed');
    totalTaskCount = BaseJsonParser.goodInt(json, 'totaltaskcount');
    assignPending = BaseJsonParser.goodInt(json, 'assignment_pending');
    hasPendingTasksYN = BaseJsonParser.goodString(json, 'haspendingtasksyn');
  }
}
class ProjectWiseCount {
  int? projectId;
  String? projectName;
  String? reportingToYN;
  int? ticketCount;
  int? openCount;
  int? delayedCount;
  int? openSubmitCount;
  int? openRejectedCount;
  int? openAssignedCount;
  int? openUnassignedCount;
  int? openReassignedCount;
  int? openForwardedCount;
  int? delayedSubmitCount;
  int? delayedRejectedCount;
  int? delayedAssignedCount;
  int? delayedUnassignedCount;
  int? delayedReassignedCount;
  int? delayedForwardedCount;

  ProjectWiseCount.fromJson(Map<String, dynamic> json) {
    projectId = BaseJsonParser.goodInt(json, 'projectid');
    projectName = BaseJsonParser.goodString(json, 'projectname');
    reportingToYN = BaseJsonParser.goodString(json, 'reportingtoyn');
    openCount = BaseJsonParser.goodInt(json, 'open_count');
    ticketCount = BaseJsonParser.goodInt(json, 'TicketCount');
    delayedCount = BaseJsonParser.goodInt(json, 'delayed_count');
    openSubmitCount = BaseJsonParser.goodInt(json, 'open_submit_count');
    openRejectedCount = BaseJsonParser.goodInt(json, 'open_rejected_count');
    openAssignedCount = BaseJsonParser.goodInt(json, 'open_assigned_count');
    openUnassignedCount = BaseJsonParser.goodInt(json, 'open_unassigned_count');
    openReassignedCount = BaseJsonParser.goodInt(json, 'open_reassigned_count');
    openForwardedCount = BaseJsonParser.goodInt(json, 'open_forwarded_count');
    delayedSubmitCount = BaseJsonParser.goodInt(json, 'delayed_submit_count');
    delayedRejectedCount = BaseJsonParser.goodInt(json, 'delayed_rejected_count');
    delayedAssignedCount = BaseJsonParser.goodInt(json, 'delayed_assigned_count');
    delayedUnassignedCount = BaseJsonParser.goodInt(json, 'delayed_unassigned_count');
    delayedReassignedCount = BaseJsonParser.goodInt(json, 'delayed_reassigned_count');
    delayedForwardedCount = BaseJsonParser.goodInt(json, 'delayed_forwarded_count');
  }
}

class ProjectWiseSchedule {
  int? projectId;
  String? projectName;
  String? reportingToYN;
  int? onTrack;
  int? delayed;
  int? totalPending;

  ProjectWiseSchedule.fromJson(Map<String, dynamic> json) {
    projectId = BaseJsonParser.goodInt(json, 'projectid');
    projectName = BaseJsonParser.goodString(json, 'projectname');
    reportingToYN = BaseJsonParser.goodString(json, 'reportingtoyn');
    onTrack = BaseJsonParser.goodInt(json, 'on_track');
    delayed = BaseJsonParser.goodInt(json, 'delayed');
    totalPending = BaseJsonParser.goodInt(json, 'total_pending');
  }
}

class ProjectWiseMaterial {
  int? projectId;
  String? projectName;
  int? optionId;
  int? approvalPendingCount;
  int? poUpdateCount;
  int? receivedCount;
  int? exceededReceivedCount;
  int? sendBackCount;

  ProjectWiseMaterial.fromJson(Map<String, dynamic> json) {
    projectId = BaseJsonParser.goodInt(json, 'projectid');
    projectName = BaseJsonParser.goodString(json, 'projectname');
    optionId = BaseJsonParser.goodInt(json, 'optionid');
    approvalPendingCount = BaseJsonParser.goodInt(json, 'approvalpendingcount');
    poUpdateCount = BaseJsonParser.goodInt(json, 'poupdatecount');
    receivedCount = BaseJsonParser.goodInt(json, 'receivedcount');
    exceededReceivedCount = BaseJsonParser.goodInt(json, 'exceededreceivedcount');
    sendBackCount = BaseJsonParser.goodInt(json, 'sendbackcount');
  }
}
class TicketWise {
  int? ticketId;
  int? clientid;
  String? clientName;
  String? siteName;
  String? ticketNo;
  String? isEngineerYN;
  int? optionId;
  bool isExpandedOpen = false;
  bool isExpandedDelayed = false;

  int? ticketCount;

  int? openCount;
  int? openSubmitCount;
  int? openAssignedCount;
  int? openReassignedCount;
  int? openForwardedCount;

  int? delayedCount;
  int? delayedSubmitCount;
  int? delayedAssignedCount;
  int? delayedReassignedCount;
  int? delayedForwardedCount;

  TicketWise.fromJson(Map<String, dynamic> json) {
    ticketId = BaseJsonParser.goodInt(json, 'ticketid') ?? BaseJsonParser.goodInt(json, 'optionid');
    clientid = BaseJsonParser.goodInt(json, 'clientid');
    clientName = BaseJsonParser.goodString(json, 'clientname');
    siteName = BaseJsonParser.goodString(json, 'sitename');
    ticketNo = BaseJsonParser.goodString(json, 'ticketno');
    isEngineerYN = BaseJsonParser.goodString(json, 'isengineeryn');
    optionId = BaseJsonParser.goodInt(json, 'optionid');

    ticketCount = BaseJsonParser.goodInt(json, 'TicketCount');

    openCount = BaseJsonParser.goodInt(json, 'open_count');
    openSubmitCount = BaseJsonParser.goodInt(json, 'open_submit_count');
    openAssignedCount = BaseJsonParser.goodInt(json, 'open_assigned_count');
    openReassignedCount = BaseJsonParser.goodInt(json, 'open_reassigned_count');
    openForwardedCount = BaseJsonParser.goodInt(json, 'open_forwarded_count');

    delayedCount = BaseJsonParser.goodInt(json, 'delayed_count');
    delayedSubmitCount = BaseJsonParser.goodInt(json, 'delayed_submit_count');
    delayedAssignedCount = BaseJsonParser.goodInt(json, 'delayed_assigned_count');
    delayedReassignedCount = BaseJsonParser.goodInt(json, 'delayed_reassigned_count');
    delayedForwardedCount = BaseJsonParser.goodInt(json, 'delayed_forwarded_count');
  }

  TicketWise({
    this.ticketId,
    this.clientName,
    this.siteName,
    this.ticketNo,
    this.isEngineerYN,
    this.optionId,
    required this.isExpandedOpen,
    required this.isExpandedDelayed,
    this.ticketCount,
    this.openCount,
    this.openSubmitCount,
    this.openAssignedCount,
    this.openReassignedCount,
    this.openForwardedCount,
    this.delayedCount,
    this.delayedSubmitCount,
    this.delayedAssignedCount,
    this.delayedReassignedCount,
    this.delayedForwardedCount,
  });

  TicketWise copyWith({
    int? ticketId,
    String? clientName,
    String? siteName,
    String? ticketNo,
    String? isEngineerYN,
    int? optionId,
    bool? isExpandedOpen,
    bool? isExpandedDelayed,
    int? ticketCount,
    int? openCount,
    int? openSubmitCount,
    int? openAssignedCount,
    int? openReassignedCount,
    int? openForwardedCount,
    int? delayedCount,
    int? delayedSubmitCount,
    int? delayedAssignedCount,
    int? delayedReassignedCount,
    int? delayedForwardedCount,
  }) {
    return TicketWise(
      ticketId: ticketId ?? this.ticketId,
      clientName: clientName ?? this.clientName,
      siteName: siteName ?? this.siteName,
      ticketNo: ticketNo ?? this.ticketNo,
      isEngineerYN: isEngineerYN ?? this.isEngineerYN,
      optionId: optionId ?? this.optionId,
      isExpandedOpen: isExpandedOpen ?? this.isExpandedOpen,
      isExpandedDelayed: isExpandedDelayed ?? this.isExpandedDelayed,
      ticketCount: ticketCount ?? this.ticketCount,
      openCount: openCount ?? this.openCount,
      openSubmitCount: openSubmitCount ?? this.openSubmitCount,
      openAssignedCount: openAssignedCount ?? this.openAssignedCount,
      openReassignedCount: openReassignedCount ?? this.openReassignedCount,
      openForwardedCount: openForwardedCount ?? this.openForwardedCount,
      delayedCount: delayedCount ?? this.delayedCount,
      delayedSubmitCount: delayedSubmitCount ?? this.delayedSubmitCount,
      delayedAssignedCount: delayedAssignedCount ?? this.delayedAssignedCount,
      delayedReassignedCount:
          delayedReassignedCount ?? this.delayedReassignedCount,
      delayedForwardedCount:
          delayedForwardedCount ?? this.delayedForwardedCount,
    );
  }
}
class CallTrackSummary {
  int? assignPendingCount;
  int? reviewedCount;
  int? assignedCount;
  int? inProgressCount;
  int? sendBackCount;
  int? submittedCount;

  CallTrackSummary.fromJson(Map<String, dynamic> json) {
    assignPendingCount = BaseJsonParser.goodInt(json, 'assign_pending_count');
    reviewedCount = BaseJsonParser.goodInt(json, 'reviewed_count');
    assignedCount = BaseJsonParser.goodInt(json, 'assigned_count');
    inProgressCount = BaseJsonParser.goodInt(json, 'inprogress_count');
    sendBackCount = BaseJsonParser.goodInt(json, 'sendback_count');
    submittedCount = BaseJsonParser.goodInt(json, 'submitted_count');
  }
}

class RightsModel {
  RightsData? rights;

  RightsModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? rightsMap = json['Rights'];
    if (rightsMap != null) {
      rights = RightsData.fromJson(rightsMap);
    }
  }
}

class RightsData {
  String? optionCode;
  String? optionName;
  List<RightsDetail> rightsData = [];

  RightsData.fromJson(Map<String, dynamic> json) {
    optionCode = BaseJsonParser.goodString(json, 'optioncode');
    optionName = BaseJsonParser.goodString(json, 'optionname');
    List? dataList = json['rights_data'];
    if (dataList != null) {
      for (var result in dataList) {
        rightsData.add(RightsDetail.fromJson(result));
      }
    }
  }
}

class RightsDetail {
  int? optionId;
  String? addRightsYn;
  String? editRightsYn;
  String? viewRightsYn;
  String? allowAccessYn;
  String? printRightsYn;
  String? deleteRightsYn;
  int? parentOptionId;

  RightsDetail.fromJson(Map<String, dynamic> json) {
    optionId = BaseJsonParser.goodInt(json, 'optionid');
    addRightsYn = BaseJsonParser.goodString(json, 'addrightsyn');
    editRightsYn = BaseJsonParser.goodString(json, 'editrightsyn');
    viewRightsYn = BaseJsonParser.goodString(json, 'viewrightsyn');
    allowAccessYn = BaseJsonParser.goodString(json, 'allowaccessyn');
    printRightsYn = BaseJsonParser.goodString(json, 'printrightsyn');
    deleteRightsYn = BaseJsonParser.goodString(json, 'deleterightsyn');
    parentOptionId = BaseJsonParser.goodInt(json, 'parentoptionid');
  }
}