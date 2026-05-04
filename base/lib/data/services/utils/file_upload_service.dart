

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:base/core/constants.dart';
import 'package:base/data/models/request/multipart_params.dart';
import 'package:base/data/models/response/image_upload_response.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/data/services/_connection_props.dart';
import 'package:dio/dio.dart';
import 'app_exceptions.dart';

class MultipartService {
  final MultipartBody params;
  final Function(UploadResponse) onUploadSuccess;
  final Function(String)? onFileUploadSuccess;
  final Function(AppException exception) onUploadFailure;
  final Function(double progress) onUploadProgress;

  late final Dio _dio;

  MultipartService({
    required this.params,
    required this.onUploadSuccess,
    required this.onUploadFailure,
    required this.onUploadProgress,
    this.onFileUploadSuccess,
  }) {
    _dio = Dio();
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => log(obj.toString()),
    ));
  }

  Future<void> uploadImage() async {
    try {
      String url = "${Connections().generateUri()}FileUpload/fileUpload";
      String token = await BaseSecureStorage.getString(BaseConstants.token);

      log("upload request : ${params.toMap()}");
      log("path : ${params.filedata.path}");

      // Create form data
      FormData formData = FormData.fromMap({
        'File': await MultipartFile.fromFile(
          params.filedata.path,
          filename: params.filedata.path.split('/').last,
        ),
        'serialno': params.serialNo,
        'IsProfilePic': params.isProfilePic,
      });

      // Set headers
      Options options = Options(
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        },
      );

      log("Started uploading file");
      print("file_formData : "+formData.toString());      // Upload with progress tracking
      print("file_headers : "+options.toString());      // Upload with progress tracking
      Response response = await _dio.post(
        url,
        data: formData,
        options: options,
        onSendProgress: (receivedBytes, totalBytes) {
          if (totalBytes != -1) {
            double progress = (receivedBytes / totalBytes);
            onUploadProgress(progress);
          }
        },
      );

      log("Completed uploading file");
      onUploadSuccess(_returnResponse(response));

    } on DioException catch (e) {
      log("Dio error: ${e.toString()}");
      onUploadFailure(_handleDioError(e));
    } catch (e) {
      log("General error: ${e.toString()}");
      onUploadFailure(FetchDataException("Failed to upload image: $e"));
    }
  }
  dynamic _returnResponse(Response response) {
    log(response.data.toString());
    log(response.headers.toString());
    log(response.requestOptions.toString());
    log(response.statusCode.toString());

    switch (response.statusCode) {
      case 0:
        var responseJson = jsonEncode(response.data);
        log(responseJson);
        return responseJson;
      case 200:
      // Handle both cases: response.data as Map or as JSON string
        dynamic data = response.data;
        if (data is String) {
          data = jsonDecode(data);
        }
        UploadResponseModel responseJson = UploadResponseModel.fromJson(data);
        if (responseJson.statusCode == 1) {
          // Return the first upload response item (API returns a list)
          if (responseJson.uploadResponse != null && responseJson.uploadResponse!.isNotEmpty) {
            return responseJson.uploadResponse!.first;
          }
        } else {
          log("Exception Thrown");
          throw FetchDataException(
              'Error occurred while Communication with Server : ${responseJson.statusMessage}');
        }
        break;
      case 400:
        throw BadRequestException(response.data.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.data.toString());
      case 500:
        throw FetchDataException(
            'Error occurred while Communication with Server with StatusCode : ${response.statusCode}');
      default:
        throw FetchDataException(
            'Error occurred while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }

  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return FetchDataException("Connection timeout");

      case DioExceptionType.badResponse:
        switch (error.response?.statusCode) {
          case 400:
            return BadRequestException(error.response?.data.toString() ?? "Bad request");
          case 401:
          case 403:
            return UnauthorisedException(error.response?.data.toString() ?? "Unauthorized");
          case 500:
            return FetchDataException("Internal server error");
          default:
            return FetchDataException(
                "Server error with status code: ${error.response?.statusCode}"
            );
        }

      case DioExceptionType.cancel:
        return FetchDataException("Request was cancelled");

      case DioExceptionType.unknown:
      default:
        return FetchDataException("Network error: ${error.message}");
    }
  }
}