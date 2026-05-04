import 'package:base/core/constants.dart';
import 'package:base/data/models/request/json_builder.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/project_details/observation_model.dart';
import 'package:interior_design/data/model/response/project_details/support_request_model.dart';
import 'package:interior_design/domain/repository/all_support_and_observation_request/all_support_and_observation_repository.dart';

class AllSupportAndObservationRepositoryImpl extends AllSupportAndObservationRepository {


  // observation flag- OBSERV_LIST
  // support request flag- SUP_REQ_LIST
  // Status = OPEN,DELAYED,CLOSED
  @override
  Future<void> fetchAllSupportRequestList(
      {
        String? flag,
        String? status,
        int? userId,
        bool doPassAppType = false,
        int? escalatedUserId,
        required String point,
        required int projectId,
        required int start,
        required int limit,
        required int deptId,
        required int selectedDependencyDeptId,
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
    if(projectId != 0){
      builder.addColumn("ProjectId", projectId);
    }
    if(!showAllSupport){
      builder.addColumn("DateFrom", dateFrom)
          .addColumn("DateTo", dateTo);
    }

    if (deptId != 0) {
      builder.addColumn("DepartmentId", deptId);
    }

    if (selectedDependencyDeptId != 0) {
      builder.addColumn("DependDepartmentId", selectedDependencyDeptId);
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

  // observation flag- OBSERV_LIST
  // support request flag- SUP_REQ_LIST
  // Status = OPEN,DELAYED,CLOSED
  //Fetch observation list
  @override
  Future<void> fetchAllObservationList(
      {
        String? flag,
        String? status,
        int? userId,
        required int projectId,
        required int start,
        required int limit,
        required String dateFrom,
        required String dateTo,
        required bool showAllObs,
        required bool isSuperUserObsOnly,
        required String points,
        required String transNo,
        int? observerId,
        required Function(List<ObservationDtlModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}) async {
    // Using the builder pattern
    final superUserYN = await BaseSecureStorage.getBool(BaseConstants.superUserYN);
    final superUserViewYN = (superUserYN) ? isSuperUserObsOnly ? "N" : "Y" : "N";
    final builder = DataStructureBuilder()
        .addColumn("Flag", "OBSERV_LIST")
        .addColumn("Start", start)
        .addColumn("Limit", limit)
        .addColumn("SuperUserViewYN", superUserViewYN);

    if(userId != null){
      builder.addColumn("UserId", userId);
    }

    if(status != null){
      builder.addColumn("Status", status);
    }

    if(projectId != 0){
      builder.addColumn("ProjectId", projectId);
    }

    if(!showAllObs){
      builder.addColumn("DateFrom", dateFrom)
          .addColumn("DateTo", dateTo);
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

    final rawData = builder.build();
    const String urlExtension = "Project/GetDashboardTilesList";

    performRequest(
        rawData: rawData,
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
  @override
  Future<void> followSupportRequest(
      {required int supportId,
        required Function() onRequestSuccess,
        required Function(AppException) onRequestFailure}) async {
    const String urlExtension = "SupportRequest/follow";


    performRequestWithStringBody(
        rawData: "$supportId",
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          onRequestSuccess();
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  Future<void> unFollowSupportRequest(
      {required int supportId,
        required Function() onRequestSuccess,
        required Function(AppException) onRequestFailure}) async {
    const String urlExtension = "SupportRequest/unfollow";


    performRequestWithStringBody(
        rawData: "$supportId",
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          onRequestSuccess();
        },
        onRequestFailure: onRequestFailure);
  }
}