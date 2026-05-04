import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/call_tracker/call_tracker_model.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';
import 'package:interior_design/data/remote/repository/call_tracker/add_task_repository_impl.dart';

class AddTaskUseCase{
  // void fetchTaskDetails({
  //   required int ticketId, required Function(List<ServiceTaskModel>) onRequestSuccess,
  //   required Function(AppException) onRequestFailure}){
  //   AddTaskRepositoryImpl().fetchTaskDetails(
  //       ticketId: ticketId,
  //       onRequestSuccess: onRequestSuccess, onRequestFailure: onRequestFailure);
  // }

  void fetchWorkStatusOptions({
    required Function(List<CommonMasterModel>) onRequestSuccess,
    required Function(AppException) onRequestFailure
  }){
    AddTaskRepositoryImpl().fetchWorkStatusOptions(
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }
}