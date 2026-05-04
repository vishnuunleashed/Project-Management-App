import 'package:base/data/repository/remote/base_repository.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:interior_design/data/model/response/project_schedule/activity_group_labour_model.dart';
import 'package:interior_design/data/model/response/project_schedule/activity_group_model.dart';
import 'package:interior_design/data/model/response/project_schedule/color_dto.dart';
import 'package:interior_design/data/model/response/project_schedule/labour_count_update_model.dart';
import 'package:interior_design/data/remote/repository/project_schedule/group_activity_impl.dart';

abstract class ProjectScheduleGroupActivityRepo extends BaseRepository{
  void fetchProjectScheduleGroupActivityData({
    required int projectId,
    required Function(List<ActivityGroupLabourModel>) onRequestSuccess,
    required Function(AppException) onRequestFailure,
  });

  void updateScheduleDataLabourCount({
    required GroupActivitySaveParams groupActivitySaveParams,
    required Function(List<LabourCountModel>) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
  });

  void fetchProjectScheduleGroupActivityHealth({
    required int projectId,
    required Function(List<ActivityGroup>?) onRequestSuccess,
    required Function(AppException) onRequestFailure,
  });

  Future<void> fetchProjectScheduleGroupActivityColor({
    required Function(List<StatusItem>?) onRequestSuccess,
    required Function(AppException) onRequestFailure,
  });

}