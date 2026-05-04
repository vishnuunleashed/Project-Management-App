/*------------------------------------------------------------------------------
AUTHOR		    : Shamnas Abdulla
CREATED DATE	: 04/16/2026
PURPOSE		    :
MODULE/TOPIC	:
REMARKS		    : MOM option
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		    MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------
------------------------------------------------------------------------------*/
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/request/MOM/mom_save_model.dart';
import 'package:interior_design/data/model/response/MOM/mom_list_model.dart';
import 'package:interior_design/data/model/response/add_observation/add_observation_model.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/model/response/project_details/support_request_model.dart';
import 'package:interior_design/data/remote/repository/MOM/add_mom_repository_impl.dart';
import 'package:interior_design/data/remote/repository/add_observation/add_observation_repository_impl.dart';

class AddMOMUseCase{
//For fetching owners
  void fetchOwners(
      {required int projectId,
        required Function(List<OwnerModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}){
    AddObservationRepositoryImpl().fetchOwners(
        projectId: projectId,
        excludeLoginUser: false,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void saveMOM({required MOMSaveModel momSaveModel,
    required Function({required int momHdrId}) onRequestSuccess,
    required Function(AppException) onRequestFailure}){
    AddMOMRepositoryImpl().saveMOM(
        momSaveModel: momSaveModel,
        onRequestSuccess: onRequestSuccess, onRequestFailure: onRequestFailure);

  }

  void  fetchMeetingTypes(
      {required Function(List<CommonMasterModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}){
    AddMOMRepositoryImpl().fetchMeetingTypes(onRequestSuccess: onRequestSuccess, onRequestFailure: onRequestFailure);
  }

  void fetchEditModeMOMData({
    required int momId,
    required Function(List<MOMListModel> p1) onRequestSuccess,
    required Function(AppException exception) onRequestFailure}){
    AddMOMRepositoryImpl().fetchEditModeMOMData(
        momId: momId,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  void sendMOMEmail(
      {required int momId,
        required Function() onRequestSuccess,
        required Function(AppException exception) onRequestFailure}) {
    AddMOMRepositoryImpl().sendMOMEmail(
        momId: momId,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

  Future<void> fetchMOMBasedSupportRequests(
      {required int actionItemId,
        required int start,
        required int limit,
        required Function(List<SupportRequestDtlModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}) async{
    AddMOMRepositoryImpl().fetchMOMBasedSupportRequests(
        actionItemId: actionItemId,
        start: start,
        limit: limit,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }
}