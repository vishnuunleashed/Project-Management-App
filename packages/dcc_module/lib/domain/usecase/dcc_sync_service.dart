import 'dart:async';
import 'package:dcc_module/core/dcc_app_exceptions.dart';
import 'package:dcc_module/data/local/dcc_file_storage_service.dart';
import 'package:dcc_module/data/local/dcc_local_storage_service.dart';
import 'package:dcc_module/data/model/response/dcc/dcc_file_model.dart';
import 'package:dcc_module/data/model/response/dcc/dcc_folder_model.dart';
import 'package:dcc_module/domain/usecase/document_control_center_usecase.dart';

class DccSyncResult {
  final List<DccFileModel> newFiles;
  final List<DccFileModel> updatedFiles;
  final List<int> deletedFileIds;

  DccSyncResult({
    required this.newFiles,
    required this.updatedFiles,
    required this.deletedFileIds,
  });

  bool get hasChanges =>
      newFiles.isNotEmpty || updatedFiles.isNotEmpty || deletedFileIds.isNotEmpty;
}

class DccFolderSyncResult {
  final List<DccFolderModel> newFolders;
  final List<DccFolderModel> updatedFolders;
  final List<int> deletedFolderIds;

  DccFolderSyncResult({
    required this.newFolders,
    required this.updatedFolders,
    required this.deletedFolderIds,
  });

  bool get hasChanges =>
      newFolders.isNotEmpty || updatedFolders.isNotEmpty || deletedFolderIds.isNotEmpty;
}

class DccSyncService {
  static final DccSyncService _instance = DccSyncService._internal();
  factory DccSyncService() => _instance;
  DccSyncService._internal();

  final _localStorage = DccLocalStorageService();
  final _fileStorage = DccFileStorageService();
  final _useCase = DocumentControlCenterUseCase();

  Future<(DccFolderSyncResult?, DccSyncResult?)> performFullSync({
    int? projectId,
    int? rootFolderId,
    Function(String)? onStatusUpdate,
  }) async {
    try {
      onStatusUpdate?.call('Syncing folders...');
      final folderRes = await syncFolders(projectId: projectId, rootFolderId: rootFolderId);

      onStatusUpdate?.call('Syncing file metadata...');
      final syncResult = await syncFileMetadata(projectId: projectId, rootFolderId: rootFolderId);

      if (syncResult.hasChanges) {
        onStatusUpdate?.call(
            'Downloading ${syncResult.newFiles.length + syncResult.updatedFiles.length} files...');
        await downloadPendingFiles(
          files: [...syncResult.newFiles, ...syncResult.updatedFiles],
        );
      }

      onStatusUpdate?.call('Sync complete');
      return (folderRes, syncResult);
    } catch (e) {
      onStatusUpdate?.call('Sync failed: $e');
      return (null, null);
    }
  }

  Future<DccFolderSyncResult?> syncFolders({int? projectId, int? rootFolderId}) async {
    final completer = Completer<List<DccFolderModel>>();

    if (rootFolderId != null) {
      _useCase.fetchFolderListForProject(
        rootFolderId: rootFolderId,
        onRequestSuccess: (folders) {
          completer.complete(folders);
        },
        onRequestFailure: (exception) {
          completer.completeError(exception);
        },
      );
    } else {
      _useCase.fetchFolderList(
        onRequestSuccess: (folders) {
          completer.complete(folders);
        },
        onRequestFailure: (exception) {
          completer.completeError(exception);
        },
      );
    }

    final serverFolders = await completer.future;
    final serverFolderIds = serverFolders.map((f) => f.id).toSet();

    // Determine local folder set for the current scope to identify deletions
    final List<DccFolderModel> localFolders;
    if (rootFolderId != null) {
      localFolders = await _localStorage.getFoldersForProject(rootFolderId);
    } else {
      localFolders = await _localStorage.getFolders();
    }

    // Identify folders that exist locally but no longer on the server
    final foldersToDelete = localFolders.where((f) {
      final isMissingFromServer = !serverFolderIds.contains(f.id);
      // If global sync (rootFolderId == null), only delete if it's a public folder
      if (rootFolderId == null) {
        return isMissingFromServer && f.isPublic;
      }
      // If project sync, delete if missing from the project hierarchy
      return isMissingFromServer;
    }).toList();
    
    final newFolders = <DccFolderModel>[];
    final updatedFolders = <DccFolderModel>[];
    
    final localFolderMap = {for (var f in localFolders) f.id: f};
    for (final sf in serverFolders) {
      if (!localFolderMap.containsKey(sf.id)) {
        newFolders.add(sf);
      } else {
        final lf = localFolderMap[sf.id]!;
        if (sf.name != lf.name ||
            sf.parentId != lf.parentId ||
            sf.isPublic != lf.isPublic ||
            sf.hasPermission != lf.hasPermission ||
            sf.isOwner != lf.isOwner) {
          updatedFolders.add(sf);
        }
      }
    }

    // 1. Delete removed folders and their contents
    for (final folder in foldersToDelete) {
      await _deleteFolderAndContents(folder.id);
    }

    // 2. Save/Update folders from server
    await _localStorage.saveFolders(serverFolders);
    
    return DccFolderSyncResult(
      newFolders: newFolders,
      updatedFolders: updatedFolders,
      deletedFolderIds: foldersToDelete.map((f) => f.id).toList(),
    );
  }

  Future<void> _deleteFolderAndContents(int folderId) async {
    // 1. Delete all files in this folder
    final files = await _localStorage.getFiles(folderId);
    for (final file in files) {
      if (file.localPath != null) {
        await _fileStorage.deleteFile(file.localPath!);
      }
      await _localStorage.deleteFile(file.id);
    }

    // 2. Delete the folder itself
    await _localStorage.deleteFolder(folderId);
    
    print('DCC Sync: Deleted folder $folderId and its associated files.');
  }

  Future<DccSyncResult> syncFileMetadata({int? projectId, int? rootFolderId}) async {
    // If projectId is provided, we only sync folders belonging to that project's hierarchy
    final List<DccFolderModel> folders;
    if (rootFolderId != null) {
      folders = await _localStorage.getFoldersForProject(rootFolderId);
    } else {
      // Global sync: Sync metadata for all discoverable folders to ensure offline access
      folders = await _localStorage.getFolders();
    }
    
    print('DCC Sync: Starting file metadata sync for ${folders.length} folders.');
    
    final localFiles = await _localStorage.getAllFiles();

    final localFileMap = <int, DccFileModel>{};
    for (final file in localFiles) {
      localFileMap[file.id] = file;
    }

    final allServerFiles = <DccFileModel>[];
    final completer = Completer<List<DccFileModel>>();

    if (rootFolderId != null) {
      _useCase.fetchFileListForProject(
        rootFolderId: rootFolderId,
        onRequestSuccess: (files) => completer.complete(files),
        onRequestFailure: (exception) {
          print('DCC Sync: Failed to fetch files for project root $rootFolderId: $exception');
          completer.complete([]);
        },
      );
    } else {
      _useCase.fetchFileList(
        folderId: 0, // Global root
        onRequestSuccess: (files) => completer.complete(files),
        onRequestFailure: (exception) {
          print('DCC Sync: Failed to fetch files for global root: $exception');
          completer.complete([]);
        },
      );
    }

    allServerFiles.addAll(await completer.future);


    final serverFileMap = <int, DccFileModel>{};
    for (final file in allServerFiles) {
      serverFileMap[file.id] = file;
    }

    final newFiles = <DccFileModel>[];
    final updatedFiles = <DccFileModel>[];
    final deletedFileIds = <int>[];

    for (final entry in serverFileMap.entries) {
      final serverFile = entry.value;
      if (!localFileMap.containsKey(serverFile.id)) {
        newFiles.add(serverFile);
      } else {
        final localFile = localFileMap[serverFile.id]!;
        bool versionChanged = serverFile.currentversionno != localFile.currentversionno;
        bool notDownloaded = !localFile.isDownloaded;

        if (versionChanged || notDownloaded) {
          updatedFiles.add(serverFile);
        }
      }
    }

    // For deletions, we only care about files in the folders we just synced
    final folderIds = folders.map((f) => f.id).toSet();
    if (rootFolderId != null) folderIds.add(rootFolderId);

    for (final localId in localFileMap.keys) {
      final localFile = localFileMap[localId]!;
      if (folderIds.contains(localFile.folderid) && !serverFileMap.containsKey(localId)) {
        deletedFileIds.add(localId);
      }
    }

    if (allServerFiles.isNotEmpty) {
      await _localStorage.saveFiles(allServerFiles);
      print('DCC Sync: Saved ${allServerFiles.length} file metadata records to Hive.');
    }

    for (final deletedId in deletedFileIds) {
      final file = localFileMap[deletedId];
      if (file?.localPath != null) {
        await _fileStorage.deleteFile(file!.localPath!);
      }
      await _localStorage.deleteFile(deletedId);
    }

    return DccSyncResult(
      newFiles: newFiles,
      updatedFiles: updatedFiles,
      deletedFileIds: deletedFileIds,
    );
  }

  Future<void> downloadPendingFiles({
    required List<DccFileModel> files,
    Function(double)? onOverallProgress,
  }) async {
    print('DCC Sync: Starting download of ${files.length} pending files.');
    int completed = 0;

    for (final file in files) {
      try {
        if (file.physicalFileUrl.isEmpty) continue;

        final localPath = await _fileStorage.downloadFile(
          url: file.physicalFileUrl,
          folderId: file.folderid,
          documentId: file.id,
          extension: file.fileextension,
        );

        await _localStorage.markFileAsDownloaded(file.id, localPath);
        completed++;
        onOverallProgress?.call(completed / files.length);
      } catch (e) {
        print('DCC Sync: Failed to download file ${file.id}: $e');
      }
    }
  }

  Future<String?> downloadSingleFile(DccFileModel file, {
    Function(double)? onProgress,
  }) async {
    try {
      if (file.physicalFileUrl.isEmpty) return null;

      final localPath = await _fileStorage.downloadFile(
        url: file.physicalFileUrl,
        folderId: file.folderid,
        documentId: file.id,
        extension: file.fileextension,
        onProgress: onProgress,
      );

      await _localStorage.markFileAsDownloaded(file.id, localPath);
      return localPath;
    } catch (e) {
      print('DCC: Failed to download file ${file.id}: $e');
      return null;
    }
  }
}
