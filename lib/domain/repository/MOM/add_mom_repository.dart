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
import 'package:base/data/repository/remote/base_repository.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/request/MOM/mom_save_model.dart';
import 'package:interior_design/data/model/response/MOM/mom_list_model.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/model/response/project_details/support_request_model.dart';

abstract class AddMOMRepository extends BaseRepository{
  Future<void> saveMOM({
    required MOMSaveModel momSaveModel,
    required Function({required int momHdrId}) onRequestSuccess,
    required Function(AppException) onRequestFailure
});

  Future<void>  fetchMeetingTypes(
      {required Function(List<CommonMasterModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure});

  Future<void>  fetchEditModeMOMData(
      {required int momId,
        required Function(List<MOMListModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure});

  Future<void>  sendMOMEmail(
      {required int momId,
        required Function() onRequestSuccess,
        required Function(AppException exception) onRequestFailure});

  Future<void> fetchMOMBasedSupportRequests(
      {required int actionItemId,
        required int start,
        required int limit,
        required Function(List<SupportRequestDtlModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure});


}