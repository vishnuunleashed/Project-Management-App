
import 'dart:async';
import 'dart:io';

import 'package:base/core/constants.dart';
import 'package:base/core/loader_value.dart';
import 'package:base/data/models/login/login_model.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:base/presentation/provider/base_provider.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/base_dialog.dart';
import 'package:base/presentation/utility/navigator_key.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/local/hive/dcc_project_model.dart';
import 'package:interior_design/data/local/hive/project_local_storage_service.dart';
import 'package:interior_design/data/local/hive/project_sync_service.dart';
import 'package:interior_design/data/model/response/home/count_update_dto.dart';
import 'package:interior_design/data/model/response/home/home_projectlist_model.dart';
import 'package:interior_design/data/model/response/home/notification_count_model.dart';
import 'package:interior_design/data/model/response/project_location/user_status.dart';
import 'package:interior_design/data/remote/repository/project_location/project_location_impl.dart';
import 'package:interior_design/domain/usecase/home/home_usecase.dart';
import 'package:interior_design/domain/usecase/project_details/project_details_usecase.dart';
import 'package:interior_design/domain/usecase/project_location/project_location_usecase.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/login_and_splash/login_provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';


class HomeProvider extends BaseProvider {

  List<HomeProjectListModel> projectLists = [];
  List<UserRightsModel> rightsLists = [];
  List<HomeProjectListModel> projectListWithFilter = [];
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();
  PageController pageController = PageController();
  String userName = '';
  bool addObservationRight = false;
  bool addSupportRight = false;
  bool addAdditionalMaterial = false;
  bool closeObservationRight = false;
  bool closeSupportRight = false;
  bool viewSupportDashBoard = false;
  bool viewObservationDashBoard = false;
  bool mobMarkPresenceRight = false;
  String addObservationOptionName = '';
  String addSupportOptionName = '';
  String addAdditionalMaterialOptionName = '';
  String closeSupportOptionName = '';
  String closeObservationOptionName = '';
  String mobMarkPresenceName = '';
  bool isSearching = false;
  int selectedIndex = 0;
  int selectedOptionIndex = 0;
  int tabCount = 0;
  int? expandedIndex;

  bool isSuperUser = false;
  bool isProjectDepartment = false;
  bool isProcurementDepartment = false;
  String profileImageUrl = '';
  
  bool isOffline = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  final syncService = ProjectSyncService();

  Future<void> initValues({int initialIndex = 0}) async {
    profileImageUrl = await BaseSecureStorage.getString(BaseConstants.loggedInUserProfileImageUrl);
    isProjectDepartment = await BaseSecureStorage.getString(BaseConstants.departmentCode) == "PRJ";
    isProcurementDepartment = await BaseSecureStorage.getString(BaseConstants.departmentCode) == "PRC";
    selectedIndex = initialIndex;
    currentPageIndex = initialIndex;
    expandedIndex = null;
    selectedOptionIndex = initialIndex;
    projectLists = [];
    rightsLists = [];
    projectListWithFilter = [];
    searchController = TextEditingController();
    isSearching = false;
    tabCount = 0;
    isSuperUser = await BaseSecureStorage.getBool(BaseConstants.superUserYN);
    initStaticValues();

    // Initial connectivity check
    final connectivityResult = await Connectivity().checkConnectivity();
    isOffline = connectivityResult.contains(ConnectivityResult.none) || connectivityResult.isEmpty;
    
    if (_connectivitySubscription == null) {
      startConnectivityListener();
    }

    fetchNotificationCountList(updateBadgeCount: false);
    fetchProjectDetails(); // Removed to avoid duplicate call on startup

    notifyListeners();
  }

  void startConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      final wasOffline = isOffline;
      isOffline = results.contains(ConnectivityResult.none) || results.isEmpty;
      
      if (wasOffline != isOffline) {
        notifyListeners();
        // If we just came back online, refresh data
        if (!isOffline) {
          fetchProjectDetails();
        }
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    searchController.dispose();
    pageController.dispose();
    pageControllerHome.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  String getOptionNameIfHasRights({required String optionCode, bool isAddRights = true}) {
    String optionName = '';
    for (var right in rightsLists) {
      if (right.optionCode?.toUpperCase() == optionCode.toUpperCase()) {
        if (right.rightsData.isNotEmpty) {
         if( isAddRights?right.rightsData.first.addRightSyn?.toUpperCase() == 'Y'
              :right.rightsData.first.allowAccessYn?.toUpperCase() == 'Y') {
           optionName = right.optionName ??'';
         }
        }
        return optionName; // No rights data found
      }
    }
    return optionName;
  }
  Future<void> initStaticValues() async {
    userName = await BaseSecureStorage.getString(BaseConstants.userName);
    notifyListeners();
  }

resetSelectedIndex(){
    expandedIndex = null;
    notifyListeners();
}
  /// Handle tab selection
  void onTabSelected(int index) {
    selectedOptionIndex = index;
    searchFocusNode.unfocus();
    notifyListeners();
  }

  /// Get tab labels from login provider modules
  List<String> getTabLabels(List<ModuleListDto> moduleList) {
    if (moduleList.isEmpty) {
      tabCount = 0;
      // Default tabs if no modules available
      return [];
    } else {
      List<String> tabLabels = moduleList.map((module) => module.label).toList();
      tabCount = tabLabels.length;
      return tabLabels;
    }
  }

  /// change index when tap on bottom navigation item
  void onItemTapped(int index) {
    selectedIndex = index;
    print("Selected index = $selectedIndex");
    notifyListeners();
    searchFocusNode = FocusNode();
  }

  ItemScrollController tileListScrollController = ItemScrollController();


  Future<void> changeExpanded(int index) async {
    expandedIndex = index;
    if(index > 2){
      tileListScrollController.scrollTo(
        index: index - 1,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    }
    notifyListeners();
  }

  changeIsSearching() {
    isSearching = !isSearching;
    if (!isSearching) {
      searchController.clear();
      projectListWithFilter = projectLists;
      searchFocusNode.unfocus();
    }
    else{
      searchFocusNode.requestFocus();
    }
    notifyListeners();
  }

  void removeSearch(){
    isSearching = false;
    searchController.clear();
    searchFocusNode = FocusNode();
    notifyListeners();
  }

  void removeSearchWithOurClearingText(){
    isSearching = false;
    searchFocusNode = FocusNode();
  }

  void scrollToTab(ScrollController controller, int index) {
    final offset = index * 100.0; // approximate width per tab
    controller.animateTo(
      offset,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }

  changeSearchText(String searchText) {
    expandedIndex = null;
    if (searchText.isEmpty) {
      projectListWithFilter = List.from(projectLists);
      notifyListeners();
      return;
    }
    searchText = searchText.toLowerCase().trim();
    projectListWithFilter = projectLists.where((project) {
      final projectName = project.project?.toLowerCase() ?? '';
      final location = project.projectLocation?.toLowerCase() ?? '';
      return projectName.contains(searchText) || location.contains(searchText);
    }).toList();

    notifyListeners();
  }

  void onPageChanged(int index) {
    selectedOptionIndex = index;
    notifyListeners();
  }
  bool oneSignedIn = false;
  bool checkInLoaderStatus = false;

  Future<void> refreshProjectListViaSync(List<HomeProjectListModel> projects) async {
    if(isOffline){

      final cachedProjects = await syncService.loadCachedProjects();
      final homeProjects = cachedProjects.map((e) {

        return HomeProjectListModel(
          projectId: e.projectId,
          project: e.projectName,
          projectLocation: e.location,
          projectEndDate: e.endDate,
          rootFolderId: e.rootFolderId,
        );
      }).toList();

      if (cachedProjects.isNotEmpty) {
        projectLists = homeProjects;
        projectListWithFilter = homeProjects;

        notifyListeners();

      }
    }else{
      if(projects.isNotEmpty){
          projectLists = projects;
          projectListWithFilter = projects;
      }
    }
    notifyListeners();
  }
  Future<void> fetchProjectDetails() async {
   if(isOffline){

     final cachedProjects = await syncService.loadCachedProjects();
     final homeProjects = cachedProjects.map((e) {

       return HomeProjectListModel(
         projectId: e.projectId,
         project: e.projectName,
         projectLocation: e.location,
         projectEndDate: e.endDate,
         rootFolderId: e.rootFolderId,
       );
     }).toList();

     if (cachedProjects.isNotEmpty) {
       projectLists = homeProjects;
       projectListWithFilter = homeProjects;

       notifyListeners();

     }
   }else{


     expandedIndex = null;
     checkInLoaderStatus = false;
     changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
     HomeUseCase().fetchProjectList(onRequestSuccess: (result) async {
       if (result.projectList.isNotEmpty) {
         projectLists = result.projectList;
         projectListWithFilter = result.projectList;

         // PERSIST TO HIVE: Ensure online refresh is available offline
         final dccProjects = projectLists.map((e) => DccProjectModel(
           projectId: e.projectId,
           projectName: e.project,
           location: e.projectLocation,
           endDate: e.projectEndDate,
           rootFolderId: e.rootFolderId,
         )).toList();
         await syncService.cacheProjects(dccProjects);

         rightsLists = result.userRights;
         addObservationOptionName = getOptionNameIfHasRights(optionCode: 'MOB_ADD_OBSERVATION',);
         addObservationRight = addObservationOptionName.isNotEmpty;
         addSupportOptionName = getOptionNameIfHasRights(optionCode: 'MOB_ADD_SUPPORT_REQUEST');
         addSupportRight = addSupportOptionName .isNotEmpty;
         addAdditionalMaterialOptionName = getOptionNameIfHasRights(optionCode: 'MOB_ADDT_MAT_CHART');
         addAdditionalMaterial = addAdditionalMaterialOptionName .isNotEmpty;
         closeObservationOptionName = getOptionNameIfHasRights(optionCode: 'MOB_CLOSE_OBSERVATION');
         closeObservationRight = closeObservationOptionName.isNotEmpty;
         closeSupportOptionName = getOptionNameIfHasRights(optionCode: 'MOB_CLOSE_SUPPORT_REQ');
         closeSupportRight = closeSupportOptionName.isNotEmpty;
         viewObservationDashBoard = getOptionNameIfHasRights(optionCode: 'MOB_OBSERV_DASHBOARD',isAddRights: false).isNotEmpty;
         viewSupportDashBoard = getOptionNameIfHasRights(optionCode: 'MOB_SUP_REQ_DASHBOARD',isAddRights: false).isNotEmpty;
         mobMarkPresenceName = getOptionNameIfHasRights(optionCode: 'MOB_MARK_PRESENCE');
         mobMarkPresenceRight = mobMarkPresenceName.isNotEmpty;
         loadAllStatusesParallel();

         changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
       }
     }, onRequestFailure: (exception) {
       changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error,exception: exception));
     });
   }
  }


  /// Merge API data with cached data using efficient Map lookup (NOT nested loops!)
  Future<void> mergeWithCachedProjects() async {
    try {
      print('Merge Sync Started');
      final cachedProjects = await ProjectLocalStorageService().getProjects();
      if (cachedProjects.isEmpty) return;

      final cachedMap = <int, DccProjectModel>{};
      for (final project in cachedProjects) {
        if (project.projectId != null) {
          cachedMap[project.projectId!] = project;
        }
      }

      // 1. Update existing projects with cached metadata
      for (int i = 0; i < projectLists.length; i++) {
        final projectId = projectLists[i].projectId;
        if (projectId != null && cachedMap.containsKey(projectId)) {
          projectLists[i] = projectLists[i].copyWith(
            rootFolderId: cachedMap[projectId]?.rootFolderId,
          );
          cachedMap.remove(projectId); // Item accounted for
        }
      }

      // 2. Add projects that are ONLY in cache (API staleness protection)
      if (cachedMap.isNotEmpty) {
        for (final missingProject in cachedMap.values) {
          projectLists.add(HomeProjectListModel(
            projectId: missingProject.projectId,
            project: missingProject.projectName,
            projectLocation: missingProject.location,
            projectEndDate: missingProject.endDate,
            rootFolderId: missingProject.rootFolderId,
          ));
        }
      }

      // Sync filter list
      projectListWithFilter = List.from(projectLists);
      notifyListeners();

      print('[Merge] Merged ${cachedProjects.length} projects (including ${cachedMap.length} unique to cache)');
    } catch (e) {
      print('[Merge Error] Failed to merge cached projects: $e');
    }
  }





 Future<void> fetchPendingCount({required List<int> projectIds}) async {
    HomeUseCase().fetchPendingCount(
        projectIds: projectIds,
        onRequestSuccess: (List<ProjectStats> list) {
          if(list.isNotEmpty){
            for (var item in projectLists) {
              if(item.projectId == list.first.projectid){
                item.pendingObservation = list.first.pendingobservation;
                item.pendingSupportReq = list.first.pendingsupportreq;
              }
          }
        }
          notifyListeners();
    }, onRequestFailure: (exception) {
      changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error,exception: exception));
    });
  }
  List<NotifyCountDTO> notificationCountData = [];
 void fetchNotificationCountList({bool updateBadgeCount = true}) async {
    HomeUseCase().fetchNotificationCountList(
        onRequestSuccess: (result) async {
          notificationCountData = result;
          notifyListeners();
    }, onRequestFailure: (exception) {
      changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error,exception: exception));
    });
  }
  List<SignInResultObjectModel> signInStatusList = [];


  Future<void> loadAllStatusesParallel() async {
    if (projectListWithFilter.isEmpty) {
      checkInLoaderStatus = true;
      notifyListeners();
      return;
    }

    // Create list of futures
    final futures = <Future<void>>[];

    for (int i = 0; i < projectListWithFilter.length; i++) {
      final projectId = projectListWithFilter[i].projectId;
      if (projectId != null) {
        futures.add(_getUserSignInStatusSync(projectId: projectId, index: i));
      }
    }

    // Wait for all to complete
    await Future.wait(futures);

    // Update UI once after all are loaded
    checkInLoaderStatus = true;
    notifyListeners();
  }

  // Synchronous version of getUserSignInStatus that returns a Future
  Future<void> _getUserSignInStatusSync({
    required int projectId,
    required int index,
  }) async {
    final completer = Completer<void>();

    ProjectLocationUseCase().getUserSignInStatus(
      projectId: projectId,
      onRequestSuccess: (isSignedIn) {
        // Update the specific project's status
        if (index < projectListWithFilter.length) {
          projectListWithFilter[index] =
              projectListWithFilter[index].copyWith(isSignedIn: isSignedIn);

          // Update oneSignedIn flag
          oneSignedIn = projectListWithFilter.any((item) => item.isSignedIn == true);

          // Don't notify listeners here - we'll do it once at the end
        }
        completer.complete();
      },
      onRequestFailure: (exception) {
        // Log error but continue loading other projects
        print('Error loading status for project $projectId: $exception');
        completer.complete();
      },
    );

    return completer.future;
  }



  Future<void> getUserSignInStatus({required int projectId}) async {

    ProjectLocationUseCase().getUserSignInStatus(
      projectId: projectId,
      onRequestSuccess: (isSignedIn) {
        final index = projectListWithFilter.indexWhere((p) => p.projectId == projectId);
        if (index != -1) {
          projectListWithFilter[index] =
              projectListWithFilter[index].copyWith(isSignedIn: isSignedIn);
        }
        oneSignedIn = projectListWithFilter
            .any((item) => item.isSignedIn == true);
        notifyListeners();
      },
      onRequestFailure: (exception) {
        changeLoadingStatus(
          loadingStatus: LoadingStatus(loader: Loader.error, message: exception.toString()),
        );
      },
    );
  }

  void signInToProjectLocation({required LocationParams params}){
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    ProjectLocationUseCase().signInToProjectLocation(
        params: params,
        onRequestSuccess: (message){
         changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
          BaseDialog.show(
              context: NavigatorKey.navKey.currentContext!,
              title: "Success",
              message: message,
              icon: Icon(Icons.check_circle_outline,color: bayaInfraGreen,size: 36,),
              actions: [
                BaseElevatedButton(
                  borderRadius: 24,
                  onPressed: () {
                    GoRouter.of(NavigatorKey.navKey.currentContext!).pop();
                  },
                  backgroundColor: Theme.of(NavigatorKey.navKey.currentState!.context).primaryColor,
                  text: "Ok",
                ),
              ]);
        },
        onRequestFailure: (exception){
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
          BaseDialog.show(
              context: NavigatorKey.navKey.currentContext!,
              title: "Alert",
              message: "$exception",
              icon: Icon(Icons.warning,color: bayaInfraAmber,size: 36,),
              actions: [
                BaseElevatedButton(
                  borderRadius: 24,
                  onPressed: () {
                    GoRouter.of(NavigatorKey.navKey.currentContext!).pop();
                  },
                  backgroundColor:Theme.of(NavigatorKey.navKey.currentState!.context).primaryColor,
                  text: "Ok",
                ),
              ]);
        });

  }

  void signOutToProjectLocation({required LocationParams params}){
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
    ProjectLocationUseCase().signOutToProjectLocation(
        params: params,
        onRequestSuccess: (message){
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
          BaseDialog.show(
              context: NavigatorKey.navKey.currentContext!,
              title: "Success",
              message: message,
              icon: Icon(Icons.check_circle_outline,color: bayaInfraGreen,size: 36,),
              actions: [
                BaseElevatedButton(
                  borderRadius: 24,
                  onPressed: () {
                    GoRouter.of(NavigatorKey.navKey.currentContext!).pop();
                  },
                  backgroundColor: Theme.of(NavigatorKey.navKey.currentState!.context).primaryColor,
                  text: "Ok",
                ),
              ]);
        },
        onRequestFailure: (exception){
          BaseDialog.show(
              context: NavigatorKey.navKey.currentContext!,
              title: "Failure",
              message: "$exception",
              icon: Icon(Icons.close,color: bayaInfraRed,size: 36,),
              actions: [
                BaseElevatedButton(
                  borderRadius: 24,
                  onPressed: () {
                    GoRouter.of(NavigatorKey.navKey.currentContext!).pop();
                  },
                  backgroundColor: Theme.of(NavigatorKey.navKey.currentState!.context).primaryColor,
                  text: "Ok",
                ),
              ]);
        });

  }
  void uploadImageFile({
    required LocationParams params,
    required List<File> files,
  }) async {
    changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.loading));
    await ProjectLocationUseCase().uploadImageFile(
        file: files,
        uploadProgress: (progress){
          loadingProgress = progress;
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.success));
          notifyListeners();
        },
        attachmentSerialNo:"",
        onRequestSuccess: (response) {

          params = params.copyWith(imagesDtl: response);
          print("entered_vishnu");
          signInToProjectLocation(params: params);

        },
        onRequestFailure: (exception) {
          changeLoadingStatus(loadingStatus: LoadingStatus(loader: Loader.error, exception: exception));
        });


  }

// Add TabController
  PageController pageControllerHome = PageController(initialPage: 0);


  int currentPageIndex = 0;

  void updateCurrentPageIndex(int index){
    currentPageIndex= index;
    notifyListeners();
  }

  // Remove these - not needed anymore
  // int selectedOptionIndex = 0;
  // PageController pageController = PageController();

  // Keep the rest of your variables...

  // Initialize TabController
  // void initTabController(TickerProvider vsync, int length) {
  //   tabController?.dispose();
  //   tabController = TabController(
  //     length: length,
  //     vsync: vsync,
  //     initialIndex: 0,
  //   );
  //
  //   // Listen to tab changes
  //   tabController?.addListener(() {
  //     if (!tabController!.indexIsChanging) {
  //       notifyListeners();
  //     }
  //   });
  // }



  // Simplified - no need for complex scroll logic
  void onTabBarSelected(int index) {
    // tabController?.animateTo(index);
    searchFocusNode.unfocus();
    notifyListeners();
  }


  // Simplified - no need for complex scroll logic
  void onPageSelected(int index) {
    pageControllerHome.animateToPage(index, duration: Duration(milliseconds: 800), curve: Curves.easeOut);
    searchFocusNode.unfocus();
    notifyListeners();
  }

  List<String> tabLabels = [];
  List<ModuleListDto> moduleList = [];
  void initModuleList({
    required TickerProvider ticker,
    required LoginProvider loginProvider}){

    ModuleListDto? list =
    loginProvider.loginDetails.isEmpty || loginProvider.loginDetails.first.modulelist.isEmpty
        ? null
        : !loginProvider.loginDetails.first.modulelist.first.children.any((element) => element.label == "Home Mob")
        ? null
        : loginProvider.loginDetails.first.modulelist.first.children.firstWhere((element) => element.label == "Home Mob");
    moduleList = list == null ? [] : list.children.reversed.toList();
    tabLabels = getTabLabels(moduleList);
    if (tabLabels.isNotEmpty) {
      print("entered___");
      // initTabController(ticker, tabLabels.length);
    }

    notifyListeners();
  }






}

