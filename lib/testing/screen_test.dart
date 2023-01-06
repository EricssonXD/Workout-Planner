import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:workoutplanner/utils/notification_manager.dart';
import 'package:workoutplanner/utils/riverpod.dart';

class TestScreen extends HookConsumerWidget {
  const TestScreen({super.key});
  final String ddd = "uyoin";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercise = ref.watch(helloWorldProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Testing"),
      ),
      body: Center(
          child: TextButton(
        child: Text(exercise),
        onPressed: () async {
          // sleep(const Duration(seconds: 5));
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
                  fullScreenIntent: true,
                  displayOnForeground: true,
                  displayOnBackground: true,
                  actionType: ActionType.Default));
        },
      )),
    );
  }
}
