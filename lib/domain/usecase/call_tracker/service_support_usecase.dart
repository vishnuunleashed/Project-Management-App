import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/call_tracker/user_list.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/model/response/project_details/support_request_model.dart';
import 'package:interior_design/data/remote/repository/call_tracker/service_support_request_impl.dart';

class ServiceSupportUseCase {

  void fetchSupportRequestList({
    String? flag,
    String? status,
    String? logStatus,
    String? scopeFlag,
    String? refOptionCode,
    bool doPassAppType = false,
    required int refDataId,
    required int start,
    required int limit,
    required int deptId,
    required String dateFrom,
    required String dateTo,
    required bool showAllSupport,
    required int userId,
    required String delayedYN,
    required String point,
    int? escalatedUserId,
    required Function(List<SupportRequestDtlModel>) onRequestSuccess,
    required Function(AppException) onRequestFailure,
  }){
    ServiceSupportRequestImpl().fetchServiceSupportRequestList(
        start: start,
        limit: limit,
        refDataId: refDataId,
        refOptionCode: refOptionCode,
        flag: flag,
        logStatus: logStatus,
        scopeFlag: scopeFlag,
        deptId: deptId,
        dateFrom: dateFrom,
        point: point,
        escalatedUserId: escalatedUserId,
        dateTo: dateTo,
        showAllSupport: showAllSupport,
        userId: userId,
        delayedYN: delayedYN,
        status: status,
        doPassAppType: false,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void getStatusType(
      {required Function(List<CommonMasterModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}){
    ServiceSupportRequestImpl().getStatusType(
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void fetchServiceDetailBasedSupportRequestList(
      {String? refOptionCode,
        required int refDataId,
        String? flag,
        String? status,
        int? userId,
        bool doPassAppType = false,
        int? escalatedUserId,
        required String point,
        required int start,
        required int limit,
        required int deptId,
        required String dateFrom,
        required String dateTo,
        required bool showAllSupport,
        required bool isSuperUserSupportOnly,
        required Function(List<SupportRequestDtlModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure,
        required bool isCritical,
        required bool isAllSupport}){
    ServiceSupportRequestImpl().fetchServiceDetailBasedSupportRequestList(
        refDataId: refDataId,
        refOptionCode: refOptionCode,
        point: point,
        start: start,
        limit: limit,
        deptId: deptId,
        dateFrom: dateFrom,
        dateTo: dateTo,
        showAllSupport: showAllSupport,
        isSuperUserSupportOnly: isSuperUserSupportOnly,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure,
        isCritical: isCritical,
        isAllSupport: isAllSupport,
        flag: flag,
        doPassAppType: false,
        escalatedUserId: escalatedUserId,
        status: status,
        userId: userId
    );
  }

  void getUserForCallTracker(
      {required Function(List<EmployeeModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}){
    ServiceSupportRequestImpl().getUserForCallTracker(
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }
}