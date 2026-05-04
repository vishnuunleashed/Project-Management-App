import 'dart:async';
import 'package:base/data/services/_connection_props.dart';
import 'package:dcc_module/data/local/dcc_local_storage_service.dart';
import 'package:interior_design/data/local/hive/dcc_project_model.dart';
import 'package:interior_design/data/local/hive/project_local_storage_service.dart';
import 'package:interior_design/data/model/response/home/home_projectlist_model.dart';
import 'package:dcc_module/domain/usecase/dcc_sync_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:base/core/constants.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:interior_design/data/local/hive/home_projectlist_model_adapter.dart';
import 'package:dcc_module/dcc_module.dart';
import 'package:interior_design/domain/usecase/home/home_usecase.dart';
import 'package:interior_design/utils/background_logger.dart';

/// Handles project list caching and multi-project DCC background sync.
class ProjectSyncService {
  static final ProjectSyncService _instance = ProjectSyncService._internal();
  factory ProjectSyncService() => _instance;
  ProjectSyncService._internal();

  final _localStorage = ProjectLocalStorageService();
  Timer? _syncTimer;

  final _localStorageDcc = DccLocalStorageService();
  /// Robust entry point for background tasks (WorkManager).
  /// Handles its own Hive initialization and credential seeding.
  static Future<void> performRobustBackgroundSync() async {
    await BackgroundLogger.log('Starting robust background sync...');
    print('Starting robust background sync...');

    try {
      // 1. Initialize Hive for the background isolate
      await Hive.initFlutter();

      // 2. Register all required adapters
      if (!Hive.isAdapterRegistered(112)) {
        Hive.registerAdapter(DccProjectHiveAdapter());
      }
      // DCC Adapters (110, 111) are handled by DccModuleConfig.init()
      // but we can also register them here for safety if needed.

      // 3. Seed Credentials from Secure Storage
      int companyId = await BaseSecureStorage.getInt(BaseConstants.companyId);
      int userId = await BaseSecureStorage.getInt(BaseConstants.userID);
      int syncInterval = await BaseSecureStorage.getInt(BaseConstants.syncInterval);
      String clientId = Connections().clientId;

      if (companyId == 0 || userId == 0) {
        await BackgroundLogger.log(' No valid user session found. Skipping sync.');
        print('No valid user session found. Skipping sync.');
        return;
      }

      await DccModuleConfig.instance.init(
        tokenProvider: () => BaseSecureStorage.getString(BaseConstants.token),
        userIdProvider: () async => userId,
        companyIdProvider: () async => companyId,
        syncIntervalProvider: () async => syncInterval,
        getClientId: () async => clientId,
      );




      await Future.wait([
      DccSyncService().performFullSync(),
      ]);
      await Future.wait([
        ProjectSyncService().syncAllProjectsDcc()
      ]);


      print('Robust background sync completed successfully.');
      await BackgroundLogger.log('Robust background sync completed successfully.');
    } catch (e) {

      await BackgroundLogger.log('Fatal error in robust background sync: $e');
    }
  }


  // ─── Hive Cache ──────────────────────────────────────────────

  /// Load cached project list from Hive.
  Future<List<DccProjectModel>> loadCachedProjects() async {
    return _localStorage.getProjects();
  }

  /// Persist the project list to Hive.
  Future<void> cacheProjects(List<DccProjectModel> projects) async {
    await _localStorage.saveProjects(projects);
  }

  Future<void> cacheSingleProject(DccProjectModel projects) async {
    await _localStorage.saveSingleProject(projects);
  }

  /// Clear local project cache (e.g. on logout).
  Future<void> clearCache() async {
    await _localStorage.clearProjects();
  }

  // ─── Background Timer ────────────────────────────────────────

  /// Start a periodic background sync.
  Future<void> startPeriodicSync(Future<void> Function() onTick) async {
    _syncTimer?.cancel();
    int syncIntervalInSeconds = await BaseSecureStorage.getIntervalInSeconds(BaseConstants.syncInterval);
    _syncTimer = Timer.periodic(Duration(seconds: syncIntervalInSeconds + 5), (_) => onTick());
  }

  /// Stop the background sync timer.
  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  // ─── DCC Sync ────────────────────────────────────────────────

  /// Sync DCC documents for every project in the cached list.
  /// Resolves rootFolderId per project and saves it back to Hive.
  Future<void> syncAllProjectsDcc({Function(List<HomeProjectListModel>)? onSuccess}) async {
    try {
      print('[ProjectSync] Starting multi-project DCC sync...');

      final result = await fetchProjectListFromAPI();
      if (result != null && result.projectList.isNotEmpty) {
        // Cache the projects (they already have rootFolderId parsed from JSON)
        final dccProjects = result.projectList.map((e) => DccProjectModel(
          projectId: e.projectId,
          projectName: e.project,
          location: e.projectLocation,
          endDate: e.projectEndDate,
          rootFolderId: e.rootFolderId,
        )).toList();
        
        await cacheProjects(dccProjects);
        print('[Cache] Persisted ${dccProjects.length} projects to Hive');

        if (onSuccess != null) {
          onSuccess(result.projectList);
        }
      }
      print('[ProjectSync] Multi-project DCC sync complete.');

    } catch (e) {
      print('[ProjectSync] Error during DCC sync: $e');
    }
  }

  Future<HomeDashboardWrapper?> fetchProjectListFromAPI() async {
    final completer = Completer<HomeDashboardWrapper?>();

    HomeUseCase().fetchProjectList(
      onRequestSuccess: (result) {
        print('[API] Received ${result.projectList.length} projects');
        completer.complete(result);
      },
      onRequestFailure: (exception) {
        print('[API] Error: $exception');
        completer.completeError(exception);
      },
    );

    return completer.future;
  }
}
