import 'dart:developer';


import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';
import 'package:flutter/material.dart';

class NotificationModel extends BaseResponseModel {
  List<NotificationList> jsonList = [];

  NotificationModel.fromJson(Map<String, dynamic> parsedJson)
      : super.fromJson(parsedJson) {
    jsonList = List.from(BaseJsonParser.goodList(parsedJson, "resultObject")
        .map((e) => NotificationList.fromJson(e))
        .toList());
  }
}
class NotificationList {
  final List<RoutePathItem>? routePath;
  final int notificationId;
  final String? clientId;
  final String? viewOptionCode;
  final String? viewOptionName;
  final String? title;
  final String? message;
  final int? optionId;
  final int? transId;
  final int? transTableId;
  final String? lastModDate;
  final int? notificationBatchId;
  final int? projectId;
  final String? readstatusupdatereqyn;
  final String? createdDate;
  final String? readStatusYN;
  final int? totalRecords;

  NotificationList({
    this.routePath,
    required this.notificationId,
    this.clientId,
    this.viewOptionCode,
    this.viewOptionName,
    this.title,
    this.message,
    this.optionId,
    this.transId,
    this.transTableId,
    this.lastModDate,
    this.notificationBatchId,
    this.projectId,
    this.readstatusupdatereqyn,
    this.createdDate,
    this.readStatusYN,
    this.totalRecords
  });

  factory NotificationList.fromJson(Map<String, dynamic> json) {
    List<RoutePathItem>? parsedRoutePath;
    final rawRoutePath = json['route_path'];
    if (rawRoutePath is List) {
      parsedRoutePath = rawRoutePath
          .map((e) => RoutePathItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return NotificationList(
      routePath: parsedRoutePath,
      notificationId: json['notificationid'],
      clientId: json['clientid'] as String?,
      viewOptionCode: json['viewoptioncode'] as String?,
      viewOptionName: json['viewoptionname'] as String?,
      title: json['title'] as String?,
      message: json['message'] as String?,
      optionId: json['optionid'] as int?,
      transId: json['transid'] as int?,
      transTableId: json['transtableid'] as int?,
      lastModDate: json['lastmoddate']??"",
      notificationBatchId: json['notificationbatchid'] as int?,
      projectId: json['projectid'],
      readstatusupdatereqyn: json['readstatusupdatereqyn'],
      createdDate: json['createddate'],
      readStatusYN: json['readstatusyn'],
        totalRecords: json['totalrecords']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'route_path': routePath?.map((e) => e.toMap()).toList(),
      'notificationid': notificationId,
      'clientid': clientId,
      'viewoptioncode': viewOptionCode,
      'viewoptionname': viewOptionName,
      'title': title,
      'message': message,
      'optionid': optionId,
      'transid': transId,
      'transtableid': transTableId,
      'lastmoddate': lastModDate,
      'notificationbatchid': notificationBatchId,
      'projectid': projectId,
      'readstatusupdatereqyn': readstatusupdatereqyn,
      'createddate': createdDate,
      'readstatusyn': readStatusYN,
      'totalrecords':totalRecords,
    };
  }

  List<RoutePathItem> get sortedRoutePaths {
    final list = List<RoutePathItem>.from(routePath ?? []);
    list.sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
    return list;
  }

  List<String> get orderedRoutes =>
      sortedRoutePaths.map((e) => e.routePath ?? "").toList();


}

class RoutePathItem {
   int? order = 0;
   String? routePath = "";

  RoutePathItem({
     this.order,
     this.routePath,
  });

   factory RoutePathItem.fromJson(Map<String, dynamic> json)  {
     return RoutePathItem(
         order : BaseJsonParser.goodInt(json, 'order')??0,
         routePath: BaseJsonParser.goodString(json, 'routepath')??"");
  }

  Map<String, dynamic> toMap() {
    return {
      'order': order,
      'routepath': routePath,
    };
  }
}
