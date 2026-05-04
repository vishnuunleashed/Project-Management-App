import 'package:base/data/models/response/base_response_model.dart';
import 'package:base/data/services/utils/base_json_parser.dart';

class SignInStatusResponseModel extends BaseResponseModel {
  List<SignInResultObjectModel> signInStatusList = [];

  SignInStatusResponseModel.fromJson(Map<String, dynamic> json)
      : super.fromJson(json) {
    if(json["statusCode"] != 0) {
      signInStatusList.add(
          SignInResultObjectModel.fromJson(json['resultObject']));
    }
  }

}

class SignInResultObjectModel {
  int projectId = 0;
  bool isSignedIn = false;
  DateTime? signInTime;

  SignInResultObjectModel();

  SignInResultObjectModel.fromJson(Map<String, dynamic> json) {
    projectId = BaseJsonParser.goodInt(json, 'projectId') ?? 0;
    isSignedIn = BaseJsonParser.goodBoolean(json, 'isSignedIn') ?? false;

    String? timeString = BaseJsonParser.goodString(json, 'signInTime');
    if (timeString != null && timeString.isNotEmpty) {
      signInTime = DateTime.tryParse(timeString);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'isSignedIn': isSignedIn,
    };
  }
}