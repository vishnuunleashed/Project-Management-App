
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/request/add_support_request/add_support_request_model.dart';
import 'package:interior_design/data/model/response/add_observation/add_observation_model.dart';
import 'package:interior_design/data/model/response/add_support_request/add_support_request_dept_model.dart';
import 'package:interior_design/data/model/response/call_tracker/user_list.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/model/response/project_details/project_details_model.dart';
import 'package:interior_design/data/model/response/project_schedule/task_type_dropdown_model.dart';
import 'package:interior_design/data/remote/repository/add_observation/add_observation_repository_impl.dart';
import 'package:interior_design/data/remote/repository/add_support_request/add_support_request_repository_impl.dart';
import 'package:interior_design/data/remote/repository/call_tracker/service_support_request_impl.dart';
import 'package:interior_design/data/remote/repository/project_details/project_details_repository_impl.dart';
import 'package:interior_design/data/remote/repository/project_schedule/project_schedule_impl.dart';
import 'package:interior_design/domain/repository/add_support_request/add_support_request_repository.dart';

class AddSupportRequestUseCase {

  factory AddSupportRequestUseCase() => _instance;
  static final AddSupportRequestUseCase _instance = AddSupportRequestUseCase._internal();
  AddSupportRequestUseCase._internal();


  //For fetching department dropdown
  void fetchDepartmentDropDown(
      { required Function(List<DepartmentDropDownObj> departmentList) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}) {
    AddSupportRequestRepositoryImpl().fetchDepartmentDropDown(
        onRequestSuccess: onRequestSuccess, onRequestFailure: onRequestFailure);
  }

  void fetchOwners(
      {required int projectId,
        bool excludeLoginUser = false,
        required Function(List<OwnerModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}){
    AddObservationRepositoryImpl().fetchOwners(
        projectId: projectId,
        excludeLoginUser: excludeLoginUser,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }


  //Save
  void addSupportRequest(
      { required AddSupportRequestModel addSupportRequestModel,
        required Function({required String transNo}) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}) {
    AddSupportRequestRepositoryImpl().addSupportRequest(
      addSuppReqModel: addSupportRequestModel,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void fetchTaskTypeDropdown({
    required Function(List<TaskTypeDropdownDtlModel>) onRequestSuccess,
    required Function(AppException) onRequestFailure
  }){
    ProjectScheduleImpl().fetchTaskTypeDropdown(
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

  void getMaterialSupportType(
      {required Function(List<CommonMasterModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}){

    AddSupportRequestRepositoryImpl().getMaterialSupportType(
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void getCallTrackerType(
      {required Function(List<CommonMasterModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}){

    AddSupportRequestRepositoryImpl().getCallTrackerType(
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void getUserForCallTracker(
      {required Function(List<EmployeeModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}){
    ServiceSupportRequestImpl().getUserForCallTracker(
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }
}
