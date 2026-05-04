import 'package:base/data/repository/remote/base_repository.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/project_dashboard/project_dashboard_model.dart';
import 'package:interior_design/data/model/response/project_dashboard/user_hierarchy_dto.dart';
import 'package:interior_design/data/model/response/project_details/project_details_model.dart';

abstract class ProjectDashboardRepository extends BaseRepository{
  Future<void> fetchDashboard(
      {required int userId,
        required String scopeFlag,
        required String categoryFlag,

        required Function(List<UserDashboardData>) onRequestSuccess,
        required Function(AppException) onRequestFailure});
  Future<void> getUserHierarchy(
      {
        required Function(List<UserHierarchyModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure});
}