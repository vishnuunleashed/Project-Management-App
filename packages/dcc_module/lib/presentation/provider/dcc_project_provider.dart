import 'dart:async';
import 'package:dcc_module/core/dcc_constants.dart';
import 'package:dcc_module/core/loading_status.dart';
import 'package:dcc_module/core/storage/dcc_secure_storage.dart';
import 'package:dcc_module/data/local/dcc_local_storage_service.dart';
import 'package:dcc_module/domain/usecase/dcc_sync_service.dart';
import 'package:dcc_module/domain/usecase/document_control_center_usecase.dart';
import 'package:dcc_module/presentation/provider/dcc_provider.dart';
import 'package:dcc_module/data/model/response/dcc/dcc_folder_model.dart';
/// Project-scoped DCC Provider.
///
/// Extends [DccProvider] to add project-specific initialization,
/// folder-mapping resolution, and background sync timers.
///
/// The [rootFolderId] is resolved by the main app (via
/// `Project/GetProjectDocMappingDetails`) and passed to this provider.
class DccProjectProvider extends DccProvider {
  int? _projectId;
  int? get projectId => _projectId;

  int? _rootFolderId;
  int? get rootFolderId => _rootFolderId;

  final _useCase = DocumentControlCenterUseCase();
  final _localStorage = DccLocalStorageService();
  final _syncService = DccSyncService();


  // ── Project Initialization ────────────────────────────────

  /// Initialize DCC for a specific project.
  ///
  /// [projectId] is used for scoped storage isolation.
  /// [rootFolderId] is resolved by the main app from
  /// `Project/GetProjectDocMappingDetails` API.
  Future<void> initDccForProject({
    required int projectId,
    required int rootFolderId,
  }) async {
    print("_projectId $_projectId");
    print("_rootFolderId $_rootFolderId");
    _projectId = projectId;
    _rootFolderId = rootFolderId;

    print("State initialized: _projectId=$_projectId, _rootFolderId=$_rootFolderId");

    // Reset UI state for the new project
    clearFilter();
    currentFolder = null;
    breadcrumb = [];
    currentFolders = [];
    currentFiles = [];
    notifyListeners();

    final token = beginLoadingWithStatus();

    try {
      // Start connectivity listener (inherited from DccProvider)
      await startConnectivityListener();
      
      startHiveListeners();

      // 1. Initial load from cache
      await updateFolderStats();
      await updateCurrentView();
      // Manual refresh removed here to prevent redundant UI flickering; 
      // the server fetch below will trigger the update.

      if (currentFolders.isNotEmpty) {
        changeLoadingStatusIfActive(
          token: token,
          loadingStatus: DccLoadingStatus(loader: DccLoader.success),
        );
      }

      // 2. Fetch from server if online
      if (!isOffline) {
        await _fetchProjectFoldersFromServer(token);
      } else if (currentFolders.isEmpty) {
        changeLoadingStatusIfActive(
          token: token,
          loadingStatus: DccLoadingStatus(loader: DccLoader.error),
        );
      }
    } catch (e) {
      if (currentFolders.isEmpty) {
        changeLoadingStatusIfActive(
          token: token,
          loadingStatus: DccLoadingStatus(loader: DccLoader.error),
        );
      }
    }
  }

  Future<void> _fetchProjectFoldersFromServer(String token) async {
    if (_rootFolderId == null) return;

    _useCase.fetchFolderListForProject(
      rootFolderId: _rootFolderId!,
      onRequestSuccess: (folders) async {
        await _localStorage.saveFolders(folders);
        await updateFolderStats();
        await updateCurrentView();


        if (currentFolder != null) {
          await fetchFilesForProjectFolder(currentFolder!.id);
        } else {
          await fetchFilesForProjectFolder(_rootFolderId!);
        }

        changeLoadingStatusIfActive(
          token: token,
          loadingStatus: DccLoadingStatus(loader: DccLoader.success),
        );
        silentProjectSync();
      },
      onRequestFailure: (exception) async {
        if (currentFolders.isEmpty) {
          changeLoadingStatusIfActive(
            token: token,
            loadingStatus: DccLoadingStatus(loader: DccLoader.error, exception: exception),
          );
        } else {
          changeLoadingStatusIfActive(
            token: token,
            loadingStatus: DccLoadingStatus(loader: DccLoader.success),
          );
        }
      },
    );
  }

  // ── Project File Fetching ─────────────────────────────────

  Future<void> fetchFilesForProjectFolder(int folderId) async {

    if (_projectId == null) return;


    // 1. Load from cache
    final cachedFiles = await _localStorage.getFiles(folderId);
    if (cachedFiles.isNotEmpty) {
      currentFiles = cachedFiles;
      notifyListeners();
    }

    // 2. Fetch from remote ONLY if it's the root folder of the project
    if (!isOffline && folderId == _rootFolderId) {
      _useCase.fetchFileListForProject(
        rootFolderId: folderId,
        onRequestSuccess: (files) async {
          await _localStorage.saveFiles(files);
          await updateFolderStats();
          currentFiles = await _localStorage.getFiles(folderId);

          notifyListeners();
        },
        onRequestFailure: (exception) {},
      );
    }
  }

  @override
  Future<void> refreshFiles(int folderId) async {
    await fetchFilesForProjectFolder(folderId);
  }

  // ── Override Navigation to use project-scoped file fetching ──

  @override
  Future<void> navigateToFolder(folder) async {
    clearFilter();
    if (_rootFolderId != null && folder.id == _rootFolderId) {
      await navigateToRoot();
      return;
    }
    currentFolder = folder;
    breadcrumb = buildBreadcrumbFor(folder);
    await updateCurrentView();
    notifyListeners();
    await fetchFilesForProjectFolder(folder.id);
  }

  @override
  List<DccFolderModel> buildBreadcrumbFor(DccFolderModel folder) {
    List<DccFolderModel> path = [];
    DccFolderModel? current = folder;
    
    while (current != null) {
      // Stop if we reach the project root
      if (_rootFolderId != null && current.id == _rootFolderId) {
        break;
      }
      path.insert(0, current);
      if (current.parentId == null || current.parentId == 0) {
        break;
      }
      try {
        current = allFolders.firstWhere((f) => f.id == current!.parentId);
      } catch (e) {
        current = null;
      }
    }
    return path;
  }

  @override
  Future<void> navigateBack() async {
    clearFilter();
    if (breadcrumb.isEmpty) return;
    breadcrumb.removeLast();
    currentFolder = breadcrumb.isEmpty ? null : breadcrumb.last;
    await updateCurrentView();
    if (currentFolder != null) {
      await fetchFilesForProjectFolder(currentFolder!.id);
    } else if (_rootFolderId != null) {
      await fetchFilesForProjectFolder(_rootFolderId!);
    } else {
      currentFiles = [];
      notifyListeners();
    }
  }

  @override
  Future<void> navigateToRoot() async {
    clearFilter();
    currentFolder = null;
    breadcrumb.clear();
    await updateCurrentView();
    if (_rootFolderId != null) {
      await fetchFilesForProjectFolder(_rootFolderId!);
    } else {
      currentFiles = [];
      notifyListeners();
    }
  }

  @override
  Future<void> navigateToBreadcrumb(int index) async {
    clearFilter();
    if (index < 0 || index >= breadcrumb.length) return;
    breadcrumb = breadcrumb.sublist(0, index + 1);
    currentFolder = breadcrumb.last;
    await updateCurrentView();
    await fetchFilesForProjectFolder(currentFolder!.id);
  }

  @override
  Future<void> refreshCurrentFolder() async {
    if (currentFolder != null) {
      await fetchFilesForProjectFolder(currentFolder!.id);
    } else {
      await initDccForProject(projectId: _projectId!, rootFolderId: _rootFolderId!);
    }
  }



  Future<void> silentProjectSync() async {
    if (isOffline || _rootFolderId == null || _projectId == null) return;
    print('DCC Project Silent Sync Started for project $_projectId');

    isSilentSyncing = true;
    notifyListeners();

    final (folderRes, fileRes) = await _syncService.performFullSync(
      projectId: _projectId,
      rootFolderId: _rootFolderId,
    );
    
    isSilentSyncing = false;
    notifyListeners();
    
    await updateFolderStats();
    await updateCurrentView();

    if (currentFolder != null) {
      final cachedFiles = await _localStorage.getFiles(currentFolder!.id);
      currentFiles = cachedFiles;
      notifyListeners();
    } else if (_rootFolderId != null) {
      final cachedFiles = await _localStorage.getFiles(_rootFolderId!);
      currentFiles = cachedFiles;
      notifyListeners();
    }

    print('DCC Project Silent Sync Complete:');
    if (folderRes != null) {
      print('- Folders: New(${folderRes.newFolders.length}), Updated(${folderRes.updatedFolders.length}), Deleted(${folderRes.deletedFolderIds.length})');
    }
    if (fileRes != null) {
      print('- Files: New(${fileRes.newFiles.length}), Updated(${fileRes.updatedFiles.length}), Deleted(${fileRes.deletedFileIds.length})');
    }
  }


  @override
  Future<void> updateCurrentView() async {
    if (_rootFolderId == null) {
      await super.updateCurrentView();
      return;
    }

    if (currentFolder == null) {
      // We are at the root level of the project.
      // Fetch project subfolders.
      currentFolders = await _localStorage.getSubFolders(_rootFolderId!);
      currentFiles = await _localStorage.getFiles(_rootFolderId!);

      // Also inject Global folders (Public/Shared) as requested.
      // final globalFolders = await _localStorage.getGlobalFolders();
      // for (final global in globalFolders) {
      //   // Avoid adding the project's own root if it happens to be global metadata
      //   if (global.id != _rootFolderId &&
      //       !currentFolders.any((f) => f.id == global.id)) {
      //     currentFolders.add(global);
      //   }
      // }
      currentFolders.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else {
      currentFolders = await _localStorage.getSubFolders(currentFolder!.id);
      currentFiles = await _localStorage.getFiles(currentFolder!.id);
    }
    notifyListeners();
  }

  @override
  String get currentLocationTitle => isAtRoot ? 'Project Documents' : currentFolder!.name;

  @override
  void reset() {
    _projectId = null;
    _rootFolderId = null;
    super.reset();
  }

}
