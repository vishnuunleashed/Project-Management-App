/*------------------------------------------------------------------------------
AUTHOR		    : Shamnas Abdulla
CREATED DATE	: 04/16/2026
PURPOSE		    :
MODULE/TOPIC	:
REMARKS		    : MOM option
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		    MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/

class MOMSaveModel {
  final int id;
  final int companyId;
  final int optionId;
  final int projectId;
  final String meetingTitle;
  final int? meetingTypeId;
  final DateTime dateTime;
  final String location;
  final String discussionPoint;

  String externalUsers;
  String externalUserEmails;

  final String decisionTaken;
  final List<MomDetail> moMDtls;
  final List<MomAttendee> moMAttendeesDtls;

  MOMSaveModel({
    required this.id,
    required this.companyId,
    required this.optionId,
    required this.projectId,
    required this.meetingTitle,
    required this.meetingTypeId,
    required this.dateTime,
    required this.location,
    required this.discussionPoint,
    required this.externalUsers,
    required this.externalUserEmails,
    required this.decisionTaken,
    required this.moMDtls,
    required this.moMAttendeesDtls,
  });

  factory MOMSaveModel.fromJson(Map<String, dynamic> json) {
    return MOMSaveModel(
      id: json['id'] ?? 0,
      companyId: json['companyId'] ?? 0,
      optionId: json['optionId'] ?? 0,
      projectId: json['projectId'] ?? 0,
      meetingTitle: json['meetingTitle'] ?? '',
      meetingTypeId: json['meetingTypeId'] ?? 0,

      //  SAFE PARSE
      dateTime: json['dateTime'] != null
          ? DateTime.parse(json['dateTime'])
          : DateTime.now(),

      location: json['location'] ?? '',
      discussionPoint: json['discussionPoint'] ?? '',

      //  FIXED KEYS
      externalUsers: json['externalUsers'] ?? '',
      externalUserEmails: json['externalUserEmails'] ?? '',

      decisionTaken: json['decisionTaken'] ?? '',

      moMDtls: (json['moMDtls'] as List<dynamic>?)
          ?.map((e) => MomDetail.fromJson(e))
          .toList() ??
          [],

      moMAttendeesDtls:
      (json['moMAttendeesDtls'] as List<dynamic>?)
          ?.map((e) => MomAttendee.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "companyId": companyId,
      "optionId": optionId,
      "projectId": projectId,
      "meetingTitle": meetingTitle,
      "meetingTypeId": meetingTypeId,


      //  ISO FORMAT (BACKEND FRIENDLY)
      "dateTime": dateTime.toIso8601String(),

      "location": location,
      "discussionPoint": discussionPoint,

      //  STRING FORMAT (NO EXTRA SPACES)
      "externalUsers": externalUsers.trim(),
      "externalUserEmails": externalUserEmails.trim(),

      "decisionTaken": decisionTaken,
      "moMDtls": moMDtls.map((e) => e.toJson()).toList(),
      "moMAttendeesDtls":
      moMAttendeesDtls.map((e) => e.toJson()).toList(),
    };
  }
}

class MomDetail {
  final int id;
  final String actionItem;
  final int? ownerId;
  final int? refOptionId;

  MomDetail({
    required this.id,
    required this.actionItem,
    required this.ownerId,
    required this.refOptionId,
  });

  factory MomDetail.fromJson(Map<String, dynamic> json) {
    return MomDetail(
      id: json['id'] ?? 0,
      actionItem: json['actionItem'] ?? '',
      ownerId: json['ownerId'] ?? 0,
      refOptionId: json['refOptionId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "actionItem": actionItem,
      "ownerId": ownerId,
      "refOptionId": refOptionId,
    };
  }
}

class MomAttendee {
  final int id;
  final int userId;

  MomAttendee({
    required this.id,
    required this.userId,
  });

  factory MomAttendee.fromJson(Map<String, dynamic> json) {
    return MomAttendee(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userId": userId,
    };
  }
}