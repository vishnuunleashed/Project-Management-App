import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/request/call_tracker/new_service_add_model.dart';
import 'package:interior_design/data/model/response/call_tracker/location_address_dto.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/remote/repository/call_tracker/add_service_request_impl.dart';

class AddServiceRequestUsecase {
  void fetchClientLists(
      {required Function(List<CommonMasterModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}){
    AddServiceRequestImpl().fetchClientLists(
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }
  void fetchCityLists(
      {required Function(List<CommonMasterModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}){
    AddServiceRequestImpl().fetchCityLists(
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void fetchServiceCategory(
      {required Function(List<CommonMasterModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}){
    AddServiceRequestImpl().fetchServiceCategory(
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void fetchServicePriority(
      {required Function(List<CommonMasterModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}){
    AddServiceRequestImpl().fetchServicePriority(
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void fetchUserByDepartment(
      {required String departmentCode,
        required Function(List<CommonMasterModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}){
    AddServiceRequestImpl().fetchUserByDepartment(
        departmentCode: departmentCode,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }
  void fetchAllUserByDepartment(
      {
        required Function(List<CommonMasterModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}){
    AddServiceRequestImpl().fetchAllUserByDepartment(

        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void fetchLocationAddress(
      {
        required int clientId,
        required Function(List<LocationModelAddresses>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}){
    AddServiceRequestImpl().fetchLocationAddress(
        clientId: clientId,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void saveNewServiceRequest(
      {required TicketModel ticketModel,
        required Function() onRequestSuccess,
        required Function(AppException exception) onRequestFailure}){
    AddServiceRequestImpl().saveNewServiceRequest(
        ticketModel: ticketModel,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void reassignEngineer({
    required int ticketId,
    required int assignedUsedId,
    required String lastModDate,
    String? targetClosureDate,
    required Function() onRequestSuccess,
    required Function(AppException p1) onRequestFailure
}) async {
    AddServiceRequestImpl().reassignEngineer(
        ticketId: ticketId,
        assignedUsedId: assignedUsedId,
        lastModDate: lastModDate,
        targetClosureDate: targetClosureDate,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void updateClosureDate({
    required int ticketId,
    required String targetClosureDate,
    required String lastModDate,
    required Function() onRequestSuccess,
    required Function(AppException p1) onRequestFailure}) async {
    AddServiceRequestImpl().updateClosureDate(
        ticketId: ticketId,
        targetClosureDate: targetClosureDate,
        lastModDate: lastModDate,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }
}
