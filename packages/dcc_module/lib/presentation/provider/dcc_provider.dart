import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dcc_module/core/dcc_base_provider.dart';
import 'package:dcc_module/core/dcc_constants.dart';
import 'package:dcc_module/core/loading_status.dart';
import 'package:dcc_module/core/storage/dcc_secure_storage.dart';
import 'package:dcc_module/data/local/dcc_file_storage_service.dart';
import 'package:dcc_module/data/local/dcc_hive_models.dart';
import 'package:dcc_module/data/local/dcc_local_storage_service.dart';
import 'package:dcc_module/data/model/response/dcc/dcc_file_model.dart';
import 'package:dcc_module/data/model/response/dcc/dcc_folder_model.dart';
import 'package:dcc_module/domain/usecase/dcc_sync_service.dart';
import 'package:dcc_module/domain/usecase/document_control_center_usecase.dart';
import 'package:eraser/eraser.dart';
import 'package:hive/hive.dart';
import 'package:open_filex/open_filex.dart';

class DccProvider extends DccBaseProvider {
  List<DccFolderModel> allFolders = [];
  List<DccFolderModel> currentFolders = [];
  List<DccFileModel> currentFiles = [];
  List<DccFolderModel> breadcrumb = [];
  DccFolderModel? currentFolder;
  Map<int, int> folderFileCounts = {};
  bool isSyncing = false;
  bool isSilentSyncing = false;
  bool isOffline = false;
  int? downloadingFileId;
  double downloadProgress = 0.0;
  List<DccFileModel> searchFilesResult = [];
  List<DccFolderModel> searchFoldersResult = [];
  bool isSearching = false;
  String searchQuery = "";
  
  DccFolderModel? _preSearchFolder;
  List<DccFolderModel> _preSearchBreadcrumb = [];
  bool _isSearchStateSaved = false;

  int? filteredFileId;

  List<DccFolderModel> get visibleFolders {
    if (filteredFileId != null) return [];
    return currentFolders;
  }

  List<DccFileModel> get visibleFiles {
    List<DccFileModel> files = currentFiles;
    if (isOffline) {
      files = files.where((f) => f.isDownloaded).toList();
    }
    if (filteredFileId != null) {
      files = files.where((f) => f.id == filteredFileId).toList();
    }
    return files;
  }

  void clearFilter() {
    if (filteredFileId != null) {
      filteredFileId = null;
      notifyListeners();
    }
  }

  Future<void> refreshFiles(int folderId) async {
    await _fetchFilesForFolder(folderId);
  }

  final _useCase = DocumentControlCenterUseCase();
  final _localStorage = DccLocalStorageService();
  final _fileStorage = DccFileStorageService();
  final _syncService = DccSyncService();

  Timer? _syncTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<BoxEvent>? _folderBoxSubscription;
  StreamSubscription<BoxEvent>? _fileBoxSubscription;
  Timer? _debounceTimer;
  Timer? _searchDebounceTimer;
  final Set<int> _affectedFolders = {};

  void startHiveListeners() {
    stopHiveListeners();
    
    // Listen for folder changes
    Hive.openBox<DccFolderHive>(DccLocalStorageService.folderBoxName).then((box) {
      _folderBoxSubscription = box.watch().listen((event) {
        _triggerDebouncedRefresh();
      });
    });

    // Listen for file changes
    Hive.openBox<DccFileHive>(DccLocalStorageService.fileBoxName).then((box) {
      _fileBoxSubscription = box.watch().listen((event) {
        if (event.value is DccFileHive) {
          final file = event.value as DccFileHive;
          _affectedFolders.add(file.folderid);
        }
        _triggerDebouncedRefresh();
      });
    });
  }

  void _triggerDebouncedRefresh() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 200), () async {
      print('DCC: Reactive refresh triggered for ${_affectedFolders.length} folders');
      
      if (_affectedFolders.isNotEmpty) {
        for (final folderId in _affectedFolders) {
          await updateFolderStats(onlyForFolderId: folderId);
        }
        _affectedFolders.clear();
      } else {
        await updateFolderStats();
      }
      
      await updateCurrentView();
    });
  }

  void stopHiveListeners() {
    _folderBoxSubscription?.cancel();
    _fileBoxSubscription?.cancel();
    _folderBoxSubscription = null;
    _fileBoxSubscription = null;
  }

  Future<void> syncWithTimer({Function()? onSuccess}) async {
    if (_syncTimer != null) return;
    int syncIntervalInSeconds = await DccSecureStorage.getIntervalInSeconds(DccConstants.syncInterval);
    await silentSync(onSuccess: onSuccess);
    _syncTimer = Timer.periodic( Duration(seconds: syncIntervalInSeconds), (timer) async {
      await silentSync();
      if(onSuccess != null){
        onSuccess();
      }
    });
  }

  Future<void> silentSync({Function()? onSuccess}) async {

    if (isOffline) return;
    print('DCC Silent Sync Started');
    isSilentSyncing = true;
    notifyListeners();
    
    // Perform sync
    final (folderSyncResult, fileSyncResult) = await _syncService.performFullSync();
    
    isSilentSyncing = false;
    notifyListeners();
    
    await updateFolderStats();
    await updateCurrentView();

    if (currentFolder != null) {
      final cachedFiles = await _localStorage.getFiles(currentFolder!.id);
      if (cachedFiles.isNotEmpty) {
        currentFiles = cachedFiles;
        notifyListeners();
      }
    }
    // Log the sync results
    final folders = await _localStorage.getFolders();
    final subfoldersCount = folders.where((f) => f.parentId != null && f.parentId != 0).length;
    final rootFoldersCount = folders.where((f) => f.parentId == null || f.parentId == 0).length;
    final totalFilesCount = (await _localStorage.getAllFiles()).length;
    
    print('DCC Silent Sync Complete:');
    print('- Root Folders ($rootFoldersCount), Subfolders ($subfoldersCount)');
    print('- Total Files Synced/Indexed: $totalFilesCount');
    final offlineFilesCount = (await _localStorage.getAllFiles()).where((f) => f.isDownloaded).length;
    print('- Total Files Available Offline: $offlineFilesCount');
    
    if (folderSyncResult != null) {
      print('- New Folders: ${folderSyncResult.newFolders.length}');
      print('- Updated Folders: ${folderSyncResult.updatedFolders.length}');
      print('- Deleted Folders: ${folderSyncResult.deletedFolderIds.length}');
    }

    if (fileSyncResult != null) {
      print('- New Files: ${fileSyncResult.newFiles.length}');
      print('- Updated Files: ${fileSyncResult.updatedFiles.length}');
      print('- Deleted Files: ${fileSyncResult.deletedFileIds.length}');
    }

    if(onSuccess != null){
      onSuccess();
    }
  }

  


  Future<void> initDcc() async {
    final token = beginLoadingWithStatus();

    try {
      if (_connectivitySubscription == null) {
        await startConnectivityListener();
      }

      startHiveListeners();

      await updateFolderStats();
      await updateCurrentView();

      // Initial check if we have any folders to determine "success" state
      final rootFolders = await _localStorage.getRootFolders();
      if (rootFolders.isNotEmpty) {
        changeLoadingStatusIfActive(
          token: token,
          loadingStatus: DccLoadingStatus(loader: DccLoader.success),
        );
      }

      if (!isOffline) {
        await _fetchFoldersFromServer(token);
      } else if (rootFolders.isEmpty) {
        changeLoadingStatusIfActive(
          token: token,
          loadingStatus: DccLoadingStatus(loader: DccLoader.error),
        );
      }
    } catch (e) {
      final rootFolders = await _localStorage.getRootFolders();
      if (rootFolders.isEmpty) {
        changeLoadingStatusIfActive(
          token: token,
          loadingStatus: DccLoadingStatus(loader: DccLoader.error),
        );
      }
    }
  }

  Future<void> _fetchFoldersFromServer(String token) async {
    _useCase.fetchFolderList(
      onRequestSuccess: (folders) async {
        await _localStorage.saveFolders(folders);
        await updateFolderStats();
        await updateCurrentView();

        // Mark as success as soon as folders are ready
        changeLoadingStatusIfActive(
          token: token,
          loadingStatus: DccLoadingStatus(loader: DccLoader.success),
        );

        // Fetch files for current folder if applicable (non-blocking for UI state)
        if (currentFolder != null) {
          await _fetchFilesForFolder(currentFolder!.id);
        }

        _performBackgroundSync();
      },
      onRequestFailure: (exception) async {
        final rootFolders = await _localStorage.getRootFolders();
        if (rootFolders.isEmpty) {
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

  Future<void> navigateToFolder(DccFolderModel folder) async {
    clearFilter();
    currentFolder = folder;
    breadcrumb = buildBreadcrumbFor(folder);
    await updateCurrentView();
    notifyListeners();
    await _fetchFilesForFolder(folder.id);
  }

  Future<void> navigateToFolderAndFile(int folderId, int fileId) async {
    // 1. Ensure allFolders is populated
    if (allFolders.isEmpty) {
      allFolders = await _localStorage.getFolders();
    }

    DccFolderModel? folder;
    try {
      folder = allFolders.firstWhere((f) => f.id == folderId);
    } catch (e) {
      folder = await _localStorage.getFolder(folderId);
    }

    if (folder != null) {
      currentFolder = folder;
      breadcrumb = buildBreadcrumbFor(folder);
      filteredFileId = fileId;
      await updateCurrentView();
      await refreshFiles(folderId);
    }
  }

  List<DccFolderModel> buildBreadcrumbFor(DccFolderModel folder) {
    List<DccFolderModel> path = [];
    DccFolderModel? current = folder;
    
    while (current != null) {
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

  String getLocationPathForFolder(int folderId) {
    try {
      final folder = allFolders.firstWhere((f) => f.id == folderId);
      final pathList = buildBreadcrumbFor(folder);
      if (pathList.length <= 1) return 'Home';
      final pathStr = pathList.sublist(0, pathList.length - 1).map((f) => f.name).join(' > ');
      return 'Home > $pathStr';
    } catch (e) {
      return '';
    }
  }

  String getLocationPathForFile(int folderId) {
    try {
      if (folderId == 0) return 'Home';
      final folder = allFolders.firstWhere((f) => f.id == folderId);
      final pathList = buildBreadcrumbFor(folder);
      if (pathList.isEmpty) return 'Home';
      return 'Home > ' + pathList.map((f) => f.name).join(' > ');
    } catch (e) {
      return 'Home';
    }
  }

  Future<void> navigateBack() async {
    clearFilter();
    if (breadcrumb.isEmpty) return;
    breadcrumb.removeLast();
    currentFolder = breadcrumb.isEmpty ? null : breadcrumb.last;
    await updateCurrentView();
    if (currentFolder != null) {
      await _fetchFilesForFolder(currentFolder!.id);
    } else {
      currentFiles = [];
      notifyListeners();
    }
  }

  Future<void> navigateToRoot() async {
    clearFilter();
    currentFolder = null;
    breadcrumb.clear();
    await updateCurrentView();
    currentFiles = [];
    notifyListeners();
  }

  Future<void> navigateToBreadcrumb(int index) async {
    clearFilter();
    if (index < 0 || index >= breadcrumb.length) return;
    breadcrumb = breadcrumb.sublist(0, index + 1);
    currentFolder = breadcrumb.last;
    await updateCurrentView();
    await _fetchFilesForFolder(currentFolder!.id);
  }

  Future<void> updateCurrentView() async {
    if (currentFolder == null) {
      currentFolders = await _localStorage.getRootFolders();
      currentFiles = []; // Root usually has no direct files in this app's logic
    } else {
      currentFolders = await _localStorage.getSubFolders(currentFolder!.id);
      currentFiles = await _localStorage.getFiles(currentFolder!.id);
    }
    notifyListeners();
  }

  Future<void> _fetchFilesForFolder(int folderId) async {
    // 1. Initial load from local cache
    final cachedFiles = await _localStorage.getFiles(folderId);
    if (cachedFiles.isNotEmpty) {
      currentFiles = cachedFiles;
      notifyListeners();
    }

    // 2. Fetch from remote is avoided since all files are synced by the provider
    /*
    if (!isOffline) {
      _useCase.fetchFileList(
        folderId: folderId,
        onRequestSuccess: (files) async {
          // Save to local storage (which merges the download status)
          await _localStorage.saveFiles(files);
          await updateFolderStats();
          
          // 3. Reload from local storage (Single Source of Truth)
          // This ensures UI correctly reflects both server updates and local download status.
          currentFiles = await _localStorage.getFiles(folderId);
          notifyListeners();
        },
        onRequestFailure: (exception) {},
      );
    }
    */
  }

  Future<void> openFile(DccFileModel file) async {
    if (file.isDownloaded && file.localPath != null) {
      final exists = await _fileStorage.fileExists(file.localPath);
      if (exists) {
        OpenFilex.open(file.localPath!);
        return;
      } else {
        await _localStorage.markFileAsNotDownloaded(file.id);
      }
    }

    if (file.physicalFileUrl.isNotEmpty) {
      OpenFilex.open(file.physicalFileUrl);
      _downloadInBackground(file);
    }
  }

  Future<void> _downloadInBackground(DccFileModel file) async {
    downloadingFileId = file.id;
    downloadProgress = 0.0;
    notifyListeners();

    final localPath = await _syncService.downloadSingleFile(
      file,
      onProgress: (progress) {
        downloadProgress = progress;
        notifyListeners();
      },
    );

    if (localPath != null) {
      // Reload the single file state from local storage to be sure
      final files = await _localStorage.getFiles(file.folderid);
      currentFiles = files;
    }

    downloadingFileId = null;
    notifyListeners();
  }

  Future<void> syncNow() async {
    if (isSyncing) return;
    if (isOffline) return;

    isSyncing = true;
    notifyListeners();

    final (folderRes, fileRes) = await _syncService.performFullSync();
    allFolders = await _localStorage.getFolders();
    await updateFolderStats();
    updateCurrentView();

    if (currentFolder != null) {
      await _fetchFilesForFolder(currentFolder!.id);
    }
    
    print('DCC Manual Sync Complete:');
    if (folderRes != null) {
      print('- Folders: New(${folderRes.newFolders.length}), Updated(${folderRes.updatedFolders.length}), Deleted(${folderRes.deletedFolderIds.length})');
    }
    if (fileRes != null) {
      print('- Files: New(${fileRes.newFiles.length}), Updated(${fileRes.updatedFiles.length}), Deleted(${fileRes.deletedFileIds.length})');
    }
    final offlineFilesCount = (await _localStorage.getAllFiles()).where((f) => f.isDownloaded).length;
    print('- Total Files Available Offline: $offlineFilesCount');

    isSyncing = false;
    notifyListeners();
  }

  void _performBackgroundSync() {
    if (isSyncing) return;
    isSyncing = true;
    notifyListeners();

    _syncService.performFullSync().then((results) async {
      final (folderSyncResult, fileSyncResult) = results;
      
      if (currentFolder != null) {
        final files = await _localStorage.getFiles(currentFolder!.id);
        if (files.isNotEmpty) currentFiles = files;
      }
      await updateFolderStats();
      
      print('DCC Background Sync Detailed Stats:');
      if (folderSyncResult != null) {
        print('- Folders: New(${folderSyncResult.newFolders.length}), Updated(${folderSyncResult.updatedFolders.length}), Deleted(${folderSyncResult.deletedFolderIds.length})');
      }
      if (fileSyncResult != null) {
        print('- Files: New(${fileSyncResult.newFiles.length}), Updated(${fileSyncResult.updatedFiles.length}), Deleted(${fileSyncResult.deletedFileIds.length})');
      }
      final offlineFilesCount = (await _localStorage.getAllFiles()).where((f) => f.isDownloaded).length;
      print('- Total Files Available Offline: $offlineFilesCount');

      isSyncing = false;
      notifyListeners();
    }).catchError((e) {
      isSyncing = false;
      notifyListeners();
    });
  }

  Future<void> refreshCurrentFolder() async {
    if (currentFolder != null) {
      await _fetchFilesForFolder(currentFolder!.id);
    } else {
      await initDcc();
    }
  }

  bool get isAtRoot => currentFolder == null;
  String get currentLocationTitle => isAtRoot ? 'Document Control Center' : currentFolder!.name;
  bool get isCurrentEmpty => visibleFolders.isEmpty && visibleFiles.isEmpty;
  
  // Removed visibleFiles getter as it is now defined above

  List<DccFileModel> get visibleSearchFiles {
    if (isOffline) {
      return searchFilesResult.where((f) => f.isDownloaded).toList();
    }
    return searchFilesResult;
  }

  Future<void> updateFolderStats({int? onlyForFolderId}) async {
    try {
      if (onlyForFolderId != null) {
        // Targeted update for one folder to save memory/CPU
        var folderFiles = await _localStorage.getFiles(onlyForFolderId);
        if (isOffline) {
          folderFiles = folderFiles.where((f) => f.isDownloaded).toList();
        }
        folderFileCounts[onlyForFolderId] = folderFiles.length;
      } else {
        // Full update (only call when necessary)
        allFolders = await _localStorage.getFolders();
        final allFiles = await _localStorage.getAllFiles();
        final Map<int, int> counts = {};
        for (final file in allFiles) {
          if (isOffline && !file.isDownloaded) continue;
          counts[file.folderid] = (counts[file.folderid] ?? 0) + 1;
        }
        folderFileCounts = counts;
      }
      notifyListeners();
    } catch (e) {
      // Keep existing counts or default to empty on error
      print('Error updating folder stats: $e');
    }
  }

  Future<void> startConnectivityListener() async {
    // Initial check
    final results = await Connectivity().checkConnectivity();
    _updateConnectivity(results);

    // Stream listener
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      _updateConnectivity(results);
    });
  }

  void _updateConnectivity(List<ConnectivityResult> results) {
    final wasOffline = isOffline;
    isOffline = results.contains(ConnectivityResult.none) || results.isEmpty;
    
    if (wasOffline != isOffline) {
      updateFolderStats();
      notifyListeners();
      // If we just came back online, trigger a background sync
      if (!isOffline) {
        _performBackgroundSync();
      }
    }
  }


  void disposeConnections() {
    _syncTimer?.cancel();
    _debounceTimer?.cancel();
    _searchDebounceTimer?.cancel();
    stopHiveListeners();

  }

  void reset() {
    allFolders = [];
    currentFolders = [];
    currentFiles = [];
    breadcrumb = [];
    currentFolder = null;
    folderFileCounts = {};
    isSyncing = false;
    isSilentSyncing = false;
    downloadingFileId = null;
    downloadProgress = 0.0;
    searchFilesResult = [];
    searchFoldersResult = [];
    isSearching = false;
    searchQuery = "";
    _preSearchFolder = null;
    _preSearchBreadcrumb = [];
    _isSearchStateSaved = false;
    filteredFileId = null;
    notifyListeners();
  }




  void searchFile({int searchRootFolderId = 0,
  int folderId = 0,
  String searchQuery = ""}){
    this.searchQuery = searchQuery;
    
    if (searchQuery.trim().isEmpty) {
      clearSearch();
      return;
    }

    if (!isSearching && !_isSearchStateSaved) {
      _preSearchFolder = currentFolder;
      _preSearchBreadcrumb = List.from(breadcrumb);
      _isSearchStateSaved = true;
    }

    isSearching = true;
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () async {
      final token = beginLoadingWithStatus();
      
      try {
        final queryLower = searchQuery.toLowerCase();
        
        final Set<int> descendantIds = {};
        int? startParentId = currentFolder?.id;
        if (startParentId == null && searchRootFolderId != 0) {
          startParentId = searchRootFolderId;
        }
        
        void findChildren(int? parentId) {
          final children = allFolders.where((f) => f.parentId == parentId);
          for (final child in children) {
            if (!descendantIds.contains(child.id)) {
              descendantIds.add(child.id);
              findChildren(child.id);
            }
          }
        }
        
        if (startParentId != null) {
          descendantIds.add(startParentId);
        }
        findChildren(startParentId);

        searchFoldersResult = allFolders.where((f) {
          if (startParentId != null && f.id == startParentId) return false;
          if (startParentId != null && !descendantIds.contains(f.id)) return false;
          return f.name.toLowerCase().contains(queryLower);
        }).toList();

        final allLocalFiles = await _localStorage.getAllFiles();
        searchFilesResult = allLocalFiles.where((f) {
          if (startParentId != null && !descendantIds.contains(f.folderid)) return false;
          return f.filename.toLowerCase().contains(queryLower);
        }).toList();

        changeLoadingStatusIfActive(
          token: token,
          loadingStatus: DccLoadingStatus(loader: DccLoader.success),
        );
      } catch (e) {
        changeLoadingStatusIfActive(
          token: token,
          loadingStatus: DccLoadingStatus(loader: DccLoader.error),
        );
      }
    });
    notifyListeners();
  }

  int? notificationId;
  void setNotificationId(int id){
    notificationId =  id;
    updateNotificationStatus();
  }


  void updateNotificationStatus() {
    if(notificationId == null || notificationId == 0){
      return;
    }


    DocumentControlCenterUseCase().updateNotificationStatus(
        notificationId: notificationId??0,
        onRequestSuccess: (notificationId) {
          removeNotificationUsingIdList(notificationId);


        },
        onRequestFailure: (exception) {

        });
  }
  Future<void> removeNotificationUsingIdList(int notificationId) async {
    if(Platform.isAndroid) {
      Eraser.clearAppNotificationsById(notificationId);
    }

  }

  Future<void> commitSearchAndNavigate(DccFolderModel folder) async {
    isSearching = false;
    searchQuery = "";
    searchFilesResult = [];
    searchFoldersResult = [];
    _searchDebounceTimer?.cancel();
    _isSearchStateSaved = false; // Discard pre-search state
    
    await navigateToFolder(folder);
  }

  void clearSearch() {
    clearFilter();
    isSearching = false;
    searchQuery = "";
    searchFilesResult = [];
    searchFoldersResult = [];
    _searchDebounceTimer?.cancel();

    if (_isSearchStateSaved) {
      currentFolder = _preSearchFolder;
      breadcrumb = List.from(_preSearchBreadcrumb);
      _isSearchStateSaved = false;
    }

    updateCurrentView();
  }

}
