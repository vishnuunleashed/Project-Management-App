/*------------------------------------------------------------------------------
AUTHOR		    : Shamnas Abdulla
CREATED DATE	: 11/08/2025
PURPOSE		    : Observation List
MODULE/TOPIC	:
REMARKS		    : IN008 - 25
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		    MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/close_observation/close_observation_model.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';
import 'package:interior_design/data/model/response/project_details/department_model.dart';
import 'package:interior_design/data/model/response/project_details/observation_model.dart';
import 'package:interior_design/data/model/response/project_details/project_details_model.dart';
import 'package:interior_design/data/model/response/project_details/support_request_model.dart';
import 'package:interior_design/data/remote/repository/call_tracker/service_support_request_impl.dart';
import 'package:interior_design/data/remote/repository/close_observation/close_observation_repository_impl.dart';
import 'package:interior_design/data/remote/repository/project_details/project_details_repository_impl.dart';

class ProjectDetailsUseCase {



  Future<void> fetchProjectDetails(
      {required int projectId,
      required Function(List<ProjectDetailsModel>) onRequestSuccess,
      required Function(AppException) onRequestFailure}) async {
    ProjectDetailsRepositoryImpl().fetchProjectDetails(
        projectId: projectId,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  Future<void> fetchDepartmentDropDown(
      {required Function(List<DepartmentDropDownModel>) onRequestSuccess,
       required Function(AppException) onRequestFailure})async{
    ProjectDetailsRepositoryImpl().fetchDepartmentDropDown(
        onRequestSuccess: onRequestSuccess, onRequestFailure: onRequestFailure);
  }

  Future<void> fetchObservationList(
      {
        String? flag,
        String? status,
        String? logStatus,
        required int start,
      required int limit,
      required int projectId,
      required String dateFrom,
      required String dateTo,
      required bool showAllObs,
      bool? obsViewOtherTransactionYN,
      required Function(List<ObservationDtlModel>) onRequestSuccess,
      required Function(AppException) onRequestFailure,
        required String transNo,
        required String points,
        int? observerId,
        required String delayedYN,
        required int userId}) async {
    ProjectDetailsRepositoryImpl().fetchObservationList(
        flag: flag,
        status: status,
        logStatus: logStatus,
        projectId: projectId,
        start: start,
        limit: limit,
        dateFrom: dateFrom,
        dateTo: dateTo,
        showAllObs: showAllObs,
        points: points,
        transNo: transNo,
        observerId:observerId,
        delayedYN:delayedYN,
        userId:userId,
        obsViewOtherTransactionYN : obsViewOtherTransactionYN,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  Future<void> fetchSupportRequestList(
      {
        String? status,
        String? logStatus,
        String? flag,
        required int projectId,
        required int start,
        required int limit,
      required int deptId,
      required int dependencyDeptId,
      required String dateFrom,
      required String dateTo,
      required bool showAllSupport,
        required int userId,
      bool? supViewOtherTransactionYN,
      required Function(List<SupportRequestDtlModel>) onRequestSuccess,
      required Function(AppException) onRequestFailure,
        required String point,

        int? escalatedUserId,
        required String delayedYN, }) async {
    ProjectDetailsRepositoryImpl().fetchSupportRequestList(
        delayedYN:delayedYN,
        logStatus: logStatus,
      start: start,
      status: status,
      limit: limit,
        point:point,
        flag: flag,
        escalatedUserId:escalatedUserId,
      showAllSupport: showAllSupport,
        supViewOtherTransactionYN: supViewOtherTransactionYN,
        projectId: projectId,
        deptId: deptId,
        dependencyDeptId: dependencyDeptId,
        dateFrom: dateFrom,
        dateTo: dateTo,
        userId:userId,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  Future<void> fetchAttachmentsDetail(
      {required List<AttachmentDetailObs> attachmentList,
        bool isProfilePic = false,
        required Function(AttachmentResponseModel) onRequestSuccess,
        required Function(AppException) onRequestFailure}
      )async{
    ProjectDetailsRepositoryImpl().fetchAttachmentsDetail(
      isProfilePic: isProfilePic,
        attachmentList: attachmentList,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void fetchSingleImageAttachmentsDetail({
    required String fileName,
    bool isProfilePic = false,

    required Function(AttachmentResponseModel) onRequestSuccess,
    required Function(AppException) onRequestFailure,
  }){
    ProjectDetailsRepositoryImpl().fetchSingleImageAttachmentsDetail(
        fileName: fileName,
        isProfilePic: true,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  //For fetching status types
  void fetchStatusTypes(
      {required Function(List<StatusModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}) {
    CloseObservationRepositoryImpl().fetchStatusTypes(
        onRequestSuccess: onRequestSuccess, onRequestFailure: onRequestFailure);
  }

  void getStatusType(
      {required Function(List<CommonMasterModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}){
    ServiceSupportRequestImpl().getStatusType(
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

}
