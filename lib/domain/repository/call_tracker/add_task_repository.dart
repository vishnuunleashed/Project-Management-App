import 'package:base/data/repository/remote/base_repository.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/call_tracker/call_tracker_model.dart';
import 'package:interior_design/data/model/response/common/common_master_dto.dart';

abstract class AddTaskRepository extends BaseRepository{
  // Future<void> fetchTaskDetails({
  //   required int ticketId,
  //   required Function(List<ServiceTaskModel>) onRequestSuccess,
  //   required Function(AppException) onRequestFailure
  // });

  Future<void> fetchWorkStatusOptions({
    required Function(List<CommonMasterModel>) onRequestSuccess,
    required Function(AppException) onRequestFailure
  });

}