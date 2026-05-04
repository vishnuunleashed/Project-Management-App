import 'package:dcc_module/core/dcc_app_exceptions.dart';
import 'package:dcc_module/core/network/dcc_post_service_helper.dart';

/// Utility class for handling DCC module related http requests.
class DccHttpRequestHelper {
  final Map<String, dynamic> requestParams;
  final String stringParams;
  final String urlExtension;

  final Function(Map<String, dynamic>) onRequestSuccess;
  final Function(DccException exception) onRequestFailure;
  final Function(DccException exception) unauthorizedAccess;

  DccHttpRequestHelper({
    required this.urlExtension,
    required this.requestParams,
    this.stringParams = "",
    required this.onRequestSuccess,
    required this.onRequestFailure,
    required this.unauthorizedAccess,
  });

  Future<void> post() async {
    await DccPostServiceHelper(httpRequest: this).postRequest();
  }

  Future<void> get() async {
    await DccPostServiceHelper(httpRequest: this).getRequest();
  }

  Future<void> getWithParentConnection() async {
    await DccPostServiceHelper(httpRequest: this).getRequestWithParentConnection();
  }
}
