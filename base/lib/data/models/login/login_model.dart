import 'dart:convert';

import 'package:base/data/models/response/base_response_model.dart';

class LoginWrapper extends BaseResponseLoginModel{
  List<LoginResponseDto> loginResponse = [];

  LoginWrapper.fromJson(Map<String, dynamic> parsedJson)
      : super.fromJson(parsedJson) {
    if (parsedJson['resultObject'] != null &&
        parsedJson['resultObject'].toString().isNotEmpty) {
      loginResponse = [];
      List<dynamic> responseList = jsonDecode(parsedJson['resultObject']);
      for (var mod in responseList) {
        loginResponse.add(LoginResponseDto.fromJson(mod));
      }
    } else {
      loginResponse = [];
    }
  }
}


class LoginResponseDto {
  final String username;
  final String loginname;
  final List<String> notificationtopics;
  final int userid;
  final int companyid;
  final int foregroundinterval;
  final int branchid;
  final int locationid;
  final int finyearid;
  final String operatingcurrencyid;
  final int loginid;
  final List<ModuleListDto> modulelist;
  String superUserYN = "";
  int departmentId = 0;
  final String departmentName;
  final String departmentcode;
  final String userEmailId;
  final String phoneNo;
  final String profileimage;
  final String profileimageurl;
  final String viewAllTaskYN;
  MobileVersion? mobileVersion;
  LoginResponseDto({
    required this.username,
    required this.loginname,
    required this.userid,
    required this.companyid,
    required this.branchid,
    required this.locationid,
    required this.finyearid,
    required this.operatingcurrencyid,
    required this.loginid,
    required this.modulelist,
    required this.notificationtopics,
    required this.superUserYN,
    required this.departmentId,
    required this.departmentName,
    required this.departmentcode,
    required this.userEmailId,
    required this.phoneNo,
    required this.profileimage,
    required this.profileimageurl,
    required this.viewAllTaskYN,
    required this.mobileVersion,
    required this.foregroundinterval
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      username: json['username'] ?? '',
      loginname: json['loginname'] ?? '',
      userid: json['userid'] ?? 0,
      foregroundinterval: int.parse(json['foregroundinterval'].toString()) ?? 0,
      companyid: json['companyid'] ?? 0,
      branchid: json['branchid'] ?? 0,
      locationid: json['locationid'] ?? 0,
      finyearid: json['finyearid'] ?? 0,
      operatingcurrencyid: json['operatingcurrencyid'] ?? '',
      loginid: json['loginid'] ?? 0,
      departmentId : json["departmentid"]??0,
      departmentName: json["departmentname"] ?? "",
      departmentcode: json["departmentcode"] ?? "",
      profileimage: json["profileimage"] ?? "",
      profileimageurl: json["profileimageurl"] ?? "",
      userEmailId: json["mailid"] ?? "",
      phoneNo: json['phoneno'] ?? "",
      superUserYN : json["superuseryn"],
      viewAllTaskYN: json['viewalltaskyn'] ?? "",

      modulelist: (json['modulelist'] as List<dynamic>?)
          ?.map((e) => ModuleListDto.fromJson(e))
          .toList() ??
          [],
      mobileVersion: json['mobileversion'] != null ? MobileVersion.fromJson(json['mobileversion']) : null,
      notificationtopics: (json['notificationtopics'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? []
      ,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'loginname': loginname,
      'userid': userid,
      'companyid': companyid,
      'branchid': branchid,
      'locationid': locationid,
      'finyearid': finyearid,
      'operatingcurrencyid': operatingcurrencyid,
      'loginid': loginid,
      'modulelist': modulelist.map((e) => e.toJson()).toList(),
      'notificationtopics': notificationtopics,
    };
  }
}

class ModuleListDto {
  final String label;
  final String? menuId;
  final List<ModuleListDto> children;
  final bool? leaf;
  final String? addyn;
  final String? edityn;
  final String? viewyn;
  final String? printyn;
  final String? deleteyn;
  final int? optionid;
  final String? superuseryn;
  final String? componentName;
  final String? docattachmentreqyn;
  final String? requiredapprovalyn;
  final String? showrelationshipyn;
  final String? directentryallowedyn;

  ModuleListDto({
    required this.label,
    this.menuId,
    this.children = const [],
    this.leaf,
    this.addyn,
    this.edityn,
    this.viewyn,
    this.printyn,
    this.deleteyn,
    this.optionid,
    this.superuseryn,
    this.componentName,
    this.docattachmentreqyn,
    this.requiredapprovalyn,
    this.showrelationshipyn,
    this.directentryallowedyn,
  });

  factory ModuleListDto.fromJson(Map<String, dynamic> json) {
    return ModuleListDto(
      label: json['label'] ?? '',
      menuId: json['menuId'],
      leaf: json['leaf'],
      addyn: json['addyn'],
      edityn: json['edityn'],
      viewyn: json['viewyn'],
      printyn: json['printyn'],
      deleteyn: json['deleteyn'],
      optionid: json['optionid'],
      superuseryn: json['superuseryn'],
      componentName: json['componentName'],
      docattachmentreqyn: json['docattachmentreqyn'],
      requiredapprovalyn: json['requiredapprovalyn'],
      showrelationshipyn: json['showrelationshipyn'],
      directentryallowedyn: json['directentryallowedyn'],
      children: (json['children'] as List<dynamic>?)
          ?.map((e) => ModuleListDto.fromJson(e))
          .toList()??[],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'label': label,
    };

    if (menuId != null) data['menuId'] = menuId;
    if (leaf != null) data['leaf'] = leaf;
    if (addyn != null) data['addyn'] = addyn;
    if (edityn != null) data['edityn'] = edityn;
    if (viewyn != null) data['viewyn'] = viewyn;
    if (printyn != null) data['printyn'] = printyn;
    if (deleteyn != null) data['deleteyn'] = deleteyn;
    if (optionid != null) data['optionid'] = optionid;
    if (superuseryn != null) data['superuseryn'] = superuseryn;
    if (componentName != null) data['componentName'] = componentName;
    if (docattachmentreqyn != null) data['docattachmentreqyn'] = docattachmentreqyn;
    if (requiredapprovalyn != null) data['requiredapprovalyn'] = requiredapprovalyn;
    if (showrelationshipyn != null) data['showrelationshipyn'] = showrelationshipyn;
    if (directentryallowedyn != null) data['directentryallowedyn'] = directentryallowedyn;
    if (children != null) data['children'] = children!.map((e) => e.toJson()).toList();

    return data;
  }
}

class MobileVersion {
  final String version;
  final String? mandatoryyn;

  MobileVersion({
    required this.version,
    this.mandatoryyn,
  });

  factory MobileVersion.fromJson(Map<String, dynamic> json) {
    return MobileVersion(
      version: json['version'] ?? '',
      mandatoryyn: json['mandatoryyn'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'version': version,
    };

    if (mandatoryyn != null) data['mandatoryyn'] = mandatoryyn;

    return data;
  }
}