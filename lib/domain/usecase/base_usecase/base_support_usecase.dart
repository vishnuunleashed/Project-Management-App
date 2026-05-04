/*------------------------------------------------------------------------------
AUTHOR		    : Brenta Roy
CREATED DATE	: 20/08/2025
PURPOSE		    :
MODULE/TOPIC	: CloseSupportRequestUseCase
REMARKS		    :
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------*/
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/request/add_support_request/add_support_request_model.dart';
import 'package:interior_design/data/model/request/close_support_request/close_support_request_model.dart';
import 'package:interior_design/data/model/response/add_observation/add_observation_model.dart';
import 'package:interior_design/data/model/response/add_support_request/add_support_request_dept_model.dart';
import 'package:interior_design/data/model/response/close_observation/read_status_update_dto.dart';
import 'package:interior_design/data/model/response/close_support_request/close_support_request_model.dart';
import 'package:interior_design/data/remote/repository/add_observation/add_observation_repository_impl.dart';
import 'package:interior_design/data/remote/repository/add_support_request/add_support_request_repository_impl.dart';
import 'package:interior_design/data/remote/repository/close_support_request/close_support_request_repository_impl.dart';
import 'package:interior_design/domain/repository/close_support_request/close_support_request_repository.dart';

class BaseCloseSupportRequestUseCase {

  //For fetching status dropdown
  void fetchStatusDropdown(
      {required Function(List<CloseSupportRequestStatusModelObj> supportRequestStatusList) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}) {
    CloseSupportRequestRepositoryImpl().fetchStatusDropdown(
        onRequestSuccess: onRequestSuccess, onRequestFailure: onRequestFailure);
  }

  //For fill Support Request Details
  void fillSupportRequestDetails(
      {required int supportRequestId,
        required Function(List<SupportRequestFillModel> supportRequestStatusList)
        onRequestSuccess,
        required Function(AppException exception) onRequestFailure}) {
    CloseSupportRequestRepositoryImpl().fillSupportRequestDetails(
        supportRequestId: supportRequestId,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void updateNotificationStatus(
      {
       required int notificationId,
        required Function(int) onRequestSuccess,
        required Function(AppException) onRequestFailure}
      ){
    CloseSupportRequestRepositoryImpl().updateNotificationStatus(
       notificationId: notificationId,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);


  }
  void fetchOwners(
      {required int projectId,
        required bool excludeLoginUser,
        required Function(List<OwnerModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}){
    AddObservationRepositoryImpl().fetchOwners(
        projectId: projectId,
        excludeLoginUser:excludeLoginUser,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }


  void saveSupportRequest({
    required int optionId,
    required int projectId,
    required String requestDescription,
    required int dependencyDepartmentId,
    required String targetClosureDate,
    int? escalatedTo,
    required Function() onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  }) {

    CloseSupportRequestRepositoryImpl().supportRequestApi(
      closeSuppReqModel: CloseSupportRequestModel(
        id: 0,
        optionid: optionId,
        projectid: projectId,
        requestdescription: requestDescription,
        dependencydepartmentid: dependencyDepartmentId,
        targetclosuredate: targetClosureDate,
        escalatedto: escalatedTo,
      ),
      onRequestSuccess: onRequestSuccess,
      onRequestFailure: onRequestFailure,
    );
  }


  void forwardSupportRequest({
    required int id,
    required int logId,
    required int projectId,
    required String remarks,
    int? escalatedTo,
    required Function() onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  }) {

    CloseSupportRequestRepositoryImpl().supportRequestApi(
      closeSuppReqModel: CloseSupportRequestModel(
        id: id,
        projectid: projectId,
        remarks: remarks,
        escalatedto: escalatedTo,
        status: "FORWARD",
        prevlogid: logId
      ),
      onRequestSuccess: onRequestSuccess,
      onRequestFailure: onRequestFailure,
    );
  }


  void submitSupportRequest({
    required int id,
    required int logId,
    required int projectId,
    required String remarks,
    required Function() onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  }) {

    CloseSupportRequestRepositoryImpl().supportRequestApi(
      closeSuppReqModel: CloseSupportRequestModel(
        id: id,
        projectid: projectId,
        remarks: remarks,
        status: "SUBMIT",
        prevlogid: logId
      ),
      onRequestSuccess: onRequestSuccess,
      onRequestFailure: onRequestFailure,
    );
  }


  void reassignSupportRequest({
    required int id,
    required int logId,
    required int projectId,
    required String remarks,
    int? escalatedTo,
    required Function() onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  }) {

    CloseSupportRequestRepositoryImpl().supportRequestApi(
      closeSuppReqModel: CloseSupportRequestModel(
        id: id,
        projectid: projectId,
        remarks: remarks,
        escalatedto: escalatedTo,
        status: "REASSIGNED",
        prevlogid: logId
      ),
      onRequestSuccess: onRequestSuccess,
      onRequestFailure: onRequestFailure,
    );
  }


  void closeSupportRequest({
    required int id,
    required int logId,
    required int projectId,
    String? remarks,
    required Function() onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  }) {

    CloseSupportRequestRepositoryImpl().supportRequestApi(
      closeSuppReqModel: CloseSupportRequestModel(
        id: id,
        projectid: projectId,
        remarks: remarks,
        status: "CLOSED",
        prevlogid: logId
      ),
      onRequestSuccess: onRequestSuccess,
      onRequestFailure: onRequestFailure,
    );
  }


  void cancelSupportRequest({
    required int id,
    required int logId,
    required Function() onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  }) {

    CloseSupportRequestRepositoryImpl().cancelSupportRequest(
      closeSuppReqModel: CloseSupportRequestModel(
        id: id,
        status: "CANCELLED",
        prevlogid: logId
      ),
      onRequestSuccess: onRequestSuccess,
      onRequestFailure: onRequestFailure,
    );
  }

  void fetchDepartmentDropDown(
      { required Function(List<DepartmentDropDownObj> departmentList) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}) {
    AddSupportRequestRepositoryImpl().fetchDepartmentDropDown(
        onRequestSuccess: onRequestSuccess, onRequestFailure: onRequestFailure);
  }

  void sendCommentSupportTrack (
      {required String comment,
        required int supportId,
        required Function() onRequestSuccess,
        required Function(AppException) onRequestFailure}){
    CloseSupportRequestRepositoryImpl().sendCommentSupportTrack(
        comment: comment,
        supportId: supportId,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }
}