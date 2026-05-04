import 'package:base/presentation/utility/navigator_key.dart';
import 'package:base/presentation/views/base_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:interior_design/presentation/provider/call_tracker/call_tracker_provider.dart';
import 'package:interior_design/presentation/provider/call_tracker/providers/service_request_dashboard_provider.dart';
import 'package:interior_design/presentation/provider/call_tracker/service_details_landing_provider.dart';
import 'package:interior_design/presentation/provider/call_tracker/ticket_dashboard/service_tasks_provider.dart';
import 'package:interior_design/presentation/provider/change_notifier_providers.dart';
import 'package:interior_design/presentation/provider/close_support_request/close_support_request_provider.dart';
import 'package:interior_design/presentation/provider/common_observation/base_observation_provider.dart';
import 'package:interior_design/presentation/provider/common_support/base_support_provider.dart';
import 'package:interior_design/presentation/provider/material_chart_provider/material_chart_provider.dart';
import 'package:interior_design/presentation/provider/project_schedule/project_schedule_provider.dart';
import 'package:interior_design/presentation/provider/view_support_request/view_support_request_provider.dart';
import 'package:interior_design/presentation/view/MOM/add_mom_screen.dart';
import 'package:interior_design/presentation/view/MOM/mom_action_item_screen.dart';
import 'package:interior_design/presentation/view/MOM/mom_list_screen.dart';
import 'package:interior_design/presentation/view/add_observation/all_images_gridobs.dart';
import 'package:interior_design/presentation/view/add_support_request/add_support_request_screen.dart';
import 'package:interior_design/presentation/view/add_observation/add_observation_screen.dart';
import 'package:interior_design/presentation/view/all_observation_request/all_observation_request_screen.dart';
import 'package:interior_design/presentation/view/all_support_request/all_support_request_screen.dart';
import 'package:interior_design/presentation/view/call_tracker/add_service_request/add_service_request_screen.dart';
import 'package:interior_design/presentation/view/call_tracker/call_tracker_page.dart';
import 'package:interior_design/presentation/view/call_tracker/detail_view/_partials/reassign_engineer_screen.dart';
import 'package:interior_design/presentation/view/call_tracker/detail_view/service_details_landing_page.dart';
import 'package:interior_design/presentation/view/call_tracker/detail_view/_partials/service_details.dart';
import 'package:interior_design/presentation/view/call_tracker/detail_view/_partials/support_details.dart';
import 'package:interior_design/presentation/view/call_tracker/from_home/service_task_from_home.dart';
import 'package:interior_design/presentation/view/call_tracker/service_based_support_from_home/service_support_screen.dart';
import 'package:interior_design/presentation/view/call_tracker/service_based_support_from_home/view_service_based_support_request_screen.dart';
import 'package:interior_design/presentation/view/call_tracker/service_detail_based_support_request/service_detail_support_request_screen.dart';
import 'package:interior_design/presentation/view/call_tracker/ticket_dashboard/call_tracker_from_dashboard_graph.dart';
import 'package:interior_design/presentation/view/call_tracker/ticket_dashboard/tasks_list.dart';
import 'package:interior_design/presentation/view/call_tracker/ticket_dashboard/ticket_dashboard.dart';
import 'package:interior_design/presentation/view/close_observation/close_observation_screen.dart';
import 'package:interior_design/presentation/view/common/service_ticket/service_ticket_tracking.dart';
import 'package:interior_design/presentation/view/common/success_loader.dart';
import 'package:interior_design/presentation/view/dashboard/dashboard_list_screen.dart';
import 'package:interior_design/presentation/view/home/home_screen.dart';
import 'package:interior_design/presentation/view/login_and_splash/login.dart';
import 'package:interior_design/presentation/view/login_and_splash/splash.dart';
import 'package:interior_design/presentation/view/material_chart/add_additional_material/add_additional_material.dart';
import 'package:interior_design/presentation/view/material_chart/additional_material_chart/addition_material_detail_page/additional_material_detail_view.dart';
import 'package:interior_design/presentation/view/material_chart/additional_material_chart/additional_material_chart_screen.dart';
import 'package:interior_design/presentation/view/material_chart/additional_material_chart/image_grid.dart';
import 'package:interior_design/presentation/view/material_chart/material_chart_screen.dart';
import 'package:interior_design/presentation/view/my_observation/my_observation_screen.dart';
import 'package:interior_design/presentation/view/my_observation/view_observation_screen.dart';
import 'package:interior_design/presentation/view/my_support/my_support_screen.dart';
import 'package:interior_design/presentation/view/my_support/view_support_request_screen.dart';
import 'package:interior_design/presentation/view/notification_history/notification_history_screen.dart';
import 'package:interior_design/presentation/view/profile/change_password_screen.dart';
import 'package:interior_design/presentation/view/profile/forgot_password_screen.dart';
import 'package:interior_design/presentation/view/profile/personal_information.dart';
import 'package:interior_design/presentation/view/profile/profile_screen.dart';
import 'package:interior_design/presentation/view/project_details/partials/observation_list_screen.dart';
import 'package:interior_design/presentation/view/project_details/partials/support_request_list_screen.dart';
import 'package:interior_design/presentation/view/project_details/project_unified_dashboard_screen.dart';
import 'package:interior_design/presentation/view/close_support_request/close_support_request_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/presentation/view/project_details/schedule_status_graphs_and_widgets/graph_basedl_support_request/graph_based_support_request_screen.dart';
import 'package:interior_design/presentation/view/project_details/schedule_status_graphs_and_widgets/tasks_based_on_graph_screen.dart';
import 'package:interior_design/presentation/view/project_details/widgets/all_obs_landing_page.dart';
import 'package:interior_design/presentation/view/project_details/widgets/all_sup_landing_page.dart';
import 'package:interior_design/presentation/view/project_location/project_location_page.dart';
import 'package:interior_design/presentation/view/project_schedule/labour_count_screen.dart';
import 'package:interior_design/presentation/view/project_schedule/project_schedule_detail_page.dart';
import 'package:interior_design/presentation/view/project_schedule/project_schedule_page.dart';
import 'package:interior_design/presentation/view/project_schedule/project_schedule_status_page.dart';
import 'package:interior_design/presentation/view/project_schedule/schedule_health.dart';
import 'package:interior_design/presentation/view/project_schedule/activity_group_dashboard_screen.dart';
import 'package:interior_design/presentation/view/project_schedule/task_against_support_list_page.dart';
import 'package:interior_design/presentation/view/project_schedule/widgets/all_images_grid.dart';
import 'package:interior_design/presentation/view/project_details/schedule_status_graphs_and_widgets/project_schedule_dashboard_screen.dart';
import 'package:interior_design/presentation/view/settings/settings_screen.dart';
import 'package:dcc_module/dcc_module.dart';


class ObserverUtils {
  static final PageRouteObserver routeObserver = PageRouteObserver();
}

class PageRouteObserver extends RouteObserver<ModalRoute> {
  Route? lastPushedRoute;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    lastPushedRoute = route;
    super.didPush(route, previousRoute);
  }
}


class AppRoutes {
  AppRoutes._();
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String settings = 'settings';
  static const String profile = 'profile';
  static const String callTrackerPage = 'callTrackerPage';
  static const String notificationHistoryScreen = 'notificationHistoryScreen';

  static const String forgotPasswordScreen = '/forgotPasswordScreen';
  static const String personalInformation = 'personalInformation';
  static const String myObservationPage = 'myObservationPage';
  static const String mySupportRequestScreen = 'mySupportRequestScreen';
  static const String closeObservationDirect = '/home/closeObservationDirect';
  static const String closeSupportRequestDirect = '/home/closeSupportRequestDirect';
  static const String projectDetails = '/home/projectDetails';
  static const String addObservation = 'addObservation';
  static const String closeObservation = '/home/projectDetails/closeObservation';
  static const String closeAllObservation = 'closeAllObservation';
  static const String viewClosedObservationScreen = 'viewClosedObservationScreen';
  static const String viewSupportRequestScreen = 'viewSupportRequestScreen';
  static const String addSupportRequest = 'addSupportRequest';
  static const String closeSupportRequest = '/home/projectDetails/closeSupportRequest';
  static const String closeAllSupportRequest = 'closeAllSupportRequest';
  static const String dashBoard = '/home/projectDetails';
  static const String dashBoardList = '/home/projectDetails/dashBoardList';
  static const String imageViewer = '/imageViewer';
  static const String successLoaderObservation = 'successLoaderObservation';
  static const String successLoaderObservationDirect = '/successLoaderObservationDirect';
  static const String successLoaderSupport = 'successLoaderSupport';
  static const String successLoaderAllSupport = 'successLoaderAllSupport';
  static const String successLoaderMySupport = 'successLoaderMySupport';
  static const String successLoaderSupportDirect = '/successLoaderSupportDirect';
  static const String changePasswordScreen = 'changePasswordScreen';
  static const String allObservationListScreen = "allObservationListScreen";
  static const String allObservationDashBoardListScreen = "allObservationDashBoardListScreen";
  static const String allSupportRequestScreen = "allSupportRequestScreen";
  static const String allSupportRequestDashBoardListScreen = "allSupportRequestDashBoardListScreen";
  static const String projectSchedule = '/home/projectSchedule';
  static const String scheduleSummaryScreen = 'scheduleSummaryScreen';
  static const String taskStatusPage = 'taskStatusPage';
  static const String taskBasedGraphPage = 'taskBasedGraphPage';
  static const String graphBasedSupportRequestScreen = 'graphBasedSupportRequestScreen';
  static const String projectScheduleMyTaskDirect = 'projectScheduleMyTaskDirect';
  static const String projectScheduleReporteeTaskDirect = 'projectScheduleReporteeTaskDirect';
  static const String projectScheduleAllTaskDirect = 'projectScheduleAllTaskDirect';
  static const String activityGroupDashboard = 'activityGroupDashboard';
  static const String scheduleLabourCountScreen = 'scheduleLabourCountScreen';
  static const String taskDetail = 'taskDetailDirect';
  static const String taskDetailDirect = '/home/taskDetailDirect';
  static const String taskDetailFromCloseSupport = 'taskDetailFromCloseSupport';
  static const String graphScreen = 'graphScreen';
  static const String taskAgainstSupportListPage = 'taskAgainstSupportListPage';
  static const String imageGridScreen = 'imageGridScreenDirect';
  static const String imageGridObsScreen = 'imageGridObsScreen';
  static const String projectLocationPage = 'projectLocationPage';
  static const String projectLocationPageDirect = 'projectLocationPageDirect';
  static const String materialChartScreen = 'materialChartScreen';
  static const String materialItemDetailScreen = 'materialItemDetailScreen';
  static const String addAdditionalMaterialScreen = 'addAdditionalMaterialScreen';
  static const String addAdditionalMaterialScreenFromChart = 'addAdditionalMaterialScreen';
  static const String additionMaterialMainScreen = 'additionMaterialMainScreen';
  static const String additionalMaterialDetailView = 'additionalMaterialDetailView';
  static const String additionalMaterialDetailViewDirect = '/home/additionalMaterialDetailViewDirect';
  static const String imageGridChartScreen = 'imageGridChartScreen';
  static const String addServiceRequestScreen = 'addServiceRequestScreen';
  static const String serviceCallTrackerDetailViewDirect = 'serviceCallTrackerDetailViewDirect';
  static const String serviceSupportRequestSiteWiseScreen = 'serviceSupportRequestSiteWiseScreen';
  static const String serviceCallTrackerDetailSupportRequestScreen = 'serviceCallTrackerDetailSupportRequestScreen';
  static const String viewServiceSupportRequestScreen = 'viewServiceSupportRequestScreen';
  static const String successServiceLoaderMySupport = 'successServiceLoaderMySupport';
  static const String successServiceCallTrackerDetailsLoaderMySupport = 'successServiceCallTrackerDetailsLoaderMySupport';
  static const String serviceTrackingProgressScreen = 'serviceTrackingProgressScreen';
  static const String serviceTicketDashboardScreen = 'serviceTicketDashboardScreen';
  static const String serviceDetailsScreen = 'serviceDetailsScreen';
  static const String serviceSupportSummaryScreen = 'serviceSupportSummaryScreen';
  static const String reassignEngineerScreen = 'reassignEngineerScreen';
  static const String serviceTicketDashboardDirect = 'serviceTicketDashboardDirect';
  static const String serviceDetailsScreenDirect = 'serviceDetailsScreenDirect';
  static const String serviceTaskScreenDirect = 'serviceTaskScreenDirect';
  static const String serviceTrackerBaseHolder = 'serviceTrackerBaseHolder';
  static const String serviceTaskLists = 'serviceTaskLists';
  static const String allObsLandingPage = 'allObsLandingPage';
  static const String allSupLandingPage = 'allSupLandingPage';
  static const String assignedObsScreen = 'assignedObsScreen';
  static const String assignedSupScreen = 'assignedSupScreen';
  static const String serviceTaskListsFromHome = 'serviceTaskListsFromHome';
  static const String dccScreenDirect = 'dccScreenDirect';
  static const String dccProjectScreen = 'dccProjectScreen';
  static const String addMOMScreen = 'addMOMScreen';
  static const String listMOMScreen = 'listMOMScreen';
  static const String momActionItemListScreen = 'momActionItemListScreen';





  
  // GoRouter configuration
  static final router = GoRouter(
    observers: [ObserverUtils.routeObserver],
    navigatorKey: NavigatorKey.navKey,
    initialLocation: AppRoutes.splash,
    routes: [



      // Splash route - can navigate to home or login
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      // Login route - can navigate to home
      GoRoute(
        path: forgotPasswordScreen,
        name: 'forgotPasswordScreen',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      //Forgot password route
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),


      // Home route with nested children
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final initialIndex = extra?['initialIndex'] as int? ?? 0;
          return HomeMainScreen(initialIndex: initialIndex);
        },
        routes: [
          GoRoute(
            path: 'callTrackerPage',
            name: 'callTrackerPage',
            builder: (context, state) => const CallTrackerPage(),
          ),
          GoRoute(
            path: 'serviceTicketDashboardDirect',
            name: 'serviceTicketDashboardDirect',
            builder: (context, state) => const ServiceDetailsLandingPage(),
          ),
          GoRoute(
            path: 'serviceDetailsScreenDirect',
            name: 'serviceDetailsScreenDirect',
            builder: (context, state) => const ServiceDetailsScreen(),
          ),

          GoRoute(
            path: 'serviceTaskScreenDirect',
            name: 'serviceTaskScreenDirect',
            builder: (context, state) => const ServiceDetailsScreen(),
          ),


          GoRoute(
            path: settings,
            name: 'settings',
            builder: (context, state) => const SettingsView(),
          ),
          GoRoute(
            path: 'dccScreenDirect',
            name: 'dccScreenDirect',
            builder: (context, state) {
              // Extract the extra data here in the main project
              final extra = state.extra as Map<String, dynamic>?;
              final fileId = extra?['fileId'] as int?;

              // Pass it into the module's screen via constructor
              return DccScreen();
            }
          ),
          GoRoute(
            path: profile,
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: notificationHistoryScreen,
            name: 'notificationHistoryScreen',
            builder: (context, state) => const NotificationHistoryScreen(),
          ),
          GoRoute(
            path: serviceTrackerBaseHolder,
            name: 'serviceTrackerBaseHolder',
            builder: (context, state) => ProviderScope(
                overrides: [
                  callTrackerProvider.overrideWith((ref) {
                    return CallTrackerProvider();
                  },
                  )
                ],

                child: const ServiceTrackerBaseHolder()),
          ),
          GoRoute(
            path: serviceTaskLists,
            name: 'serviceTaskLists',
            builder: (context, state) => ProviderScope(
                overrides: [
                  serviceTasksListProvider.overrideWith((ref) {
                    return ServiceTasksListProvider();
                  },
                  )
                ],

                child: const ServiceTaskLists()),
          ),
          GoRoute(
            path: serviceTaskListsFromHome,
            name: 'serviceTaskListsFromHome',
            builder: (context, state) => ProviderScope(
                overrides: [
                  serviceTasksListProvider.overrideWith((ref) {
                    return ServiceTasksListProvider();
                  },
                  )
                ],

                child: const ServiceTaskListsFromHome()),
          ),
          GoRoute(
            path: addServiceRequestScreen,
            name: 'addServiceRequestScreen',
            builder: (context, state) =>  AddServiceRequestScreen(),
          ),


          GoRoute(
            path: serviceCallTrackerDetailViewDirect,
            name: 'serviceCallTrackerDetailViewDirect',
            routes: [
              GoRoute(
                path: serviceDetailsScreen,
                name: 'serviceDetailsScreen',
                builder: (context, state) => ProviderScope(
                    overrides: [

                      serviceRequestDashboardProvider.overrideWith((ref) {
                        return ServiceRequestDashboardProvider();
                      },
                      )
                    ],
                  child:  const ServiceDetailsScreen()

                ),
              ),
              GoRoute(
                path: serviceSupportSummaryScreen,
                name: 'serviceSupportSummaryScreen',
                builder: (context, state) => const ServiceSupportScreen(),
              ),
              GoRoute(
                path: serviceTrackingProgressScreen,
                name: 'serviceTrackingProgressScreen',
                builder: (context, state) =>  ServiceTrackingProgressScreen(provider: serviceRequestDashboardProvider,),
              ),
              GoRoute(
                path: reassignEngineerScreen,
                name: 'reassignEngineerScreen',
                builder: (context, state) =>  ReassignEngineerScreen(),
              ),

              GoRoute(
                path: serviceTicketDashboardScreen,
                name: 'serviceTicketDashboardScreen',
                builder: (context, state) =>  ServiceTicketDashboardScreen(),
              ),
              GoRoute(
                path: serviceCallTrackerDetailSupportRequestScreen,
                name: 'serviceCallTrackerDetailSupportRequestScreen',
                routes: [

                  GoRoute(
                    path:
                    'successServiceCallTrackerDetailsLoaderMySupport',
                    name: 'successServiceCallTrackerDetailsLoaderMySupport',
                    builder: (context, state) {
                      final args = state.extra as Map<String, dynamic>;
                      return SuccessLoader<BaseSupportProvider>(
                        provider: args["provider"],
                        onPressed: args["onPressed"],
                        key: args["key"],
                        actionType: args['actionType'],
                        title: args["title"],
                        transNo: args["transNo"],
                        // extra:args["screenExtra"],
                        // routePath: args["prevRoute"],
                      );
                    },
                  ),

                ],
                builder: (context, state) =>  ServiceDetailsSupportRequestScreen(),
              )
            ],
            builder: (context, state) => ProviderScope(
                overrides: [
                  serviceDetailsLandingProvider.overrideWith((ref) {
                    return ServiceDetailsLandingProvider();
                  },
                  ),
                  serviceRequestDashboardProvider.overrideWith((ref) {
                    return ServiceRequestDashboardProvider();
                  },
                  )
                ],
              child: const ServiceDetailsLandingPage()
            ),
          ),
          GoRoute(
            path: addAdditionalMaterialScreen,
            name: 'addAdditionalMaterialScreen',
            builder: (context, state) =>  AddAdditionalMaterialScreen(),
          ),


          GoRoute(
            path: 'additionalMaterialDetailViewDirect',
            name: 'additionalMaterialDetailViewDirect',
            builder: (context, state) => const AdditionalMaterialDetailView(),
          ),
          GoRoute(
            path: additionMaterialMainScreen,
            name: 'additionMaterialMainScreen',
            routes: [
              GoRoute(
                path: additionalMaterialDetailView,
                name: 'additionalMaterialDetailView',
                builder: (context, state) =>  AdditionalMaterialDetailView(),
              ),
            ],
            builder: (context, state) {
              return AdditionMaterialMainScreen();
            },

          ),
          GoRoute(
            path: serviceSupportRequestSiteWiseScreen,
            name: 'serviceSupportRequestSiteWiseScreen',
            routes: [
              GoRoute(
                  path: viewServiceSupportRequestScreen,
                  name: 'viewServiceSupportRequestScreen',
                  builder: (context, state) {
                    return ProviderScope(
                        overrides: [
                          viewSupportRequestProvider.overrideWith((ref) {
                            return ViewSupportRequestProvider();
                          },
                          )
                        ],
                        child: ViewServiceSupportRequestScreen());
                  },
                  routes: [
                    GoRoute(
                      path:
                      'successServiceLoaderMySupport',
                      name: 'successServiceLoaderMySupport',
                      builder: (context, state) {
                        final args = state.extra as Map<String, dynamic>;
                        return SuccessLoader<BaseSupportProvider>(
                          provider: args["provider"],
                          onPressed: args["onPressed"],
                          key: args["key"],
                          actionType: args['actionType'],
                          title: args["title"],
                          transNo: args["transNo"],
                          // extra:args["screenExtra"],
                          // routePath: args["prevRoute"],
                        );
                      },
                    ),
                  ]
              ),
            ],
            builder: (context, state) =>  ServiceSupportRequestSiteWiseScreen(),
          ),
          GoRoute(
              path: "materialChartScreen",
              name: 'materialChartScreen',
              routes: [
                GoRoute(
                  path: addAdditionalMaterialScreenFromChart,
                  name: 'addAdditionalMaterialScreenFromChart',
                  builder: (context, state) =>  AddAdditionalMaterialScreen(),

                ),
                GoRoute(
                  path: 'imageGridChartScreen',
                  name: 'imageGridChartScreen',
                  builder: (context, state) {
                    final args = state.extra as Map<String, dynamic>;
                    return ImageGridChartScreen(urls: args["urlList"]);
                  },
                ),
              ],
              builder: (context,state) => ProviderScope(
                  overrides: [
                    materialChartProvider.overrideWith((ref) {
                      return MaterialChartProvider();
                    },
                    )
                  ],
                  child: MaterialChartScreen())
          ),
          GoRoute(
            path: "projectSchedule",
            name: 'projectSchedule',
            routes: [
              GoRoute(
                path: "scheduleSummaryScreen",
                name: 'scheduleSummaryScreen',
                routes: [
                  GoRoute(
                    path: "taskStatusPage",
                    name: 'taskStatusPage',

                    builder: (context,state) =>TaskStatusPage()
                  )
                ],
                builder: (context, state) => const ScheduleSummaryScreen(),
              ),
              GoRoute(
                path: "activityGroupDashboard",
                name: 'activityGroupDashboard',
                builder: (context, state) {

                  return ActivityGroupDashboardScreen();
                },
              ),
              GoRoute(
                path: "scheduleLabourCountScreen",
                name: 'scheduleLabourCountScreen',
                builder: (context, state) {

                  return LabourCountScreen();
                },
              ),
            ],
            builder: (context, state) => const ProjectSchedulePage(),
          ),



          GoRoute(
            path: "projectScheduleMyTaskDirect",
            name: 'projectScheduleMyTaskDirect',
            builder: (context, state) => const ProjectSchedulePage(),
          ),
          GoRoute(
            path: "projectScheduleReporteeTaskDirect",
            name: 'projectScheduleReporteeTaskDirect',
            builder: (context, state) => const ProjectSchedulePage(),
          ),
          GoRoute(
            path: "projectScheduleAllTaskDirect",
            name: 'projectScheduleAllTaskDirect',
            builder: (context, state) => const ProjectSchedulePage(),
          ),

          GoRoute(
            path: projectLocationPageDirect,
            name: 'projectLocationPageDirect',
            builder: (context, state) {
              return ProjectLocationPage();
            },

          ),

          GoRoute(
            path: allObsLandingPage,
            name: 'allObsLandingPage',
            routes: [
            ],
            builder: (context, state) => const AllObsLandingPage(),
          ),

          GoRoute(
            path: allSupLandingPage,
            name: 'allSupLandingPage',
            routes: [],
            builder: (context, state) => const AllSupLandingPage(),
          ),
          GoRoute(
            path: assignedObsScreen,
            name: 'assignedObsScreen',
            routes: [],
            builder: (context, state) => const ObservationListScreen(),
          ),

          GoRoute(
            path: assignedSupScreen,
            name: 'assignedSupScreen',
            routes: [],
            builder: (context, state) => const SupportRequestListScreen(),
          ),

          GoRoute(
            path: "taskDetailDirect",
            name: 'taskDetailDirect',
            routes: [
              GoRoute(
                path: 'imageGridScreenDirect',
                name: 'imageGridScreenDirect',
                builder: (context, state) {
                  final args = state.extra as Map<String, dynamic>;
                  return ImageGridScreen(projectScheduleProvider: args["projectScheduleProvider"],);
                },
              ),
              GoRoute(
                path: "taskAgainstSupportListPage",
                name: 'taskAgainstSupportListPage',
                builder: (context, state) => const TaskAgainstSupportListPage(),
              ),
            ],
            builder: (context, state) {
              return ProviderScope(
                overrides: [
                  projectScheduleProvider.overrideWith((ref) {
                    return ProjectScheduleProvider();
                  },
                  )
                ],
                child: TaskDetailPage(),
              );
            },
          ),

          GoRoute(
            path: personalInformation,
            name: 'personalInformation',
            builder: (context, state) =>  PersonalInformation(),
          ),
          GoRoute(
            path: myObservationPage,
            name: 'myObservationPage',
            routes: [
              GoRoute(
                path: 'viewClosedObservationScreen', // This creates /home/addSupportRequest
                name: 'viewClosedObservationScreen',
                builder: (context, state) => ViewClosedObservationScreen(),
              ),
            ],
            builder: (context, state) =>  MyObservationPage(),
          ),
          GoRoute(
            path: mySupportRequestScreen,
            name: 'mySupportRequestScreen',
            routes: [
              GoRoute(
                path: 'viewSupportRequestScreen',
                name: 'viewSupportRequestScreen',
                builder: (context, state) {
                  return ProviderScope(
                      overrides: [
                        viewSupportRequestProvider.overrideWith((ref) {
                          return ViewSupportRequestProvider();
                        },
                        )
                      ],
                      child: ViewSupportRequestScreen());
                },
                routes: [
                  GoRoute(
                    path:
                    'successLoaderMySupport',
                    name: 'successLoaderMySupport',
                    builder: (context, state) {
                      final args = state.extra as Map<String, dynamic>;
                      return SuccessLoader<BaseSupportProvider>(
                        provider: args["provider"],
                        onPressed: args["onPressed"],
                        key: args["key"],
                        actionType: args['actionType'],
                        title: args["title"],
                        transNo: args["transNo"],
                        // extra:args["screenExtra"],
                        // routePath: args["prevRoute"],

                      );
                    },
                  ),
                ]
              ),
            ],
            builder: (context, state) =>  MySupportRequestScreen(),
          ),
          GoRoute(
            path: changePasswordScreen,
            name: 'changePasswordScreen',
            builder: (context, state) => ChangePasswordScreen()
          ),


          // Add screens accessible directly from home
          GoRoute(
            path: 'addObservation', // This creates /home/addObservation
            name: 'addObservation',
            routes: [
              GoRoute(
                path: 'imageGridObsScreen',
                name: 'imageGridObsScreen',
                builder: (context, state) {
                  final args = state.extra as Map<String, dynamic>;
                  return ImageGridObsScreen(addObservationProvider: args["addObservationProvider"]);
                },
              ),
            ],
            builder: (context, state) => const AddObservationsScreen(),
          ),
          GoRoute(
            path: 'addSupportRequest', // This creates /home/addSupportRequest
            name: 'addSupportRequest',
            builder: (context, state) => AddSupportRequestScreen(),
          ),
          GoRoute(
            path:
            '/home/successLoaderObservationDirect',
            name: '/successLoaderObservationDirect',
            builder: (context, state) {
              final args = state.extra as Map<String, dynamic>;
              return SuccessLoader<BaseObservationProvider>(
                provider: args["provider"],
                onPressed: args["onPressed"],
                key: args["key"],
                actionType: args['actionType'],
                title: args["title"],
                transNo: args["transNo"],
                // extra:args["screenExtra"],
                // routePath: args["prevRoute"],
              );
            },
          ),
          GoRoute(
            path:
            '/home/successLoaderSupportDirect',
            name: '/successLoaderSupportDirect',
            builder: (context, state) {
              final args = state.extra as Map<String, dynamic>;
              return SuccessLoader<BaseSupportProvider>(
                provider: args["provider"],
                onPressed: args["onPressed"],
                key: args["key"],
                actionType: args['actionType'],
                title: args["title"],
                transNo: args["transNo"],
                // extra:args["screenExtra"],
                // routePath: args["prevRoute"],
              );
            },
          ),

          GoRoute(
            path: 'closeObservationDirect',
            name: 'closeObservationDirect',
            builder: (context, state) => const CloseObservationScreen(),
          ),
          GoRoute(
            path:
            'closeSupportRequestDirect',
            name: 'closeSupportRequestDirect',
            routes: [
              GoRoute(
                path: taskDetailFromCloseSupport,
                name: 'taskDetailFromCloseSupport',
                builder: (context, state) {
                  final args = state.extra as Map<String, dynamic>;
                  return TaskDetailPage(
                    taskId: args['taskId'],
                    projectName: args['projectName'],

                  );
                },
              ),
            ],

            builder: (context, state) {

              return ProviderScope(
                  overrides: [
                    closeSupportRequestProvider.overrideWith((ref) {
                      return CloseSupportRequestProvider();
                    },
                    )
                  ],
                  child: CloseSupportRequestScreen());
            },
          ),
          // Project details nested under home
          GoRoute(
            path: 'projectDetails', // This creates /home/projectDetails
            name: 'projectDetails',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final projectId = extra?["projectId"] as int? ?? 0;
              final rootFolderId = extra?["rootFolderId"] as int? ?? 0;
              return ProjectUnifiedDashboardScreen(projectId: projectId,rootFolderId: rootFolderId,);
            },
            routes: [
              GoRoute(
                path: projectLocationPage,
                name: 'projectLocationPage',
                builder: (context, state) {
                  return ProjectLocationPage();
                },

              ),
              GoRoute(
                path: 'dccProjectScreen',
                name: 'dccProjectScreen',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  final projectId = extra?['projectId'] as int? ?? 0;
                  final rootFolderId = extra?['rootFolderId'] as int? ?? 0;
                  return DccScreen(projectId: projectId, rootFolderId: rootFolderId);
                },
              ),



              GoRoute(
                path:
                graphScreen,
                name: 'graphScreen',
                routes: [
                  GoRoute(
                      path: "taskBasedGraphPage",
                      name: 'taskBasedGraphPage',
                      builder: (context,state) =>TaskBasedGraphPage()
                  ),
                  GoRoute(
                      path: "graphBasedSupportRequestScreen",
                      name: 'graphBasedSupportRequestScreen',
                      builder: (context,state) => GraphBasedSupportRequestScreen()
                  )
                ],
                builder: (context, state) {
                  return ProjectScheduleDashBoardScreen();
                },

              ),
              GoRoute(
                path: 'imageViewer',
                name: 'imageViewer',
                builder: (context, state) {
                  final args = state.extra as Map<String, dynamic>;
                  return ImageViewer(
                    images: args['images'],
                    initialIndex: args['initialIndex'],
                  );
                },
              ),
              // Close screens nested under project details
              GoRoute(
                path:
                    'closeObservation',
                name: 'closeObservation',
                routes: [
                  GoRoute(
                    path:
                    'successLoaderObservation',
                    name: 'successLoaderObservation',
                    builder: (context, state) {
                      final args = state.extra as Map<String, dynamic>;
                      return SuccessLoader<BaseObservationProvider>(
                        provider: args["provider"],
                        onPressed: args["onPressed"],
                        key: args["key"],
                        actionType: args['actionType'],
                        title: args["title"],
                        transNo: args["transNo"],
                        // extra:args["screenExtra"],
                        // routePath: args["prevRoute"],
                      );
                    },
                  ),
                ],
                builder: (context, state) => const CloseObservationScreen(),
              ),
              GoRoute(
                path:
                    'closeSupportRequest',
                name: 'closeSupportRequest',
                routes: [
                  GoRoute(
                    path:
                    'successLoaderSupport',
                    name: 'successLoaderSupport',
                    builder: (context, state) {
                      final args = state.extra as Map<String, dynamic>;
                      return SuccessLoader<BaseSupportProvider>(
                        provider: args["provider"],
                        onPressed: args["onPressed"],
                        key: args["key"],
                        actionType: args['actionType'],
                        title: args["title"],
                        transNo: args["transNo"],
                        // extra:args["screenExtra"],
                        // routePath: args["prevRoute"],
                      );
                    },
                  ),
                ],
                builder: (context, state) => CloseSupportRequestScreen(),
              ),
              GoRoute(
                path: 'dashBoardList',
                name: 'dashBoardList',
                routes: [
                  GoRoute(
                    path: allObservationDashBoardListScreen,
                    name: 'allObservationDashBoardListScreen',
                    builder: (context, state) => const AllObservationRequestScreen(),),

                  GoRoute(
                    path: allSupportRequestDashBoardListScreen,
                    name: 'allSupportRequestDashBoardListScreen',

                    builder: (context, state) => const AllSupportRequestScreen(),),
                ],
                builder: (context, state) => const DashboardListScreen(),
              ),

              // GoRoute(
              //     path: 'dashBoard',
              //     name: 'dashBoard',
              //     builder: (context, state) => const DashboardMainScreen(),
              //
              // ),




              GoRoute(
                  path: allObservationListScreen,
                  name: 'allObservationListScreen',
                  routes: [
                  ],
                  builder: (context, state) => const AllObservationRequestScreen(),
              ),



              GoRoute(
                  path: allSupportRequestScreen,
                  name: 'allSupportRequestScreen',
                routes: [
                  GoRoute(
                    path:
                    "closeAllSupportRequest",
                    name: "closeAllSupportRequest",
                    builder: (context, state) => CloseSupportRequestScreen(),
                  ),
                  ],
                  builder: (context, state) => const AllSupportRequestScreen(),),

              GoRoute(
                path: addMOMScreen,
                name: 'addMOMScreen',
                builder: (context, state) => const AddMOMScreen(),
              ),

              GoRoute(
                path: listMOMScreen,
                name: 'listMOMScreen',
                builder: (context, state) => const MOMListScreen(),
              ),
              GoRoute(
                path: momActionItemListScreen,
                name: 'momActionItemListScreen',
                builder: (context, state) => const MOMActionItemsScreen(),
              ),


            ],
          ),


        ],
      ),

    ],
    // Error handling
    errorBuilder: (context, state) => const Scaffold(
      body: Center(
        child: Text('Page not found!'),
      ),
    ),
    // Optional: Redirect logic for auto-login
    redirect: (BuildContext context, GoRouterState state) {
      return null; // No redirect needed
    },
  );
}