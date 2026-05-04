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
import 'package:interior_design/data/remote/repository/MOM/add_mom_repository_impl.dart';
import 'package:interior_design/data/remote/repository/MOM/mom_list_repository_impl.dart';
import 'package:interior_design/data/remote/repository/add_observation/add_observation_repository_impl.dart';

class MOMListUseCase{
  Future<void> fetchMOMList(
      { required int projectId,
        required Function(List<MOMListModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}) async{
    MOMListRepositoryImpl().fetchMOMList(
      projectId: projectId,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }
}