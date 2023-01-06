import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class NotificationManager {
  static void initMain() {
    AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
              channelGroupKey: 'basic_channel_group',
              channelKey: ChannelKey.basic,
              importance: NotificationImportance.Default,
              channelName: 'Basic notifications',
              playSound: false,
              channelDescription: 'Notification channel for basic tests',
              // defaultColor: const Color.fromARGB(255, 255, 0, 0),
              ledColor: Colors.white),
          NotificationChannel(
              channelKey: ChannelKey.timeIsUp,
              importance: NotificationImportance.Max,
              channelName: "Time's Up",
              playSound: false,
              channelDescription: 'Notification channel for basic tests',
              // defaultColor: const Color.fromARGB(255, 255, 0, 0),
              ledColor: Colors.white),
        ],
        // Channel groups are only visual and are not required
        channelGroups: [
          NotificationChannelGroup(
              channelGroupKey: 'basic_channel_group',
              channelGroupName: 'Basic group')
        ],
        debug: kDebugMode ? true : false);

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  static void initListeners() {
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: _NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:
            _NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            _NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            _NotificationController.onDismissActionReceivedMethod);
  }

  static void restTimeOver() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        wakeUpScreen: true,
        category: NotificationCategory.Reminder,
        criticalAlert: true,
        id: 10,
        channelKey: ChannelKey.timeIsUp,
        title: 'Rest Time is Over!',
        body: 'Click to return to Workout',
        // criticalAlert: true,
        // fullScreenIntent: true,
        displayOnForeground: false,
        displayOnBackground: true,
        actionType: ActionType.Default,
      ),
    );
  }
}

class _NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here
    switch (receivedAction.channelKey) {
      case ChannelKey.timeIsUp:
        // debugPrint("yoink");

        break;
      default:
        App.navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/notification-page',
            (route) =>
                (route.settings.name != '/notification-page') || route.isFirst,
            arguments: receivedAction);
    }
    // Navigate into pages, avoiding to open the notification details page over another details page already opened
  }
}

@immutable
abstract class ChannelKey {
  const ChannelKey();
  static const String timeIsUp = "timeIsUp";
  static const String basic = "basic_channel";
}
