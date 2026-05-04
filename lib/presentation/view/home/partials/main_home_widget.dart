/*------------------------------------------------------------------------------
AUTHOR		    :Aswani Mohan
CREATED DATE	: 07/08/2025
PURPOSE		    :
MODULE/TOPIC	:
REMARKS		    :
--------------------------------------------------------------------------------
REVISION HISTORY
--------------------------------------------------------------------------------
REV#	DATE		MODIFIED BY		TICKET#		    DESCRIPTION
--------------------------------------------------------------------------------*/
import 'dart:io';
import 'dart:ui' as ui;

import 'package:base/core/constants.dart';
import 'package:base/core/loader_value.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/presentation/base/base_view.dart';
import 'package:base/presentation/provider/change_notifier_provider.dart';
import 'package:base/presentation/theme_config.dart';
import 'package:base/presentation/utility/camera_for_profile_picture.dart';
import 'package:base/presentation/utility/orientation.dart';
import 'package:base/presentation/views/base_elevated_button.dart';
import 'package:base/presentation/views/base_elevated_icon_button.dart';
import 'package:dcc_module/presentation/view/dcc_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/remote/repository/project_location/project_location_impl.dart';

import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/home/home_provider.dart';
import 'package:interior_design/presentation/view/call_tracker/call_tracker_page.dart';
import 'package:interior_design/presentation/view/common/cached_image_view.dart';
import 'package:interior_design/presentation/view/common/view_profile_image.dart';
import 'package:interior_design/presentation/view/home/swipable_side_bar.dart';
import 'package:interior_design/presentation/view/profile/profile_screen.dart';
import 'package:interior_design/presentation/view/project_dash_board/project_dash_board.dart';

import 'package:interior_design/presentation/view/project_location/widgets/sign_in_dialog.dart';
import 'package:interior_design/utils/routes.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class MainHomeWidget extends ConsumerStatefulWidget {
  const MainHomeWidget({super.key});

  @override
  ConsumerState<MainHomeWidget> createState() => _MainHomeWidgetState();
}

class _MainHomeWidgetState extends ConsumerState<MainHomeWidget>
    with TickerProviderStateMixin, RouteAware {

  bool _isPageRoute = false;

  @override
  void didPushNext() {
    _isPageRoute = ObserverUtils.routeObserver.lastPushedRoute is PageRoute;
    super.didPushNext();
  }

  @override
  void didPopNext() {
    if (_isPageRoute) {
      Future.microtask(() async {
        ref.read(projectDashboardProvider).fetchDashboard();
      });
    }
    _isPageRoute = false;
    super.didPopNext();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ObserverUtils.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    ObserverUtils.routeObserver.unsubscribe(this);
    super.dispose();
  }

  // helper
  String logoAssetFor(AppThemeVariant variant) {
    switch (variant) {
      case AppThemeVariant.skyBlue:     return 'assets/svgs/logo_sky_blue.svg';
      case AppThemeVariant.forestGreen: return 'assets/svgs/logo_forest_green_1.svg';
      case AppThemeVariant.slate:       return 'assets/svgs/logo_slate_blue.svg';
      case AppThemeVariant.terracotta:  return 'assets/svgs/logo_terracotta.svg';
      case AppThemeVariant.violet:      return 'assets/svgs/logo_violet.svg';
    }
  }

  String logoAssetForProjectIcon(AppThemeVariant variant) {
    switch (variant) {
      case AppThemeVariant.skyBlue:     return 'assets/svgs/project_icon_sky_blue.svg';
      case AppThemeVariant.forestGreen: return 'assets/svgs/project_icon_forest_green.svg';
      case AppThemeVariant.slate:       return 'assets/svgs/project_icon_slate_blue.svg';
      case AppThemeVariant.terracotta:  return 'assets/svgs/project_icon_terracotta.svg';
      case AppThemeVariant.violet:      return 'assets/svgs/project_icon_violet.svg';
    }
  }




  String logoAssetForEmptyProjectList(AppThemeVariant variant) {
    switch (variant) {
      case AppThemeVariant.skyBlue:     return 'assets/svgs/empty_list/EmptyStateLight 2.svg';
      case AppThemeVariant.forestGreen: return 'assets/svgs/empty_list/EmptyStateLight 3.svg';
      case AppThemeVariant.slate:       return 'assets/svgs/empty_list/EmptyStateLight 4.svg';
      case AppThemeVariant.terracotta:  return 'assets/svgs/empty_list/EmptyStateLight 5.svg';
      case AppThemeVariant.violet:      return 'assets/svgs/empty_list/EmptyStateLight 6.svg';
    }
  }
  GlobalKey<ScaffoldState> scaffoldKeyHome = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return BaseView<HomeProvider>(
      initState: (context, provider, ref) async {
        ProviderScope.containerOf(context).read(dccProvider).syncWithTimer(onSuccess: (){
          provider.syncService.syncAllProjectsDcc(
            onSuccess: (projects){
              provider.refreshProjectListViaSync(projects);

            }
          );
        });

        ref.watch(projectDashboardProvider).initValue();
        ref.watch(callTrackerProvider).initialize();
        await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);


      },
      isLoaderRequired: false,
      endDrawerEnableOpenDragGesture: false,
      endDrawer: const EdgeSwipeMenu(),
      onEndDrawerChanged: (flag) {
        ref.watch(sideBarProvider.notifier).onEndDrawerChange(flag);
      },
      scaffoldKey: scaffoldKeyHome,
      provider: homeProvider,
      builder: (context, provider, ref) {
        final variant = ref.watch(
          settingsProvider.select((s) => s.currentVariant),
        );
         Color headerBlue = Theme.of(context).primaryColor;
        final ThemeMode currentTheme = ref.watch(
            settingsProvider.select((settings) => settings.currentTheme));
        bool isDarkTheme =
            (SchedulerBinding.instance.platformDispatcher.platformBrightness ==
                        Brightness.dark &&
                    currentTheme == ThemeMode.system) ||
                currentTheme == ThemeMode.dark;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor

              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16,),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6.0),
                              child: SvgPicture.asset(
                                logoAssetFor(variant),
                                height: 32,
                              )
                            ),
                            Padding(
                               padding: EdgeInsets.symmetric(horizontal: 10),
                               child: Row(
                                 mainAxisSize: MainAxisSize.min,
                                 children: [
                                   Text(
                                     "Keechery",
                                     style: Theme.of(context)
                                         .textTheme
                                         .headlineLarge
                                         ?.copyWith(
                                           color: headerBlue,
                                         ),
                                   ),
                                   if (provider.isOffline) 
                                       Container(
                                         margin: const EdgeInsets.only(left: 8, top: 4),
                                         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                         decoration: BoxDecoration(
                                           color: Colors.red.shade600,
                                           borderRadius: BorderRadius.circular(4),
                                         ),
                                         child: const Text(
                                           'OFFLINE',
                                           style: TextStyle(
                                             color: Colors.white,
                                             fontSize: 10,
                                             fontWeight: FontWeight.bold,
                                             letterSpacing: 0.5,
                                           ),
                                         ),
                                       ),
                                 ],
                               ),
                             ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 12,
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              GoRouter.of(context).pushNamed(AppRoutes.profile);
                            },
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: GestureDetector(
                                    onDoubleTap: () async {
                                      final userName =
                                          await BaseSecureStorage.getString(
                                              BaseConstants.userName);
                                      ProfileImageDialog.show(
                                          context: context,
                                          imageUrl: provider.profileImageUrl,
                                          userName: userName);
                                    },
                                    child: CachedNetworkImageWidget(
                                      size: 33,
                                      padding: EdgeInsets.zero,
                                      imageUrl: provider.profileImageUrl,
                                      userName: provider.userName,

                                      textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                                        color: headerBlue,
                                      ),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          shape: BoxShape.circle,

                                          border: Border.all(
                                            color: headerBlue,
                                              width: 1
                                          )
                                      ),

                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 6, bottom: 8.0, right: 0),
                                child: IconButton(onPressed: (){
                                  GoRouter.of(context).pushNamed(AppRoutes.notificationHistoryScreen);
                                }, icon: Container(
                                    width: 30 ,
                                    height: 30 ,


                                    child: Icon(Icons.notifications_outlined,size: 29,color: headerBlue,)),),
                              ),
                                provider.notificationCountData.isEmpty ||provider.notificationCountData.first.unreadcount == 0
                                  ? SizedBox.shrink()
                                  : Container(
                                decoration: BoxDecoration(
                                  color: bayaInfraLightRedColor,
                                  shape: BoxShape.circle
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Center(
                                    child: Text("${provider.notificationCountData.first.unreadcount > 99 ? '99+' : provider.notificationCountData.first.unreadcount}",
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: bayaInfraWhiteColor
                                      ),),
                                  ),
                                ),
                              )
                            ],
                          ),
                          // Replace the PopupMenuButton section with this:
                          SizedBox(width: 10,),

// 2. The new elegant more-button
                          Builder(
                            builder: (context) => GestureDetector(
                              onTap: () => _showUserMenu(context, ref, headerBlue),
                              child: Container(
                                width: 34,
                                height: 32,
                                margin: const EdgeInsets.only(right: 12, bottom: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: headerBlue,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(3, (_) => Container(
                                    width: 4, height: 4,
                                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                    decoration: BoxDecoration(
                                      color: headerBlue,
                                      shape: BoxShape.circle,
                                    ),
                                  )),
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                    )
                  ],
                ),
            ),
          ),
            // Divider(
            //   height: 5,
            //   thickness: 0.4,
            // ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [


                    // Tabs Row
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TabBarView(
                              physics: ClampingScrollPhysics(),
                              children: [
                                DashboardScreen(
                                    scaffoldKeyHome: scaffoldKeyHome),
                                buildProjectListView(
                                    context, provider, isDarkTheme,variant),
                                CallTrackerPage(),
                                DccScreen(isFromHome: true,)
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Add this method to your widget class:
  void _showUserMenu(BuildContext context, WidgetRef ref, Color accentColor) async {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(button.size.bottomLeft(Offset.zero), ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final result = await showMenu<String>(
      context: context,
      position: position,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Theme.of(context).cardColor,
      items: [
        // User identity header
        PopupMenuItem<String>(
          value: 'settings',
          child: _menuRow(context, Icons.settings_outlined, 'Settings', accentColor),
        ),
        PopupMenuItem<String>(
          value: 'profile',
          child: _menuRow(context, Icons.person_outline_rounded, 'Profile', accentColor),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'logout',
          child: _menuRow(context, Icons.logout_rounded, 'Log out', Colors.red),
        ),
      ],
    );

    if (result == 'settings') {
      GoRouter.of(context).pushNamed(AppRoutes.settings);
    } else if (result == 'logout') {
      logOutPopUp(context, ref);
    } else if (result == 'profile') {
      GoRouter.of(context).pushNamed(AppRoutes.profile);
    }
  }

  Widget _menuRow(BuildContext context, IconData icon, String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 14),
          Text(label, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget buildProjectListView(
      BuildContext context, HomeProvider provider, bool isDarkTheme, AppThemeVariant variant) {

    return BaseView<HomeProvider>(
        initState: (context, provider, ref) {},
        provider: homeProvider,
        isLoaderRequired: true,
        builder: (context, provider, ref) {
          provider.tileListScrollController = ItemScrollController();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: provider.isSearching
                        ? AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      decoration: BoxDecoration(
                        borderRadius:
                        BorderRadius.all(Radius.circular(6)),
                        color: provider.isSearching
                            ? Theme.of(context).colorScheme.secondary
                            : null,
                      ),
                      child: TextField(
                        focusNode: provider.searchFocusNode,
                        controller: provider.searchController,
                        onChanged: (value) {
                          provider.changeSearchText(value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                        ),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                        : Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Project List",
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        provider.changeIsSearching();
                      },
                      icon: Icon(Icons.search,
                          color: Theme.of(context).iconTheme.color))
                ],
              ),
              provider.projectListWithFilter.isEmpty
                  ? buildEmptyView(
                    context, provider, 'No Project Found ', '', isDarkTheme,variant)
                  : Expanded(
                child: RefreshIndicator(
                  color: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).highlightColor,
                  onRefresh: () async {
                    provider.removeSearch();
                    await provider.fetchProjectDetails();
                  },
                  child: ScrollablePositionedList.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: ClampingScrollPhysics(),
                    ),
                    itemScrollController: provider.tileListScrollController,
                    padding: EdgeInsets.zero,
                    itemCount: provider.projectListWithFilter.length,
                    itemBuilder: (context, index) {
                      final project = provider.projectListWithFilter[index];
                      final projectName = project.project ?? '';

                      return Padding(
                        padding: EdgeInsets.only(
                            bottom: (index ==
                                provider.projectListWithFilter.length - 1)
                                ? 150
                                : 0.0),
                        child: InkWell(
                          onTap: () {
                            GoRouter.of(context)
                                .go(AppRoutes.projectDetails, extra: {
                              "projectId": provider
                                  .projectListWithFilter[index]
                                  .projectId ??
                                  0,
                              "rootFolderId": provider
                                  .projectListWithFilter[index]
                                  .rootFolderId ??
                                  0
                            });
                          },
                          child: Card(
                            elevation: 0.5,
                            color: Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                width: 0.5,
                                color: Theme.of(context).cardColor,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        logoAssetForProjectIcon(variant),
                                        height: 50,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    projectName,
                                                    maxLines: 3,
                                                    overflow:
                                                    TextOverflow.ellipsis,
                                                    style: Theme.of(context).textTheme.titleLarge,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                          Icons
                                                              .location_on_outlined,
                                                          size: 14,
                                                          color: Theme.of(context)
                                                              .iconTheme
                                                              .color),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          project.projectLocation ??
                                                              '',
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            _signAndSignOutFeature(
                                                context, provider, index)
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  // End Date
                                  // End Date Row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Icon(Icons.calendar_month_outlined,
                                                size: 16,
                                                color: Theme.of(context).iconTheme.color),
                                            const SizedBox(width: 8),
                                            Text('End Date : ',
                                                style:Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),),
                                            Text(
                                              DateFormat('MMM dd, yyyy').format(
                                                provider
                                                    .projectListWithFilter[index]
                                                    .projectEndDate ??
                                                    DateTime.now(),
                                              ),
                                              style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),
                                      //  Replaces "View Schedule" button — opens bottom sheet
                                      GestureDetector(
                                        onTap: () {
                                          provider.removeSearchWithOurClearingText();
                                          _showProjectActionsBottomSheet(
                                            context: context,
                                            provider: provider,
                                            projectId: provider.projectListWithFilter[index].projectId ?? 0,
                                            projectName: provider.projectListWithFilter[index].project ?? '', variant: variant,
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 2,vertical: 4),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Quick Actions",
                                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                                  color: Theme.of(context).primaryColor,
                                                  decoration: TextDecoration.underline,
                                                  decorationColor:
                                                  Theme.of(context).primaryColor.withValues(alpha: 0.4),
                                                  decorationThickness: 1.5,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(Icons.arrow_outward_rounded,
                                                  size: 12, color: Theme.of(context).primaryColor),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        });
  }

  void _showProjectActionsBottomSheet({
    required BuildContext context,
    required HomeProvider provider,
    required int projectId,
    required String projectName,
    required AppThemeVariant variant
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                // Handle bar
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                // Header
                Row(
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 4.0),
                    //   child: SvgPicture.asset(
                    //     logoAssetForProjectIcon(variant),
                    //     height: 40,
                    //   ),
                    // ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            projectName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            "Select an action to continue",
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Divider(
                    height: 1,
                    thickness: 0.6,
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
                  ),
                ),
                // Action tiles
                if (provider.addObservationRight)
                  _buildBottomSheetAction(
                    context: context,
                    icon: Icons.remove_red_eye_outlined,
                    label: 'Add Observation',
                    subtitle: 'Record site findings',
                    color: const Color(0xFF0298DB),
                    onTap: () {
                      Navigator.pop(context);
                      GoRouter.of(context).pushNamed(
                        AppRoutes.addObservation,
                        extra: {"projectId": projectId},
                      );
                    },
                  ),
                if (ref.watch(homeProvider).addSupportRight)
                  _buildBottomSheetAction(
                    context: context,
                    icon:  Icons.support_agent_rounded,
                    label: 'Add Support Request',
                    subtitle: 'Raise a support ticket',
                    color: const Color(0xFF4A8C55),
                    onTap: () {
                      Navigator.pop(context);
                      GoRouter.of(context).pushNamed(
                        AppRoutes.addSupportRequest,
                        extra: {"projectId": projectId},
                      );
                    },
                  ),
                if((provider.isSuperUser || provider.isProjectDepartment))
                _buildBottomSheetAction(
                  context: context,
                  icon: Icons.inventory_2_outlined,
                  label: 'Add Material Indent',
                  subtitle: 'Request additional materials',
                  color: const Color(0xFFB8745A),
                  onTap: () {
                    Navigator.pop(context);
                    GoRouter.of(context).pushNamed(
                      AppRoutes.addAdditionalMaterialScreen,
                      extra: {"projectId": projectId},
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetAction({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.18),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 18, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _signAndSignOutFeature(
      BuildContext context, HomeProvider provider, int index) {
    final isCurrentSignedIn =
        provider.projectListWithFilter[index].isSignedIn == true;

    return Visibility(
      visible: provider.mobMarkPresenceRight &&
          (provider.projectListWithFilter[index].latitude != null &&
              provider.projectListWithFilter[index].longitude != null),
      child: (!provider.checkInLoaderStatus)
          ? SizedBox(
              height: 0,
            )
          : Column(
              children: [
                Visibility(
                  visible: !provider.oneSignedIn,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        GestureDetector(
                            onTap: () async {
                              final File? image = await SingleImageService
                                  .instance
                                  .pickImageWithCrop(
                                      context: context,
                                      showGalleryUpload: false);

                              if (image?.path == null) return;

                              provider.changeLoadingStatus(
                                  loadingStatus:
                                      LoadingStatus(loader: Loader.loading));
                              final permission = await Location().requestPermission();
                              if (permission == PermissionStatus.denied ||
                                  permission ==
                                      PermissionStatus.deniedForever) {}
                              // 2️⃣ Get current location
                              LocationData position = await Location().getLocation();

                              // Convert lat/lng to address
                              List<Placemark> placemarks =
                                  await placemarkFromCoordinates(
                                      position.latitude??0, position.longitude??0);

                              final place = placemarks.first;
                              final address =
                                  '${place.street}, ${place.locality}, ${place.subLocality}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}';

                              provider.changeLoadingStatus(
                                  loadingStatus:
                                      LoadingStatus(loader: Loader.success));
                              logInDialog(
                                  context: context,
                                  image: image!,
                                  position: position,
                                  address: address,
                                  onPressed: () {
                                    provider.uploadImageFile(
                                        files: [image],
                                        params: LocationParams(
                                            projectId: provider
                                                    .projectListWithFilter[
                                                        index]
                                                    .projectId ??
                                                0,
                                            latitude: position.latitude??0,
                                            longitude: position.longitude??0,
                                            allowedRadiusMeters: "0",
                                            geoTolerance: "0",
                                            projectName: ""));
                                    Navigator.of(context).pop();
                                  });
                            },
                            child: SizedBox(
                                height: 50,
                                width: 50,
                                child: SvgPicture.asset(
                                    "assets/svgs/off_button.svg"))),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: isCurrentSignedIn,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        GestureDetector(
                            onTap: () async {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  double defaultHeight =
                                      MediaQuery.of(context).size.height;
                                  return AlertDialog(
                                    title: const Text('Check-Out'),
                                    content: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: SizedBox(
                                          height: defaultHeight / 6,
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Icon(Icons.warning,
                                                    size: 60,
                                                    color: bayaInfraAmber),
                                                Text(
                                                    "Are you sure want to Check-Out?",
                                                    textAlign: TextAlign.center,
                                                    maxLines: 6,
                                                    softWrap: true,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleMedium)
                                              ])),
                                    ),
                                    actions: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: BaseElevatedButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(false); // No
                                              },
                                              text: "No",
                                            ),
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ),
                                          Expanded(
                                            child: BaseElevatedButton(
                                              text: "Yes",
                                              onPressed: () async {
                                                Navigator.of(context)
                                                    .pop(true); // Yes
                                                provider.changeLoadingStatus(
                                                    loadingStatus:
                                                        LoadingStatus(
                                                            loader: Loader
                                                                .loading));
                                                final permission =
                                                    await Location().requestPermission();
                                                if (permission ==
                                                    PermissionStatus
                                                            .denied ||
                                                    permission ==
                                                        PermissionStatus
                                                            .deniedForever) {}

                                                LocationData position = await Location().getLocation();





                                                provider.changeLoadingStatus(
                                                    loadingStatus:
                                                        LoadingStatus(
                                                            loader: Loader
                                                                .success));

                                                provider.signOutToProjectLocation(
                                                    params: LocationParams(
                                                        projectId: provider
                                                                .projectListWithFilter[
                                                                    index]
                                                                .projectId ??
                                                            0,
                                                        latitude:
                                                            position.latitude??0,
                                                        longitude:
                                                            position.longitude??0,
                                                        allowedRadiusMeters:
                                                            "0",
                                                        geoTolerance: "0",
                                                        projectName: ""));
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: SizedBox(
                                height: 50,
                                width: 50,
                                child: SvgPicture.asset(
                                    "assets/svgs/on_button.svg"))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget buildAnimatedContainer(
    HomeProvider provider,
    int index,
    BuildContext context,
    WidgetRef ref,
  ) {
    final isExpanded = provider.expandedIndex == index;

    return Visibility(
      visible: provider.addObservationRight ||
          provider.addSupportRight ||
          provider.closeObservationRight ||
          provider.closeSupportRight,
      child: ClipRect(
        child: AnimatedSize(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: isExpanded ? 1.0 : 0.0, // animates vertical expansion
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Divider(color: Theme.of(context).primaryColor),

                // Stats Row
                Wrap(
                  runAlignment: WrapAlignment.spaceBetween,
                  children: [
                    Visibility(
                      visible: provider.closeObservationRight,
                      child: InkWell(
                        onTap: () {
                          if ((!provider.addObservationRight &&
                                  !provider.addSupportRight &&
                                  !provider.closeObservationRight &&
                                  !provider.closeSupportRight) ||
                              provider.expandedIndex == index) {
                            provider.searchFocusNode.unfocus();

                            GoRouter.of(context)
                                .go(AppRoutes.projectDetails, extra: {
                              "projectId": provider
                                  .projectListWithFilter[index].projectId ?? 0,
                              "rootFolderId": provider
                                  .projectListWithFilter[index].rootFolderId ?? 0,
                              "isFromObservation": true,
                              "flagObs": "AGAINST",
                              "DelayedYN": "None"
                            });
                          } else {
                            provider.changeExpanded(index);
                          }
                        },
                        child: SizedBox(
                          width: (MediaQuery.of(context).size.width / 2) - 24,
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Observations',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${provider.projectListWithFilter[index].pendingObservation} Nos',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: Theme.of(context).primaryColor),
                                ),
                                Text("Awaiting your response",
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: provider.closeSupportRight,
                      child: InkWell(
                        onTap: () {
                          if ((!provider.addObservationRight &&
                                  !provider.addSupportRight &&
                                  !provider.closeObservationRight &&
                                  !provider.closeSupportRight) ||
                              provider.expandedIndex == index) {
                            provider.searchFocusNode.unfocus();
                            GoRouter.of(context)
                                .go(AppRoutes.projectDetails, extra: {
                              "projectId": provider
                                  .projectListWithFilter[index].projectId ?? 0,
                              "rootFolderId": provider
                                  .projectListWithFilter[index]
                                  .rootFolderId ??
                                  0,
                              "isFromSupport": true,
                              "flagObs": "AGAINST",
                              "DelayedYN": "None"
                            });
                          } else {
                            provider.changeExpanded(index);
                          }
                        },
                        child: SizedBox(
                          width: (MediaQuery.of(context).size.width / 2) - 24,
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Support Requests',
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${provider.projectListWithFilter[index].pendingSupportReq} Nos',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: Theme.of(context).primaryColor),
                                ),
                                Text("Awaiting your response",
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Visibility(
                          visible: provider.addObservationRight,
                          child: Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.add, size: 16),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  foregroundColor: bayaInfraWhiteColor,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  GoRouter.of(context).pushNamed(
                                      AppRoutes.addObservation,
                                      extra: {
                                        "projectId": provider
                                            .projectListWithFilter[index]
                                            .projectId
                                      });
                                },
                                label: Text('Add Observation',
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                            color: bayaInfraWhiteColor,
                                            overflow: TextOverflow.ellipsis)),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: provider.addSupportRight,
                          child: Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: ElevatedButton.icon(
                                icon: Icon(Icons.add, size: 16),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  foregroundColor: bayaInfraWhiteColor,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  provider.searchFocusNode.unfocus();

                                  GoRouter.of(context).pushNamed(
                                      AppRoutes.addSupportRequest,
                                      extra: {
                                        "projectId": provider
                                                .projectListWithFilter[index]
                                                .projectId ??
                                            0
                                      });
                                },
                                label: Text('Add Support ',
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                            color: bayaInfraWhiteColor,
                                            overflow: TextOverflow.ellipsis)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Action Buttons (if any)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAddButtons(
      HomeProvider provider, WidgetRef ref, int index, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Visibility(
            visible: provider.addObservationRight,
            child: BaseElevatedIconButton(
              onPressed: () {
                provider.searchFocusNode.unfocus();

                GoRouter.of(context)
                    .pushNamed(AppRoutes.addObservation, extra: {
                  "projectId": provider.projectListWithFilter[index].projectId
                });
              },
              icon: Icons.add,
              text: 'Add Observation',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Visibility(
            visible: provider.addSupportRight,
            child: BaseElevatedIconButton(
              icon: Icons.add,
              onPressed: () {
                provider.searchFocusNode.unfocus();

                GoRouter.of(context)
                    .pushNamed(AppRoutes.addSupportRequest, extra: {
                  'projectId': provider.projectListWithFilter[index].projectId,
                });
              },
              text: 'Add Support ',
            ),
          ),
        ),
      ],
    );
  }

  Widget buildEmptyView(BuildContext context, HomeProvider provider,
      String message, String description, bool isDarkTheme,AppThemeVariant variant) {
    return RefreshIndicator(
      color: Theme.of(context).primaryColor,
      backgroundColor: Theme.of(context).highlightColor,
      onRefresh: () async {
        provider.removeSearch();
        await provider.fetchProjectDetails();

      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: isPortraitMode()
              ? MediaQuery.of(context).size.height * 0.55
              : MediaQuery.of(context).size.width * 0.38,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  SvgPicture.asset(
                    logoAssetForEmptyProjectList(variant),
                    width: 135,
                    height: 135,
                  ),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.titleSmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// Stylish Header Card Widget
// Primary color: Color(0xFF0298DB)


class StylishHeaderCard extends StatelessWidget {
  final String profileImageUrl;
  final String userName;
  final VoidCallback onProfileTap;
  final VoidCallback onProfileDoubleTap;
  final VoidCallback onNotificationTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;

  const StylishHeaderCard({
    super.key,
    required this.profileImageUrl,
    required this.userName,
    required this.onProfileTap,
    required this.onProfileDoubleTap,
    required this.onNotificationTap,
    required this.onSettingsTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF0298DB);
    const deepBlue = Color(0xFF0176B0);
    const accentBlue = Color(0xFF54C5F8);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [primaryBlue, deepBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circle accents
          Positioned(
            top: -18,
            right: -18,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentBlue.withValues(alpha: 0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -12,
            left: 40,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile avatar
                GestureDetector(
                  onTap: onProfileTap,
                  onDoubleTap: onProfileDoubleTap,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      backgroundImage: profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : null,
                      child: profileImageUrl.isEmpty
                          ? Text(
                        userName.isNotEmpty
                            ? userName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 16,
                          color: primaryBlue,
                        ),
                      )
                          : null,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // User greeting text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.8),
                          letterSpacing: 0.3,
                        ),
                      ),
                      Text(
                        userName.isNotEmpty ? userName : 'User',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Notification button
                _HeaderIconButton(
                  icon: Icons.notifications_outlined,
                  onTap: onNotificationTap,
                  badge: true, // set false if no badge needed
                ),

                const SizedBox(width: 4),

                // Menu popup
                _HeaderPopupMenu(
                  onSettingsTap: onSettingsTap,
                  onLogoutTap: onLogoutTap,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool badge;

  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
            ),
            child: Icon(icon, size: 22, color: Colors.white),
          ),
          if (badge)
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeaderPopupMenu extends StatelessWidget {
  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;

  const _HeaderPopupMenu({
    required this.onSettingsTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'settings') onSettingsTap();
        if (value == 'logout') onLogoutTap();
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              const Icon(Icons.settings_outlined, size: 20),
              const SizedBox(width: 12),
              Text('Settings',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout_outlined, size: 20),
              const SizedBox(width: 12),
              Text('Log Out',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge),
            ],
          ),
        ),
      ],
      offset: const Offset(-10, 40),
      color: Theme.of(context).cardColor,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.zero,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
        ),
        child: const Icon(Icons.menu_rounded, size: 22, color: Colors.white),
      ),
    );
  }
}
