
import 'dart:convert';

import 'package:base/data/services/utils/app_exceptions.dart';
import 'package:eraser/eraser.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:interior_design/data/model/response/notification/notification_response_model.dart';
import 'package:interior_design/data/remote/repository/notification/notification.dart';

import 'firebase_tap_config.dart';

Future<void> showNotification(RemoteMessage message) async {
  // const int notificationLimit = 20;
  await Notification().getNotificationData(
    onRequestSuccess: (response) async {
      List<ActiveNotification> activeNotifications = List.from(await _getActiveNotifications());
      List<NotificationList> messageModel = List.from(response.jsonList);
      List<NotificationList> notificationsToDisplay =
      List.from(_prepareNotifications(messageModel, /*notificationLimit*/));
      //sort active notification in ascending order
      activeNotifications.sort((a, b) => (a.id??0).compareTo(b.id??0));
      // Step 1: Filter new notifications that are not in activeNotifications
      List<NotificationList> notificationsToAdd = List.from(notificationsToDisplay
          .where((msg) => !activeNotifications
          .any((active) => active.id == msg.notificationId))
          .toList());
      List<ActiveNotification> notificationsToRemove = List.from(activeNotifications
          .where((msg) => !notificationsToDisplay
          .any((active) => active.notificationId == msg.id))
          .toList());

      await removeNotifications(notificationsToRemove);
      await addNotifications(notificationsToAdd);


    },
    onRequestFailure: (AppException exception) {

    },
  );

}

List<NotificationList> _prepareNotifications(
    List<NotificationList> newMessages,/*
    int limit*/) {
  // List<NotificationList> allNotifications = List.from(newMessages);
  // allNotifications.sort((a, b) => a.notificationId.compareTo(b.notificationId));
  // List<NotificationList> newAllNotifications = [];
  // if(limit < allNotifications.length){
  //   newAllNotifications = List.from(allNotifications.sublist(allNotifications.length - (limit)));
  // }else{
  //
  //   newAllNotifications = List.from(allNotifications);
  // }

  return newMessages;
}

/// Function to remove excess notifications before showing new ones
Future<void> removeNotifications(List<ActiveNotification> notificationsToRemove) async {
  for(var notifications in notificationsToRemove){
    await Eraser.clearAppNotificationsById(notifications.id!);
  }
}

/// Function to display new notifications only after removals are completed
Future<void> addNotifications(List<NotificationList> remainingNotificationList) async {
  for (var notification in remainingNotificationList) {
    _showNotification(notification);

  }
}

void _showNotification(NotificationList notification)  {
  var platformDetails = _getPlatformNotificationDetails();

  flutterLocalNotificationsPlugin.show(
    notification.notificationId,
    notification.title.toString(),
    trimString(notification.message??""),
    platformDetails,
    payload: jsonEncode(notification.toMap()),
  );
}

NotificationDetails _getPlatformNotificationDetails() {
  var android = AndroidNotificationDetails(
    'Sample Project', // Channel ID (must match the channel created above)
    'Sample Project Notification Channel', // Channel Name
    channelDescription: 'Notifications for Sample Project',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
    channelShowBadge: false,
    styleInformation: BigTextStyleInformation(''),
  );

  var ios = DarwinNotificationDetails();

  return NotificationDetails(
    android: android,
    iOS: ios,
  );
}

String trimString(String input) {
  return (input.length > 100) ? '${input.substring(0, 100)}...' : input;
}
Future<List<ActiveNotification>> _getActiveNotifications() async {
  return await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.getActiveNotifications() ??
      [];
}