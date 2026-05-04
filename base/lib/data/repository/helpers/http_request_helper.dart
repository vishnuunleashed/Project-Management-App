
import 'package:base/data/services/utils/app_exceptions.dart';

import '_post_request_helper.dart';

/// Utility class for handling app related [http] requests.

class HttpRequestHelper {
  final Map<String, dynamic> requestParams;
  final String stringParams;
  final String urlExtension;

  final Function(Map<String, dynamic>) onRequestSuccess;
  final Function(AppException exception) onRequestFailure;
  final Function(AppException exception) unauthorizedAccess;

  // final String service;

  /// Callback [onRequestSuccess] pass the result of consumed request and
  /// callback[onRequestFailure]  calls when the request fails and pass [AppException].
    HttpRequestHelper(
      {required this.urlExtension,
      required this.requestParams,
      this.stringParams = "",
      required this.onRequestSuccess,
      required this.onRequestFailure,
      required this.unauthorizedAccess,
      /*this.service = "getdata"*/});

  /// calls [PostServiceHelper.postRequest] for result of  [requestParams].
  Future<void> authenticatePost() async {
    await PostServiceHelper(httpRequest: this).authenticatedPostRequest();
  }

  Future<void> post() async {
    await PostServiceHelper(httpRequest: this).postRequest();
  }
  Future<void> postWithStringInput() async {
    await PostServiceHelper(httpRequest: this).postWithRawInput();
  }
  Future<void> postWithStringParams() async {
    await PostServiceHelper(httpRequest: this).postRequestWithStringParams();
  }
  Future<void> get() async {
    await PostServiceHelper(httpRequest: this).getRequest();
  }
  Future<void> getWithListSupport() async {
    await PostServiceHelper(httpRequest: this).getRequestWithListSupport();
  }
}
