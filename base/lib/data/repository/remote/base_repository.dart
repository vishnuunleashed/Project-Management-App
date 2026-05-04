import 'dart:io';

import 'package:base/core/constants.dart';
import 'package:base/data/models/request/post_model.dart';
import 'package:base/data/repository/helpers/http_request_helper.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/data/repository/login/login_repository_impl.dart';
import 'package:base/data/services/settings.dart';
import 'package:base/data/services/utils/app_exceptions.dart';

/// Repository class that requires network calls can extend this.
class BaseRepository {

  void performRequest({
    required Map<String, dynamic> rawData,
    required String urlExtension,
    bool doPassAppType = true,
    required Function(Map<String, dynamic>) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
    bool isSsnIdRequired = true
  }) async {

    Map<String, dynamic> baseParams = {};
    if (doPassAppType) {
      baseParams["appType"] = "USER_APP_MOBILE";
      baseParams["ostype"] = "android";
    }

    Post body = Post(
      rawData: {...rawData, ...baseParams},
      urlExtension: urlExtension,
    );

    Future<void> _retry() async {
      HttpRequestHelper(
        urlExtension: urlExtension,
        requestParams: body.toMap(),
        onRequestFailure: onRequestFailure,
        onRequestSuccess: onRequestSuccess,
        unauthorizedAccess: (e) async => await _handleUnauthorized(
            retry: _retry,
            onRequestFailure: onRequestFailure
        ),
      ).post();
    }

    try {
      await _retry();
    } catch (e) {
      onRequestFailure(FetchDataException());
    }
  }
  void performRequestWithStringInput({
    required String rawData,
    required String urlExtension,
    bool doPassAppType = true,
    required Function(Map<String, dynamic>) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
    bool isSsnIdRequired = true
  }) async {

    Map<String, dynamic> baseParams = {};
    if (doPassAppType) {
      baseParams["appType"] = "USER_APP_MOBILE";
      baseParams["ostype"] = "android";
    }



    Future<void> _retry() async {
      HttpRequestHelper(
        urlExtension: urlExtension,
        stringParams: rawData,
        requestParams: {},
        onRequestFailure: onRequestFailure,
        onRequestSuccess: onRequestSuccess,
        unauthorizedAccess: (e) async => await _handleUnauthorized(
            retry: _retry,
            onRequestFailure: onRequestFailure
        ),
      ).postWithStringInput();
    }

    try {
      await _retry();
    } catch (e) {
      onRequestFailure(FetchDataException());
    }
  }
  void performRequestWithStringBody({
    required String rawData,
    required String urlExtension,
    bool doPassAppType = true,
    required Function(Map<String, dynamic>) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
    bool isSsnIdRequired = true
  }) async {

    Future<void> _retry() async {
      HttpRequestHelper(
        urlExtension: urlExtension,
        stringParams: rawData,
        requestParams: {},
        onRequestFailure: onRequestFailure,
        onRequestSuccess: onRequestSuccess,
        unauthorizedAccess: (e) async => await _handleUnauthorized(
            retry: _retry,
            onRequestFailure: onRequestFailure
        ),
      ).postWithStringParams();
    }

    try {
      await _retry();
    } catch (e) {
      onRequestFailure(FetchDataException());
    }
  }

  void performGetRequest({
    required Map<String, dynamic> rawData,
    required String urlExtension,
    bool doPassAppType = true,
    required Function(Map<String, dynamic>) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
    bool isSsnIdRequired = true
  }) async {

    Map<String, dynamic> baseParams = {};
    if (doPassAppType) {
      baseParams["appType"] = "USER_APP_MOBILE";
    }

    Post body = Post(
      rawData: {...rawData, ...baseParams},
      urlExtension: urlExtension,
    );

    Future<void> _retry() async {
      HttpRequestHelper(
        urlExtension: urlExtension,
        requestParams: body.toMap(),
        onRequestFailure: onRequestFailure,
        onRequestSuccess: onRequestSuccess,
        unauthorizedAccess: (e) async => await _handleUnauthorized(
            retry: _retry,
            onRequestFailure: onRequestFailure
        ),
      ).get();
    }

    try {
      await _retry();
    } catch (e) {
      onRequestFailure(FetchDataException());
    }
  }
  void performGetRequestWithListSupport({
    required Map<String, dynamic> rawData,
    required String urlExtension,
    required Function(Map<String, dynamic>) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
    bool isSsnIdRequired = true
  }) async {

    Map<String, dynamic> baseParams = {};
    baseParams["appType"] = "USER_APP_MOBILE";
    baseParams["ostype"] = "android";

    Post body = Post(
      rawData: {...rawData, ...baseParams},
      urlExtension: urlExtension,
    );

    Future<void> _retry() async {
      HttpRequestHelper(
        urlExtension: urlExtension,
        requestParams: body.toMap(),
        onRequestFailure: onRequestFailure,
        onRequestSuccess: onRequestSuccess,
        unauthorizedAccess: (e) async => await _handleUnauthorized(
            retry: _retry,
            onRequestFailure: onRequestFailure
        ),
      ).getWithListSupport();
    }

    try {
      await _retry();
    } catch (e) {
      onRequestFailure(FetchDataException());
    }
  }


  void performAuthenticateRequest({
    required Map<String, dynamic> rawData,
    required String urlExtension,
    required Function(Map<String, dynamic>) onRequestSuccess,
    required Function(AppException exception) onRequestFailure,
    bool isSsnIdRequired = true
  }) async {

    Map<String, dynamic> baseParams = {};
    baseParams["appType"] = Settings.getAppType();
    baseParams["OsType"] = Settings.getOSType();
    baseParams["AppVersion"] = Settings.getVersionNumber();

    Post body = Post(
      rawData: {...rawData, ...baseParams},
      urlExtension: urlExtension,
    );

    try {
      HttpRequestHelper(
        urlExtension: urlExtension,
        requestParams: body.toMap(),
        onRequestFailure: onRequestFailure,
        onRequestSuccess: onRequestSuccess,
        unauthorizedAccess: onRequestFailure,
      ).authenticatePost();

    } catch (e) {
      onRequestFailure(FetchDataException());
    }
  }


  Future<void> _handleUnauthorized({
    required Future<void> Function() retry,
    required Function(AppException exception) onRequestFailure,
  }) async {

    String refreshToken = await BaseSecureStorage.getString(BaseConstants.refreshToken);
    int userID = await BaseSecureStorage.getInt(BaseConstants.userID);

    LoginRepositoryImpl().authenticateAutoLogin(
      userID: userID,
      refreshToken: refreshToken,
      onRequestSuccess: (loginResponse) async {
        await BaseSecureStorage.setString(BaseConstants.token, loginResponse.token ?? "");
        await BaseSecureStorage.setString(BaseConstants.refreshToken, loginResponse.refreshToken ?? "");
        await retry();
      },
      onRequestFailure: (_) async {
        await BaseSecureStorage.remove(BaseConstants.refreshToken);
        onRequestFailure(UnauthorisedException()); // propagate failure
      },
    );
  }
}
