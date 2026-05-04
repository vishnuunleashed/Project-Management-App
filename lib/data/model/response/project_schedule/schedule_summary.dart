import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';

class ProjectScheduleSummaryModel extends BaseResponseModel {
  List<SummaryModel> resultObject = [];

  ProjectScheduleSummaryModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    resultObject = BaseJsonParser.goodList(json, 'resultObject')
        .map((e) => SummaryModel.fromJson(e))
        .toList();
  }
}


class SummaryModel {
  DateTime? projectStart;
  DateTime? projectFinish;
  DateTime? forecastFinishDate;
  String? forecastP50;
  String? forecastP70;
  String? forecastP90;

  int forecastVarianceDays = 0;
  double percentComplete = 0;
  double plannedProgress = 0;
  double spi = 0;

  String? riskLevel;
  int confidenceScore = 0;

  int totalTasks = 0;
  int completedTasks = 0;
  int delayedTasks = 0;
  int onTimeTasks = 0;
  int inProgressTasks = 0;
  int notStartedTasks = 0;
  int criticalTasks = 0;

  String? status;
  String? statusColor;
  String? statusText;
  String? notes;
  List<int> criticalTaskIds = [];

  SummaryModel.fromJson(Map<String, dynamic> json) {
    projectStart = BaseJsonParser.goodDateTime(json, 'projectStart');
    projectFinish = BaseJsonParser.goodDateTime(json, 'projectFinish');
    forecastFinishDate =
        BaseJsonParser.goodDateTime(json, 'forecastFinishDate');
    forecastP50 = BaseJsonParser.goodString(json, 'forecastP50');
    forecastP70 = BaseJsonParser.goodString(json, 'forecastP70');
    forecastP90 = BaseJsonParser.goodString(json, 'forecastP90');

    forecastVarianceDays =
        BaseJsonParser.goodInt(json, 'forecastVarianceDays')??0;
    percentComplete =
        BaseJsonParser.goodDouble(json, 'percentComplete')??0;
    plannedProgress =
        BaseJsonParser.goodDouble(json, 'plannedProgress')??0;
    spi = BaseJsonParser.goodDouble(json, 'spi')??0;

    riskLevel = BaseJsonParser.goodString(json, 'riskLevel')??"";
    confidenceScore =
        BaseJsonParser.goodInt(json, 'confidenceScore')??0;

    totalTasks = BaseJsonParser.goodInt(json, 'totalTasks')??0;
    completedTasks = BaseJsonParser.goodInt(json, 'completedTasks')??0;
    delayedTasks = BaseJsonParser.goodInt(json, 'delayedTasks')??0;
    onTimeTasks = BaseJsonParser.goodInt(json, 'onTimeTasks')??0;
    inProgressTasks = BaseJsonParser.goodInt(json, 'inProgressTasks')??0;
    notStartedTasks = BaseJsonParser.goodInt(json, 'notStartedTasks')??0;
    criticalTasks = BaseJsonParser.goodInt(json, 'criticalTasks')??0;
    status = BaseJsonParser.goodString(json, 'status');
    statusColor = BaseJsonParser.goodString(json, 'statusColor')??"";
    statusText = BaseJsonParser.goodString(json, 'statusText');
    notes = BaseJsonParser.goodString(json, 'notes');
    criticalTaskIds = BaseJsonParser.goodList(json, 'criticalTaskIds')
        .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
        .toList();
  }
}
