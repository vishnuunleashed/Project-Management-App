/*------------------------------------------------------------------------------
AUTHOR		    :Aswani Mohan
CREATED DATE	: 07/08/2025
PURPOSE		    :
MODULE/TOPIC	:
REMARKS		    :
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------*/
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/dashboard/dashboard_model.dart';
import 'package:interior_design/data/model/response/project_details/project_details_model.dart';
import 'package:interior_design/data/remote/repository/dashboard/dashboard_repository_impl.dart';
import 'package:interior_design/data/remote/repository/project_details/project_details_repository_impl.dart';
import 'package:interior_design/domain/repository/dashboard/dashboard_repository.dart';

class DashboardUseCase {
  factory DashboardUseCase() => _instance;
  static final DashboardUseCase _instance = DashboardUseCase._internal();
  DashboardUseCase._internal();


  void fetchDashBoardData({
    required int projectId,
    required bool isSelectedSupportRequest,
    required Function(List<DashBoardDetail>) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
    required bool isCritical,
  }) {
    DashboardRepositoryImpl().fetchDashBoardData(
        isCritical:isCritical,
      projectId: projectId,
        isSelectedSupportRequest: isSelectedSupportRequest,
        onRequestSuccess: onRequestSuccess, onRequestFailure: onRequestFailure);
  }

  void fetchDashBoardWithGraph({
    required int projectId,
    required bool isCritical,
    required bool isSelectedSupportRequest,
    required Function(List<DashBoardDetail>) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  }) {
    DashboardRepositoryImpl().fetchDashBoardData(
      projectId: projectId,
        isCritical:isCritical,
        isSelectedSupportRequest: isSelectedSupportRequest,
        onRequestSuccess: onRequestSuccess, onRequestFailure: onRequestFailure);
  }

  Future<void> fetchProjectDetails(
      {required int projectId,
        required Function(List<ProjectDetailsModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}) async {
    ProjectDetailsRepositoryImpl().fetchProjectDetails(
        projectId: projectId,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }
}
