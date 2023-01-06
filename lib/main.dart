import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:workoutplanner/exercise_list/screen_exercise_list.dart';
import 'package:workoutplanner/home/screen_home.dart';
import 'package:workoutplanner/settings/themes.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:workoutplanner/utils/notification_manager.dart';

Future main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  NotificationManager.initMain();
  runApp(ProviderScope(
      child: App())); //Wrap in provider scope for riverpod to work
}

class App extends ConsumerWidget {
  App({super.key}) {
    NotificationManager.initListeners();
  }
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData? themeProvider = ref.watch(themeManagerProvider).value;

    if (themeProvider != null) {
      FlutterNativeSplash.remove();
      return MaterialApp(
        navigatorKey: navigatorKey,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                builder: (context) => const Home(),
              );
            case '/notification-page':
              return MaterialPageRoute(builder: (context) {
                // ignore: unused_local_variable
                final ReceivedAction receivedAction =
                    settings.arguments as ReceivedAction;
                // return MyNotificationPage(receivedAction: receivedAction);
                return const ExerciseList();
              });

            default:
              assert(false, 'Page ${settings.name} not found');
              return null;
          }
        },
        debugShowCheckedModeBanner: false,
        home: const Home(),
        theme: themeProvider,
      );
    } else {
      return const MaterialApp();
    }
  }
}
