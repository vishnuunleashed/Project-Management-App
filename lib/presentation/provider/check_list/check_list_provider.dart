import 'package:base/core/loader_value.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:interior_design/data/model/response/check_list/check_list_response_model.dart';
import 'package:interior_design/domain/usecase/check_list/check_list_usecase.dart';

class CheckListProvider extends BaseProvider{
  List<CheckListModel> checkLists = [];
  void fetchCheckList({required int refId, required int refTableId}) {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));

    CheckListUseCase().fetchCheckList(
        refId: refId,
        refTableId: refTableId,
        onRequestSuccess: (result) {
          checkLists = result;
          notifyListeners();
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus:
              LoadingStatus(loader: Loader.error, exception: exception));
        });
  }
}
