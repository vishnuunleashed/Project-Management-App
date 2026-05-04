import 'package:hive/hive.dart';
import 'package:dcc_module/data/local/dcc_hive_models.dart';
import 'package:dcc_module/data/model/response/dcc/dcc_file_model.dart';
import 'package:dcc_module/data/model/response/dcc/dcc_folder_model.dart';

import 'dcc_file_storage_service.dart';

class DccLocalStorageService {
  static const String folderBoxName = 'dcc_folders';
  static const String fileBoxName = 'dcc_files';
  static const String projectBoxName = 'dcc_projects';



  // ── Folder Methods (Unified) ──────────────────────────────

  Future<void> saveFolders(List<DccFolderModel> folders) async {
    final box = await Hive.openBox<DccFolderHive>(folderBoxName);
    for (final folder in folders) {
      await box.put(folder.id, DccFolderHive.fromModel(folder));
    }
  }

  Future<List<DccFolderModel>> getFolders() async {
    final box = await Hive.openBox<DccFolderHive>(folderBoxName);
    final list = box.values.map((h) => h.toModel()).toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  Future<DccFolderModel?> getFolder(int folderId) async {
    final box = await Hive.openBox<DccFolderHive>(folderBoxName);
    final hiveFolder = box.get(folderId);
    return hiveFolder?.toModel();
  }

  Future<List<DccFolderModel>> getRootFolders() async {
    final box = await Hive.openBox<DccFolderHive>(folderBoxName);
    final list = box.values
        .where((h) => h.parentId == null || h.parentId == 0)
        .map((h) => h.toModel())
        .toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  Future<List<DccFolderModel>> getGlobalFolders() async {
    final box = await Hive.openBox<DccFolderHive>(folderBoxName);
    final list = box.values
        .where((h) =>
            (h.parentId == null || h.parentId == 0) &&
            (h.isPublic || (!h.isOwner && h.hasPermission)))
        .map((h) => h.toModel())
        .toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  Future<List<DccFolderModel>> getFoldersForProject(int rootFolderId) async {
    final allFolders = await getFolders();
    final result = getFoldersRecursive(allFolders, rootFolderId);
    result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return result;
  }

  List<DccFolderModel> getFoldersRecursive(List<DccFolderModel> allFolders, int parentId) {
    final List<DccFolderModel> result = [];
    final children = allFolders.where((f) => f.parentId == parentId).toList();
    children.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    for (final child in children) {
      result.add(child);
      result.addAll(getFoldersRecursive(allFolders, child.id));
    }
    return result;
  }

  Future<List<DccFolderModel>> getSubFolders(int parentFolderId) async {
    final box = await Hive.openBox<DccFolderHive>(folderBoxName);
    final list = box.values
        .where((h) => h.parentId == parentFolderId)
        .map((h) => h.toModel())
        .toList();
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return list;
  }

  // ── File Methods (Unified) ───────────────────────────────

  Future<void> saveFiles(List<DccFileModel> files) async {
    final box = await Hive.openBox<DccFileHive>(fileBoxName);
    for (final file in files) {
      final existing = box.get(file.id);
      if (existing != null) {
        // Only mark as changed if version has incremented
        bool versionChanged = file.currentversionno != existing.currentversionno;

        if (!versionChanged) {
          // Keep our local download status if the server version hasn't changed
          await box.put(
              file.id,
              DccFileHive.fromModel(file.copyWith(
                localPath: existing.localPath,
                isDownloaded: existing.isDownloaded,
              )));
        } else {
          // Version changed! Existing file on disk is now stale.
          // We let the sync service handle deletions of old physical files,
          // but we reset the record here to mark it as not downloaded.
          await box.put(file.id, DccFileHive.fromModel(file));
        }
      } else {
        // New file entirely
        await box.put(file.id, DccFileHive.fromModel(file));
      }
    }
  }

  Future<List<DccFileModel>> getFiles(int folderId) async {
    final box = await Hive.openBox<DccFileHive>(fileBoxName);
    final list = box.values
        .where((h) => h.folderid == folderId)
        .map((h) => h.toModel())
        .toList();
    list.sort((a, b) => a.filename.toLowerCase().compareTo(b.filename.toLowerCase()));
    return list;
  }

  Future<List<DccFileModel>> getAllFiles() async {
    final box = await Hive.openBox<DccFileHive>(fileBoxName);
    final list = box.values.map((h) => h.toModel()).toList();
    list.sort((a, b) => a.filename.toLowerCase().compareTo(b.filename.toLowerCase()));
    return list;
  }

  Future<void> markFileAsDownloaded(int fileId, String localPath) async {
    final box = await Hive.openBox<DccFileHive>(fileBoxName);
    final hiveFile = box.get(fileId);
    if (hiveFile != null) {
      hiveFile.localPath = localPath;
      hiveFile.isDownloaded = true;
      await hiveFile.save();
    }
  }

  Future<void> markFileAsNotDownloaded(int fileId) async {
    final box = await Hive.openBox<DccFileHive>(fileBoxName);
    final hiveFile = box.get(fileId);
    if (hiveFile != null) {
      hiveFile.localPath = null;
      hiveFile.isDownloaded = false;
      await hiveFile.save();
    }
  }

  Future<void> deleteFolder(int folderId) async {
    final box = await Hive.openBox<DccFolderHive>(folderBoxName);
    await box.delete(folderId);
  }

  Future<void> deleteFile(int fileId) async {
    final box = await Hive.openBox<DccFileHive>(fileBoxName);
    await box.delete(fileId);
  }

  Future<void> clearAll() async {
    // 1. Close boxes if they are open
    if (Hive.isBoxOpen(folderBoxName)) await Hive.box<DccFolderHive>(folderBoxName).close();
    if (Hive.isBoxOpen(fileBoxName)) await Hive.box<DccFileHive>(fileBoxName).close();

    // 2. Delete Hive boxes from disk
    await Hive.deleteBoxFromDisk(folderBoxName);
    await Hive.deleteBoxFromDisk(fileBoxName);
    await Hive.deleteBoxFromDisk(projectBoxName);

    // 3. Clear physical files from device
    await DccFileStorageService().clearDccCache();
  }

  Future<List<DccFileModel>> searchFilesOffline(String query, {int? rootFolderId}) async {
    final box = await Hive.openBox<DccFileHive>(fileBoxName);
    List<DccFileModel> allFiles = box.values.map((h) => h.toModel()).toList();

    if (rootFolderId != null && rootFolderId != 0) {
      // Filter by project folders
      final projectFolders = await getFoldersForProject(rootFolderId);
      final projectFolderIds = projectFolders.map((f) => f.id).toSet();
      projectFolderIds.add(rootFolderId); // Include root folder itself

      allFiles = allFiles.where((f) => projectFolderIds.contains(f.folderid)).toList();
    }

    final list = allFiles
        .where((f) => f.filename.toLowerCase().contains(query.toLowerCase()))
        .toList();
    list.sort((a, b) => a.filename.toLowerCase().compareTo(b.filename.toLowerCase()));
    return list;
  }


}
