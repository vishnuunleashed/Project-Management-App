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
import 'package:interior_design/data/model/response/MOM/mom_list_model.dart';
import 'package:interior_design/domain/repository/MOM/mom_list_repository.dart';

class MOMListRepositoryImpl extends MOMListRepository{
  @override
  Future<void> fetchMOMList({
    required int projectId,
    required Function(List<MOMListModel>) onRequestSuccess,
    required Function(AppException exception) onRequestFailure})async {
    String urlExtension = "MoM/getMeetingList";
    Map<String, dynamic> rawData = {};
    rawData["projectId"] = projectId;

    performGetRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result){
          MOMListResponseModel response = MOMListResponseModel.fromJson(result);
          if(response.statusCode == 1){
            onRequestSuccess(response.momList);
          }
          else{
            onRequestFailure(AppException(response.statusMessage ?? ""));
          }
        },
        onRequestFailure: onRequestFailure);
  }

}