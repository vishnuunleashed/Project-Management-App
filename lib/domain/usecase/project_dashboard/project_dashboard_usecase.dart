import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/project_dashboard/project_dashboard_model.dart';
import 'package:interior_design/data/model/response/project_dashboard/user_hierarchy_dto.dart';

import 'package:interior_design/data/remote/repository/project_dashboard/project_dashboard_impl.dart';

class ProjectDashBoardUseCase{
  void fetchDashboard(
      {
        required int userId,
        required String scopeFlag, required String categoryFlag,
        required Function(List<UserDashboardData>) onRequestSuccess,
        required Function(AppException) onRequestFailure}){
    ProjectDashboardImpl().fetchDashboard(
      userId: userId,
        categoryFlag: categoryFlag,
        scopeFlag: scopeFlag,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);

  }
  void getUserHierarchy(
      {
        required Function(List<UserHierarchyModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}){
    ProjectDashboardImpl().getUserHierarchy(
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }
}