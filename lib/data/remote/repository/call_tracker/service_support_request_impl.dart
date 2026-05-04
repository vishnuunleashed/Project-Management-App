import 'package:base/core/constants.dart';
import 'package:base/data/models/request/json_builder.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/call_tracker/user_list.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/model/response/project_details/support_request_model.dart';
import 'package:interior_design/domain/repository/call_tracker/service_support_request_repository.dart';

class ServiceSupportRequestImpl extends ServiceSupportRequestRepository{

  @override
  Future<void> fetchServiceSupportRequestList({
    String? flag,
    String? status,
    String? logStatus,
    String? scopeFlag,
    String? refOptionCode,
    bool doPassAppType = false,
    required int refDataId,
    required int start,
    required int limit,
    required int deptId,
    required String dateFrom,
    required String dateTo,
    required bool showAllSupport,
    required int userId,
    required String delayedYN,
    required String point,
    int? escalatedUserId,
    required Function(List<SupportRequestDtlModel>) onRequestSuccess,
    required Function(AppException) onRequestFailure,
  }) async {


    final builder = DataStructureBuilder()
        .addColumn("Start", start)
        .addColumn("Limit", limit)
        .addColumn("Flag", flag ?? "ALL_SUPPORT");

    if (scopeFlag != null) {
      if(scopeFlag == "TEAM"){
        builder.addColumn("SuperUserViewYN", "Y");
      }else {
        builder.addColumn("SuperUserViewYN", "N");
      }
    }

    if (status != null) {
      builder.addColumn("Status", status);
    }
    
    if (logStatus != null) {
      builder.addColumn("LogStatus", logStatus);
    }

    if(delayedYN != "None"){
      builder.addColumn("DelayedYN", delayedYN);
    }
    if (refOptionCode != null) {
      builder.addColumn("RefOptionCode", refOptionCode);
    }

    if (refDataId != 0) {
      builder.addColumn("RefDataId", refDataId);
    }

    if (deptId != 0) {
      builder.addColumn("DepartmentId", deptId);
    }

    if (userId != 0) {
      builder.addColumn("UserId", userId);
    }

    if (!showAllSupport) {
      builder
          .addColumn("DateFrom", dateFrom)
          .addColumn("DateTo", dateTo);
    }

    if (point.isNotEmpty) {
      builder.addColumn("Points", point);
    }
    if (escalatedUserId != null) {
      builder.addColumn("EscalatedUserId", escalatedUserId);
    }

    if (doPassAppType) {
      builder
          .addColumn("AppType", "USER_APP_MOBILE")
          .addColumn("OsType", "android");
    }

    final rawData = builder.build();
    const String urlExtension = "SupportRequest/List";

    performRequest(
      doPassAppType: doPassAppType,
      rawData: rawData,
      urlExtension: urlExtension,
      onRequestSuccess: (result) {
        final response = SupportRequestModel.fromJson(result);
        onRequestSuccess(response.supportRequestList);
      },
      onRequestFailure: onRequestFailure,
    );
  }

  @override
  void getStatusType(
      {required Function(List<CommonMasterModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}) async {
    const String urlExtension = "lookup/GetCommonMasterByType";
    final Map<String, dynamic> rawData = {};

    rawData["type"] = "SUPPORT_STATUS";

    performGetRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          CommonMasterResponseModel response =
          CommonMasterResponseModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.resultObject);
          } else {
            onRequestFailure(AppException(response.statusMessage??""));
          }
        },
        onRequestFailure: onRequestFailure);
  }


  @override
  void getUserForCallTracker(
      {required Function(List<EmployeeModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}) async {
    const String urlExtension = "lookup/GetUsers";

    performGetRequest(
        rawData: {},
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          EmployeeModelResponse response =
          EmployeeModelResponse.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.employeeResponse);
          } else {
            onRequestFailure(AppException(response.statusMessage??""));
          }
        },
        onRequestFailure: onRequestFailure);
  }



  @override
  Future<void> fetchServiceDetailBasedSupportRequestList(
      {String? refOptionCode,
        required int refDataId,
        String? flag,
        String? status,
        int? userId,
        bool doPassAppType = false,
        int? escalatedUserId,
        required String point,
        required int start,
        required int limit,
        required int deptId,
        required String dateFrom,
        required String dateTo,
        required bool showAllSupport,
        required bool isSuperUserSupportOnly,
        required Function(List<SupportRequestDtlModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure,
        required bool isCritical,
        required bool isAllSupport}) async {

    final superUserYN = await BaseSecureStorage.getBool(BaseConstants.superUserYN);

    final superUserViewYN = (superUserYN) ? isSuperUserSupportOnly ? "N" : "Y" : "N";
    final builder = DataStructureBuilder()
        .addColumn("Flag", "SUP_REQ_LIST")
        .addColumn("Start", start)
        .addColumn("Limit", limit)
        .addColumn("SuperUserViewYN", superUserViewYN);

    if(doPassAppType){
      builder.addColumn("AppType", "USER_APP_MOBILE")
          .addColumn('OsType', "android");
    }

    if(userId != null){
      builder.addColumn("UserId", userId);
    }

    if(status != null){
      builder.addColumn("Status", status);
    }
    if (refDataId != 0) {
      builder.addColumn("RefDataId", refDataId);
    }

    if (refOptionCode != null) {
      builder.addColumn("RefOptionCode", refOptionCode);
    }

    if(!showAllSupport){
      builder.addColumn("DateFrom", dateFrom)
          .addColumn("DateTo", dateTo);
    }

    if (deptId != 0) {
      builder.addColumn("DepartmentId", deptId);
    }
    if(!isAllSupport){
      builder.addColumn("IsCriticalYN", isCritical?"Y":"N");
    }


    if (point.isNotEmpty) {
      builder.addColumn("Points", point);
    }
    if (escalatedUserId != null) {
      builder.addColumn("EscalatedUserId", escalatedUserId);
    }



    final rawData = builder.build();
    const String urlExtension = "Project/GetDashboardTilesList";

    performRequest(
        doPassAppType: false,
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          SupportRequestModel response = SupportRequestModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.supportRequestList);
          } else {
            onRequestFailure(AppException(response.statusMessage??""));
          }

        },
        onRequestFailure: (e) {
          onRequestFailure(e);
        });
  }

  @override
  Future<void> fetchServiceSupportRequestSiteWiseList({
    String? flag,
    String? status,
    String? siteName,
    String? logStatus,
    String? scopeFlag,
    bool doPassAppType = false,
    required int start,
    required int limit,
    required int deptId,
    required int dependencyDeptId,
    required String dateFrom,
    required String dateTo,
    required bool showAllSupport,
    required int userId,
    required String delayedYN,
    required String point,
    int? escalatedUserId,
    int? clientId,
    required Function(List<SupportRequestDtlModel>) onRequestSuccess,
    required Function(AppException) onRequestFailure,
  }) async {
  //   {"action":"CALL_TRACKER","Columns":
  //   [{"Key":"Start","Value":0},
  // {"Key":"Limit","Value":10},{"Key":"DelayedYN","Value":"Y"},
  // {"Key":"LogStatus","Value":"ASSIGNED"},{"Key":"Flag","Value":"RAISED"},
  // {"Key":"SiteName","Value":"Celestica"},{"Key":"Status","Value":"PENDING"}]}

    final builder = DataStructureBuilder()
        .addColumn("Start", start)
        .addColumn("Limit", limit);

    // if (scopeFlag != null) {
    //   if(scopeFlag == "TEAM"){
    //     builder.addColumn("SuperUserViewYN", "Y");
    //   }else {
    //     builder.addColumn("SuperUserViewYN", "N");
    //   }
    // }

    if (flag != null  && flag.isNotEmpty) {
      builder.addColumn("Flag", flag);
    }

    if (siteName != null  && siteName.isNotEmpty) {
      builder.addColumn("SiteName", siteName);
    }
    if (clientId != null){
      builder.addColumn("ClientId", clientId);
    }

    if (status != null  && status.isNotEmpty) {
      builder.addColumn("Status", status);
    }

    if (logStatus != null  && logStatus.isNotEmpty) {
      builder.addColumn("LogStatus", logStatus);
    }

    if(delayedYN != "None" &&  delayedYN.isNotEmpty){
      builder.addColumn("DelayedYN", delayedYN);
    }




    if (deptId != 0) {
      builder.addColumn("DepartmentId", deptId);
    }

    if (dependencyDeptId != 0) {
      builder.addColumn("DependDepartmentId", dependencyDeptId);
    }

    // if (userId != 0) {
    //   builder.addColumn("UserId", userId);
    // }

    if (!showAllSupport) {
      builder
          .addColumn("DateFrom", dateFrom)
          .addColumn("DateTo", dateTo);
    }

    if (point.isNotEmpty) {
      builder.addColumn("Points", point);
    }
    if (escalatedUserId != null) {
      builder.addColumn("EscalatedUserId", escalatedUserId);
    }

    if (doPassAppType) {
      builder
          .addColumn("AppType", "USER_APP_MOBILE")
          .addColumn("OsType", "android");
    }

    final rawData = {
      "action":"CALL_TRACKER",
      ...builder.build()
    };
    const String urlExtension = "SupportRequest/List";

    performRequest(
      doPassAppType: doPassAppType,
      rawData: rawData,
      urlExtension: urlExtension,
      onRequestSuccess: (result) {
        final response = SupportRequestModel.fromJson(result);
        onRequestSuccess(response.supportRequestList);
      },
      onRequestFailure: onRequestFailure,
    );
  }
}