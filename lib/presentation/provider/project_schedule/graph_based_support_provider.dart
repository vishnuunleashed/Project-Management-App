
import 'package:base/core/loader_value.dart';
import 'package:interior_design/domain/usecase/project_details/project_details_usecase.dart';
import 'package:interior_design/domain/usecase/project_schedule/project_schedule_usecase.dart';
import 'package:interior_design/presentation/provider/common_support/base_all_support_provider.dart';

class GraphBasedSupportProvider extends BaseAllSupportProvider{

  String label = '';
  String supportType = '';
  @override
  void setNavigationParameters({required Map<String, dynamic> extra}){
    projectId = extra["projectId"];
    label = extra["label"];
    supportType = extra["type"];
    notifyListeners();
    fetchProjectDetails(projectId: projectId);
    fetchSupportRequestList(changeStart: true);
  }

  @override
  Future<void> fetchSupportRequestList({bool changeStart = false}) async {
    supportRequestFetched = false;
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    if(changeStart){
      supportRequestList = [];
      supStart = 0;
    }else{
      supportRequestFetched = true;
    }
    ProjectScheduleUseCase().fetchGraphBasedSupportRequestList(
        start: supStart,
        limit: supLimit,
        supportType: supportType,
        isCritical:isCritical,
        isAllSupport: isAllSupport,
        projectId: projectId,
        userId: userId,
        onRequestSuccess: (result){
          if (supStart == 0) {
            supportRequestList = result;
          } else {
            supportRequestList.addAll(result);
          }
          for (var item in supportRequestList) {
            fetchSingleImageAttachmentsDetailForGraph(fileName: item.logfromuserprofile??"");
          }
          supportRequestTotalRecords = result.isNotEmpty
              ? (result.first.totalRecords ?? 0)
              : supportRequestTotalRecords;


          hasMoreSupData = supportRequestList.length < supportRequestTotalRecords;

          supportRequestFetched = true;
          notifyListeners();

          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus: LoadingStatus(
                  loader: Loader.error,
                  exception: exception));
          supportRequestFetched = true;
          notifyListeners();

        });

    notifyListeners();
  }


  void fetchSingleImageAttachmentsDetailForGraph({
    required String fileName,
  }) {

    ProjectDetailsUseCase().fetchSingleImageAttachmentsDetail(
      fileName: fileName,
      isProfilePic: true,
      onRequestSuccess: (result) {
        for (int i = 0; i < supportRequestList.length; i++) {
          final item = supportRequestList[i];

          if (result.attachmentUrl.first.key ==
              item.logfromuserprofile.toString()) {
            supportRequestList[i] =
                item.copyWith(
                  logFromUserProfileUrl: result.attachmentUrl.first.url,
                );
            break;
          }
        }

        notifyListeners();
      },
      onRequestFailure: (exception) {
        changeLoadingStatus(
            loadingStatus: LoadingStatus(loader: Loader.error,exception: exception));
      },
    );


  }


}