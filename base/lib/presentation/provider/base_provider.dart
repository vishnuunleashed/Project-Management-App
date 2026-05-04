import 'dart:developer';

import 'package:base/core/loader_value.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:base/domain/usecase/generate_uuid.dart';
import 'package:base/presentation/utility/base_snackbar.dart';
import 'package:base/presentation/utility/navigator_key.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

abstract class BaseProvider extends ChangeNotifier {
  LoadingStatus loadingStatus = LoadingStatus();
  double loadingProgress = 0;
  bool isLoginProvider = false;


  final Map<String, String> _activeTokens = {};
  static const String _kGlobal = '__global__';

    String beginLoading([String slot = _kGlobal]) {
    final token = const Uuid().v4();
    _activeTokens[slot] = token;
    return token;
  }


  bool isTokenActive(String token, [String slot = _kGlobal]) {
    return _activeTokens[slot] == token;
  }

  String beginLoadingWithStatus([String slot = _kGlobal]) {
    final token = beginLoading(slot);
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    return token;
  }

  

  void updateLoadingProgress({required double progress}){
    loadingProgress = progress;
    notifyListeners();
  }


  ///Call this method for changing Loader value.
  void changeLoadingStatus({required LoadingStatus loadingStatus}) async {
    this.loadingStatus = loadingStatus;
    if (loadingStatus.loader == Loader.error) {
      final connectivityResult = await Connectivity().checkConnectivity();
      bool isOffline = connectivityResult.contains(ConnectivityResult.none);
      if (!isOffline || isLoginProvider) {
        BaseSnackBar().show(message: loadingStatus.exception.toString());
      }
    }
    notifyListeners();
  }

  void changeLoadingStatusIfActive({
    required String token,
    required LoadingStatus loadingStatus,
    String slot = _kGlobal,
    bool showSnackbarOnError = true,
  }) async {
    if (!isTokenActive(token, slot)) return;
    this.loadingStatus = loadingStatus;
    if (showSnackbarOnError && loadingStatus.loader == Loader.error) {
      final connectivityResult = await Connectivity().checkConnectivity();
      bool isOffline = connectivityResult.contains(ConnectivityResult.none);
      if (!isOffline || isLoginProvider) {
        BaseSnackBar().show(message: loadingStatus.exception.toString());
      }
    }
    if (NavigatorKey.navKey.currentState!.context.mounted) {
      notifyListeners();
    }
  }

  ///this fn is to change the loading status message dynamically
  void changeLoadingStatusMessage({required String updateLoadingMessage}){
    loadingStatus.message = updateLoadingMessage;
    notifyListeners();
  }

  ///call this method when the next API call needs UUID
  void saveUUIDToBaseView()  {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    GetUUID().callUUID(onSuccess: (uuid) {
      log(uuid);
      changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
    }, onFailure: (exception) {
      changeLoadingStatus(
          loadingStatus:
              LoadingStatus(loader: Loader.error, exception: exception));
      notifyListeners();
    });
  }
  String getUUID() {

    var uuid = const Uuid();
    String generatedUuid = uuid.v4();
    return generatedUuid;
  }

  ///call this method to clear UUID for the next API call
  void clearUUID()  {
    GetUUID().clearUUID(onSuccess: (uuid) {}, onFailure: (exception) {});
  }
}
