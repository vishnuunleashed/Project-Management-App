import 'package:base/core/loader_value.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:interior_design/data/model/response/project_schedule/activity_group_model.dart';
import 'package:interior_design/data/model/response/project_schedule/color_dto.dart';
import 'package:interior_design/domain/usecase/project_schedule/project_schedule_group_activity_usecase.dart';

class ProjectScheduleGroupActivityProvider extends BaseProvider {
  List<ActivityGroup> activityGroupList = [];
  List<StatusItem> activitySummaryColor = [];

  int projectId = 0;
  void initValues(Map<String, dynamic>? extra) {
    projectId  = extra!["projectId"]??0;
    fetchProjectScheduleGroupActivityColor();
    fetchActivityGroupData(projectId: projectId);
  }


  void fetchActivityGroupData({required int projectId}) {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ProjectScheduleGroupActivityUseCase().fetchProjectScheduleGroupActivityHealth(
      projectId: projectId,
      onRequestSuccess: (result) {
        activityGroupList = result ?? [];
        changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
      },
      onRequestFailure: (exception) {
        changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error, exception: exception));
      },
    );
  }

  void fetchProjectScheduleGroupActivityColor() {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ProjectScheduleGroupActivityUseCase().fetchProjectScheduleGroupActivityColor(
      onRequestSuccess: (result) {
        activitySummaryColor = result ?? [];

        changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
      },
      onRequestFailure: (exception) {
        changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error, exception: exception));
      },
    );
  }


  void clearData() {
    activityGroupList = [];
    notifyListeners();
  }

}
