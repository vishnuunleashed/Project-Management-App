import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';


class UserListResponseModel extends BaseResponseModel {
  List<UserHierarchyModel> resultObject = [];

  UserListResponseModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    List? list = json['resultObject'];
    if (list != null) {
      for (var item in list) {
        resultObject.add(UserHierarchyModel.fromJson(item));
      }
    }
  }
}


class UserHierarchyModel {
  int? userId;
  String? userName;
  String? userProfileImage;
  int? reportingTo;
  int? to_docount;
  String? reportingToName;
  String? userProfileImageUrl;
  bool isExpanded = false;


  UserHierarchyModel(
      {this.userId,
      this.userName,
      this.userProfileImage,
      this.reportingTo,
      this.reportingToName,
      this.to_docount,
        this.isExpanded = false,
      this.userProfileImageUrl});

  UserHierarchyModel.fromJson(Map<String, dynamic> json) {
    userId = BaseJsonParser.goodInt(json, 'userid');
    to_docount = BaseJsonParser.goodInt(json, 'to_docount');
    userName = BaseJsonParser.goodString(json, 'username');
    userProfileImage =
        BaseJsonParser.goodString(json, 'userprofileimage');
    reportingTo = BaseJsonParser.goodInt(json, 'reportingto');
    reportingToName =
        BaseJsonParser.goodString(json, 'reportingtoname');
    userProfileImageUrl =
        BaseJsonParser.goodString(json, 'userprofileimageurl');
  }

  UserHierarchyModel copyWith({
    int? userId,
    String? userName,
    String? userProfileImage,
    int? reportingTo,
    int? to_docount,
    String? reportingToName,
    String? userProfileImageUrl,
    bool? isExpanded,
  }) {
    return UserHierarchyModel(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userProfileImage: userProfileImage ?? this.userProfileImage,
      reportingTo: reportingTo ?? this.reportingTo,
      to_docount: to_docount ?? this.to_docount,
      reportingToName: reportingToName ?? this.reportingToName,
      userProfileImageUrl: userProfileImageUrl ?? this.userProfileImageUrl,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}
