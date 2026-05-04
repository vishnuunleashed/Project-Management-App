import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/project_details/department_model.dart';
import 'package:interior_design/data/model/response/project_details/support_request_model.dart';
import 'package:interior_design/data/remote/repository/project_details/project_details_repository_impl.dart';

class MySupportRequestUseCase{
  factory MySupportRequestUseCase() => _instance;
  static final MySupportRequestUseCase _instance = MySupportRequestUseCase._internal();
  MySupportRequestUseCase._internal();

  Future<void> fetchDepartmentDropDown(
      {required Function(List<DepartmentDropDownModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure})async{
    ProjectDetailsRepositoryImpl().fetchDepartmentDropDown(
        onRequestSuccess: onRequestSuccess, onRequestFailure: onRequestFailure);
  }

  Future<void> fetchSupportRequestList(
      {
        String? flag,
        String? status,
        required int projectId,
        required int start,
        required int limit,
        required int deptId,
        required int dependencyDeptId,
        required String dateFrom,
        required String dateTo,
        int? escalatedUserId,
        required String point,
        required bool showAllSupport,
        required bool supViewOtherTransactionYN,
        required Function(List<SupportRequestDtlModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}) async {
    ProjectDetailsRepositoryImpl().fetchSupportRequestList(
      doPassAppType: true,
      flag: flag,
        status: status,
        start: start,
        limit: limit,
        showAllSupport: showAllSupport,
        supViewOtherTransactionYN: supViewOtherTransactionYN,
        projectId: projectId,
        deptId: deptId,
        dependencyDeptId: dependencyDeptId,
        dateFrom: dateFrom,
        dateTo: dateTo,
        escalatedUserId: escalatedUserId,
        point: point,
        delayedYN: "None",
        userId: 0,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }
}