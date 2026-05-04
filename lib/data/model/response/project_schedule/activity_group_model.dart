import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';

class ActivityGroupResponseModel extends BaseResponseModel {
  List<ActivityGroup> activityGroupList = [];

  ActivityGroupResponseModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    // resultObject is List<List<dynamic>> in the provided JSON
    final outerList = BaseJsonParser.goodList(json, 'resultObject');
    if (outerList.isNotEmpty && outerList.first is List) {
      activityGroupList = (outerList.first as List)
          .map((e) => ActivityGroup.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }
}

class ActivityGroup {
  int? activityGroupId;
  String? activityGroupName;
  String? activityGroupCode;
  double? score;
  String? status;
  String? statusColor;
  List<String> reasons = [];
  int totalTasks = 0;
  int delayedTasks = 0;
  int blockedTasks = 0;
  int completedLateTasks = 0;
  int causingDelayTasks = 0;
  int shouldHaveStartedTasks = 0;
  int behindScheduleTasks = 0;

  ActivityGroup({
    this.activityGroupId,
    this.activityGroupName,
    this.activityGroupCode,
    this.score,
    this.status,
    this.statusColor,
    this.reasons = const [],
    this.totalTasks = 0,
    this.delayedTasks = 0,
    this.blockedTasks = 0,
    this.completedLateTasks = 0,
    this.causingDelayTasks = 0,
    this.shouldHaveStartedTasks = 0,
    this.behindScheduleTasks = 0,
  });

  ActivityGroup.fromJson(Map<String, dynamic> json) {
    activityGroupId = BaseJsonParser.goodInt(json, 'activityGroupId');
    activityGroupName = BaseJsonParser.goodString(json, 'activityGroupName');
    activityGroupCode = BaseJsonParser.goodString(json, 'activityGroupCode');
    score = BaseJsonParser.goodDouble(json, 'score');
    status = BaseJsonParser.goodString(json, 'status');
    statusColor = json['statusColor']?.toString();
    reasons = BaseJsonParser.goodList(json, 'reasons').cast<String>();
    totalTasks = BaseJsonParser.goodInt(json, 'totalTasks') ?? 0;
    delayedTasks = BaseJsonParser.goodInt(json, 'delayedTasks') ?? 0;
    blockedTasks = BaseJsonParser.goodInt(json, 'blockedTasks') ?? 0;
    completedLateTasks = BaseJsonParser.goodInt(json, 'completedLateTasks') ?? 0;
    causingDelayTasks = BaseJsonParser.goodInt(json, 'causingDelayTasks') ?? 0;
    shouldHaveStartedTasks = BaseJsonParser.goodInt(json, 'shouldHaveStartedTasks') ?? 0;
    behindScheduleTasks = BaseJsonParser.goodInt(json, 'behindScheduleTasks') ?? 0;
  }
}
