/*------------------------------------------------------------------------------
AUTHOR		    : Brenta Roy
CREATED DATE	: 13/08/2025
PURPOSE		    :
MODULE/TOPIC	: CloseSupportRequestRepository
REMARKS		    :
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------*/
import 'package:base/data/repository/remote/base_repository.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/request/add_support_request/add_support_request_model.dart';
import 'package:interior_design/data/model/request/close_support_request/close_support_request_model.dart';
import 'package:interior_design/data/model/response/close_observation/read_status_update_dto.dart';
import 'package:interior_design/data/model/response/close_support_request/close_support_request_model.dart';

abstract class CloseSupportRequestRepository extends BaseRepository {

  //For fetching status dropdown
  void fetchStatusDropdown({
    required Function(List<CloseSupportRequestStatusModelObj> supportRequestStatusList)
        onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  });

  //To fill Support Request Details
  void fillSupportRequestDetails({
    required int supportRequestId,
    required Function(List<SupportRequestFillModel> departmentList)
    onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  });

  //Save
  void supportRequestApi({
    required  CloseSupportRequestModel closeSuppReqModel,
    required Function()    onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  });

  void updateNotificationStatus (
      {required int notificationId,
        required Function(int) onRequestSuccess,
        required Function(AppException) onRequestFailure});

  void cancelSupportRequest({
    required  CloseSupportRequestModel closeSuppReqModel,
    required Function() onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  });

  void sendCommentSupportTrack (
      {required String comment,
        required int supportId,
        required Function() onRequestSuccess,
        required Function(AppException) onRequestFailure});
}
