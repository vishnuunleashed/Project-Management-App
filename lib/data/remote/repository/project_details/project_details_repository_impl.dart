/*------------------------------------------------------------------------------
AUTHOR		    : Shamnas Abdulla
CREATED DATE	: 11/08/2025
PURPOSE		    : Observation List
MODULE/TOPIC	:
REMARKS		    : IN008 - 25
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		    MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
import 'dart:async';

import 'package:base/data/models/request/json_builder.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';
import 'package:interior_design/data/model/response/project_details/department_model.dart';
import 'package:interior_design/data/model/response/project_details/observation_model.dart';
import 'package:interior_design/data/model/response/project_details/project_details_model.dart';
import 'package:interior_design/data/model/response/project_details/support_request_model.dart';
import 'package:interior_design/domain/repository/project_details/project_details_repository.dart';

class ProjectDetailsRepositoryImpl extends ProjectDetailsRepository {
  factory ProjectDetailsRepositoryImpl() => _instance;
  static final ProjectDetailsRepositoryImpl _instance = ProjectDetailsRepositoryImpl._internal();
  ProjectDetailsRepositoryImpl._internal();
  //Fetch project info
  @override
  Future<void> fetchProjectDetails(
      {required int projectId,
      required Function(List<ProjectDetailsModel>) onRequestSuccess,
      required Function(AppException) onRequestFailure}) async {
    const String urlExtension = "Project/ProjectById?";
    final Map<String, dynamic> rawData = {};

    rawData["projectId"] = projectId;

    performGetRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          ProjectDetailsHdrModel response =
              ProjectDetailsHdrModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.projectDetails);
          } else {
            onRequestFailure(AppException(response.statusMessage??""));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  //Fetch department dropdown
  @override
  Future<void> fetchDepartmentDropDown(
      {required Function(List<DepartmentDropDownModel>) onRequestSuccess,
      required Function(AppException) onRequestFailure}) async {
    const String urlExtension = "Lookup/GetDepartments";
    final Map<String, dynamic> rawData = {};

    performGetRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          DepartmentModel response = DepartmentModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.departmentList);
          } else {
            onRequestFailure(AppException(response.statusMessage??""));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  Future<void> fetchObservationList(
      {
        String? flag,
        String? status,
        String? logStatus,
        required int start,
        required int limit,
        required int projectId,
        required String dateFrom,
        required String dateTo,
        required bool showAllObs,
        required String points,
        required String transNo,
        int? observerId,
        required int userId,
        required String delayedYN,
        bool? obsViewOtherTransactionYN,
        required Function(List<ObservationDtlModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure})async {
    // Using the builder pattern

    final builder = DataStructureBuilder()
        .addColumn("Flag", flag??"AGAINST")
        .addColumn("Start", start)
        .addColumn("Limit", limit);

    if(obsViewOtherTransactionYN != null){
      builder.addColumn("ViewOtherTransYN", obsViewOtherTransactionYN ? "N" : "Y" );
    }

    if(status != null && status != ""){
      builder.addColumn("Status", status);
    }
    if (logStatus != null && logStatus != "") {
      builder.addColumn("LogStatus", logStatus);
    }
    if(observerId != null){
      builder.addColumn("ObserverId", observerId);
    }
    if(transNo.isNotEmpty){
      builder.addColumn("TransNo", transNo);
    }
    if(points.isNotEmpty){
      builder.addColumn("Points", points);
    }

    if(projectId != 0){
      builder.addColumn("ProjectId", projectId);
    }
    if(userId != 0){
      builder.addColumn("UserId", userId);
    }

    if(delayedYN != "None"){
      builder.addColumn("DelayedYN", delayedYN);
    }

    if(!showAllObs){
      builder.addColumn("DateFrom", dateFrom)
          .addColumn("DateTo", dateTo);
    }
    // builder.addColumn("AppType", "USER_APP_MOBILE");
    final rawData = builder.build();
    const String urlExtension = "Observation/ObservationsList";

    performRequest(
        rawData: rawData,
        doPassAppType: false,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          ObservationModel response = ObservationModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.observationList);
          } else {
            onRequestFailure(AppException(response.statusMessage??""));
          }
        },
        onRequestFailure: (e) {
          onRequestFailure(e);
        });
  }

  //Fetch support request list
  @override
  Future<void> fetchSupportRequestList(
      {
      String? flag,
      String? status,
      String? logStatus,
        bool doPassAppType = false,
      required int projectId,
      required int start,
      required int limit,
      required int deptId,
      required int dependencyDeptId,
      required String dateFrom,
      required String dateTo,
      required bool showAllSupport,
      bool? supViewOtherTransactionYN,
      required String point,
      int? escalatedUserId,
        required String delayedYN,
      required int userId,
      required Function(List<SupportRequestDtlModel>) onRequestSuccess,
      required Function(AppException) onRequestFailure,

        }) async {



    final builder = DataStructureBuilder()
        .addColumn("Flag", flag??"AGAINST")
        .addColumn("Start", start)
        .addColumn("Limit", limit);

    if(supViewOtherTransactionYN != null){
      builder.addColumn("ViewOtherTransYN", supViewOtherTransactionYN ? "N" : "Y");
    }
    if(doPassAppType){
      builder.addColumn("AppType", "USER_APP_MOBILE")
          .addColumn('OsType', "android");
    }
    if(status != null){
      builder.addColumn("Status", status);
    }
    if(logStatus != null && logStatus != ""){
      builder.addColumn("LogStatus", logStatus);
    }
    if(projectId != 0){
      builder.addColumn("ProjectId", projectId);
    }

    if(userId != 0){
      builder.addColumn("UserId", userId);
    }

    if(delayedYN != "None"){
      builder.addColumn("DelayedYN", delayedYN);
    }
    if(!showAllSupport){
      builder.addColumn("DateFrom", dateFrom)
          .addColumn("DateTo", dateTo);
    }

    if (deptId != 0) {
      builder.addColumn("DepartmentId", deptId);
    }

    if (dependencyDeptId != 0) {
      builder.addColumn("DependDepartmentId", dependencyDeptId);
    }

    if (point.isNotEmpty) {
      builder.addColumn("Points", point);
    }
    if (escalatedUserId != null) {
      builder.addColumn("EscalatedUserId", escalatedUserId);
    }

    final rawData = builder.build();
    const String urlExtension = "SupportRequest/List";

    performRequest(
      doPassAppType: false,
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          SupportRequestModel response = SupportRequestModel.fromJson(result);
          onRequestSuccess(response.supportRequestList);
        },
        onRequestFailure: (e) {
          onRequestFailure(e);
        });
  }

  @override
  Future<void> fetchAttachmentsDetail({
    required List<AttachmentDetailObs> attachmentList,
    bool isProfilePic = false,
    required Function(AttachmentResponseModel) onRequestSuccess,
    required Function(AppException) onRequestFailure,
  }) async {
    final List<String> fileNames = attachmentList
        .map((attachment) => attachment.attachmentPhysicalName ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
    final Map<String, dynamic> rawData = {};
    for (int i = 0; i < fileNames.length; i++) {
      rawData['keys[$i]'] = fileNames[i];
      rawData['IsProfilePic'] = isProfilePic;
    }
    final String urlExtension = "FileUpload/GetFiles?";
    performGetRequest(
      rawData: rawData,
      urlExtension: urlExtension,
      onRequestSuccess: (result) {
        AttachmentResponseModel response = AttachmentResponseModel.fromJson(result);

        if (response.statusCode == 1) {
          onRequestSuccess(response);
        }
        else{
          onRequestFailure(AppException(response.statusMessage??""));
        }
      },
      onRequestFailure: onRequestFailure,
    );
  }


  @override
  Future<void> fetchSingleImageAttachmentsDetail({
    required String fileName,
    bool isProfilePic = false,
    required Function(AttachmentResponseModel) onRequestSuccess,
    required Function(AppException) onRequestFailure,
  }) async {
    final Map<String, dynamic> rawData = {};
    rawData['keys[0]'] = fileName;
    rawData['IsProfilePic'] = isProfilePic;
    final String urlExtension = "FileUpload/GetFiles?";
    performGetRequest(
      rawData: rawData,
      urlExtension: urlExtension,
      onRequestSuccess: (result) {
        AttachmentResponseModel response = AttachmentResponseModel.fromJson(result);
        if (response.statusCode == 1) {
          onRequestSuccess(response);
        }
        else{
          onRequestFailure(AppException(response.statusMessage??""));
        }
      },
      onRequestFailure: onRequestFailure,
    );
  }

}
