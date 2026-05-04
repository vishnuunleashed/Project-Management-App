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
import 'package:base/data/repository/remote/base_repository.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/dashboard/dashboard_model.dart';
import 'package:interior_design/data/model/response/project_schedule/project_schedule_dashboard_model.dart';

abstract class DashboardRepository extends BaseRepository {
  void fetchDashBoardData({
    required int projectId,
    required bool isCritical,
    required bool isSelectedSupportRequest,
    required Function(List<DashBoardDetail>) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  });
  void fetchDashBoardWithGraph({
    required int projectId,
    String type,
    required Function(List<ProjectData>) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  });
}