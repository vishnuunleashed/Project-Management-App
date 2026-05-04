import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:base/data/services/_connection_props.dart';
import 'package:http/http.dart' as http;
import 'package:dcc_module/core/dcc_app_exceptions.dart';
import 'package:dcc_module/core/dcc_constants.dart';
import 'package:dcc_module/core/network/dcc_http_request_helper.dart';
import 'package:dcc_module/core/services/_connection_props.dart';
import 'package:dcc_module/core/storage/dcc_secure_storage.dart';

/// Class that handles all DCC module [http] requests.
/// Uses internal [DCCConnections] for URL management.
class DccPostServiceHelper {
  final DccHttpRequestHelper httpRequest;

  DccPostServiceHelper({required this.httpRequest});

  Future<void> postRequest() async {
    // Use standalone connection properties
    final baseUrl = DCCConnections().generateWebUrl();
    final url = "$baseUrl${httpRequest.urlExtension}";

    // Read token directly from internal secure storage
    final token = await DccSecureStorage.getString(DccConstants.token);

    // log("DCC Request URL: $url");

    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    String body = json.encode(httpRequest.requestParams);
    // log("DCC Request Body: $body");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: requestHeaders,
        body: body,
      );

      final parsedResponse = _parseResponse(response);

      if (parsedResponse is DccException) {
        if (parsedResponse is DccUnauthorisedException) {
          httpRequest.unauthorizedAccess(parsedResponse);
        } else {
          httpRequest.onRequestFailure(parsedResponse);
        }
      } else {
        httpRequest.onRequestSuccess(parsedResponse);
      }
    } on SocketException {
      httpRequest.onRequestFailure(
          DccFetchDataException("Unable to reach the server. Please check your connection."));
    } catch (e) {
      log("DCC Post Error: ${e.toString()}");
      httpRequest.onRequestFailure(DccException(e.toString()));
    }
  }

  Future<void> getRequest() async {
    // Use standalone connection properties
    final baseUrl = DCCConnections().generateWebUrl();

    // Read token directly from internal secure storage
    final token = await DccSecureStorage.getString(DccConstants.token);

    Uri uri = Uri.parse("$baseUrl${httpRequest.urlExtension}").replace(
      queryParameters: httpRequest.requestParams.map((key, value) => MapEntry(key, value.toString())),
    );

    log("DCC GET URL: $uri");

    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(uri, headers: requestHeaders);

      final parsedResponse = _parseResponse(response);

      if (parsedResponse is DccException) {
        if (parsedResponse is DccUnauthorisedException) {
          httpRequest.unauthorizedAccess(parsedResponse);
        } else {
          httpRequest.onRequestFailure(parsedResponse);
        }
      } else {
        log("DCC Result :"+ parsedResponse.toString());
        httpRequest.onRequestSuccess(parsedResponse);
      }
    } on SocketException {
      httpRequest.onRequestFailure(
          DccFetchDataException("Unable to reach the server. Please check your connection."));
    } catch (e) {
      log("DCC GET Error: ${e.toString()}");
      httpRequest.onRequestFailure(DccException(e.toString()));
    }
  }

  dynamic _parseResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        try {
          return jsonDecode(response.body);
        } catch (e) {
          throw DccFetchDataException("Invalid response format from server");
        }
      case 401:
        return DccUnauthorisedException("Session expired");
      case 400:
        return DccBadRequestException.fromResult(json.decode(response.body));
      default:
        try {
          return DccException.fromResult(json.decode(response.body));
        } catch (_) {
          return DccException("Server returned error ${response.statusCode}");
        }
    }
  }

  Future<void> getRequestWithParentConnection() async {
    // Use standalone connection properties
    final baseUrl = Connections().generateWebUrl();

    // Read token directly from internal secure storage
    final token = await DccSecureStorage.getString(DccConstants.token);

    Uri uri = Uri.parse("$baseUrl${httpRequest.urlExtension}").replace(
      queryParameters: httpRequest.requestParams.map((key, value) => MapEntry(key, value.toString())),
    );

    log("DCC GET URL: $uri");

    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(uri, headers: requestHeaders);

      final parsedResponse = _parseResponse(response);

      if (parsedResponse is DccException) {
        if (parsedResponse is DccUnauthorisedException) {
          httpRequest.unauthorizedAccess(parsedResponse);
        } else {
          httpRequest.onRequestFailure(parsedResponse);
        }
      } else {
        log("DCC Result :"+ parsedResponse.toString());
        httpRequest.onRequestSuccess(parsedResponse);
      }
    } on SocketException {
      httpRequest.onRequestFailure(
          DccFetchDataException("Unable to reach the server. Please check your connection."));
    } catch (e) {
      log("DCC GET Error: ${e.toString()}");
      httpRequest.onRequestFailure(DccException(e.toString()));
    }
  }

}
