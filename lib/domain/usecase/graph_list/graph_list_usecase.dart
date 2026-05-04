import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/dashboard/dashboard_model.dart';
import 'package:interior_design/data/model/response/project_schedule/project_schedule_dashboard_model.dart';
import 'package:interior_design/data/remote/repository/dashboard/dashboard_repository_impl.dart';

class GraphListUseCase{

  void fetchDashBoardWithGraph({
    required int projectId,
    String? type,
    required Function(List<ProjectData>) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  }) {
    DashboardRepositoryImpl().fetchDashBoardWithGraph(
        projectId: projectId,
        type: type,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }
}