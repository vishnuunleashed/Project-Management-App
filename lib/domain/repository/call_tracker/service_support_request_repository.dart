import 'package:base/data/repository/remote/base_repository.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/call_tracker/user_list.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/model/response/project_details/support_request_model.dart';

abstract class ServiceSupportRequestRepository extends BaseRepository{
  Future<void> fetchServiceSupportRequestList({
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
  });

  void getStatusType(
      {required Function(List<CommonMasterModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure});


  Future<void> fetchServiceDetailBasedSupportRequestList(
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
        required bool isAllSupport});

  void getUserForCallTracker(
      {required Function(List<EmployeeModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure});

  Future<void> fetchServiceSupportRequestSiteWiseList({
    String? flag,
    String? status,
    String? logStatus,
    String? scopeFlag,
    String? siteName,
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
  });

}