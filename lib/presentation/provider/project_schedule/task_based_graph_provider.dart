import 'dart:async';
import 'package:base/core/loader_value.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:interior_design/data/model/response/project_details/project_details_model.dart';
import 'package:interior_design/data/model/response/project_schedule/my_schedule_response_model.dart';
import 'package:interior_design/data/model/response/project_schedule/project_schedule_dto.dart';
import 'package:interior_design/domain/usecase/project_schedule/project_schedule_usecase.dart';
import 'package:interior_design/presentation/provider/project_schedule/project_schedule_provider.dart';
import 'package:interior_design/presentation/view/project_details/schedule_status_graphs_and_widgets/tasks_based_on_graph_screen.dart';

class TaskBasedGraphProvider extends ProjectScheduleProvider{
  int projectId = 0;
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
  GraphList status = GraphList.Empty;
  List<int> criticalTaskIds = [];
  int? userId;
  String label = '';
  String delayCategory = '';
  void initSubLevel(Map<String,dynamic> extra){
    status = extra["GraphList"];
    projectId = extra["projectId"];
    label = extra["label"]??"";
    if(extra["userId"] != null && extra["userId"] != ''){
      userId = int.parse(extra["userId"].toString());
    }
    if(extra["delayCategory"] != null){
      delayCategory = extra["delayCategory"];
    }
    taskStatusBased = [];
    searchResultTaskStatusBased = [];
    isSearching = false;
    taskStatusBased = [];
    searchStarted = false;
    searchQuery = "";
    fetchProjectDetails(projectId: projectId);
    fetchProjectScheduleDataGraphBased();
  }







  Future<void> fetchProjectScheduleDataGraphBased() async{
    saveExpandedState();
    final completer = Completer<void>();
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ProjectScheduleUseCase().fetchProjectScheduleDataGraphBased(
        projectId: projectId,
        status: status,
        userId: userId,
        label:(status ==GraphList.DaysDelayGraph)?delayCategory:label,
        onRequestSuccess: (result){
          if (result.first.tasks.isNotEmpty) {
            taskStatusBased = result.first.tasks ?? [];

            if (_expandedStateSnapshot.isNotEmpty) {
              // Restore previous expanded state
              restoreExpandedState(taskStatusBased);
            } else {
              // First load — expand root
              taskStatusBased.first.isExpanded = true;
            }

            notifyListeners();
          }
          isProjectLocked = result.first.isProjectLocked ?? false;
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.success));
          completer.complete();
        },
        onRequestFailure: (exception) {
          changeLoadingStatus(
              loadingStatus: LoadingStatus(loader: Loader.error, exception: exception));
          completer.complete();
        },
    );
    return completer.future;
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

  Map<int, bool> _expandedStateSnapshot = {};

  void saveExpandedState() {
    _expandedStateSnapshot = {};
    _captureExpandedState(taskStatusBased);
  }

  void _captureExpandedState(List<TaskModel> tasks) {
    for (final task in tasks) {
      if (task.id != null) {
        _expandedStateSnapshot[task.id!] = task.isExpanded;
      }
      if (task.children.isNotEmpty) {
        _captureExpandedState(task.children);
      }
    }
  }

  void restoreExpandedState(List<TaskModel> tasks) {
    for (final task in tasks) {
      if (task.id != null && _expandedStateSnapshot.containsKey(task.id!)) {
        task.isExpanded = _expandedStateSnapshot[task.id!]!;
      }
      if (task.children.isNotEmpty) {
        restoreExpandedState(task.children);
      }
    }
  }
  double _savedScrollOffset = 0.0;

  void saveScrollOffset(double offset) {
    _savedScrollOffset = offset;
  }

  double getSavedScrollOffset() => _savedScrollOffset;

}