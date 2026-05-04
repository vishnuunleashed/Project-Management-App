import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:base/core/constants.dart';
import 'package:base/data/repository/local/base_prefs.dart';
import 'package:base/presentation/utility/navigator_key.dart';
import 'package:eraser/eraser.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:interior_design/data/model/response/close_observation/read_status_update_dto.dart';
import 'package:interior_design/data/remote/repository/close_support_request/close_support_request_repository_impl.dart';
import 'package:interior_design/data/remote/repository/project_schedule/project_schedule_impl.dart';
import 'package:interior_design/presentation/provider/close_observation/close_observation_provider.dart';
import 'package:interior_design/presentation/provider/home/home_provider.dart';
import 'package:interior_design/presentation/provider/login_and_splash/login_provider.dart';
import 'package:interior_design/utils/routes.dart';

import '../presentation/provider/change_notifier_providers.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

bool _notificationHandled = false;
/// Foreground local notification tap
void onForegroundTap(String? payload) {
  _notificationHandled = true;
  if (payload == null) return;
  final Map<String, dynamic> data = jsonDecode(payload);
  print("Foreground tapped with data: $data");

  _navigateFromPayloadForeGroundAndBg(data);
}

/// Terminated
void onTerminatedTap(String? payload) {

  if (payload == null) return;
  final Map<String, dynamic> data = jsonDecode(payload);
  print("Terminated tapped with data: $data");


  _navigateFromPayloadTerminated(data);
}

/// Background & Terminated system notification tap
void onBackgroundTap(RemoteMessage message) {
  if (_notificationHandled) {
    _notificationHandled = false;
    print("Skipping onBackgroundTap — already handled by local notification");
    return;
  }
  final data = message.data;
  print("Notification tapped (BG/Terminated). Data: $data");

  _navigateFromPayloadForeGroundAndBg(data);
}
DateTime? _lastNavigationTime;
void _navigateFromPayloadForeGroundAndBg(Map<String, dynamic> data) {
  final now = DateTime.now();
  if (_lastNavigationTime != null &&
      now.difference(_lastNavigationTime!).inMilliseconds < 1000) {
    print("Duplicate navigation suppressed");
    return;
  }
  _lastNavigationTime = now;

  if (data["readstatusupdatereqyn"] != null && data["readstatusupdatereqyn"] == "Y") {
    _updateReadStatus(notificationId: data['notificationid']??data['notificationId']);
  }

  final ctx = NavigatorKey.navKey.currentContext;
  if (ctx == null) {
    print("No context available yet for navigation.");
    return;
  }

  final GoRouter router = GoRouter.of(ctx);
  String currentRoute = GoRouter.of(ctx).routerDelegate.currentConfiguration.uri.toString();
  print("ForeGroundAndBg Current route: $currentRoute");

  // CHANGED: Parse route_path as a List instead of a plain String,
  // then sort by 'order' to ensure correct navigation sequence
  final rawRoutePath = data['route_path'];
  final List<Map<String, dynamic>> routes = _parseRoutePaths(rawRoutePath);

  // CHANGED: Extract route name strings, filtering out any empty values
  final List<String> routeNames = routes
      .map((e) => (e['routepath'] as String?) ?? "")
      .where((r) => r.isNotEmpty)
      .toList();

  // CHANGED: Fallback to old String format if route_path is not a List
  // (handles legacy notifications that still send route_path as a plain string)
  if (routeNames.isEmpty) {
    final String route = rawRoutePath is String ? rawRoutePath : AppRoutes.home;
    _goToRoute(router, currentRoute, route, data);
    return;
  }

  // CHANGED: Navigate to first route using existing same-route guard logic
  if (routeNames.isNotEmpty) {
    _goToRoute(router, currentRoute, routeNames[0], data);
  }

  // CHANGED: Push second route on top of first if present
  if (routeNames.length > 1) {
    router.pushNamed(routeNames[1], extra: data);
  }
}

void _goToRoute(GoRouter router, String currentRoute, String route, Map<String, dynamic> data) {
  if (currentRoute == route) {
    // Pop all extra routes and refresh in place — don't push again
    while (router.canPop()) {
      router.pop();
    }
    router.replace(route, extra: data); // Use replace instead of push+pop
  } else {
    router.go(route, extra: data);
  }
}


void _navigateFromPayloadTerminated(Map<String, dynamic> data) {
  if (data["readstatusupdatereqyn"] != null && data["readstatusupdatereqyn"] == "Y") {
    _updateReadStatus(notificationId: data['notificationid']??data['notificationId']);
  }

  final ctx = NavigatorKey.navKey.currentContext;
  if (ctx == null) {
    print("No context available yet for navigation.");
    return;
  }

  final GoRouter router = GoRouter.of(ctx);

  // CHANGED: Parse route_path as a List instead of a plain String,
  // then sort by 'order' to ensure correct navigation sequence
  final rawRoutePath = data['route_path'];
  final List<Map<String, dynamic>> routes = _parseRoutePaths(rawRoutePath);

  // CHANGED: Extract route name strings, filtering out any empty values
  final List<String> routeNames = routes
      .map((e) => (e['routepath'] as String?) ?? "")
      .where((r) => r.isNotEmpty)
      .toList();

  // CHANGED: Fallback to old String format if route_path is not a List
  // (handles legacy notifications that still send route_path as a plain string)
  if (routeNames.isEmpty) {

    final String route = rawRoutePath is String ? rawRoutePath : AppRoutes.home;
    router.go(route, extra: data);
    return;
  }

  // CHANGED: Use go() for first route to set it as the base of the stack
  if (routeNames.isNotEmpty) {
    router.go(routeNames[0], extra: data);
  }

  // CHANGED: Push second route on top of first if present
  if (routeNames.length > 1) {
    router.pushNamed(routeNames[1], extra: data);
  }
}

StreamSubscription? homeScreenListener;
StreamSubscription? generalScreenListener;
StreamSubscription? notificationList;

Future<void> setupNotificationHandlers() async {
  if(Platform.isAndroid) {
    // Init local notifications (foreground)
    const AndroidInitializationSettings initSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
    InitializationSettings(android: initSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        onForegroundTap(response.payload);
      },
    );
  }
  // Background tap
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
    if(message != null && !_notificationHandled) {
      onBackgroundTap(message);
    }
    _notificationHandled = false;
  });

  bool isInitialLoad = await BaseSecureStorage.getBool(BaseConstants.isInitialLoad);
  ///Firebase listener to work in terminated state
  FirebaseMessaging.instance
      .getInitialMessage()
      .then((RemoteMessage? message) {
        if(Platform.isIOS){
          if(message != null){
            onBackgroundTap(message);
          }

        } else {
          if (isInitialLoad) {
            handleTerminatedAppLaunch();
          }
        }
  });


}

List<Map<String, dynamic>> _parseRoutePaths(dynamic rawRoutePath) {
  try {
    List<dynamic> parsed = [];

    if (rawRoutePath is List) {
      // Android: already a List (existing working case — untouched)
      parsed = rawRoutePath;
    } else if (rawRoutePath is String) {
      final trimmed = rawRoutePath.trim();
      if (trimmed.startsWith('[')) {
        // iOS: route_path is a JSON-encoded String — decode it
        parsed = jsonDecode(trimmed) as List<dynamic>;
      } else {
        // Plain route string like "/home" — return empty to trigger fallback
        return [];
      }
    } else {
      return [];
    }

    final routes = parsed
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    // FIXED: Safe int parsing — handles both "1" (iOS String) and 1 (Android int)
    routes.sort((a, b) {
      final aOrder = int.tryParse(a['order'].toString()) ?? 0;
      final bOrder = int.tryParse(b['order'].toString()) ?? 0;
      return aOrder.compareTo(bOrder);
    });

    return routes;

  } catch (e) {
    print("Error parsing route_path: $e");
    return []; // Safe fallback — triggers home navigation
  }
}

void onMessageReceivedListener({required Function() onListenerInvoke}) {
  homeScreenListener =
      FirebaseMessaging.onMessage.listen((message) async {
        final container = ProviderScope.containerOf(NavigatorKey.navKey.currentState!.context);
        HomeProvider provider = container.read(homeProvider);
        provider.fetchPendingCount(projectIds: [int.parse(message.data["projectid"])]);
        provider.fetchNotificationCountList();
        onListenerInvoke();
        ProviderScope.containerOf(NavigatorKey.navKey.currentState!.context).read(callTrackerProvider).loadTickets();
      });
}

void onMessageGeneralListener({required Function() onListenerInvoke}) {
  generalScreenListener =
      FirebaseMessaging.onMessage.listen((message) async {

        onListenerInvoke();
      });
}
void onMessageNotificationList({required Function() onListenerInvoke}) {
  notificationList =
      FirebaseMessaging.onMessage.listen((message) async {
        onListenerInvoke();
      });
}



Future<void> removeNotificationUsingIdList(int notificationId) async {
  if(Platform.isAndroid) {
      print("notificationid_removed: " + notificationId.toString());
      Eraser.clearAppNotificationsById(notificationId);
  }

}


/// Handle terminated app launch - call this after app initialization
Future<void> handleTerminatedAppLaunch() async {
  try {
    // Check for local notification that launched the app
    NotificationAppLaunchDetails? pay = await flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails();

    log("Checking terminated app launch details...");

    if (pay?.didNotificationLaunchApp == true && pay?.notificationResponse?.payload != null) {
      // App launched from local notification
      log("App launched from terminated state with local notification");
      log("PAY LOAD BEFORE: ${pay?.notificationResponse?.payload ?? ""}");

      String? payload = pay?.notificationResponse?.payload;


      if (payload != null) {
        try {

          // Process the local notification payload
          onTerminatedTap(payload);

        } catch (e) {
          log('Error parsing payload: $e');
        }
      }
    } else {
      log("App launched normally (not from notification)");
    }
  } catch (e) {
    log("Error handling terminated app launch: $e");
  }
}

_updateReadStatus({
  required int notificationId,

}){
  CloseSupportRequestRepositoryImpl().updateNotificationStatus(
    notificationId: notificationId,
      onRequestSuccess: (result){
        print("read_status_update_success");
      },
      onRequestFailure: (exception){
        print("read_status_update_failure");
      },
  );
}