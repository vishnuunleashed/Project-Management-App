import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/check_list/check_list_response_model.dart';
import 'package:interior_design/data/remote/repository/check_list/check_list_repository_impl.dart';

class CheckListUseCase{
  void fetchCheckList(
      {required int refId,
        required int refTableId,
        required Function(List<CheckListModel>) onRequestSuccess,
        required Function(AppException exception) onRequestFailure}) {
    CheckListRepositoryImpl().fetchCheckList(
        id: refId,
        tableId: refTableId,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }
}