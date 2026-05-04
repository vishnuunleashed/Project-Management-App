
import 'package:base/core/loader_value.dart' show LoadingStatus, Loader;
import 'package:base/presentation/provider/base_provider.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/data/model/response/dashboard/dashboard_model.dart';
import 'package:interior_design/data/model/response/project_schedule/project_schedule_dashboard_model.dart';
import 'package:interior_design/domain/usecase/graph_list/graph_list_usecase.dart';
import 'package:interior_design/presentation/provider/project_details/project_details_provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ProjectScheduleDashBoardProvider extends ProjectDetailsProvider{


  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  int initialTabIndex = 0;
  var tabTapInProgress = false;
  late TabController tabController;
  ScrollController scrollController = ScrollController();



  List<ProjectData> projectScheduleDashBoardList = [];

  List<ProjectProgress> projectProgressJson = [];
  List<DelayTaskByDays> delayTaskInDaysJson = [];
  List<DelayTaskByUser> delayTaskUserJson = [];
  List<CompleteTaskByUser> completeTaskUserJson = [];
  List<SupportRequestOverDelay> supprtReqOverDelay = [];
  List<ActivityGroupModel> activityGroup = [];

  void childInitState({Map<String,dynamic>? extra, int? projectId}) {
    final effectiveProjectId = projectId ?? extra?["projectId"] ?? 0;
    if (effectiveProjectId != 0) {
      setProjectId(projectId: effectiveProjectId);
      fetchDashBoardWithGraph();
    }
  }



  bool allGraphsEmpty = false;
  void fetchDashBoardWithGraph(){
    changeLoadingStatus(
        loadingStatus: LoadingStatus(loader: Loader.loading, ));
    GraphListUseCase().fetchDashBoardWithGraph(
        projectId: projectId,
        onRequestSuccess: (result){
          projectScheduleDashBoardList = result;
          projectProgressJson = result.first.projectProgressJson??[];
          delayTaskInDaysJson = result.first.delayTaskInDaysJson??[];
          delayTaskUserJson = result.first.delayTaskUserJson??[];
          completeTaskUserJson = result.first.completeTaskUserJson??[];
          supprtReqOverDelay = result.first.supprtReqOverDelay??[];
          activityGroup = result.first.activityGroupModel??[];

          allGraphsEmpty =
              projectProgressJson.isEmpty &&
                  delayTaskInDaysJson.isEmpty &&
                  delayTaskUserJson.isEmpty &&
                  supprtReqOverDelay.isEmpty &&
                  activityGroup.isEmpty &&
                  completeTaskUserJson.isEmpty;



          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception) {
        changeLoadingStatus(
          loadingStatus: LoadingStatus(loader: Loader.error, exception: exception));
    });
  }




}