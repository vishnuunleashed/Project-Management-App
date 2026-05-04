
import 'dart:convert';

/// Base class for http response model
class BaseResponseModel {
   int? statusCode;
  String? statusMessage;
   bool result = false;

 BaseResponseModel();
  BaseResponseModel.fromJson(Map<String, dynamic> parsedJson) {
    statusCode = parsedJson['statusCode'] ?? 0;
    statusMessage = parsedJson['statusMessage'] ?? '';
    result = parsedJson.containsKey("resultObject") &&
        parsedJson["resultObject"] != null;
  }

  Map toMap() {
    Map map = Map<String, dynamic>();
    map["statusCode"] = statusCode;
    map["_statusMessage"] = statusMessage;
    return map;
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
/// Base class for http response model
class BaseResponseLoginModel {
   int? statusCode;
   String? statusMessage;
   List<dynamic> resultObject= [];
   bool result = false;
   String token = "";
   String expiration ="";
   String refreshToken ="";
   int userID = 0;
   String userName  = "";
   String loginName  = "";
   String? operatingCurrencyId;

   BaseResponseLoginModel();
   BaseResponseLoginModel.fromJson(Map<String, dynamic> parsedJson) {
    result = parsedJson.containsKey("resultObject") &&
        parsedJson["resultObject"] != null;
    resultObject = jsonDecode(parsedJson["resultObject"]);
    statusCode = parsedJson["statusCode"] ?? 0;
    statusMessage = parsedJson["statusMessage"] ?? "";
    token = parsedJson["token"] ?? "";
    expiration = parsedJson["expiration"] ?? "";
    refreshToken = parsedJson["refreshToken"] ?? "";
    userID = parsedJson["userID"];
    userName = parsedJson["userName"] ?? "";
    loginName = parsedJson["loginName"] ?? "";
    operatingCurrencyId = parsedJson["operatingCurrencyId"];

  }

  // Map toMap() {
  //   Map map = Map<String, dynamic>();
  //   map["statusCode"] = statusCode;
  //   map["_statusMessage"] = statusMessage;
  //   return map;
  // }

  // @override
  // String toString() {
  //   return toMap().toString();
  // }
}
