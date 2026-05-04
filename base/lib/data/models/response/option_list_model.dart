
class OptionListModel {
  int? optionId;
  int? parentOptionId;
  String? optionCode;
  String? optionName;
  int? sortOrder;
  String? showRelationshipYN;
  String? requiredApprovalYN;
  String? screenNoteEnableYN;
  String? docAttachmentReqYN;
  String? mobileIcon;
  String? iconColor;
  String? allowAccessYN;
  String? addRightsYN;
  String? editRightsYN;
  String? deleteRightsYN;
  String? viewRightsYN;
  String? printRightsYN;
  OptionListModel({this.optionId,
    this.parentOptionId,
    this.optionCode,
    this.optionName,
    this.sortOrder,
    this.showRelationshipYN,
    this.requiredApprovalYN,
    this.screenNoteEnableYN,
    this.docAttachmentReqYN,
    this.mobileIcon,
    this.iconColor,
    this.allowAccessYN,
    this.addRightsYN,
    this.editRightsYN,
    this.deleteRightsYN,
    this.viewRightsYN,
    this.printRightsYN,
  });

  Map<String, dynamic> toMap() {
    return {
    'optionId': optionId,
    'parentOptionId':parentOptionId,
    'optionCode':optionCode,
    'optionName':optionName,
    'sortOrder':sortOrder,
    'showRelationshipYN':showRelationshipYN,
    'requiredApprovalYN':requiredApprovalYN,
    'screenNoteEnableYN':screenNoteEnableYN,
    'docAttachmentReqYN':docAttachmentReqYN,
    'mobileIcon':mobileIcon,
    'iconColor':iconColor,
    'allowAccessYN':allowAccessYN,
    'addRightsYN':addRightsYN,
    'editRightsYN':editRightsYN,
    'deleteRightsYN':deleteRightsYN,
    'viewRightsYN':viewRightsYN,
    'printRightsYN':printRightsYN
    };
  }
}

