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
import 'package:base/data/repository/remote/base_repository.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/project_details/attachment_model.dart';
import 'package:interior_design/data/model/response/project_details/department_model.dart';
import 'package:interior_design/data/model/response/project_details/observation_model.dart';
import 'package:interior_design/data/model/response/project_details/project_details_model.dart';
import 'package:interior_design/data/model/response/project_details/support_request_model.dart';

abstract class ProjectDetailsRepository extends BaseRepository {
  Future<void> fetchProjectDetails(
      {required int projectId,
      required Function(List<ProjectDetailsModel>) onRequestSuccess,
      required Function(AppException) onRequestFailure});

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
        required String points,
        required String transNo,
        int? observerId,
        required int userId,
        required String delayedYN,
        bool? obsViewOtherTransactionYN,
      required Function(List<ObservationDtlModel>) onRequestSuccess,
      required Function(AppException) onRequestFailure});

  Future<void> fetchSupportRequestList(
      {
        String? flag,
        String? status,
        String? logStatus,
        bool doPassAppType = false,
        required int projectId,
        required int start,
        required int limit,
        required int deptId,
        required int dependencyDeptId,
        required String dateFrom,
        required String dateTo,
        required bool showAllSupport,
        bool? supViewOtherTransactionYN,
        required String point,
        required int userId,
        int? escalatedUserId,
        required String delayedYN,
        required Function(List<SupportRequestDtlModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure,
      });

  Future<void> fetchDepartmentDropDown(
      {required Function(List<DepartmentDropDownModel>) onRequestSuccess,
      required Function(AppException) onRequestFailure});

  Future<void> fetchAttachmentsDetail(
  {required List<AttachmentDetailObs> attachmentList,
    required Function(AttachmentResponseModel) onRequestSuccess,
    required Function(AppException) onRequestFailure}
      );

  Future<void> fetchSingleImageAttachmentsDetail({
    required String fileName,
    bool isProfilePic = false,
    required Function(AttachmentResponseModel) onRequestSuccess,
    required Function(AppException) onRequestFailure,
  });

}
