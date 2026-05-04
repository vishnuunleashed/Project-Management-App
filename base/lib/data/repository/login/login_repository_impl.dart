import 'dart:developer';
import 'package:base/data/models/login/login_model.dart';
import 'package:base/data/services/_connection_props.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:base/domain/repository/login_repository.dart';


class LoginRepositoryImpl extends LoginRepository {
  factory LoginRepositoryImpl() => _instance;
  static final LoginRepositoryImpl _instance = LoginRepositoryImpl._internal();
  LoginRepositoryImpl._internal();
  @override
  void authenticate({required String username,
    required String password,
    required Function(LoginWrapper) onRequestSuccess,
    required Function(AppException exception) onRequestFailure}) {
    String urlExtension = "Authentication/login";

    Map<String, dynamic> rawData = {};
    rawData["username"] = username;
    rawData["password"] = password;
    rawData["clientId"] = Connections().clientId;
    rawData["loginDate"] = DateTime.now().toIso8601String();

    performAuthenticateRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (result) {
          try {
            LoginWrapper authenticateResponse = LoginWrapper.fromJson(result);
            onRequestSuccess(authenticateResponse);
          } catch (e) {
            onRequestFailure(AppException(
              "Error parsing user data: ${e.toString()}",
            ));
          }
        },
        onRequestFailure: onRequestFailure);
  }

  @override
  void authenticateAutoLogin({required int userID,
    required String refreshToken,
    required Function(LoginWrapper) onRequestSuccess,
    required Function(AppException exception) onRequestFailure}) {
    String urlExtension = "Authentication/RefreshToken";

    Map<String, dynamic> rawData = {};
    rawData["userID"] = "$userID";
    rawData["refreshToken"] = "$refreshToken";
    rawData["clientId"] = Connections().clientId;

    performAuthenticateRequest(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (result) {
          try {
            if (result["statusCode"] != 0) {
              LoginWrapper authenticateResponse = LoginWrapper.fromJson(result);
              onRequestSuccess(authenticateResponse);
            } else {
              onRequestFailure(AppException(result['statusMessage']));
            }
          } catch (e) {
            onRequestFailure(AppException(
              "Error parsing user data: ${e.toString()}",
            ));
          }
        },
        onRequestFailure: onRequestFailure);
  }

}
