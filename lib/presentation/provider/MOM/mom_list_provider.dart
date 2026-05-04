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
import 'package:base/core/loader_value.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:interior_design/data/model/response/MOM/mom_list_model.dart';
import 'package:interior_design/domain/usecase/MOM/mom_list_usecase.dart';

class MOMListProvider extends BaseProvider {
  int? projectId;
  List<MOMListModel> momList = [];

  void initValues(){
    momList = [];
    notifyListeners();
  }

  Future<void> setNavigationParameter(Map<String, dynamic>? extra) async {
    if (extra != null) {
      projectId = extra['projectId'];
      fetchMOMList();
    }
  }

  Future<void> fetchMOMList() async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    MOMListUseCase().fetchMOMList(
        projectId: projectId ?? 0,
        onRequestSuccess: (result) {
          momList = result;
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (e) {
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.error, exception: e));
        });
  }
}
