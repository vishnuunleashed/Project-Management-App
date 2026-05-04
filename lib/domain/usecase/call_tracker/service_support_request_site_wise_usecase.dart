import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/project_details/support_request_model.dart';
import 'package:interior_design/data/remote/repository/call_tracker/service_support_request_impl.dart';

class ServiceSupportRequestSiteWiseUseCase{

  void fetchServiceSupportRequestSiteWiseList({
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
  }) {
    ServiceSupportRequestImpl().fetchServiceSupportRequestSiteWiseList(
        start: start,
        limit: limit,
        deptId: deptId,
        dependencyDeptId: dependencyDeptId,
        dateFrom: dateFrom,
        dateTo: dateTo,
        showAllSupport: showAllSupport,
        userId: userId,
        delayedYN: delayedYN,
        point: point,
        siteName: siteName,
        scopeFlag: scopeFlag,
        logStatus: logStatus,
        status: status,
        doPassAppType: doPassAppType,
        escalatedUserId: escalatedUserId,
        flag: flag,
        clientId: clientId,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }
}