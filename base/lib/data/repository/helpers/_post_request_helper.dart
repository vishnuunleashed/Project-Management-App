
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:base/core/constants.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/data/services/_connection_props.dart';
import 'package:base/data/services/utils/app_exceptions.dart';

import 'package:http/http.dart' as http;

import 'http_request_helper.dart';

/// Class that handle all [http-Post] requests.
class PostServiceHelper {
  final HttpRequestHelper httpRequest;

  PostServiceHelper({required this.httpRequest});

  /// perform http post request from param [httpRequest]
  /// params for post request are generated from [httpRequest]
  /// url generated from [connection_props.generateUri] and the service from [httpRequest]
  /// throws a 500 Exception if the cookies are not correctly handled.
  /// perform [httpRequest.onRequestSuccess] on request success and [httpRequest.onRequestFailure] on failure.
  Future<dynamic> authenticatedPostRequest() async {
    String url = "${Connections().generateUri()}${httpRequest.urlExtension}";

    // String formBody = "";
    // httpRequest.requestParams.forEach((key, value) =>
    //     formBody += '$key=${Uri.encodeQueryComponent(value.toString())}&');
    //
    // List<int> bodyBytes = utf8.encode(formBody);
    //
    // Map<String, String> requestHeaders = {
    //   'Content-type': 'application/x-www-form-urlencoded; charset=UTF-8',
    //   'Accept': '*/*',
    //   'Accept-Encoding': 'gzip, deflate, br',
    //   'Connection': 'keep-alive',
    //   'Cookie': await BasePrefs.getString(BaseConstants.COOKIE_KEY)
    // };

    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': '*/*',
      'Accept-Encoding': 'gzip, deflate, br',
      'Connection': 'keep-alive',
    };

    String body = json.encode(httpRequest.requestParams);
    log("request: ${httpRequest.requestParams}");
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: requestHeaders,
        body: body
      );

      final parsedResponse = _parseResponse(response);

      if (parsedResponse is AppException) {
        httpRequest.onRequestFailure(parsedResponse);
      } else {
        httpRequest.onRequestSuccess(parsedResponse);
      }
    } on SocketException {
      httpRequest
          .onRequestFailure(FetchDataException("Unable to reach the server at the moment. Please try again later."));
    } catch (e) {
      log(e.toString());
      httpRequest.onRequestFailure(FetchDataException(e.toString()));
    }
    return;
  }

  Future<dynamic> postRequest() async {
    String url = "${Connections().generateUri()}${httpRequest.urlExtension}";



    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': '*/*',
      'Accept-Encoding': 'gzip, deflate, br',
      'Connection': 'keep-alive',
      'Authorization': 'Bearer ${await BaseSecureStorage.getString(BaseConstants.token)}',
    };

    String body = json.encode(httpRequest.requestParams);
    log("request: ${httpRequest.requestParams}");
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: requestHeaders,
        body: body
      );

      final parsedResponse = _parseResponse(response);

      if (parsedResponse is AppException) {
        if(parsedResponse is UnauthorisedException){
          httpRequest.unauthorizedAccess(parsedResponse);
        }else{
          httpRequest.onRequestFailure(parsedResponse);
        }
      } else {
        httpRequest.onRequestSuccess(parsedResponse);
      }
    } on SocketException {
      httpRequest
          .onRequestFailure(FetchDataException("Unable to reach the server at the moment. Please try again later."));
    } catch (e) {
      log(e.toString());
      if(e is UnauthorisedException){
        httpRequest.unauthorizedAccess(e);
      }else{
        httpRequest.onRequestFailure(AppException(e.toString()));
      }

    }
    return;
  }
  Future<dynamic> postWithRawInput() async {
    String url = "${Connections().generateUri()}${httpRequest.urlExtension}";



    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': '*/*',
      'Accept-Encoding': 'gzip, deflate, br',
      'Connection': 'keep-alive',
      'Authorization': 'Bearer ${await BaseSecureStorage.getString(BaseConstants.token)}',
    };
    // Use the raw string directly without encoding
    String body = jsonEncode(httpRequest.stringParams);
    log("request: $body");

    try {
      final response = await http.post(
          Uri.parse(url),
          headers: requestHeaders,
          body: body
      );

      final parsedResponse = _parseResponse(response);

      if (parsedResponse is AppException) {
        if(parsedResponse is UnauthorisedException){
          httpRequest.unauthorizedAccess(parsedResponse);
        }else{
          httpRequest.onRequestFailure(parsedResponse);
        }
      } else {
        httpRequest.onRequestSuccess(parsedResponse);
      }
    } on SocketException {
      httpRequest
          .onRequestFailure(FetchDataException("Unable to reach the server at the moment. Please try again later."));
    } catch (e) {
      log(e.toString());
      if(e is UnauthorisedException){
        httpRequest.unauthorizedAccess(e);
      }else{
        httpRequest.onRequestFailure(AppException(e.toString()));
      }

    }
    return;
  }

  Future<dynamic> postRequestWithStringParams() async {
    String url = "${Connections().generateUri()}${httpRequest.urlExtension}";



    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': '*/*',
      'Accept-Encoding': 'gzip, deflate, br',
      'Connection': 'keep-alive',
      'Authorization': 'Bearer ${await BaseSecureStorage.getString(BaseConstants.token)}',
    };

    String body = jsonEncode(httpRequest.stringParams);
    log("request: ${jsonEncode(httpRequest.stringParams)}");
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: requestHeaders,
        body: body
      );

      final parsedResponse = _parseResponse(response);

      if (parsedResponse is AppException) {
        if(parsedResponse is UnauthorisedException){
          httpRequest.unauthorizedAccess(parsedResponse);
        }else{
          httpRequest.onRequestFailure(parsedResponse);
        }
      } else {
        httpRequest.onRequestSuccess(parsedResponse);
      }
    } on SocketException {
      httpRequest
          .onRequestFailure(FetchDataException("Unable to reach the server at the moment. Please try again later."));
    } catch (e) {
      log(e.toString());
      if(e is UnauthorisedException){
        httpRequest.unauthorizedAccess(e);
      }else{
        httpRequest.onRequestFailure(AppException(e.toString()));
      }

    }
    return;
  }
  Future<dynamic> getRequest() async {
    String baseUrl = "${Connections().generateUri()}${httpRequest.urlExtension}";

    // Build query parameters into URL
    Uri uri = Uri.parse(baseUrl).replace(queryParameters:
    httpRequest.requestParams.map((key, value) => MapEntry(key, value.toString()))
    );



    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': '*/*',
      'Accept-Encoding': 'gzip, deflate, br',
      'Connection': 'keep-alive',
      'Authorization': 'Bearer ${await BaseSecureStorage.getString(BaseConstants.token)}',
    };

    try {
      final response = await http.get(uri, headers: requestHeaders);

      final parsedResponse = _parseResponse(response);

      if (parsedResponse is AppException) {
        if(parsedResponse is UnauthorisedException){
          httpRequest.unauthorizedAccess(parsedResponse);
        }else{
          httpRequest.onRequestFailure(parsedResponse);
        }
      } else {
        httpRequest.onRequestSuccess(parsedResponse);
      }
    } on SocketException {
      httpRequest.onRequestFailure(
        FetchDataException("Unable to reach the server at the moment. Please try again later."),
      );
    } catch (e) {
      log(e.toString());
      if(e is UnauthorisedException){
        httpRequest.unauthorizedAccess(e);
      }else{
        httpRequest.onRequestFailure(
          FetchDataException(e.toString()),
        );
      }
    }
  }

  Future<dynamic> getRequestWithListSupport() async {
    String baseUrl =
        "${Connections().generateUri()}${httpRequest.urlExtension}";

    /// Convert params to query-safe format
    final Map<String, dynamic> processedParams = {};

    httpRequest.requestParams.forEach((key, value) {
      if (value == null) return;

      if (value is List) {
        // keep list as-is → Uri will expand it correctly
        processedParams[key] =
            value.map((e) => e.toString()).toList();
      } else {
        processedParams[key] = value.toString();
      }
    });

    Uri uri = Uri.parse(baseUrl).replace(
      queryParameters: processedParams,
    );



    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'Accept': '*/*',
      'Accept-Encoding': 'gzip, deflate, br',
      'Connection': 'keep-alive',
      'Authorization':
      'Bearer ${await BaseSecureStorage.getString(BaseConstants.token)}',
    };

    try {
      final response = await http.get(uri, headers: requestHeaders);

      final parsedResponse = _parseResponse(response);

      if (parsedResponse is AppException) {
        if (parsedResponse is UnauthorisedException) {
          httpRequest.unauthorizedAccess(parsedResponse);
        } else {
          httpRequest.onRequestFailure(parsedResponse);
        }
      } else {
        httpRequest.onRequestSuccess(parsedResponse);
      }
    } on SocketException {
      httpRequest.onRequestFailure(
        FetchDataException(
            "Unable to reach the server at the moment. Please try again later."),
      );
    } catch (e) {
      log(e.toString());
      if (e is UnauthorisedException) {
        httpRequest.unauthorizedAccess(e);
      } else {
        httpRequest.onRequestFailure(
          FetchDataException(e.toString()),
        );
      }
    }
  }

  /// Function return formatted [http.Response] for app return [AppException] if the request failures and Map<String,dynamic> if success
  /// called after getting response [postRequest],[authenticateRequest].

  dynamic _parseResponse(http.Response response) {
    if(response.statusCode != 401) {
      try {
        _printRequest(response);
      } catch (e) {
        log(e.toString());
        throw FetchDataException.fromResult(json.decode(response.body));
      }
    }

    switch (response.statusCode) {
      case 200:
        try {
          return jsonDecode(response.body);
        } catch (e) {
          throw FetchDataException.fromResult(json.decode(response.body));
        }

      case 400:
        throw BadRequestException.fromResult(json.decode(response.body));
      case 401:
        throw UnauthorisedException.fromResult({"statusMessage":"token expired"});
      case 403:
        throw FetchDataException.fromResult(json.decode(response.body));
      case 500:
        throw FetchDataException.fromResult(json.decode(response.body));
      default:
        throw FetchDataException.fromResult(json.decode(response.body));
    }
  }

  void _printRequest(http.Response response) {
    var request = httpRequest.requestParams.toString();
    var requestHeaders = response.request!.headers.toString();
    var result = json.decode(utf8.decode(response.bodyBytes));
    var header = response.headers;

    log('*********************  Request Body     ****************************');
    log('Request query : $request');
    log('Request path : ${response.request.toString()}');
    log('Request headers  : $requestHeaders');
    log('*********************  ****************************');
    log('*********************  Response Body    **************************');
    log('headers : $header');
    log('result : $result');
    log('********************  ****************************');
  }
}

