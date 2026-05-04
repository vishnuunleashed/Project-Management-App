import 'package:base/core/loader_value.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/data/model/response/project_schedule/activity_group_labour_model.dart';
import 'package:interior_design/data/remote/repository/project_schedule/group_activity_impl.dart';
import 'package:interior_design/domain/usecase/project_schedule/project_schedule_group_activity_usecase.dart';

class ProjectScheduleLabourCountProvider extends BaseProvider{
  int projectId = 0;
  final TextEditingController countController = TextEditingController();
  DateTime selectedLabourDate = DateTime.now();
  void initValues(Map<String, dynamic>? extra) {
    projectId  = extra!["projectId"];

    selectedLabourDate = DateTime.now();
    activityGroupLabourList = [];
    fetchProjectScheduleGroupActivityData(projectId: projectId);
    notifyListeners();
  }

  List<ActivityGroupLabourModel> activityGroupLabourList = [];
  void fetchProjectScheduleGroupActivityData({required int projectId}){
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
ProjectScheduleGroupActivityUseCase().fetchProjectScheduleGroupActivityData(
        projectId: projectId,
        onRequestSuccess: (result){
          activityGroupLabourList = result;

          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (e){
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error,exception: e));
        });
  }


  void updateScheduleDataLabourCount({required int activityGroupID, required Function() onSuccess, required Function(String message) onFailure}){
    String formattedDate =
        "${selectedLabourDate.year}-${selectedLabourDate.month.toString().padLeft(2, '0')}-${selectedLabourDate.day.toString().padLeft(2, '0')}";

    int count = int.tryParse(countController.text) ?? 0;
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ProjectScheduleGroupActivityUseCase().updateScheduleDataLabourCount(
        groupActivitySaveParams: GroupActivitySaveParams(
            projectID: projectId,
            activityGroupID: activityGroupID,
            labourDate: formattedDate,
            labourCount:count ),
        onRequestSuccess: (result){
          if(result.isNotEmpty){
            if(result.first.isUpdated == true){
              onSuccess();
            }
            else{
              onFailure(result.first.message??"");
            }
          }

          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));


          clearDialog();
        },
        onRequestFailure: (e){
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error,exception: e));
        });


  }

  void changeLabourDate(DateTime date){
    selectedLabourDate = date;
    notifyListeners();
  }

  void clearDialog(){
    selectedLabourDate = DateTime.now();
    countController.clear();
    notifyListeners();
  }
}