
import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';

class CountUpdateDto extends BaseResponseModel{
  List<ProjectStats> resultObject = [];

  CountUpdateDto.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    resultObject = BaseJsonParser.goodList(json, 'resultObject').map((e) => ProjectStats.fromJson(e)).toList();
  }
}

class ProjectStats {
  final int projectid;
  final int userid;
  final int pendingobservation;
  final int pendingsupportreq;

  ProjectStats({
    required this.projectid,
    required this.userid,
    required this.pendingobservation,
    required this.pendingsupportreq,
  });

  factory ProjectStats.fromJson(Map<String, dynamic> json) {
    return ProjectStats(
      projectid: json['projectid'],
      userid: json['userid'],
      pendingobservation: json['pendingobservation'],
      pendingsupportreq: json['pendingsupportreq'],
    );
  }
}