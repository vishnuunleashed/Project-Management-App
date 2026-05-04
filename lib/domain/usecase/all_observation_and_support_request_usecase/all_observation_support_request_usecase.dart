
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/project_details/department_model.dart';
import 'package:interior_design/data/model/response/project_details/observation_model.dart';
import 'package:interior_design/data/model/response/project_details/project_details_model.dart';
import 'package:interior_design/data/model/response/project_details/support_request_model.dart';
import 'package:interior_design/data/remote/repository/all_support_and_observation_request/all_support_and_observation_request_impl.dart';
import 'package:interior_design/data/remote/repository/project_details/project_details_repository_impl.dart';

class AllObservationAndSupportUseCase{
  Future<void> fetchAllObservationList(
      {
        String? flag,
        String? status,
        int? userId,
        required int start,
        required int limit,
        required int projectId,
        required String dateFrom,
        required String dateTo,
        required bool showAllObs,
        required bool isSuperUserObsOnly,
        required Function(List<ObservationDtlModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure,
        required String points,
        required String transNo,
        int? observerId}) async {
    AllSupportAndObservationRepositoryImpl().fetchAllObservationList(
        flag: flag,
        status: status,
        projectId: projectId,
        userId: userId,
        start: start,
        limit: limit,
        dateFrom: dateFrom,
        dateTo: dateTo,
        showAllObs: showAllObs,
        points: points,
        transNo: transNo,
        observerId: observerId,
        isSuperUserObsOnly : isSuperUserObsOnly,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  Future<void> fetchAllSupportRequestList(
      {
        String? flag,
        String? status,
        int? userId,
        required int projectId,
        required int start,
        required int limit,
        required int deptId,
        required int selectedDependencyDeptId,
        required String dateFrom,
        required String dateTo,
        required bool showAllSupport,
        int? escalatedUserId,
        required String point,
        required bool isSuperUserSupportOnly,
        required Function(List<SupportRequestDtlModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure,
        required bool isCritical,
        required bool isAllSupport,
        }) async {
    AllSupportAndObservationRepositoryImpl().fetchAllSupportRequestList(
      doPassAppType: true,
      flag: flag,
        start: start,
        status: status,
        isCritical:isCritical,
        limit: limit,
        userId: userId,
        point: point,
        escalatedUserId: escalatedUserId,
        showAllSupport: showAllSupport,
        isSuperUserSupportOnly: isSuperUserSupportOnly,
        projectId: projectId,
        deptId: deptId,
        selectedDependencyDeptId: selectedDependencyDeptId,
        dateFrom: dateFrom,
        dateTo: dateTo,
        isAllSupport: isAllSupport,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  Future<void> fetchDepartmentDropDown(
      {required Function(List<DepartmentDropDownModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure})async{
    ProjectDetailsRepositoryImpl().fetchDepartmentDropDown(
        onRequestSuccess: onRequestSuccess, onRequestFailure: onRequestFailure);
  }

  void followSupportRequest(
      {required int supportId,
        required Function() onRequestSuccess,
        required Function(AppException) onRequestFailure}){
    AllSupportAndObservationRepositoryImpl().followSupportRequest(
        supportId: supportId,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void unFollowSupportRequest(
      {required int supportId,
        required Function() onRequestSuccess,
        required Function(AppException) onRequestFailure}){
    AllSupportAndObservationRepositoryImpl().unFollowSupportRequest(
        supportId: supportId,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
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