import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/check_list/check_list_response_model.dart';
import 'package:interior_design/domain/repository/check_list/check_list_repository.dart';

class CheckListRepositoryImpl extends CheckListRepository {
  @override
  Future<void> fetchCheckList(
      {required int id,
      required int tableId,
      required Function(List<CheckListModel>) onRequestSuccess,
      required Function(AppException p1) onRequestFailure}) async {

    String urlExtension = "Checklist/getChecklistAndOptionsMappingList?";

    Map<String, dynamic> rawData = {};
    rawData["refid"] = id;
    rawData["reftableid"] = tableId;

    performGetRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (result) {
         CheckListResponseModel responseModel = CheckListResponseModel.fromJson(result);
         if(responseModel.statusCode == 1) {
           onRequestSuccess(responseModel.checkList);
         }
         else{
           onRequestFailure(AppException(responseModel.statusMessage ?? ""));
         }

        },
        onRequestFailure: onRequestFailure);
  }
}


