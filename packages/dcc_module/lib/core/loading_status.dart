import 'package:dcc_module/core/dcc_app_exceptions.dart';

enum DccLoader { init, success, loading, error }

class DccLoadingStatus {
  DccLoader loader;
  String message;
  DccException? exception;

  DccLoadingStatus({
    this.loader = DccLoader.init,
    this.message = "Loading",
    this.exception,
  });
}
