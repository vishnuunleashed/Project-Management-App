/*------------------------------------------------------------------------------
AUTHOR		    : Brenta Roy
CREATED DATE	: 20/08/2025
PURPOSE		    :
MODULE/TOPIC	: CloseSupportRequestRepositoryImpl
REMARKS		    :
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------*/
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/request/close_support_request/close_support_request_model.dart';
import 'package:interior_design/data/model/response/close_observation/read_status_update_dto.dart';
import 'package:interior_design/data/model/response/close_support_request/close_support_request_model.dart';
import 'package:interior_design/domain/repository/close_support_request/close_support_request_repository.dart';

class CloseSupportRequestRepositoryImpl extends CloseSupportRequestRepository {

  //Status Dropdown
  @override
  void fetchStatusDropdown({
    required Function(List<CloseSupportRequestStatusModelObj> supportRequestStatusList) onRequestSuccess,
    required Function(AppException exception) onRequestFailure
  }) {
    const String urlExtension = "Lookup/GetCommonMasterByType";
    final Map<String, dynamic> rawData = {};
    rawData["type"] = "SUPPORT_STATUS";

    performGetRequest(
      urlExtension: urlExtension,
      rawData: rawData,
      onRequestSuccess: (response) {
        try {
          CloseSupportRequestStatusModel model = CloseSupportRequestStatusModel.fromJson(response);
          onRequestSuccess(model.statusList);
        } catch (e) {
          onRequestFailure(AppException('Failed to fetch Status: ${e.toString()}')
          );
        }
      },
      onRequestFailure: onRequestFailure
    );
  }

  //To Fill Support Request Details
  @override
  void fillSupportRequestDetails({
    required int supportRequestId,
    required Function(List<SupportRequestFillModel> supportRequestFillList) onRequestSuccess,
    required Function(AppException exception) onRequestFailure
  }) {
    const String urlExtension = "SupportRequest/List";
    final Map<String, dynamic> rawData = {};

    rawData["Key"] = "Id";
    rawData["Value"] = supportRequestId;
    Map<String, dynamic> data = {
      "Columns": [rawData]
    };

    performRequest(
      urlExtension: urlExtension,
      rawData: data,
      onRequestSuccess: (response) {
        try {
          final List<dynamic> resultList = response['resultObject'] ?? [];
          final List<SupportRequestFillModel> supportRequestFillList =
              resultList.map((item) => SupportRequestFillModel.fromJson(item)).toList();

          onRequestSuccess(supportRequestFillList);
        } catch (e) {
          onRequestFailure(AppException('Failed to fetch Close Support Request details: ${e.toString()}')
          );
        }
      },
      onRequestFailure: onRequestFailure,
    );
  }

  @override
  Future<void> supportRequestApi({
    required  CloseSupportRequestModel closeSuppReqModel,
    required Function() onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  }) async {
    final Map<String, dynamic> rawData = {};

    if (closeSuppReqModel.id != null) rawData["Id"] = closeSuppReqModel.id;
    if (closeSuppReqModel.prevlogid != null) rawData["Prevlogid"] = closeSuppReqModel.prevlogid;
    if (closeSuppReqModel.optionid != null) rawData["optionid"] = closeSuppReqModel.optionid;
    if (closeSuppReqModel.projectid != null) rawData["projectid"] = closeSuppReqModel.projectid;
    if (closeSuppReqModel.requestdescription != null && closeSuppReqModel.requestdescription!.isNotEmpty) {
      rawData["requestdescription"] = closeSuppReqModel.requestdescription;
    }
    if (closeSuppReqModel.dependencydepartmentid != null) {
      rawData["dependencydepartmentid"] = closeSuppReqModel.dependencydepartmentid;
    }
    if (closeSuppReqModel.targetclosuredate != null && closeSuppReqModel.targetclosuredate!.isNotEmpty) {
      rawData["targetclosuredate"] = closeSuppReqModel.targetclosuredate;
    }
    if (closeSuppReqModel.escalatedto != null) rawData["Escalatedto"] = closeSuppReqModel.escalatedto;
    if (closeSuppReqModel.status != null && closeSuppReqModel.status!.isNotEmpty) rawData["status"] = closeSuppReqModel.status;
    if (closeSuppReqModel.remarks != null && closeSuppReqModel.remarks!.isNotEmpty) rawData["Remarks"] = closeSuppReqModel.remarks;
    String urlExtension = "SupportRequest/saveorupdate";
    performRequest(
      urlExtension: urlExtension,
      rawData: rawData,
      onRequestSuccess: (response) {
        try {
          onRequestSuccess();
        } catch (e) {
          onRequestFailure(AppException(e.toString()));
        }
      },
      onRequestFailure: onRequestFailure,
    );
  }

  @override
  Future<void> cancelSupportRequest({
    required  CloseSupportRequestModel closeSuppReqModel,
    required Function() onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  }) async {
    final Map<String, dynamic> rawData = {};

    if (closeSuppReqModel.id != null) rawData["Id"] = closeSuppReqModel.id;
    if (closeSuppReqModel.prevlogid != null) rawData["Prevlogid"] = closeSuppReqModel.prevlogid;
    if (closeSuppReqModel.status != null && closeSuppReqModel.status!.isNotEmpty) rawData["status"] =closeSuppReqModel.status;

    String urlExtension = "SupportRequest/saveorupdate";
    performRequest(
      urlExtension: urlExtension,
      rawData: rawData,
      onRequestSuccess: (response) {
        try {
          onRequestSuccess();
        } catch (e) {
          onRequestFailure(AppException(e.toString()));
        }
      },
      onRequestFailure: onRequestFailure,
    );
  }


  @override
  void updateNotificationStatus (
      {required int notificationId,
        required Function(int) onRequestSuccess,
        required Function(AppException) onRequestFailure}) async{
    const String urlExtension = "Notification/NotificationReadCountUpdate";
    final Map<String, dynamic> rawData = {};
    rawData['notificationId'] = notificationId;

    performGetRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (response) {

          ReadStatusResponseWrapper readStatusResponseWrapper = ReadStatusResponseWrapper.fromJson(response);
          try {
            if(readStatusResponseWrapper.statusCode == 1){
              onRequestSuccess(readStatusResponseWrapper.resultObject.first.notificationid);


            }
          } catch (e) {
            onRequestFailure(AppException(e.toString()));
          }

        },
        onRequestFailure: (exception){
          onRequestFailure(exception);
        }
    );
  }


  @override
  void sendCommentSupportTrack (
      {required String comment,
        required int supportId,
        required Function() onRequestSuccess,
        required Function(AppException) onRequestFailure}) async{
    const String urlExtension = "SupportRequest/addcomment";
    final Map<String, dynamic> rawData = {};
    rawData['SupportId'] = supportId;
    rawData['Comment'] = comment;

    performRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (response) {
          try {
            if(response["statusCode"] == 1){
              onRequestSuccess();
            }
          } catch (e) {
            onRequestFailure(AppException(e.toString()));
          }

        },
        onRequestFailure: (exception){
          onRequestFailure(exception);
        }
    );
  }


}