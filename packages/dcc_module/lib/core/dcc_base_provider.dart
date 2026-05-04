import 'package:flutter/material.dart';
import 'package:dcc_module/core/dcc_app_exceptions.dart';
import 'package:dcc_module/core/loading_status.dart';

abstract class DccBaseProvider extends ChangeNotifier {
  DccLoadingStatus loadingStatus = DccLoadingStatus();
  double loadingProgress = 0;

  final Map<String, String> _activeTokens = {};
  static const String _kGlobal = '__global__';

  String beginLoading([String slot = _kGlobal]) {
    final token = DateTime.now().microsecondsSinceEpoch.toString();
    _activeTokens[slot] = token;
    return token;
  }

  bool isTokenActive(String token, [String slot = _kGlobal]) {
    return _activeTokens[slot] == token;
  }

  String beginLoadingWithStatus([String slot = _kGlobal]) {
    final token = beginLoading(slot);
    changeLoadingStatus(
      loadingStatus: DccLoadingStatus(loader: DccLoader.loading),
    );
    return token;
  }

  void updateLoadingProgress({required double progress}) {
    loadingProgress = progress;
    notifyListeners();
  }

  /// Call this method for changing Loader value.
  void changeLoadingStatus({required DccLoadingStatus loadingStatus}) {
    this.loadingStatus = loadingStatus;
    notifyListeners();
  }

  void changeLoadingStatusIfActive({
    required String token,
    required DccLoadingStatus loadingStatus,
    String slot = _kGlobal,
    bool showSnackbarOnError = true,
  }) {
    if (!isTokenActive(token, slot)) return;
    this.loadingStatus = loadingStatus;
    notifyListeners();
  }

  /// Function to change the loading status message dynamically
  void changeLoadingStatusMessage({required String updateLoadingMessage}) {
    loadingStatus.message = updateLoadingMessage;
    notifyListeners();
  }
}
