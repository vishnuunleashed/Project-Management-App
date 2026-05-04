import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/project_dashboard/project_dashboard_model.dart';
import 'package:interior_design/data/model/response/project_dashboard/user_hierarchy_dto.dart';
import 'package:interior_design/domain/repository/project_dashboard/project_dashboard_repo.dart';

class ProjectDashboardImpl extends ProjectDashboardRepository{

  @override
  Future<void> fetchDashboard(
      {required int userId,
        required String scopeFlag,
        required String categoryFlag,
        required Function(List<UserDashboardData>) onRequestSuccess,
        required Function(AppException) onRequestFailure}) async {
    const String urlExtension = "project/GetDashboardToDoList";

    final Map<String, dynamic> rawData = {};

    rawData["userId"] = userId;
    rawData["ScopeFlag"] = scopeFlag == "INDIVIDUAL"?"SELF":scopeFlag;
    rawData["category"] = categoryFlag;

    performGetRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          UserDashboardResponseModel response =
          UserDashboardResponseModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.resultObject);
          } else {
            onRequestFailure(AppException(response.statusMessage??""));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  Future<void> getUserHierarchy(
      {
        required Function(List<UserHierarchyModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}) async {
    const String urlExtension = "project/GetUserHierarchy";


    performGetRequest(
        rawData: {},
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          UserListResponseModel response =
          UserListResponseModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.resultObject);
          } else {
            onRequestFailure(AppException(response.statusMessage??""));
          }
        },
        onRequestFailure: onRequestFailure);
  }

}