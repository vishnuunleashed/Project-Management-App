import 'package:base/data_export.dart';
import 'package:interior_design/data/model/response/check_list/check_list_response_model.dart';

abstract class CheckListRepository extends BaseRepository{

  Future<void> fetchCheckList({
    required int id,
    required int tableId,
    required Function(List<CheckListModel>) onRequestSuccess,
    required Function(AppException) onRequestFailure,
});
}