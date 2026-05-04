import 'package:dcc_module/core/dcc_app_exceptions.dart';
import 'package:dcc_module/core/network/dcc_http_request_helper.dart';

abstract class DccBaseRepository {
  Future<void> performGetRequest({
    required Map<String, dynamic> rawData,
    required String urlExtension,
    required Function(Map<String, dynamic>) onRequestSuccess,
    required Function(DccException exception) onRequestFailure,
  }) async {
    await DccHttpRequestHelper(
      urlExtension: urlExtension,
      requestParams: rawData,
      onRequestSuccess: onRequestSuccess,
      onRequestFailure: onRequestFailure,
      unauthorizedAccess: (e) => onRequestFailure(e),
    ).get();
  }
  Future<void> performGetRequestWithParent({
    required Map<String, dynamic> rawData,
    required String urlExtension,
    required Function(Map<String, dynamic>) onRequestSuccess,
    required Function(DccException exception) onRequestFailure,
  }) async {
    await DccHttpRequestHelper(
      urlExtension: urlExtension,
      requestParams: rawData,
      onRequestSuccess: onRequestSuccess,
      onRequestFailure: onRequestFailure,
      unauthorizedAccess: (e) => onRequestFailure(e),
    ).getWithParentConnection();
  }

  Future<void> performPostRequest({
    required Map<String, dynamic> rawData,
    required String urlExtension,
    required Function(Map<String, dynamic>) onRequestSuccess,
    required Function(DccException exception) onRequestFailure,
  }) async {
    await DccHttpRequestHelper(
      urlExtension: urlExtension,
      requestParams: rawData,
      onRequestSuccess: onRequestSuccess,
      onRequestFailure: onRequestFailure,
      unauthorizedAccess: (e) => onRequestFailure(e),
    ).post();
  }


}
