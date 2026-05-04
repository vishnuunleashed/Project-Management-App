import 'dart:io';
import 'package:base/data/models/response/image_upload_response.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:base/data/models/request/multipart_params.dart';
import 'package:base/data/services/utils/file_upload_service.dart';

class FileUploadRepository {
  final Function(List<UploadResponse>?) onRequestSuccess;
  final Function(AppException exception) onRequestFailure;

  FileUploadRepository({required this.onRequestSuccess, required this.onRequestFailure});

  //For uploading multiple image files
  void uploadImages(
    List<File> images,
      bool isProfilePic, {
      String? attachmentSerialNo ,
    required Function(double progress) uploadProgress,
  }) async {
    List<String>? fileNames;
    String? fileName;

    List<UploadResponse> result=[];
    MultipartBody requestBody;

    try {
      for (int i = 0; i < (images.length ?? 0); i++) {
        fileNames = images[i].path.split("/");
        fileName = fileNames[fileNames.length - 1];
        fileNames = fileName.split(".");

        requestBody = MultipartBody(
          filedata: File(images[i].path ?? ""),
          filename: fileName ?? "",
          isProfilePic: isProfilePic,
          serialNo: attachmentSerialNo??"",
        );

        await MultipartService(
            params: requestBody,
            onUploadFailure: onRequestFailure,
            onUploadProgress: uploadProgress,
            onUploadSuccess: (response) {
              result.add(response);
              attachmentSerialNo = response.serialno ?? "";
            }).uploadImage();
         uploadProgress((i + 1 ~/ (images.length)) * 100);
      }
      if (result != []) {
        onRequestSuccess(result);
      } else {
        onRequestFailure(FetchDataException("Failed to upload image"));
      }
    } catch (e) {
      onRequestFailure(FetchDataException("Failed to upload image : $e"));
    }
  }
}
