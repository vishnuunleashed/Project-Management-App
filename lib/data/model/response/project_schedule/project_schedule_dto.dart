import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';
import 'package:interior_design/data/model/response/project_schedule/schedule_project_details.dart';

import 'my_schedule_response_model.dart';

// Root model response extending your base response model
class ProjectStatusHdrModel extends BaseResponseModel {
  List<ResultObjectModel> resultObject = [];

  ProjectStatusHdrModel.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    try {
      // resultObject is an array in the JSON
      final resultObjectData = json['resultObject'];

      if (resultObjectData != null) {
        if (resultObjectData is List) {
          resultObject = resultObjectData
              .where((e) => e is Map<String, dynamic>)
              .map((e) => ResultObjectModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (resultObjectData is Map<String, dynamic>) {
          // If it's a single object instead of array
          resultObject = [ResultObjectModel.fromJson(resultObjectData)];
        }
      }
    } catch (e) {
      print('Error parsing resultObject: $e');
      resultObject = [];
    }
  }
}

class ProjectStatusHdrModelMyTaskBased extends BaseResponseModel {
  MyTaskBasedDto? resultObject;

  ProjectStatusHdrModelMyTaskBased.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    try {
      final resultObjectData = json['resultObject'];

      if (resultObjectData != null && resultObjectData is Map<String, dynamic>) {
        resultObject = MyTaskBasedDto.fromJson(resultObjectData);
      }
    } catch (e) {
      print('Error parsing resultObject: $e');

    }
  }
}

class MyTaskBasedDto {
  bool isProjectLocked = false;
  List<TaskModel> schedule = [];
  List<MyScheduleModel> myScheduleList = [];
  ScheduleProjectDetails? scheduleProjectDetails;


  MyTaskBasedDto.fromJson(Map<String, dynamic> json) {
    try {

      // Parse from resultObject
      final tasksData = json['schedule']?["tasks"];
      isProjectLocked = json['schedule']?["isProjectLocked"] == true;
      if (tasksData != null && tasksData is List) {
        schedule = tasksData
            .where((e) => e is Map<String, dynamic>)
            .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
            .toList();
        myScheduleList = tasksData
            .where((e) => e is Map<String, dynamic>)
            .map((e) => MyScheduleModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      // Parse project details
      final projectDetailsData = json['projectDetails'];
      if (projectDetailsData != null && projectDetailsData is Map<String, dynamic>) {
        scheduleProjectDetails = ScheduleProjectDetails.fromJson(projectDetailsData);
      }

    } catch (e) {
      print('Error parsing ProjectResponseModel: $e');
    }
  }
}

class ResultObjectModel {
  bool isProjectLocked = false;
  List<TaskModel> tasks = [];
  ScheduleSummaryModel? scheduleSummary;
  ScheduleHealthModel? scheduleHealth;


  ResultObjectModel.fromJson(Map<String, dynamic> json) {
    try {
      isProjectLocked = json['isProjectLocked'] == true;

      // Parse tasks array
      final tasksData = json['tasks'];
      if (tasksData != null && tasksData is List) {
        tasks = tasksData
            .where((e) => e is Map<String, dynamic>)
            .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      // Parse schedule summary
      final summaryData = json['scheduleSummary'];
      if (summaryData != null && summaryData is Map<String, dynamic>) {
        scheduleSummary = ScheduleSummaryModel.fromJson(summaryData);
      }

      final scheduleHealthData = json['projectHealth'];
      if (scheduleHealthData != null && scheduleHealthData is Map<String, dynamic>) {
        scheduleHealth = ScheduleHealthModel.fromJson(scheduleHealthData);
      }
    } catch (e) {
      print('Error parsing ResultObjectModel: $e');
    }
  }
}

class TaskModel {
  int? id;
  int? taskId;
  String? name;
  int? duration;
  double? percentComplete;
  DateTime? plannedStart;
  DateTime? plannedFinish;
  int? statusid;
  List<int> predecessorTaskIds = [];
  String? uom;
  int? taskMasterID;
  String? color;
  String? statusText;
  String? statusDetails;
  List<TaskModel> children = [];
  bool isExpanded = false;




  TaskModel.fromJson(Map<String, dynamic> json) {
    try {
      id = _parseInt(json['id']);
      taskId = _parseInt(json['taskId']);
      name = json['name']?.toString();
      duration = _parseInt(json['duration']);
      percentComplete = _parseDouble(json['percentComplete']);
      plannedStart = _parseDateTime(json['plannedStart']);
      plannedFinish = _parseDateTime(json['plannedFinish']);
      statusid = _parseInt(json['statusid']);

      // Parse predecessorTaskIds - comes as string like "2,3,11" or ""
      final predecessorStr = json['predecessorTaskIds']?.toString() ?? '';
      if (predecessorStr.trim().isNotEmpty) {
        predecessorTaskIds = predecessorStr
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .map((s) => int.tryParse(s))
            .where((i) => i != null)
            .cast<int>()
            .toList();
      }

      uom = json['uom']?.toString();
      taskMasterID = _parseInt(json['taskMasterID']);
      color = json['color']?.toString();
      statusText = json['statusText']?.toString();
      statusDetails = json['statusDetails']?.toString();

      // Parse children recursively
      final childrenData = json['children'];
      if (childrenData != null && childrenData is List) {
        children = childrenData
            .where((e) => e is Map<String, dynamic>)
            .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Error parsing TaskModel: $e');
    }
  }

  // Helper methods for safe parsing
  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      return null;
    }
  }
}

class ScheduleSummaryModel {
  int? totalTasks;
  int? completedTasks;
  int? onTimeTasks;
  int? delayedTasks;
  int? inProgressTasks;
  int? notStartedTasks;
  int? criticalTasks;
  DateTime? projectStart;
  DateTime? projectFinish;
  double? percentComplete;
  double? scheduleVarianceDays;
  DateTime? forecastFinishDate;
  double? forecastVarianceDays;
  String? statusColor;
  String? statusText;
  double? spi;
  double? plannedProgress;

  ScheduleSummaryModel.fromJson(Map<String, dynamic> json) {
    totalTasks = BaseJsonParser.goodInt(json, 'totalTasks');
    completedTasks = BaseJsonParser.goodInt(json, 'completedTasks');
    onTimeTasks = BaseJsonParser.goodInt(json, 'onTimeTasks');
    delayedTasks = BaseJsonParser.goodInt(json, 'delayedTasks');
    inProgressTasks = BaseJsonParser.goodInt(json, 'inProgressTasks');
    notStartedTasks = BaseJsonParser.goodInt(json, 'notStartedTasks');
    criticalTasks = BaseJsonParser.goodInt(json, 'criticalTasks');
    projectStart = BaseJsonParser.goodDateTime(json, 'projectStart');
    projectFinish = BaseJsonParser.goodDateTime(json, 'projectFinish');
    percentComplete = BaseJsonParser.goodDouble(json, 'percentComplete');
    scheduleVarianceDays = BaseJsonParser.goodDouble(json, 'scheduleVarianceDays');
    forecastFinishDate = BaseJsonParser.goodDateTime(json, 'forecastFinishDate');
    forecastVarianceDays = BaseJsonParser.goodDouble(json, 'forecastVarianceDays');
    statusColor = BaseJsonParser.goodString(json, 'statusColor');
    statusText = BaseJsonParser.goodString(json, 'statusText');
    spi = BaseJsonParser.goodDouble(json, 'spi');
    plannedProgress = BaseJsonParser.goodDouble(json, 'plannedProgress');
  }
}
class ScheduleHealthModel {
    int color = 0xFF000000;
    String? status;
    String? statusText;

   ScheduleHealthModel.fromJson(Map<String, dynamic> json) {
     final rawColor = json['color']?.toString() ?? '';
      color = rawColor.isNotEmpty
          ? int.parse('FF${rawColor.replaceAll('#', '')}', radix: 16,)
         : 0xFF000000;
      status = BaseJsonParser.goodString(json, 'status');
      statusText = BaseJsonParser.goodString(json, 'statusText');

  }
}

