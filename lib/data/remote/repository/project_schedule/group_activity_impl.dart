import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/project_schedule/activity_group_labour_model.dart';
import 'package:interior_design/data/model/response/project_schedule/activity_group_model.dart';
import 'package:interior_design/data/model/response/project_schedule/color_dto.dart';
import 'package:interior_design/data/model/response/project_schedule/labour_count_update_model.dart';
import 'package:interior_design/domain/repository/project_schedule/group_activity_repo.dart';

class GroupActivitySaveParams{
  int projectID;
  int activityGroupID;
  String labourDate;
  int labourCount;

  GroupActivitySaveParams({
    required this.projectID,
    required this.activityGroupID,
    required this.labourDate,
    required this.labourCount,
  });
}

class ProjectScheduleGroupActivityImpl extends ProjectScheduleGroupActivityRepo{
  @override
  Future<void> fetchProjectScheduleGroupActivityData({
    required int projectId,
    required Function(List<ActivityGroupLabourModel>) onRequestSuccess,
    required Function(AppException) onRequestFailure,
  }) async {
    const String urlExtension = "Schedule/loadprojectactivities";
    final Map<String, dynamic> rawData = {};
    rawData["projectId"] = projectId;


    performGetRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          print("Result --- $result");

          ActivityGroupLabourResponseModel response = ActivityGroupLabourResponseModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.activityGroupLabourList);
          } else {
            onRequestFailure(AppException(response.statusMessage ?? ""));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  void updateScheduleDataLabourCount({
    required GroupActivitySaveParams groupActivitySaveParams,
    required Function(List<LabourCountModel>) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  }) {
    const String urlExtension = "Schedule/saveactivitygrouplabourcount";
    Map<String, dynamic> rawData = {};

    rawData = {
        "projectID": groupActivitySaveParams.projectID,
        "activityGroupID": groupActivitySaveParams.activityGroupID,
        "labourCount": groupActivitySaveParams.labourCount,
        "labourDate": groupActivitySaveParams.labourDate,
    };



    performRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          LabourCountUpdateResponseModel responseModel = LabourCountUpdateResponseModel.fromJson(result);
          if( responseModel.statusCode == 1) {
            onRequestSuccess(responseModel.labourCountResponse);
          }
          else{
            onRequestFailure(AppException(responseModel.statusMessage ?? ""));
          }
        },
        onRequestFailure: onRequestFailure);
  }



  @override
  Future<void> fetchProjectScheduleGroupActivityHealth({
    required int projectId,
    required Function(List<ActivityGroup>?) onRequestSuccess,
    required Function(AppException) onRequestFailure,
  }) async {
    const String urlExtension = "Schedule/calculateactivitygroupsummary";
    final Map<String, dynamic> rawData = {};
    rawData["projectId"] = projectId;
    rawData["type"] = "project";

    performGetRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          ActivityGroupResponseModel response = ActivityGroupResponseModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.activityGroupList);
          } else {
            onRequestFailure(AppException(response.statusMessage ?? ""));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  Future<void> fetchProjectScheduleGroupActivityColor({
    required Function(List<StatusItem>?) onRequestSuccess,
    required Function(AppException) onRequestFailure,
  }) async {
    const String urlExtension = "Schedule/activitygroupchipcolors";

    performGetRequest(
        rawData: {},
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          StatusColorResponseModel response = StatusColorResponseModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.statusList);
          } else {
            onRequestFailure(AppException(response.statusMessage ?? ""));
          }
        },
        onRequestFailure: onRequestFailure);
  }
}
