 import 'package:base/data/repository/remote/base_repository.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/request/call_tracker/new_service_add_model.dart';
import 'package:interior_design/data/model/response/call_tracker/location_address_dto.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/model/response/common/site_response_model.dart';

 abstract class AddServiceRequestRepository extends BaseRepository{
   void fetchClientLists(
       {required Function(List<CommonMasterModel>) onRequestSuccess,
         required Function(AppException exception) onRequestFailure});

   void fetchSiteLists(
       {required List<CommonMasterModel> clientList,
         required Function(List<SiteModel>) onRequestSuccess,
         required Function(AppException exception) onRequestFailure});


   void fetchCityLists(
       {required Function(List<CommonMasterModel>) onRequestSuccess,
         required Function(AppException exception) onRequestFailure});

   void fetchAllUserByDepartment(
       {
         required Function(List<CommonMasterModel>) onRequestSuccess,

         required Function(AppException exception) onRequestFailure});

   void fetchServiceCategory(
       {required Function(List<CommonMasterModel>) onRequestSuccess,
         required Function(AppException exception) onRequestFailure});

   void fetchServicePriority(
       {required Function(List<CommonMasterModel>) onRequestSuccess,
         required Function(AppException exception) onRequestFailure});

   void fetchUserByDepartment(
       {
         required String departmentCode,
         required Function(List<CommonMasterModel>) onRequestSuccess,
         required Function(AppException exception) onRequestFailure});

   void fetchLocationAddress(
       {
         required int clientId,
         required Function(List<LocationModelAddresses>) onRequestSuccess,
         required Function(AppException exception) onRequestFailure});

   void saveNewServiceRequest(
       {required TicketModel ticketModel,
         required Function() onRequestSuccess,
         required Function(AppException exception) onRequestFailure});

   void reassignEngineer({
     required int ticketId,
     required int assignedUsedId,
     required String lastModDate,
     String? targetClosureDate,
     required Function() onRequestSuccess,
     required Function(AppException) onRequestFailure
 });

   void updateClosureDate({
     required int ticketId,
     required String targetClosureDate,
     required String lastModDate,
     required Function() onRequestSuccess,
     required Function(AppException) onRequestFailure
   });
 }