import 'package:dcc_module/core/dcc_app_exceptions.dart';
import 'package:dcc_module/core/dcc_base_repository.dart';
import 'package:dcc_module/data/model/response/dcc/dcc_file_model.dart';
import 'package:dcc_module/data/model/response/dcc/dcc_folder_model.dart';

abstract class DocumentControlCenterRepo  extends DccBaseRepository{
  void fetchFolderList({
    required Function(List<DccFolderModel>) onRequestSuccess,
    required Function(DccException exception) onRequestFailure,
  });

  void fetchFileList({
    required int folderId,
    required Function(List<DccFileModel>) onRequestSuccess,
    required Function(DccException exception) onRequestFailure,
  });

  void fetchFolderListForProject({
    required int rootFolderId,
    required Function(List<DccFolderModel>) onRequestSuccess,
    required Function(DccException exception) onRequestFailure,
  });
  void updateNotificationStatus (
      {required int notificationId,
        required Function(int) onRequestSuccess,
        required Function(DccException) onRequestFailure});

  void fetchFileListForProject({
    required int rootFolderId,
    required Function(List<DccFileModel>) onRequestSuccess,
    required Function(DccException exception) onRequestFailure,
  });
  // void searchFiles({
  //   required int rootFolderId,
  //   required int folderId,
  //   required String query,
  //   required Function(List<DccFileModel>) onRequestSuccess,
  //   required Function(DccException exception) onRequestFailure,
  // });
}
