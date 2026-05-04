/*------------------------------------------------------------------------------
AUTHOR		    : Aswani Mohan
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
import 'package:interior_design/data/model/response/project_schedule/project_schedule_dashboard_model.dart';

import 'package:interior_design/domain/repository/dashboard/dashboard_repository.dart';


class DashboardRepositoryImpl extends DashboardRepository {
  @override
  void fetchDashBoardData({
    required int projectId,
    required bool isSelectedSupportRequest,
    required Function(List<DashBoardDetail>) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
    required bool isCritical,
  }) {
    const String urlExtension = "Project/GetDashboardByProject?";
    final Map<String, dynamic> rawData = {};

    rawData["projectId"] = projectId;

    if(isSelectedSupportRequest){
      rawData["IsCriticalYN"] = isCritical?"Y":"N";
    }

    rawData["type"] = isSelectedSupportRequest ? 'SUPPORT_REQ':'OBSERVATION';

    performGetRequest(
      urlExtension: urlExtension,
      rawData: rawData,
      onRequestSuccess: (response) {
        try {
          // Parse entire response into wrapper model
          DashboardModel dashboardData = DashboardModel.fromJson(response);

          onRequestSuccess(dashboardData.dashBoardDetailList);
        } catch (e) {
          onRequestFailure(
            AppException('Data parsing error: ${e.toString()}'),
          );
        }
      },
      onRequestFailure: onRequestFailure,
    );
  }

  @override
  void fetchDashBoardWithGraph({
    required int projectId,
   String? type,
    required Function(List<ProjectData>) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  }) {
    const String urlExtension = "Project/GetDashboardByProject?";
    final Map<String, dynamic> rawData = {};

    rawData["projectId"] = projectId;
    rawData["type"] = type??"PRJCT_SCHEDULE";

    performGetRequest(
      urlExtension: urlExtension,
      rawData: rawData,
      onRequestSuccess: (response) {
        try {
          // Parse entire response into wrapper model
          DashboardDto dashboardData = DashboardDto.fromJson(response);

          onRequestSuccess(dashboardData.resultObject??[]);
        } catch (e) {
          onRequestFailure(
            AppException('Data parsing error: ${e.toString()}'),
          );
        }
      },
      onRequestFailure: onRequestFailure,
    );
  }
}
