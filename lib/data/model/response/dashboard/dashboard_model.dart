
import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';

class DashboardModel extends BaseResponseModel {
  List<DashBoardDetail> dashBoardDetailList = [];

  DashboardModel.fromJson(Map<String, dynamic> json) : super.fromJson(json) {
    dashBoardDetailList = BaseJsonParser.goodList(json, 'resultObject')
        .map((e) => DashBoardDetail.fromJson(e))
        .toList();
  }
}

class DashBoardDetail {
  int? id;
  String? projectName;
  String? projectLocation;
  String? endDate;
  List<ProjectSummary>? summaryJson;
  List<ProjectDetail>? detailJson;

  DashBoardDetail({
    this.id,
    this.projectName,
    this.projectLocation,
    this.endDate,
    this.summaryJson,
    this.detailJson,
  });

  DashBoardDetail.fromJson(Map<String, dynamic> json) {
    id = BaseJsonParser.goodInt(json, 'id');
    projectName = BaseJsonParser.goodString(json, 'projectname');
    projectLocation = BaseJsonParser.goodString(json, 'projectlocation');
    endDate = BaseJsonParser.goodString(json, 'enddate');

    summaryJson = BaseJsonParser.goodList(json, 'summaryjson')
        .map((e) => ProjectSummary.fromJson(e))
        .toList();

    detailJson = BaseJsonParser.goodList(json, 'detailjson')
        .map((e) => ProjectDetail.fromJson(e))
        .toList();
  }
}

class ProjectSummary {
  int? delayedCount;
  int? pendingCount;
  int? closedCount;
  int? totalCount;

  ProjectSummary({
    this.delayedCount,
    this.pendingCount,
    this.closedCount,
    this.totalCount,
  });

  ProjectSummary.fromJson(Map<String, dynamic> json) {
    delayedCount = BaseJsonParser.goodInt(json, 'delayedcount')??0;
    pendingCount = BaseJsonParser.goodInt(json, 'pendingcount')??0;
    closedCount = BaseJsonParser.goodInt(json, 'closedcount')??0;
    totalCount = BaseJsonParser.goodInt(json, 'totalcount')??0;
  }
}

class ProjectDetail {
  String? name;
  String? code;
  String? userprofileurl;
  int? userId;
  ProjectDetailCounts? counts;

  ProjectDetail({this.name, this.counts});

  ProjectDetail.fromJson(Map<String, dynamic> json) {
    name = BaseJsonParser.goodString(json, 'username')?? BaseJsonParser.goodString(json, 'departmentname');
    userprofileurl = BaseJsonParser.goodString(json, 'userprofileurl');
    code = BaseJsonParser.goodString(json, 'usercode')?? BaseJsonParser.goodString(json, 'departmentcode');
    userId = BaseJsonParser.goodInt(json,'userid' ) ?? 0 ;
    counts = ProjectDetailCounts.fromJson(
      (json['counts'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class ProjectDetailCounts {
  int? pending;
  int? delayed;

  ProjectDetailCounts({this.pending, this.delayed});

  ProjectDetailCounts.fromJson(Map<String, dynamic> json) {
    pending = BaseJsonParser.goodInt(json, 'pending')??0;
    delayed = BaseJsonParser.goodInt(json, 'delayed')??0;
  }
}
