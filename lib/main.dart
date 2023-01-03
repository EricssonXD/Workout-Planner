import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:workoutplanner/home/screen_home.dart';
import 'package:workoutplanner/settings/themes.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

Future main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(const ProviderScope(
      child: App())); //Wrap in provider scope for riverpod to work
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData? themeProvider = ref.watch(themeManagerProvider).value;

    if (themeProvider != null) {
      debugPrint("now remove the splash");
      FlutterNativeSplash.remove();
    } else {
      return Container();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Home(),
      theme: themeProvider,
    );
  }
}
