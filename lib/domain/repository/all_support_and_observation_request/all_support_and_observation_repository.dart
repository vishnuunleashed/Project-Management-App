import 'package:base/data/repository/remote/base_repository.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/project_details/observation_model.dart';
import 'package:interior_design/data/model/response/project_details/support_request_model.dart';

abstract class AllSupportAndObservationRepository extends BaseRepository{
  Future<void> fetchAllSupportRequestList(
      {
        String? flag,
        String? status,
        int? userId,
        bool doPassAppType = false,
        int? escalatedUserId,
        required String point,
        required int projectId,
        required int start,
        required int limit,
        required int deptId,
        required int selectedDependencyDeptId,
        required String dateFrom,
        required String dateTo,
        required bool showAllSupport,
        required bool isSuperUserSupportOnly,
        required Function(List<SupportRequestDtlModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure,
        required bool isCritical,
        required bool isAllSupport});

  Future<void> fetchAllObservationList(
      {
        String? flag,
        String? status,
        int? userId,
        required int projectId,
        required int start,
        required int limit,
        required String dateFrom,
        required String dateTo,
        required bool showAllObs,
        required bool isSuperUserObsOnly,
        required String points,
        required String transNo,
        int? observerId,
        required Function(List<ObservationDtlModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure});

  Future<void> followSupportRequest(
      {required int supportId,
            required Function() onRequestSuccess,
            required Function(AppException) onRequestFailure});
  Future<void> unFollowSupportRequest(
      {required int supportId,
            required Function() onRequestSuccess,
            required Function(AppException) onRequestFailure});
}