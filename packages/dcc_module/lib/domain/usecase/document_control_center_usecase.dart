import 'package:dcc_module/core/dcc_app_exceptions.dart';
import 'package:dcc_module/data/model/response/dcc/dcc_file_model.dart';
import 'package:dcc_module/data/model/response/dcc/dcc_folder_model.dart';
import 'package:dcc_module/data/remote/repository/document_control_center_impl.dart';

class DocumentControlCenterUseCase {
  factory DocumentControlCenterUseCase() => _instance;
  static final DocumentControlCenterUseCase _instance =
      DocumentControlCenterUseCase._internal();
  DocumentControlCenterUseCase._internal();

  void fetchFolderList({
    required Function(List<DccFolderModel>) onRequestSuccess,
    required Function(DccException exception) onRequestFailure,
  }) {
    DocumentControlCenterImpl().fetchFolderList(
      onRequestSuccess: onRequestSuccess,
      onRequestFailure: onRequestFailure,
    );
  }

  void fetchFileList({
    required int folderId,
    required Function(List<DccFileModel>) onRequestSuccess,
    required Function(DccException exception) onRequestFailure,
  }) {
    DocumentControlCenterImpl().fetchFileList(
      folderId: folderId,
      onRequestSuccess: onRequestSuccess,
      onRequestFailure: onRequestFailure,
    );
  }

  void fetchFolderListForProject({
    required int rootFolderId,
    required Function(List<DccFolderModel>) onRequestSuccess,
    required Function(DccException exception) onRequestFailure,
  }) {
    DocumentControlCenterImpl().fetchFolderListForProject(
      rootFolderId: rootFolderId,
      onRequestSuccess: onRequestSuccess,
      onRequestFailure: onRequestFailure,
    );
  }

  void fetchFileListForProject({
    required int rootFolderId,
    required Function(List<DccFileModel>) onRequestSuccess,
    required Function(DccException exception) onRequestFailure,
  }) {
    DocumentControlCenterImpl().fetchFileListForProject(
      rootFolderId: rootFolderId,
      onRequestSuccess: onRequestSuccess,
      onRequestFailure: onRequestFailure,
    );
  }

  void updateNotificationStatus (
      {required int notificationId,
        required Function(int) onRequestSuccess,
        required Function(DccException) onRequestFailure}){
    DocumentControlCenterImpl().updateNotificationStatus(
        notificationId: notificationId,
        onRequestSuccess: onRequestSuccess,
        onRequestFailure: onRequestFailure);
  }

//   void searchFiles({
//     required int rootFolderId,
//     required int folderId,
//     required String query,
//     required Function(List<DccFileModel>) onRequestSuccess,
//     required Function(DccException exception) onRequestFailure,
//   }){
//     DocumentControlCenterImpl().searchFiles(
//         rootFolderId: rootFolderId,
//         folderId: folderId,
//         query: query,
//         onRequestSuccess: onRequestSuccess,
//         onRequestFailure: onRequestFailure);
//   }
}

