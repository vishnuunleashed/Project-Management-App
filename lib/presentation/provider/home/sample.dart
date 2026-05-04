// import 'dart:async';
// import 'dart:io';
//
// import 'package:base/core/constants.dart';
// import 'package:base/core/loader_value.dart';
// import 'package:base/data/models/login/login_model.dart';
// import 'package:base/data/repository/local/base_prefs.dart';
// import 'package:base/data/services/utils/app_exceptions.dart';
// import 'package:base/presentation/provider/base_provider.dart';
// import 'package:base/presentation/theme_config.dart';
// import 'package:base/presentation/utility/base_dialog.dart';
// import 'package:base/presentation/utility/navigator_key.dart';
// import 'package:base/presentation/views/base_elevated_button.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:interior_design/data/local/hive/dcc_project_model.dart';
// import 'package:interior_design/data/local/hive/project_local_storage_service.dart';
// import 'package:interior_design/data/local/hive/project_sync_service.dart';
// import 'package:interior_design/data/model/response/home/count_update_dto.dart';
// import 'package:interior_design/data/model/response/home/home_projectlist_model.dart';
// import 'package:interior_design/data/model/response/home/notification_count_model.dart';
// import 'package:interior_design/data/model/response/project_location/user_status.dart';
// import 'package:interior_design/data/remote/repository/project_location/project_location_impl.dart';
// import 'package:interior_design/domain/usecase/home/home_usecase.dart';
// import 'package:interior_design/domain/usecase/project_details/project_details_usecase.dart';
// import 'package:interior_design/domain/usecase/project_location/project_location_usecase.dart';
// import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
// import 'package:interior_design/presentation/provider/login_and_splash/login_provider.dart';
// import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
//
// class HomeProvider extends BaseProvider {
//   // ========================= Project Data =========================
//   List<HomeProjectListModel> projectLists = [];
//   List<UserRightsModel> rightsLists = [];
//   List<HomeProjectListModel> projectListWithFilter = [];
//
//   // ========================= UI Controllers =========================
//   TextEditingController searchController = TextEditingController();
//   FocusNode searchFocusNode = FocusNode();
//   PageController pageController = PageController();
//   PageController pageControllerHome = PageController(initialPage: 0);
//   ItemScrollController tileListScrollController = ItemScrollController();
//
//   // ========================= UI State =========================
//   String userName = '';
//   bool isSearching = false;
//   int selectedIndex = 0;
//   int selectedOptionIndex = 0;
//   int tabCount = 0;
//   int? expandedIndex;
//   int currentPageIndex = 0;
//
//   // ========================= User Rights =========================
//   bool addObservationRight = false;
//   bool addSupportRight = false;
//   bool addAdditionalMaterial = false;
//   bool closeObservationRight = false;
//   bool closeSupportRight = false;
//   bool viewSupportDashBoard = false;
//   bool viewObservationDashBoard = false;
//   bool mobMarkPresenceRight = false;
//
//   String addObservationOptionName = '';
//   String addSupportOptionName = '';
//   String addAdditionalMaterialOptionName = '';
//   String closeSupportOptionName = '';
//   String closeObservationOptionName = '';
//   String mobMarkPresenceName = '';
//
//   // ========================= User Info =========================
//   bool isSuperUser = false;
//   bool isProjectDepartment = false;
//   bool isProcurementDepartment = false;
//   String profileImageUrl = '';
//
//   // ========================= Sign In Status =========================
//   List<SignInResultObjectModel> signInStatusList = [];
//   bool oneSignedIn = false;
//   bool checkInLoaderStatus = false;
//
//   // ========================= Sync Management =========================
//   final syncService = ProjectSyncService();
//   Timer? _syncTimer;
//   StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
//   bool _isSyncing = false; // Prevent concurrent syncs
//   List<NotifyCountDTO> notificationCountData = [];
//
//   // ========================= INITIALIZATION =========================
//
//   Future<void> initValues() async {
//     try {
//       // Load user profile and department info
//       profileImageUrl = await BaseSecureStorage.getString(
//           BaseConstants.loggedInUserProfileImageUrl);
//       isProjectDepartment = await BaseSecureStorage.getString(
//           BaseConstants.departmentCode) ==
//           "PRJ";
//       isProcurementDepartment = await BaseSecureStorage.getString(
//           BaseConstants.departmentCode) ==
//           "PRC";
//       isSuperUser =
//       await BaseSecureStorage.getBool(BaseConstants.superUserYN);
//
//       // Reset UI state
//       selectedIndex = 0;
//       currentPageIndex = 0;
//       expandedIndex = null;
//       selectedOptionIndex = 0;
//       projectLists = [];
//       rightsLists = [];
//       projectListWithFilter = [];
//       searchController = TextEditingController();
//       isSearching = false;
//       tabCount = 0;
//
//       // Load username
//       await initStaticValues();
//
//       // Load cached projects first (offline-first approach)
//       await _loadCachedProjects();
//
//       // Fetch fresh data from API
//       await fetchProjectDetails();
//
//       // Fetch notification counts
//       fetchNotificationCountList(updateBadgeCount: false);
//
//       // Start periodic sync background task
//       await syncAllProjectsDccWithTimer();
//
//       notifyListeners();
//     } catch (e) {
//       print('[InitValues] Error: $e');
//     }
//   }
//
//   /// Load cached projects from Hive
//   Future<void> _loadCachedProjects() async {
//     try {
//       final cachedProjects = await syncService.loadCachedProjects();
//       final homeProjects = cachedProjects.map((e) {
//         return HomeProjectListModel(
//           projectId: e.projectId,
//           project: e.projectName,
//           projectLocation: e.location,
//           projectEndDate: e.endDate,
//           rootFolderId: e.rootFolderId,
//         );
//       }).toList();
//
//       if (homeProjects.isNotEmpty) {
//         projectLists = homeProjects;
//         projectListWithFilter = homeProjects;
//         print(
//             '[Cache] Loaded ${homeProjects.length} projects from cache');
//         notifyListeners();
//       }
//     } catch (e) {
//       print('[Cache Error] Failed to load cached projects: $e');
//     }
//   }
//
//   Future<void> initStaticValues() async {
//     userName = await BaseSecureStorage.getString(BaseConstants.userName);
//     notifyListeners();
//   }
//
//   // ========================= MAIN FETCH METHOD =========================
//
//   /// Fetch all project details from API and sync with cache
//   Future<void> fetchProjectDetails() async {
//     expandedIndex = null;
//     checkInLoaderStatus = false;
//
//     // Prevent concurrent syncs
//     if (_isSyncing) {
//       print('[FetchProjectDetails] Already syncing, skipping duplicate call');
//       return;
//     }
//
//     _isSyncing = true;
//     changeLoadingStatus(
//         loadingStatus: LoadingStatus(loader: Loader.loading));
//
//     try {
//       // 1. Fetch from API
//       final result = await _fetchProjectListFromAPI();
//
//       if (result == null || result.projectList.isEmpty) {
//         changeLoadingStatus(
//             loadingStatus: LoadingStatus(loader: Loader.success));
//         checkInLoaderStatus = true;
//         _isSyncing = false;
//         notifyListeners();
//         return;
//       }
//
//       // 2. Update main lists
//       projectLists = result.projectList;
//       projectListWithFilter = result.projectList;
//       rightsLists = result.userRights;
//
//       // 3. Update user rights
//       _updateUserRights();
//
//       // 4. Persist API results to Hive (CRITICAL: was missing)
//       await _persistProjectsToCache(projectLists);
//
//       // 5. Fetch missing rootFolderIds in parallel
//       final projectsNeedingRootFolder = projectLists
//           .where((p) => p.projectId != null && p.rootFolderId == null)
//           .toList();
//
//       if (projectsNeedingRootFolder.isNotEmpty) {
//         print(
//             '[FetchProjectDetails] Fetching rootFolderIds for ${projectsNeedingRootFolder.length} projects');
//         await _fetchAndCacheRootFolderIds(projectsNeedingRootFolder);
//       }
//
//       // 6. Merge with cached data
//       await _mergeWithCachedProjects();
//
//       // 7. Load sign-in statuses
//       await loadAllStatusesParallel();
//
//       changeLoadingStatus(
//           loadingStatus: LoadingStatus(loader: Loader.success));
//       notifyListeners();
//     } catch (exception) {
//       print('[FetchProjectDetails] Error: $exception');
//       changeLoadingStatus(
//           loadingStatus: LoadingStatus(
//               loader: Loader.error, exception: AppException(exception.toString())));
//     } finally {
//       _isSyncing = false;
//     }
//   }
//
//   /// Convert callback-based API call to Future
//   Future<HomeDashboardWrapper?> _fetchProjectListFromAPI() async {
//     final completer = Completer<HomeDashboardWrapper?>();
//
//     HomeUseCase().fetchProjectList(
//       onRequestSuccess: (result) {
//         print('[API] Received ${result.projectList.length} projects');
//         completer.complete(result);
//       },
//       onRequestFailure: (exception) {
//         print('[API] Error: $exception');
//         completer.completeError(exception);
//       },
//     );
//
//     return completer.future;
//   }
//
//   /// Persist projects to Hive cache
//   Future<void> _persistProjectsToCache(
//       List<HomeProjectListModel> projects) async {
//     try {
//       for (final project in projects) {
//         await syncService.cacheSingleProject(DccProjectModel(
//           projectId: project.projectId,
//           projectName: project.project,
//           location: project.projectLocation,
//           endDate: project.projectEndDate,
//           rootFolderId: project.rootFolderId,
//         ));
//       }
//       print(
//           '[Cache] Persisted ${projects.length} projects to Hive');
//     } catch (e) {
//       print('[Cache Error] Failed to persist projects: $e');
//     }
//   }
//
//   /// Fetch rootFolderIds for multiple projects in parallel
//   Future<void> _fetchAndCacheRootFolderIds(
//       List<HomeProjectListModel> projectsNeedingRootFolder) async {
//     final futures = projectsNeedingRootFolder
//         .map((project) => _fetchSingleRootFolderId(project))
//         .toList();
//
//     // Wait for all with error handling
//     await Future.wait(futures, eagerError: false);
//     print('[RootFolder] Completed fetching for all projects');
//   }
//
//   /// Fetch and cache rootFolderId for a single project
//   Future<void> _fetchSingleRootFolderId(
//       HomeProjectListModel project) async {
//     final projectId = project.projectId;
//     if (projectId == null) return;
//
//     try {
//       final completer = Completer<void>();
//
//       ProjectDetailsUseCase().fetchProjectDocMappingDetails(
//         projectId: projectId,
//         onRequestSuccess: (data) async {
//           try {
//             int? rootId;
//             final List<dynamic> list = data['resultObject'] ?? [];
//
//             if (list.isNotEmpty) {
//               rootId = list.first['folderid'] as int? ??
//                   list.first['folderId'] as int?;
//             }
//
//             if (rootId != null) {
//               // Update in-memory project
//               final index = projectLists.indexWhere((p) => p.projectId == projectId);
//               if (index != -1) {
//                 projectLists[index] =
//                     projectLists[index].copyWith(rootFolderId: rootId);
//               }
//
//               // Cache to Hive
//               await syncService.cacheSingleProject(DccProjectModel(
//                 projectId: project.projectId,
//                 projectName: project.project,
//                 location: project.projectLocation,
//                 endDate: project.projectEndDate,
//                 rootFolderId: rootId,
//               ));
//
//               print(
//                   '[RootFolder] Cached for project $projectId: rootId=$rootId');
//             }
//
//             completer.complete();
//           } catch (e) {
//             print(
//                 '[RootFolder] Error processing data for project $projectId: $e');
//             completer.complete();
//           }
//         },
//         onRequestFailure: (exception) {
//           print(
//               '[RootFolder] Failed to fetch for project $projectId: $exception');
//           completer.complete();
//         },
//       );
//
//       return completer.future;
//     } catch (e) {
//       print('[RootFolder] Unexpected error for project $projectId: $e');
//     }
//   }
//
//   /// Merge API data with cached data using efficient Map lookup (NOT nested loops!)
//   Future<void> _mergeWithCachedProjects() async {
//     try {
//       final cachedProjects =
//       await ProjectLocalStorageService().getProjects();
//
//       // Create O(1) lookup map instead of O(n²) nested loops
//       final cachedMap = <int, DccProjectModel>{};
//       for (final project in cachedProjects) {
//         if (project.projectId != null) {
//           cachedMap[project.projectId!] = project;
//         }
//       }
//
//       // Single pass merge
//       for (int i = 0; i < projectLists.length; i++) {
//         final projectId = projectLists[i].projectId;
//         if (projectId != null && cachedMap.containsKey(projectId)) {
//           projectLists[i] = projectLists[i]
//               .copyWith(rootFolderId: cachedMap[projectId]?.rootFolderId);
//         }
//       }
//
//       // Sync filter list
//       projectListWithFilter = List.from(projectLists);
//
//       print('[Merge] Merged ${cachedMap.length} cached projects');
//     } catch (e) {
//       print('[Merge Error] Failed to merge cached projects: $e');
//     }
//   }
//
//   /// Update user rights from API response
//   void _updateUserRights() {
//     addObservationOptionName = getOptionNameIfHasRights(
//       optionCode: 'MOB_ADD_OBSERVATION',
//     );
//     addObservationRight = addObservationOptionName.isNotEmpty;
//
//     addSupportOptionName =
//         getOptionNameIfHasRights(optionCode: 'MOB_ADD_SUPPORT_REQUEST');
//     addSupportRight = addSupportOptionName.isNotEmpty;
//
//     addAdditionalMaterialOptionName =
//         getOptionNameIfHasRights(optionCode: 'MOB_ADDT_MAT_CHART');
//     addAdditionalMaterial = addAdditionalMaterialOptionName.isNotEmpty;
//
//     closeObservationOptionName =
//         getOptionNameIfHasRights(optionCode: 'MOB_CLOSE_OBSERVATION');
//     closeObservationRight = closeObservationOptionName.isNotEmpty;
//
//     closeSupportOptionName =
//         getOptionNameIfHasRights(optionCode: 'MOB_CLOSE_SUPPORT_REQ');
//     closeSupportRight = closeSupportOptionName.isNotEmpty;
//
//     viewObservationDashBoard = getOptionNameIfHasRights(
//         optionCode: 'MOB_OBSERV_DASHBOARD', isAddRights: false)
//         .isNotEmpty;
//     viewSupportDashBoard = getOptionNameIfHasRights(
//         optionCode: 'MOB_SUP_REQ_DASHBOARD', isAddRights: false)
//         .isNotEmpty;
//
//     mobMarkPresenceName =
//         getOptionNameIfHasRights(optionCode: 'MOB_MARK_PRESENCE');
//     mobMarkPresenceRight = mobMarkPresenceName.isNotEmpty;
//   }
//
//   String getOptionNameIfHasRights(
//       {required String optionCode, bool isAddRights = true}) {
//     String optionName = '';
//     for (var right in rightsLists) {
//       if (right.optionCode?.toUpperCase() == optionCode.toUpperCase()) {
//         if (right.rightsData.isNotEmpty) {
//           if (isAddRights
//               ? right.rightsData.first.addRightSyn?.toUpperCase() == 'Y'
//               : right.rightsData.first.allowAccessYn?.toUpperCase() == 'Y') {
//             optionName = right.optionName ?? '';
//           }
//         }
//         return optionName;
//       }
//     }
//     return optionName;
//   }
//
//   // ========================= SYNC TIMER MANAGEMENT =========================
//
//   /// Start periodic sync with proper timer management
//   Future<void> syncAllProjectsDccWithTimer() async {
//     // Cancel any existing timer to prevent duplicates
//     _syncTimer?.cancel();
//     _syncTimer = null;
//
//     try {
//       int syncIntervalInSeconds =
//       await BaseSecureStorage.getIntervalInSeconds(
//           BaseConstants.syncInterval);
//
//       // Perform initial sync
//       print('[Sync] Starting initial DCC sync');
//       await syncService.syncAllProjectsDcc();
//
//       // Start periodic sync with error handling
//       _syncTimer = Timer.periodic(
//         Duration(seconds: syncIntervalInSeconds),
//             (timer) async {
//           try {
//             print('[Sync] Running periodic DCC sync');
//             await syncService.syncAllProjectsDcc();
//           } catch (e) {
//             print('[Sync Error] Periodic sync failed: $e');
//           }
//         },
//       );
//
//       print(
//           '[Sync] Timer started with interval: ${syncIntervalInSeconds}s');
//     } catch (e) {
//       print('[Sync Error] Failed to initialize sync timer: $e');
//     }
//   }
//
//   /// Dispose all connections and timers
//   void disposeConnections() {
//     print('[Dispose] Cleaning up connections and timers');
//
//     _syncTimer?.cancel();
//     _syncTimer = null;
//
//     _connectivitySubscription?.cancel();
//     _connectivitySubscription = null;
//   }
//
//   // ========================= SIGN IN STATUS =========================
//
//   /// Load all sign-in statuses in parallel
//   Future<void> loadAllStatusesParallel() async {
//     if (projectListWithFilter.isEmpty) {
//       checkInLoaderStatus = true;
//       notifyListeners();
//       return;
//     }
//
//     final futures = <Future<void>>[];
//
//     for (int i = 0; i < projectListWithFilter.length; i++) {
//       final projectId = projectListWithFilter[i].projectId;
//       if (projectId != null) {
//         futures.add(_getUserSignInStatusSync(projectId: projectId, index: i));
//       }
//     }
//
//     await Future.wait(futures);
//
//     checkInLoaderStatus = true;
//     notifyListeners();
//   }
//
//   Future<void> _getUserSignInStatusSync(
//       {required int projectId, required int index}) async {
//     final completer = Completer<void>();
//
//     ProjectLocationUseCase().getUserSignInStatus(
//       projectId: projectId,
//       onRequestSuccess: (isSignedIn) {
//         if (index < projectListWithFilter.length) {
//           projectListWithFilter[index] =
//               projectListWithFilter[index].copyWith(isSignedIn: isSignedIn);
//           oneSignedIn = projectListWithFilter.any((item) =>
//           item.isSignedIn == true);
//         }
//         completer.complete();
//       },
//       onRequestFailure: (exception) {
//         print(
//             '[SignInStatus] Error loading status for project $projectId: $exception');
//         completer.complete();
//       },
//     );
//
//     return completer.future;
//   }
//
//   Future<void> getUserSignInStatus({required int projectId}) async {
//     ProjectLocationUseCase().getUserSignInStatus(
//       projectId: projectId,
//       onRequestSuccess: (isSignedIn) {
//         final index = projectListWithFilter.indexWhere((p) => p.projectId == projectId);
//         if (index != -1) {
//           projectListWithFilter[index] =
//               projectListWithFilter[index].copyWith(isSignedIn: isSignedIn);
//         }
//         oneSignedIn = projectListWithFilter.any((item) => item.isSignedIn == true);
//         notifyListeners();
//       },
//       onRequestFailure: (exception) {
//         changeLoadingStatus(
//           loadingStatus: LoadingStatus(
//               loader: Loader.error, message: exception.toString()),
//         );
//       },
//     );
//   }
//
//   void signInToProjectLocation({required LocationParams params}) {
//     changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
//     ProjectLocationUseCase().signInToProjectLocation(
//       params: params,
//       onRequestSuccess: (message) {
//         changeLoadingStatus(
//             loadingStatus: LoadingStatus(loader: Loader.success));
//         BaseDialog.show(
//           context: NavigatorKey.navKey.currentContext!,
//           title: "Success",
//           message: message,
//           icon: Icon(Icons.check_circle_outline,
//               color: bayaInfraGreen, size: 36),
//           actions: [
//             BaseElevatedButton(
//               borderRadius: 24,
//               onPressed: () {
//                 GoRouter.of(NavigatorKey.navKey.currentContext!).pop();
//               },
//               backgroundColor: Theme.of(NavigatorKey.navKey.currentState!.context)
//                   .primaryColor,
//               text: "Ok",
//             ),
//           ],
//         );
//       },
//       onRequestFailure: (exception) {
//         changeLoadingStatus(
//             loadingStatus: LoadingStatus(loader: Loader.success));
//         BaseDialog.show(
//           context: NavigatorKey.navKey.currentContext!,
//           title: "Alert",
//           message: "$exception",
//           icon:
//           Icon(Icons.warning, color: bayaInfraAmber, size: 36),
//           actions: [
//             BaseElevatedButton(
//               borderRadius: 24,
//               onPressed: () {
//                 GoRouter.of(NavigatorKey.navKey.currentContext!).pop();
//               },
//               backgroundColor: Theme.of(NavigatorKey.navKey.currentState!.context)
//                   .primaryColor,
//               text: "Ok",
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void signOutToProjectLocation({required LocationParams params}) {
//     changeLoadingStatus(
//         loadingStatus: LoadingStatus(loader: Loader.success));
//     ProjectLocationUseCase().signOutToProjectLocation(
//       params: params,
//       onRequestSuccess: (message) {
//         changeLoadingStatus(
//             loadingStatus: LoadingStatus(loader: Loader.success));
//         BaseDialog.show(
//           context: NavigatorKey.navKey.currentContext!,
//           title: "Success",
//           message: message,
//           icon: Icon(Icons.check_circle_outline,
//               color: bayaInfraGreen, size: 36),
//           actions: [
//             BaseElevatedButton(
//               borderRadius: 24,
//               onPressed: () {
//                 GoRouter.of(NavigatorKey.navKey.currentContext!).pop();
//               },
//               backgroundColor: Theme.of(NavigatorKey.navKey.currentState!.context)
//                   .primaryColor,
//               text: "Ok",
//             ),
//           ],
//         );
//       },
//       onRequestFailure: (exception) {
//         BaseDialog.show(
//           context: NavigatorKey.navKey.currentContext!,
//           title: "Failure",
//           message: "$exception",
//           icon: Icon(Icons.close, color: bayaInfraRed, size: 36),
//           actions: [
//             BaseElevatedButton(
//               borderRadius: 24,
//               onPressed: () {
//                 GoRouter.of(NavigatorKey.navKey.currentContext!).pop();
//               },
//               backgroundColor: Theme.of(NavigatorKey.navKey.currentState!.context)
//                   .primaryColor,
//               text: "Ok",
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void uploadImageFile({
//     required LocationParams params,
//     required List<File> files,
//   }) async {
//     changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
//     await ProjectLocationUseCase().uploadImageFile(
//       file: files,
//       uploadProgress: (progress) {
//         loadingProgress = progress;
//         changeLoadingStatus(
//             loadingStatus: LoadingStatus(loader: Loader.success));
//         notifyListeners();
//       },
//       attachmentSerialNo: "",
//       onRequestSuccess: (response) {
//         params = params.copyWith(imagesDtl: response);
//         signInToProjectLocation(params: params);
//       },
//       onRequestFailure: (exception) {
//         changeLoadingStatus(loadingStatus:
//         LoadingStatus(loader: Loader.error, exception: exception));
//       },
//     );
//   }
//
//   // ========================= NOTIFICATION COUNT =========================
//
//   Future<void> fetchPendingCount({required List<int> projectIds}) async {
//     HomeUseCase().fetchPendingCount(
//       projectIds: projectIds,
//       onRequestSuccess: (List<ProjectStats> list) {
//         if (list.isNotEmpty) {
//           for (var item in projectLists) {
//             if (item.projectId == list.first.projectid) {
//               item.pendingObservation = list.first.pendingobservation;
//               item.pendingSupportReq = list.first.pendingsupportreq;
//             }
//           }
//         }
//         notifyListeners();
//       },
//       onRequestFailure: (exception) {
//         changeLoadingStatus(loadingStatus:
//         LoadingStatus(loader: Loader.error, exception: exception));
//       },
//     );
//   }
//
//   void fetchNotificationCountList({bool updateBadgeCount = true}) async {
//     HomeUseCase().fetchNotificationCountList(
//       onRequestSuccess: (result) async {
//         notificationCountData = result;
//         notifyListeners();
//       },
//       onRequestFailure: (exception) {
//         changeLoadingStatus(loadingStatus:
//         LoadingStatus(loader: Loader.error, exception: exception));
//       },
//     );
//   }
//
//   // ========================= UI STATE MANAGEMENT =========================
//
//   void resetSelectedIndex() {
//     expandedIndex = null;
//     notifyListeners();
//   }
//
//   void onTabSelected(int index) {
//     selectedOptionIndex = index;
//     searchFocusNode.unfocus();
//     notifyListeners();
//   }
//
//   void onItemTapped(int index) {
//     selectedIndex = index;
//     print("Selected index = $selectedIndex");
//     notifyListeners();
//     searchFocusNode = FocusNode();
//   }
//
//   void updateCurrentPageIndex(int index) {
//     currentPageIndex = index;
//     notifyListeners();
//   }
//
//   void onPageChanged(int index) {
//     selectedOptionIndex = index;
//     notifyListeners();
//   }
//
//   Future<void> changeExpanded(int index) async {
//     expandedIndex = index;
//     if (index > 2) {
//       tileListScrollController.scrollTo(
//         index: index - 1,
//         duration: const Duration(milliseconds: 700),
//         curve: Curves.easeInOut,
//       );
//     }
//     notifyListeners();
//   }
//
//   void changeIsSearching() {
//     isSearching = !isSearching;
//     if (!isSearching) {
//       searchController.clear();
//       projectListWithFilter = projectLists;
//       searchFocusNode.unfocus();
//     } else {
//       searchFocusNode.requestFocus();
//     }
//     notifyListeners();
//   }
//
//   void removeSearch() {
//     isSearching = false;
//     searchController.clear();
//     searchFocusNode = FocusNode();
//     notifyListeners();
//   }
//
//   void changeSearchText(String searchText) {
//     expandedIndex = null;
//     if (searchText.isEmpty) {
//       projectListWithFilter = List.from(projectLists);
//       notifyListeners();
//       return;
//     }
//     searchText = searchText.toLowerCase().trim();
//     projectListWithFilter = projectLists.where((project) {
//       final projectName = project.project?.toLowerCase() ?? '';
//       final location = project.projectLocation?.toLowerCase() ?? '';
//       return projectName.contains(searchText) ||
//           location.contains(searchText);
//     }).toList();
//
//     notifyListeners();
//   }
//
//   List<String> getTabLabels(List<ModuleListDto> moduleList) {
//     if (moduleList.isEmpty) {
//       tabCount = 0;
//       return [];
//     } else {
//       List<String> tabLabels = moduleList.map((module) => module.label).toList();
//       tabCount = tabLabels.length;
//       return tabLabels;
//     }
//   }
//
//   void onPageSelected(int index) {
//     pageControllerHome.animateToPage(index,
//         duration: Duration(milliseconds: 800), curve: Curves.easeOut);
//     searchFocusNode.unfocus();
//     notifyListeners();
//   }
//
//   List<String> tabLabels = [];
//   List<ModuleListDto> moduleList = [];
//
//   void initModuleList(
//       {required TickerProvider ticker,
//         required LoginProvider loginProvider}) {
//     ModuleListDto? list = loginProvider.loginDetails.isEmpty ||
//         loginProvider.loginDetails.first.modulelist.isEmpty
//         ? null
//         : !loginProvider.loginDetails.first.modulelist.first.children
//         .any((element) => element.label == "Home Mob")
//         ? null
//         : loginProvider.loginDetails.first.modulelist.first.children
//         .firstWhere((element) => element.label == "Home Mob");
//
//     moduleList = list == null ? [] : list.children.reversed.toList();
//     tabLabels = getTabLabels(moduleList);
//
//     notifyListeners();
//   }
//
//   // ========================= CLEANUP =========================
//
//   @override
//   void dispose() {
//     disposeConnections();
//
//     // Dispose controllers and focus nodes
//     searchController.dispose();
//     searchFocusNode.dispose();
//     pageController.dispose();
//     pageControllerHome.dispose();
//
//     print('[Dispose] HomeProvider disposed completely');
//     super.dispose();
//   }
//
//   /// Manual refresh - useful for pull-to-refresh
//   Future<void> refreshProjects() async {
//     print('[Refresh] Manual refresh triggered');
//     await fetchProjectDetails();
//   }
// }