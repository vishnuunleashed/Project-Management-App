
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/request/add_support_request/add_support_request_model.dart';
import 'package:interior_design/data/model/response/add_support_request/add_support_request_dept_model.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/domain/repository/add_support_request/add_support_request_repository.dart';

class AddSupportRequestRepositoryImpl extends AddSupportRequestRepository {

 //Department Dropdown
  @override
  void fetchDepartmentDropDown({
    required Function(List<DepartmentDropDownObj> departmentList) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  }) {
    const String urlExtension = "Lookup/GetDepartments";
    final Map<String, dynamic> rawData = {};

    performGetRequest(
      urlExtension: urlExtension,
      rawData: rawData,
      onRequestSuccess: (response) {
        try {
          if (response["statusCode"] == 0) {
            onRequestFailure(AppException(response["statusMessage"]));
          }else {
            AddSupportRequestDepartmentModel model = AddSupportRequestDepartmentModel
                .fromJson(response);
            onRequestSuccess(model.departmentList);
          }
        } catch (e) {
          onRequestFailure(AppException('Failed to fetch Departments: ${e.toString()}')
          );
        }
      },
      onRequestFailure: onRequestFailure
    );
  }

  //Save
  @override
  Future<void> addSupportRequest({
    required AddSupportRequestModel addSuppReqModel,
    required Function({required String transNo}) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  }) async {
    const String urlExtension = "SupportRequest/saveorupdate";
    final Map<String, dynamic> rawData = {};

    rawData["id"] = addSuppReqModel.id;
    rawData["supportEdit"] = addSuppReqModel.supportEdit;
    rawData["optionid"] = addSuppReqModel.parentOptionId;
    if(addSuppReqModel.projectId != 0){
      rawData["projectid"] = addSuppReqModel.projectId;
    }
    rawData["requestdescription"] = addSuppReqModel.requestDescription;
    rawData["dependencydepartmentid"] = addSuppReqModel.dependencyDepId;
    rawData["escalatedto"] = addSuppReqModel.selectedOwnerId;
    rawData["targetclosuredate"] = addSuppReqModel.targetClosureDate;
    rawData["Iscritical"] = addSuppReqModel.isCritical;
    if(addSuppReqModel.fromTask){
      rawData["Supporttypeid"] = addSuppReqModel.supportTypeId;
      rawData['Fromid'] = addSuppReqModel.taskId;
      rawData['From'] = "SCHEDULE";
      rawData["Fromadditionalmat"] = false;
    }
    if(addSuppReqModel.fromAdditionalMat){
      rawData["Fromadditionalmat"] = addSuppReqModel.fromAdditionalMat;
      rawData['Supporttypeid'] = addSuppReqModel.materialTypeId;
      rawData['Recid'] = addSuppReqModel.recordId;
    }
    if(addSuppReqModel.fromCallTracker){
      rawData["From"] = "CALL_TRACKER";
      rawData["Fromadditionalmat"] = false;
      rawData['Fromid'] = addSuppReqModel.callTrackerTypeId;
      rawData['Supporttypeid'] = addSuppReqModel.supportTypeId;

      if(addSuppReqModel.observersFromUser.isNotEmpty){
        rawData['Observers'] = addSuppReqModel.observersFromUser
            .map((item) => {
          "Userid": item.id,   // or item.id based on your model
        })
            .toList();
      }
    }
    if(addSuppReqModel.observers.isNotEmpty){
      rawData['Observers'] = addSuppReqModel.observers
          .map((item) => {
        "Userid": item.id,   // or item.id based on your model
      })
          .toList();
    }
    if(addSuppReqModel.isFromMom){
      rawData["From"] = "MOM";
      rawData['Fromid'] = addSuppReqModel.actionItemId;
    }

    performRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (response) {
          try {
            final resultObject = response['resultObject'];
            final transNo = resultObject.first['transactionNo'];
            onRequestSuccess(transNo: transNo);
          } catch (e) {
            onRequestFailure(AppException('Add Support Request submit failed: ${e.toString()}'));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  //edit
  @override
  Future<void> editSupportRequest({
    required AddSupportRequestModel addSuppReqModel,
    required Function({required String transNo}) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  }) async {
    const String urlExtension = "SupportRequest/saveorupdate";
    final Map<String, dynamic> rawData = {};

    rawData["id"] = 0;
    rawData["optionid"] = addSuppReqModel.parentOptionId;
    rawData["projectid"] = addSuppReqModel.projectId;
    rawData["requestdescription"] = addSuppReqModel.requestDescription;
    rawData["dependencydepartmentid"] = addSuppReqModel.dependencyDepId;
    rawData["escalatedto"] = addSuppReqModel.selectedOwnerId;
    rawData["targetclosuredate"] = addSuppReqModel.targetClosureDate;
    rawData["Iscritical"] = addSuppReqModel.isCritical;
    if(addSuppReqModel.fromTask){
      rawData["supporttypeid"] = addSuppReqModel.supportTypeId;
      rawData['taskid'] = addSuppReqModel.taskId;
      rawData['fromTask'] = addSuppReqModel.fromTask;
    }
    if(addSuppReqModel.observers.isNotEmpty){
      rawData['Observers'] = addSuppReqModel.observers
          .map((item) => {
        "Userid": item.id,   // or item.id based on your model
      })
          .toList();
    }

    performRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (response) {
          try {
            final resultObject = response['resultObject'];
            final transNo = resultObject.first['transactionNo'];
            onRequestSuccess(transNo: transNo);
          } catch (e) {
            onRequestFailure(AppException('Add Support Request submit failed: ${e.toString()}'));
          }
        },
        onRequestFailure: onRequestFailure);
  }
  @override
  void getMaterialSupportType(
      {required Function(List<CommonMasterModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}) async {
    const String urlExtension = "lookup/GetCommonMasterByType";
    final Map<String, dynamic> rawData = {};

    rawData["type"] = "MAT_CHRT_SUPPT_TYPE";

    performGetRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          CommonMasterResponseModel response =
          CommonMasterResponseModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.resultObject);
          } else {
            onRequestFailure(AppException(response.statusMessage??""));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  void getCallTrackerType(
      {required Function(List<CommonMasterModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure}) async {
    const String urlExtension = "lookup/GetCommonMasterByType";
    final Map<String, dynamic> rawData = {};

    rawData["type"] = "SRV_CALL_SUPPT_TYPE";

    performGetRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          CommonMasterResponseModel response =
          CommonMasterResponseModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.resultObject);
          } else {
            onRequestFailure(AppException(response.statusMessage??""));
          }
        },
        onRequestFailure: onRequestFailure);
  }
}