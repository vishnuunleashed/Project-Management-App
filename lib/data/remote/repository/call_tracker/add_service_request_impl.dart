import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/request/call_tracker/new_service_add_model.dart';
import 'package:interior_design/data/model/response/call_tracker/location_address_dto.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/model/response/common/site_response_model.dart';
import 'package:interior_design/domain/repository/call_tracker/add_service_request_repository.dart';

class AddServiceRequestImpl extends AddServiceRequestRepository {
  @override
  void fetchSiteLists(
      {required List<CommonMasterModel> clientList,
        required Function(List<SiteModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}) {

    String urlExtension = "lookup/GetClientsSites?";
    final Map<String, dynamic> rawData = {};
    if (clientList.isNotEmpty) {
      rawData["clientId"] = clientList.map((e) => e.id).join(",");
    }

    performGetRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (result) {
          try {
            SiteResponseModel response = SiteResponseModel.fromJson(result);
            onRequestSuccess(response.resultObject);
          } catch (e) {
            onRequestFailure(AppException(
              "Error parsing user data: ${e.toString()}",
            ));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  void fetchClientLists(
      {required Function(List<CommonMasterModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}) {
    String urlExtension = "lookup/GetClients";

    Map<String, dynamic> rawData = {};
    rawData["type"] = "SERV_TKT_STATUS";

    performGetRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (result) {
          try {
            CommonMasterResponseModel response = CommonMasterResponseModel.fromJson(result);
            onRequestSuccess(response.resultObject);
          } catch (e) {
            onRequestFailure(AppException(
              "Error parsing user data: ${e.toString()}",
            ));
          }
        },
        onRequestFailure: onRequestFailure);
  }

 @override
  void fetchCityLists(
      {required Function(List<CommonMasterModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}) {
    String urlExtension = "Lookup/GetCities";

    performGetRequest(
        urlExtension: urlExtension,
        rawData: {},
        onRequestSuccess: (result) {
          try {
            CommonMasterResponseModel response = CommonMasterResponseModel.fromJson(result);
            onRequestSuccess(response.resultObject);
          } catch (e) {
            onRequestFailure(AppException(
              "Error parsing user data: ${e.toString()}",
            ));
          }
        },
        onRequestFailure: onRequestFailure);
  }


  @override
  void fetchServiceCategory(
      {required Function(List<CommonMasterModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}) {
    String urlExtension = "lookup/GetCommonMasterByType";

    Map<String, dynamic> rawData = {};
    rawData["type"] = "SERV_CATEGORY";

    performGetRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (result) {
          try {
            CommonMasterResponseModel response = CommonMasterResponseModel.fromJson(result);
            onRequestSuccess(response.resultObject);
          } catch (e) {
            onRequestFailure(AppException(
              "Error parsing user data: ${e.toString()}",
            ));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  void fetchServicePriority(
      {required Function(List<CommonMasterModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}) {
    String urlExtension = "lookup/GetCommonMasterByType";

    Map<String, dynamic> rawData = {};
    rawData["type"] = "SERV_PRIORITY";

    performGetRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (result) {
          try {
            CommonMasterResponseModel response = CommonMasterResponseModel.fromJson(result);
            onRequestSuccess(response.resultObject);
          } catch (e) {
            onRequestFailure(AppException(
              "Error parsing user data: ${e.toString()}",
            ));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  void fetchUserByDepartment(
      {
        required String departmentCode,
        required Function(List<CommonMasterModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}) {
    String urlExtension = "lookup/GetUsersByDepartment";

    Map<String, dynamic> rawData = {};
    rawData["departmentCode"] = departmentCode;

    performGetRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (result) {
          try {
            CommonMasterResponseModel response = CommonMasterResponseModel.fromJson(result);
            onRequestSuccess(response.resultObject);
          } catch (e) {
            onRequestFailure(AppException(
              "Error parsing user data: ${e.toString()}",
            ));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  void fetchAllUserByDepartment(
      {
        required Function(List<CommonMasterModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}) {

    String urlExtension = "Lookup/GetUsers";

    Map<String, dynamic> rawData = {};

    performGetRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (result) {
          try {
            CommonMasterResponseModel response = CommonMasterResponseModel.fromJson(result);
            onRequestSuccess(response.resultObject);
          } catch (e) {
            onRequestFailure(AppException(
              "Error parsing user data: ${e.toString()}",
            ));
          }
        },
        onRequestFailure: onRequestFailure);
  }


  @override
  void fetchLocationAddress(
      {
        required int clientId,
        required Function(List<LocationModelAddresses>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}) {
    String urlExtension = "lookup/GetClientLocations";

    Map<String, dynamic> rawData = {};
    rawData["clientId"] = clientId;

    performGetRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (result) {
          try {
            LocationModelHdrModel response = LocationModelHdrModel.fromJson(result);
            onRequestSuccess(response.locations);
          } catch (e) {
            onRequestFailure(AppException(
              "Error parsing user data: ${e.toString()}",
            ));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  void saveNewServiceRequest(
      {
        required TicketModel ticketModel,
        required Function() onRequestSuccess,
        required Function(AppException exception) onRequestFailure}) {
    String urlExtension = "ServiceCallTracker/saveorupdate";
    Map<String, dynamic> rawData = {};


    rawData["Id"] = ticketModel.id;
    rawData["Client"] = ticketModel.client;
    rawData["Sitename"] = ticketModel.sitename;
    rawData["Building"] = ticketModel.building;
    rawData["Floor"] = ticketModel.floor;
    rawData["Address"] = ticketModel.address;
    rawData["CityName"] = ticketModel.cityName;
    rawData["Description"] = ticketModel.description;
    rawData["Categoryid"] = ticketModel.categoryid;
    rawData["Priorityid"] = ticketModel.priorityid;
    rawData["notifyClientYN"] = ticketModel.notifyClientYN;
    if(ticketModel.targetclosuredate != null){
      rawData["Targetclosuredate"] =
          ticketModel.targetclosuredate;
    }

    if(ticketModel.assigneduserid != null){
      rawData["Assigneduserid"] = ticketModel.assigneduserid;
    }

    if(ticketModel.servicereportuserid != null){
      rawData["Servicereportuserid"] = ticketModel.servicereportuserid;
    }
    if(ticketModel.emailId != null){
      rawData["clientMailid"] = ticketModel.emailId;
    }
    if(ticketModel.phoneNo != null){
      rawData["clientPhoneno"] = ticketModel.phoneNo;
    }

    rawData["Lastmoddate"] =
          ticketModel.lastmoddate;


    List<Map<String, dynamic>> taskDetailsList = [];
    for (int i = 0; i < ticketModel.serviceTasks.length; i++) {
      final task = ticketModel.serviceTasks[i];


      List<Map<String, dynamic>> attachmentDtls = [];
      for (var att in task.attachments) {
            attachmentDtls.add({
              "filename": att.fileName ?? "",
              "physicalfilename": att.filePhysicalName ?? "",
            });
        }


      List<Map<String, dynamic>> docAttachments = [];
      if (task.id != null && task.id != 0 && task.docAttachDetails.isNotEmpty) {
        docAttachments.add({
          "seriesno": task.docAttachDetails.first.serialNo,
          "createdUserId": task.docAttachDetails.first.createdUserId,
          "id": task.docAttachDetails.first.docAttachId ?? 0,
          "attachmentDtls": attachmentDtls,
        });
      }
      else{
        if(attachmentDtls.isNotEmpty){
        docAttachments.add({
          "seriesno": task.docAttachDetails.first.serialNo,
          "createdUserId": task.docAttachDetails.first.createdUserId,
          "id": task.attachments.first.id ?? 0,
          "attachmentDtls": attachmentDtls,
        });
        }
      }

      taskDetailsList.add({
        "id": task.id ?? 0,
        "taskname": task.description ?? "",
        "sortorder": i + 1,
        "docAttachments": docAttachments,
        "assigneduserid": task.assignedUserId,
        "servicereportuserid": null,
        "targetclosuredate": task.targetclosuredate,
        "clientdependencyyn": task.clientdependancyyn ?? "N",
      });
    }
    rawData["taskDetails"] = taskDetailsList;

    performRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (result) {
          try {
            if(result["statusCode"] == 1){
              onRequestSuccess();
            }else{
              onRequestFailure(AppException("Mobile : Internal Error"));
            }
          } catch (e) {
            onRequestFailure(AppException(
              "Error parsing user data: ${e.toString()}",
            ));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  void reassignEngineer({
    required int ticketId,
    required int assignedUsedId,
    required String lastModDate,
    String? targetClosureDate,
    required Function() onRequestSuccess,
    required Function(AppException p1) onRequestFailure}) async{
    String urlExtension = "ServiceCallTracker/reassignTicket";
    Map<String, dynamic> rawData = {};

    rawData["id"] = ticketId;
    rawData["assigneduserid"] = assignedUsedId;
    rawData["lastmoddate"] = lastModDate;
    if (targetClosureDate != null && targetClosureDate.isNotEmpty) {
      rawData["targetclosuredate"] = targetClosureDate;
    }

    performRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        doPassAppType: false,
        onRequestSuccess: (result) {
          try {
            if(result["statusCode"] == 1){
              onRequestSuccess();
            }else{
              onRequestFailure(AppException(result['statusMessage']));
            }
          } catch (e) {
            onRequestFailure(AppException(
              "Error parsing user data: ${e.toString()}",
            ));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  void updateClosureDate({
    required int ticketId,
    required String targetClosureDate,
    required String lastModDate,
    required Function() onRequestSuccess,
    required Function(AppException p1) onRequestFailure}) async {

    String urlExtension = "ServiceCallTracker/updateTargetClosureDate";
    Map<String, dynamic> rawData = {};

    rawData["id"] = ticketId;
    rawData["targetclosuredate"] = targetClosureDate;
    rawData["lastmoddate"] = lastModDate;

    performRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (result) {
          try {
            if(result["statusCode"] == 1){
              onRequestSuccess();
            }else{
              onRequestFailure(AppException(result['statusMessage']));
            }
          } catch (e) {
            onRequestFailure(AppException(
              "Error parsing user data: ${e.toString()}",
            ));
          }
        },
        onRequestFailure: onRequestFailure);

  }



}

