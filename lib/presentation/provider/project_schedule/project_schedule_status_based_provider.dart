import 'package:base/core/loader_value.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:interior_design/data/model/response/project_details/project_details_model.dart';
import 'package:interior_design/data/model/response/project_schedule/my_schedule_response_model.dart';
import 'package:interior_design/data/model/response/project_schedule/project_schedule_dto.dart';
import 'package:interior_design/domain/usecase/project_schedule/project_schedule_usecase.dart';
import 'package:interior_design/presentation/provider/project_schedule/project_schedule_provider.dart';
import 'package:interior_design/presentation/view/project_schedule/project_schedule_status_page.dart';

class ProjectTasksStatusBased extends ProjectScheduleProvider{

  List<MyScheduleModel> searchResultTaskStatusBased = [];


  // Update search query and perform search
  @override
  void updateSearchQuery(String query) {

    searchQuery = query;
    if (query.isEmpty) {
      searchResultsOfMyTask = [];
      searchResultTaskStatusBased = [];
      searchStarted = false;
    } else {
      searchStarted = true;
      _performSearch(query);
    }

    notifyListeners();
  }



  // Perform search based on current tab
  void _performSearch(String query) {
    final lowerQuery = query.toLowerCase();
    // Search in All Tasks (now MyScheduleModel list)
    final flatTasks = _flattenTasks(taskStatusBased); // MyScheduleModel list

    searchResultTaskStatusBased = flatTasks.where((task) {
        final taskName = task.name?.toLowerCase() ?? '';
        return taskName.contains(lowerQuery);
    }).toList();
  }

  List<MyScheduleModel> _flattenTasks(List<TaskModel> tasks) {
    List<MyScheduleModel> result = [];
    void extract(TaskModel task) {
      if (task.children.isEmpty) {
        // Leaf node
        result.add(_convertTaskToMySchedule(task));
      } else {
        // Continue recursively
        for (var child in task.children) {
          extract(child);
        }
      }
    }

    for (var task in tasks) {
      extract(task);
    }

    return result;
  }

  // Convert TaskModel → MyScheduleModel
  MyScheduleModel _convertTaskToMySchedule(TaskModel task) {
    return MyScheduleModel(
      id: task.id,
      name: task.name,
      color: task.color,
    );
  }

  List<TaskModel> taskStatusBased = [];
  ProjectStatus status = ProjectStatus.Empty;
  List<int> criticalTaskIds = [];
  int? activityGroupId;
  String? type;

  void initSubLevel(Map<String, dynamic> extra) {
    status = extra["ProjectStatus"];
    projectId = extra["projectId"];
    activityGroupId = extra["activityGroupId"];
    type = extra["type"];
    taskStatusBased = [];
    searchResultTaskStatusBased = [];
    isSearching = false;
    searchStarted = false;
    searchQuery = "";
    if (status == ProjectStatus.CriticalPath) {
      criticalTaskIds = extra["criticalTaskIds"] ?? [];
    }
    fetchProjectDetails(projectId: projectId);
    fetchProjectScheduleDataStatusBased();
  }

  void fetchProjectScheduleDataStatusBased() {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ProjectScheduleUseCase().fetchProjectScheduleDataStatusBased(
        projectId: projectId,
        status: status,
        criticalTaskIds: criticalTaskIds,
        activityGroupId: activityGroupId,
        type: type,
        onRequestSuccess: (result) {
          if (result.first.tasks.isNotEmpty) {
            taskStatusBased = result.first.tasks ?? [];
            taskStatusBased.first.isExpanded = true;
            notifyListeners();
          }
          isProjectLocked = result.first.isProjectLocked ?? false;
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.success));
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.error, exception: exception));
        });
  }

  @override
  void expandAndCollapseTask({
    required TaskModel task,
  }) {
    _toggleExpansion(taskStatusBased, task.id!);
    notifyListeners();
  }

  bool _toggleExpansion(List<TaskModel> list, int taskId) {
    for (final item in list) {
      if (item.id == taskId) {
        item.isExpanded = !item.isExpanded;
        return true; // found the task
      }

      if (item.children.isNotEmpty) {
        final found = _toggleExpansion(item.children, taskId);
        if (found) return true;
      }
    }
    return false; // not found in this branch
  }





}