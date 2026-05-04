/*------------------------------------------------------------------------------
AUTHOR		    : Brenta Roy
CREATED DATE	: 13/08/2025
PURPOSE		    :
MODULE/TOPIC	: AddSupportRequestRepository
REMARKS		    :
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------*/
import 'package:base/data/repository/remote/base_repository.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/request/add_support_request/add_support_request_model.dart';
import 'package:interior_design/data/model/response/add_support_request/add_support_request_dept_model.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';

abstract class AddSupportRequestRepository extends BaseRepository {

  //For fetching department dropdown
  void fetchDepartmentDropDown({
    required Function(List<DepartmentDropDownObj> departmentList)
    onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  });

  //Save
  void addSupportRequest({
    required  AddSupportRequestModel addSuppReqModel,
    required Function({required String transNo})  onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  });

  Future<void> editSupportRequest({
    required AddSupportRequestModel addSuppReqModel,
    required Function({required String transNo}) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  });

  void getMaterialSupportType(
      {required Function(List<CommonMasterModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure});

  void getCallTrackerType(
      {required Function(List<CommonMasterModel>) onRequestSuccess,
        required Function(AppException) onRequestFailure});


}