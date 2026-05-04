import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/call_tracker/call_tracker_model.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/domain/repository/call_tracker/add_task_repository.dart';

class AddTaskRepositoryImpl extends AddTaskRepository{
  // @override
  // Future<void> fetchTaskDetails({
  //   required int ticketId, required Function(List<ServiceTaskModel>) onRequestSuccess,
  //   required Function(AppException) onRequestFailure}) async {
  //
  //   const String urlExtension = "ServiceCallTracker/getTaskDetails?";
  //   final Map<String, dynamic> rawData = {};
  //
  //   rawData["ticketId"] = ticketId;
  //
  //   performGetRequest(
  //       rawData: rawData,
  //       urlExtension: urlExtension,
  //       onRequestSuccess: (result) {
  //         ServiceTasksHdrModel response = ServiceTasksHdrModel.fromJson(result);
  //         if(response.statusCode == 1){
  //           onRequestSuccess(response.tasks);
  //         }
  //         else{
  //           onRequestFailure(AppException(response.statusMessage ?? ""));
  //         }
  //
  //       },
  //       onRequestFailure: onRequestFailure);
  //
  // }
  @override
  Future<void> fetchWorkStatusOptions({
    required Function(List<CommonMasterModel>) onRequestSuccess,
    required Function(AppException) onRequestFailure
  })async{
    const String urlExtension = "lookup/GetCommonMasterByType?";
    final Map<String, dynamic> rawData = {};
    rawData["type"] = "SERV_TASK_WORK_STAT";
    performGetRequest(
        rawData: rawData,
        urlExtension: urlExtension,
        onRequestSuccess: (result) {
          CommonMasterResponseModel response = CommonMasterResponseModel.fromJson(result);
          if (response.statusCode == 1) {
            onRequestSuccess(response.resultObject);
          } else {
            onRequestFailure(AppException(response.statusMessage??""));
          }

        },
        onRequestFailure: onRequestFailure);
  }


}