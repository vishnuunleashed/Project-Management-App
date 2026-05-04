import 'dart:developer';

import 'package:dcc_module/core/dcc_app_exceptions.dart';
import 'package:dcc_module/core/dcc_base_repository.dart';
import 'package:dcc_module/core/dcc_constants.dart';
import 'package:dcc_module/core/services/_connection_props.dart';
import 'package:dcc_module/core/storage/dcc_secure_storage.dart';
import 'package:dcc_module/data/model/response/dcc/dcc_file_model.dart';
import 'package:dcc_module/data/model/response/dcc/dcc_folder_model.dart';
import 'package:dcc_module/data/model/response/read_status_update_dto.dart';
import 'package:dcc_module/domain/repository/document_control_center_repository.dart';

class DocumentControlCenterImpl extends DccBaseRepository
    implements DocumentControlCenterRepo {
  static final DocumentControlCenterImpl _instance =
      DocumentControlCenterImpl._internal();
  factory DocumentControlCenterImpl() => _instance;
  DocumentControlCenterImpl._internal();

  @override
  void fetchFolderList({
    required Function(List<DccFolderModel>) onRequestSuccess,
    required Function(DccException exception) onRequestFailure,
  }) async {
    // Read userId and companyId directly from internal secure storage
    final userId = await DccSecureStorage.getInt(DccConstants.userId);
    final companyId = await DccSecureStorage.getInt(DccConstants.companyId);
    final clientId = await DccSecureStorage.getString(DccConstants.clientId);

    performGetRequest(
      rawData: {
        "LoginUserId": userId,
        "CompanyId": companyId,
        "rootFolderId": 0,
        "clientId": clientId
      },
      urlExtension: "Folder/list",
      onRequestSuccess: (result) {
        final List<dynamic> list = result["resultObject"] ?? [];
        log("response___ "+list.toString());
        final folders = list.map((e) => DccFolderModel.fromJson(e)).toList();
        onRequestSuccess(folders);
      },
      onRequestFailure: (exception) => onRequestFailure(exception),
    );
  }

  @override
  void fetchFileList({
    required int folderId,
    required Function(List<DccFileModel>) onRequestSuccess,
    required Function(DccException exception) onRequestFailure,
  }) async {
    // Read userId and companyId directly from internal secure storage
    final userId = await DccSecureStorage.getInt(DccConstants.userId);
    final companyId = await DccSecureStorage.getInt(DccConstants.companyId);
    final clientId = await DccSecureStorage.getString(DccConstants.clientId);
    performGetRequest(
      rawData: {
        "loginUserId": userId,
        "companyId": companyId,
        "rootFolderId": folderId,
        "clientId": clientId
      },
      urlExtension: "FileUpload/GetUploadFilesList",
      onRequestSuccess: (result) {
        final List<dynamic> list = result["resultObject"] ?? [];
        // print("response___ "+list.toString());
        final files = list.map((e) => DccFileModel.fromJson(e)).toList();
        onRequestSuccess(files);
      },
      onRequestFailure: (exception) => onRequestFailure(exception),
    );
  }

  @override
  void fetchFolderListForProject({
    required int rootFolderId,
    required Function(List<DccFolderModel>) onRequestSuccess,
    required Function(DccException exception) onRequestFailure,
  }) async {
    final userId = await DccSecureStorage.getInt(DccConstants.userId);
    final companyId = await DccSecureStorage.getInt(DccConstants.companyId);
    final clientId = await DccSecureStorage.getString(DccConstants.clientId);
    // folder/list?companyId=3&loginUserId=1&rootFolderId=156
    log("request___ "+userId.toString()+companyId.toString()+rootFolderId.toString());
    performGetRequest(
      rawData: {
        "loginUserId": userId,
        "companyId": companyId,
        "rootFolderId": rootFolderId,
        "clientId":clientId
      },
      urlExtension: "folder/list",
      onRequestSuccess: (result) {
        final List<dynamic> list = result["resultObject"] ?? [];
        log("OUTCOMING_____ "+list.toString());
        final folders = list.map((e) => DccFolderModel.fromJson(e)).toList();
        onRequestSuccess(folders);
      },
      onRequestFailure: (exception) => onRequestFailure(exception),
    );
  }

  @override
  void fetchFileListForProject({
    required int rootFolderId,
    required Function(List<DccFileModel>) onRequestSuccess,
    required Function(DccException exception) onRequestFailure,
  }) async {
    final userId = await DccSecureStorage.getInt(DccConstants.userId);
    final companyId = await DccSecureStorage.getInt(DccConstants.companyId);
    final clientId = await DccSecureStorage.getString(DccConstants.clientId);
    performGetRequest(
      rawData: {
        "loginUserId": userId,
        "companyId": companyId,
        "rootFolderId": rootFolderId,
        "clientId": clientId
      },
      urlExtension: "FileUpload/GetUploadFilesList",
      onRequestSuccess: (result) {
        final List<dynamic> list = result["resultObject"] ?? [];
        // print("response___ "+list.toString());
        final files = list.map((e) => DccFileModel.fromJson(e)).toList();
        onRequestSuccess(files);
      },
      onRequestFailure: (exception) => onRequestFailure(exception),
    );
  }

  // @override
  // void searchFiles({
  //   required int rootFolderId,
  //   required int folderId,
  //   required String query,
  //   required Function(List<DccFileModel>) onRequestSuccess,
  //   required Function(DccException exception) onRequestFailure,
  // }) async {
  //   final userId = await DccSecureStorage.getInt(DccConstants.userId);
  //   final companyId = await DccSecureStorage.getInt(DccConstants.companyId);
  //   final clientId = await DccSecureStorage.getString(DccConstants.clientId);
  //   // http://192.168.10.50:5001/api/FileUpload/search?companyId=3&loginUserId=1&rootFolderId=0&clientId=PIS&query=t&folderId=0
  //   performGetRequest(
  //     rawData: {
  //       "loginUserId": userId,
  //       "companyId": companyId,
  //       "rootFolderId": rootFolderId,
  //       "clientId": clientId,
  //       "folderId": folderId,
  //       "query": query,
  //     },
  //     urlExtension: "FileUpload/search",
  //     onRequestSuccess: (result) {
  //       final List<dynamic> list = result["resultObject"] ?? [];
  //       log("response___ "+list.toString());
  //       final files = list.map((e) => DccFileModel.fromJson(e)).toList();
  //       onRequestSuccess(files);
  //     },
  //     onRequestFailure: (exception) => onRequestFailure(exception),
  //   );
  // }

  @override
  void updateNotificationStatus (
      {required int notificationId,
        required Function(int) onRequestSuccess,
        required Function(DccException) onRequestFailure}) async{
    const String urlExtension = "Notification/NotificationReadCountUpdate";
    final Map<String, dynamic> rawData = {};
    rawData['notificationId'] = notificationId;

    performGetRequestWithParent(
        urlExtension: urlExtension,
        rawData: rawData,
        onRequestSuccess: (response) {

          ReadStatusResponseWrapper readStatusResponseWrapper = ReadStatusResponseWrapper.fromJson(response);
          try {
            if(readStatusResponseWrapper.statusCode == 1){
              onRequestSuccess(readStatusResponseWrapper.resultObject.first.notificationid);


            }
          } catch (e) {
            onRequestFailure(DccException(e.toString()));
          }

        },
        onRequestFailure: (exception){
          onRequestFailure(exception);
        }
    );
  }
}
