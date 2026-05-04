import 'dart:io';

import 'package:base/data/repository/local/base_prefs.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

// const String _FIREBASE_SUBSCRIPTION_KEY = "_FIREBASE_SUBSCRIPTION_KEY";
const String _SUBSCRIPTION_LIST_KEY = "topics";

mixin FireBaseNotificationMixin {
  static final FirebaseNotificationHelper _firebaseNotificationHelper =
  FirebaseNotificationHelper();


  void initFireBase() {
    _firebaseNotificationHelper.configure();
  }

  void registerForCallback() {
    print("callbacked");
    _firebaseNotificationHelper.configure();
  }

  void subscribeToTopics(List<String> topics) {
    _firebaseNotificationHelper.subscribeTopics(topics);
  }

  void unsubscribeTopics(List<String> topics) {
    _firebaseNotificationHelper.unsubscribeTopics();
  }



}


class FirebaseNotificationHelper {
  late FirebaseMessaging _firebaseMessaging;

  static final FirebaseNotificationHelper _instance =
  FirebaseNotificationHelper._setUpFirebase();

  factory FirebaseNotificationHelper() {
    return _instance;
  }

  FirebaseNotificationHelper._setUpFirebase() {
    _firebaseMessaging = FirebaseMessaging.instance;
    // firebaseCloudMessagingListeners();
  }

  void firebaseCloudMessagingListeners() {
    _checkIOSPermission();
    _firebaseMessaging.getToken().then((token) {
      print("Firebase token: $token");
    });
  }

  void configure() {
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
    });
  }

  Future<List<String>> getSubscribedTopics() async {
    Map<String, dynamic>? subscribed_topics =
    await FirebaseTokenStorage.getTokenData();
    return subscribed_topics == null
        ? <String>[]
        : (subscribed_topics[_SUBSCRIPTION_LIST_KEY] as List)
        .map<String>((e) => e)
        .toList();
  }

  Future<void> subscribeTopics(List<String> topics) async {
    List<String> subscribedTopics = await getSubscribedTopics();
    List<String> topicsToSubscribe =
    topics.where((topic) => !subscribedTopics.contains(topic)).toList();

    topicsToSubscribe.forEach((topic) => _subscribe(topic));
    List<String> subscriptionList = [...subscribedTopics, ...topicsToSubscribe];

    Map<String, dynamic> _kMap = Map<String, dynamic>();
    _kMap[_SUBSCRIPTION_LIST_KEY] = subscriptionList;
    await FirebaseTokenStorage.saveTokenData(_kMap);

  }

  void _subscribe(String topic) async {
    print("Subscribing to topic : $topic");
    await _firebaseMessaging.subscribeToTopic('$topic').then((value) {
      print("Subscribed to topic : $topic");
    }).catchError((e) {
      print("failed to subscribe $topic $e");
      return e;
    });
  }

  void unsubscribeTopics() async {
    List<String> subscribedTopics = await getSubscribedTopics();
    subscribedTopics.forEach((element) {
      _unsubscribe(element);
    });

    List<String> subscriptionList =
    subscribedTopics.where((topic) => !subscribedTopics.contains(topic)).toList();
    print("SubscribedTopics :  $subscribedTopics");
    print("topics to unsubscribe :  $subscribedTopics");
    Map<String, dynamic> _kMap = Map<String, dynamic>();
    _kMap[_SUBSCRIPTION_LIST_KEY] = subscriptionList;

    print("subscribedTopics $_kMap");
    await FirebaseTokenStorage.deleteTokenData(); // clear old topic data
    await FirebaseTokenStorage.saveTokenData(_kMap);
  }

  void _unsubscribe(String topic) {
    print("Unsubscribing topic : $topic");

    _firebaseMessaging.unsubscribeFromTopic('$topic').then((value) {
      print("Unsubscribed to topic : $topic");
    }).catchError((e) {
      print("failed to unsubscribe $topic $e");
      return e;
    });
  }

  void _checkIOSPermission() async {
    if (Platform.isIOS) {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true, // headsup notification in IOS
          badge: true,
          sound: true,
        );
      } else {
        //close the app
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      }

      print('User granted permission: ${settings.authorizationStatus}');

    }
  }

  static final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Show local notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String? routePath,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      'Sample Project', // Channel ID (must match the channel created above)
      'Sample Project Notification Channel', // Channel Name
      channelDescription: 'Notifications for Sample Project',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      styleInformation: BigTextStyleInformation(''),
    );

    const DarwinNotificationDetails iosNotificationDetails =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'default',
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );



    await notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload ?? routePath,
    );
  }

  static void initializeLocalNotification(){
    var initializationSettingsAndroid =
    const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettingsIOS = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    notificationsPlugin.initialize(initializationSettings);
  }

  // Method 1: Using permission_handler (Recommended)
  static Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {

      final status = await Permission.notification.request();
      return status == PermissionStatus.granted;
    } else if (Platform.isIOS) {
      final result = await notificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    }
    return false;
  }

}
